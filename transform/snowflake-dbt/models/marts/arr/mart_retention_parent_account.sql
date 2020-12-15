WITH dim_crm_account AS (

    SELECT *
    FROM {{ ref('dim_crm_account') }}

), dim_date AS (

    SELECT *
    FROM {{ ref('dim_date') }}

), dim_product_details AS (

    SELECT *
    FROM {{ ref('dim_product_details') }}

), dim_subscriptions AS (

    SELECT *
    FROM {{ ref('dim_subscriptions') }}

), fct_mrr AS (

    SELECT *
    FROM {{ ref('fct_mrr') }}

), next_renewal_month AS (

    SELECT DISTINCT
      merged_accounts.ultimate_parent_account_id,
      MIN(subscription_end_month) OVER (PARTITION BY merged_accounts.ultimate_parent_account_id)    AS next_renewal_month
    FROM fct_mrr
    INNER JOIN dim_date
      ON dim_date.date_id = fct_mrr.date_id
    LEFT JOIN dim_crm_account AS crm_accounts
      ON crm_accounts.crm_account_id = fct_mrr.crm_account_id
    INNER JOIN dim_crm_account AS merged_accounts
      ON merged_accounts.crm_account_id = COALESCE(crm_accounts.merged_to_account_id, crm_accounts.crm_account_id)
    LEFT JOIN dim_subscriptions
      ON dim_subscriptions.subscription_id = fct_mrr.subscription_id
      AND subscription_end_month <= DATEADD('year', 1, date_actual)
    WHERE subscription_end_month >= DATE_TRUNC('month',CURRENT_DATE)

), last_renewal_month AS (

    SELECT DISTINCT
      merged_accounts.ultimate_parent_account_id,
      MAX(subscription_end_month) OVER (PARTITION BY merged_accounts.ultimate_parent_account_id)    AS last_renewal_month
    FROM fct_mrr
    INNER JOIN dim_date
      ON dim_date.date_id = fct_mrr.date_id
    LEFT JOIN dim_crm_account AS crm_accounts
      ON crm_accounts.crm_account_id = fct_mrr.crm_account_id
    INNER JOIN dim_crm_account AS merged_accounts
      ON merged_accounts.crm_account_id = COALESCE(crm_accounts.merged_to_account_id, crm_accounts.crm_account_id)
    LEFT JOIN dim_subscriptions
      ON dim_subscriptions.subscription_id = fct_mrr.subscription_id
      AND subscription_end_month <= DATEADD('year', 1, date_actual)
    WHERE subscription_end_month < DATE_TRUNC('month',CURRENT_DATE)

), parent_account_mrrs AS (

    SELECT
      dim_crm_account.ultimate_parent_account_id,
      dim_date.date_actual                             AS mrr_month,
      dateadd('year', 1, date_actual)                   AS retention_month,
      next_renewal_month,
      last_renewal_month,
      SUM(ZEROIFNULL(mrr))                              AS mrr_total,
      SUM(ZEROIFNULL(arr))                              AS arr_total,
      SUM(ZEROIFNULL(quantity))                         AS quantity_total,
      ARRAY_AGG(product_category)                       AS product_category,
      MAX(product_ranking)                              AS product_ranking
    FROM fct_mrr
    INNER JOIN dim_product_details
      ON dim_product_details.product_details_id = fct_mrr.product_details_id
    INNER JOIN dim_date
      ON dim_date.date_id = fct_mrr.date_id
    LEFT JOIN dim_crm_account
      ON dim_crm_account.crm_account_id = fct_mrr.crm_account_id
    LEFT JOIN next_renewal_month
      ON next_renewal_month.ultimate_parent_account_id = dim_crm_account.ultimate_parent_account_id
    LEFT JOIN last_renewal_month
      ON last_renewal_month.ultimate_parent_account_id = dim_crm_account.ultimate_parent_account_id
    {{ dbt_utils.group_by(n=5) }}

), retention_subs AS (

    SELECT
      current_mrr.ultimate_parent_account_id,
      current_mrr.mrr_month          AS current_mrr_month,
      current_mrr.retention_month,
      current_mrr.mrr_total          AS current_mrr,
      future_mrr.mrr_total           AS future_mrr,
      current_mrr.arr_total          AS current_arr,
      future_mrr.arr_total           AS future_arr,
      current_mrr.quantity_total     AS current_quantity,
      future_mrr.quantity_total      AS future_quantity,
      current_mrr.product_category   AS current_product_category,
      future_mrr.product_category    AS future_product_category,
      current_mrr.product_ranking    AS current_product_ranking,
      future_mrr.product_ranking     AS future_product_ranking,
      current_mrr.last_renewal_month,
      current_mrr.next_renewal_month
    FROM parent_account_mrrs AS current_mrr
    LEFT JOIN parent_account_mrrs AS future_mrr
      ON current_mrr.ultimate_parent_account_id = future_mrr.ultimate_parent_account_id
        AND current_mrr.retention_month = future_mrr.mrr_month

), final AS (

    SELECT
      retention_subs.ultimate_parent_account_id,
      dim_crm_account.crm_account_name         AS ultimate_parent_account_name,
      retention_month,
      dim_date.fiscal_year                     AS retention_fiscal_year,
      dim_date.fiscal_quarter                  AS retention_fiscal_quarter,
      retention_subs.last_renewal_month,
      retention_subs.next_renewal_month,
      current_mrr                               AS prior_year_mrr,
      COALESCE(future_mrr, 0)                   AS net_retention_mrr,
      CASE WHEN net_retention_mrr > 0
        THEN least(net_retention_mrr, current_mrr)
        ELSE 0 END                              AS gross_retention_mrr,
      current_arr                               AS prior_year_arr,
      COALESCE(future_arr, 0)                   AS net_retention_arr,
      CASE WHEN net_retention_arr > 0
        THEN least(net_retention_arr, current_arr)
        ELSE 0 END                              AS gross_retention_arr,
      current_quantity                          AS prior_year_quantity,
      COALESCE(future_quantity, 0)              AS net_retention_quantity,
      {{ reason_for_quantity_change_seat_change('net_retention_quantity', 'prior_year_quantity') }},
      future_product_category                   AS net_retention_product_category,
      current_product_category                  AS prior_year_product_category,
      future_product_ranking                    AS net_retention_product_ranking,
      current_product_ranking                   AS prior_year_product_ranking,
      {{ type_of_arr_change('net_retention_arr', 'prior_year_arr') }},
      {{ reason_for_arr_change_seat_change('net_retention_quantity', 'prior_year_quantity', 'net_retention_arr', 'prior_year_arr') }},
      {{ reason_for_arr_change_price_change('net_retention_product_category', 'prior_year_product_category', 'net_retention_quantity', 'prior_year_quantity', 'net_retention_arr', 'prior_year_arr', 'net_retention_product_ranking','prior_year_product_ranking') }},
      {{ reason_for_arr_change_tier_change('net_retention_product_ranking', 'prior_year_product_ranking', 'net_retention_quantity', 'prior_year_quantity', 'net_retention_arr', 'prior_year_arr') }},
      {{ annual_price_per_seat_change('net_retention_quantity', 'prior_year_quantity', 'net_retention_arr', 'prior_year_arr') }}
    FROM retention_subs
    INNER JOIN dim_date
      ON dim_date.date_actual = retention_subs.retention_month
    LEFT JOIN dim_crm_account
      ON dim_crm_account.crm_account_id = retention_subs.ultimate_parent_account_id
    WHERE retention_month <= dateadd(month, -1, CURRENT_DATE)

)

SELECT *
FROM final
