WITH fct_charges AS (

    SELECT *
    FROM {{ ref('fct_charges') }}

), fct_invoice_items_agg AS (

    SELECT *
    FROM {{ ref('fct_invoice_items_agg') }}

), dim_crm_accounts AS (

    SELECT *
    FROM {{ ref('dim_crm_accounts') }}

), dim_billing_accounts AS (

    SELECT *
    FROM {{ ref('dim_billing_accounts') }}

), dim_dates AS (

    SELECT *
    FROM {{ ref('dim_dates') }}

), dim_subscriptions AS (

    SELECT *
    FROM {{ ref('dim_subscriptions') }}

), base_charges AS (

    SELECT
      --date info
      fct_charges.effective_start_date_id,
      fct_charges.effective_end_date_id,
      fct_charges.effective_start_month,
      fct_charges.effective_end_month,
      dim_subscriptions.subscription_start_month,
      dim_subscriptions.subscription_end_month,

      --account info
      dim_billing_accounts.billing_account_id                                              AS zuora_account_id,
      dim_billing_accounts.sold_to_country                                         AS zuora_sold_to_country,
      dim_billing_accounts.billing_account_name                                            AS zuora_account_name,
      dim_billing_accounts.billing_account_number                                          AS zuora_account_number,
      COALESCE(dim_crm_accounts.merged_to_account_id, dim_crm_accounts.crm_account_id)   AS crm_id,
      dim_crm_accounts.ultimate_parent_account_id,
      dim_crm_accounts.ultimate_parent_account_name,
      dim_crm_accounts.ultimate_parent_billing_country,
      dim_crm_accounts.ultimate_parent_account_segment,
      dim_crm_accounts.ultimate_parent_industry,
      dim_crm_accounts.ultimate_parent_account_owner_team,
      dim_crm_accounts.ultimate_parent_territory,

      --subscription info
      dim_subscriptions.subscription_id,
      dim_subscriptions.subscription_name,
      dim_subscriptions.subscription_name_slugify,
      dim_subscriptions.subscription_status,

      --charge info
      fct_charges.charge_id,
      fct_charges.product_details_id,
      fct_charges.rate_plan_charge_number,
      fct_charges.rate_plan_charge_segment,
      fct_charges.rate_plan_charge_version,
      fct_charges.rate_plan_name,
      fct_charges.product_category,
      fct_charges.delivery,
      fct_charges.service_type,
      fct_charges.charge_type,
      fct_charges.unit_of_measure,
      fct_charges.mrr,
      fct_charges.mrr*12                                                    AS arr,
      fct_charges.quantity
    FROM dim_billing_accounts
    INNER JOIN dim_subscriptions
      ON dim_billing_accounts.billing_account_id = dim_subscriptions.account_id
    INNER JOIN fct_charges
      ON dim_subscriptions.subscription_id = fct_charges.subscription_id
    LEFT JOIN dim_crm_accounts
      ON dim_billing_accounts.billing_crm_id = dim_crm_accounts.crm_account_id

)

SELECT *
FROM base_charges
