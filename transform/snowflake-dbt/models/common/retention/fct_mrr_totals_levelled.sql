WITH dates AS (

    SELECT * FROM {{ ref('dim_date') }}

), mrr_totals AS (

    SELECT * FROM {{ ref('fct_mrr') }}

), subscription AS (

    SELECT * FROM {{ ref('dim_subscription') }}

), billing_account AS (

    SELECT * FROM {{ ref('dim_billing_account') }}

), crm_account AS (

    SELECT * FROM {{ ref('dim_crm_account') }}

), rate_plan AS (

    -- need to move this into a dim
    SELECT * FROM {{ ref('zuora_rate_plan') }}

), joined AS (

      SELECT
           mrr_totals.mrr_id,
           mrr_totals.dim_date_id,
           mrr_totals.dim_billing_account_id,
           mrr_totals.dim_crm_account_id,
           mrr_totals.dim_subscription_id,
           mrr_totals.dim_product_detail_id,
           mrr_totals.mrr,
           mrr_totals.arr,
           mrr_totals.quantity,
           mrr_totals.unit_of_measure,
           rate_plan.product_category,
           rate_plan.delivery,
           billing_account.billing_account_name                             AS billing_account_name,
           crm_account.crm_account_name                                     AS sfdc_account_name,
           crm_account.ultimate_parent_account_id                           AS ultimate_parent_account_id,
           crm_account.ultimate_parent_account_name                         AS ultimate_parent_account_name,
           min(subscription.cohort_month) OVER (
              PARTITION BY billing_account.dim_billing_account_id)          AS billing_account_cohort_month,
           min(subscription.cohort_quarter) OVER (
              PARTITION BY billing_account.dim_billing_account_id)          AS billing_account_cohort_quarter,
           min(subscription.cohort_month) OVER (
              PARTITION BY crm_account.crm_account_id)                      AS sfdc_account_cohort_month,
           min(subscription.cohort_quarter) OVER (
              PARTITION BY crm_account.crm_account_id)                      AS sfdc_account_cohort_quarter,
           min(subscription.cohort_month) OVER (
              PARTITION BY crm_account.ultimate_parent_account_id)          AS parent_account_cohort_month,
           min(subscription.cohort_quarter) OVER (
              PARTITION BY crm_account.ultimate_parent_account_id)          AS parent_account_cohort_quarter
    FROM mrr_totals
    LEFT JOIN billing_account
    ON billing_account.dim_billing_account_id = mrr_totals.dim_billing_account_id
    LEFT JOIN crm_account
    ON crm_account.crm_account_id = billing_account.dim_crm_account_id
    LEFT JOIN subscription
    ON subscription.dim_subscription_id = mrr_totals.dim_subscription_id
    LEFT JOIN rate_plan
    ON rate_plan.subscription_id = mrr_totals.dim_subscription_id
    -- AND rate_plan.product_id = mrr_totals.dim_product_detail_id

), final_table AS (

   SELECT joined.*,
      datediff(month, billing_account_cohort_month, dates.date_day)     AS months_since_billing_account_cohort_start,
      datediff(quarter, billing_account_cohort_quarter, dates.date_day) AS quarters_since_billing_account_cohort_start,
      datediff(month, sfdc_account_cohort_month, dates.date_day)        AS months_since_sfdc_account_cohort_start,
      datediff(quarter, sfdc_account_cohort_quarter, dates.date_day)    AS quarters_since_sfdc_account_cohort_start,
      datediff(month, parent_account_cohort_month, dates.date_day)      AS months_since_parent_account_cohort_start,
      datediff(quarter, parent_account_cohort_quarter, dates.date_day)  AS quarters_since_parent_account_cohort_start
    FROM joined
    JOIN dates ON dates.date_id = joined.dim_date_id

)

{{ dbt_audit(
    cte_ref="final_table",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-01-07",
    updated_date="2021-01-07"
) }}
