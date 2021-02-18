WITH map_merged_crm_accounts AS (

    SELECT *
    FROM {{ ref('map_merged_crm_accounts') }}

), zuora_subscription AS (

  SELECT *
  FROM {{ ref('zuora_subscription_source') }}
  WHERE is_deleted = FALSE
    AND exclude_from_analysis IN ('False', '')

), zuora_account AS (

  SELECT
    account_id,
    crm_id
  FROM {{ ref('zuora_account_source') }}

), joined AS (

  SELECT
    zuora_subscription.subscription_id                                        AS dim_subscription_id,
    map_merged_crm_accounts.dim_crm_account_id                                AS dim_crm_account_id,
    zuora_account.account_id                                                  AS dim_billing_account_id,
    zuora_subscription.invoice_owner_id                                       AS dim_crm_person_id_invoice_owner,
    zuora_subscription.sfdc_opportunity_id                                    AS dim_crm_opportunity_id,
    zuora_subscription.original_id                                            AS dim_subscription_id_original,
    zuora_subscription.previous_subscription_id                               AS dim_subscription_id_previous,
    zuora_subscription.amendment_id,
    zuora_subscription.subscription_name,
    zuora_subscription.subscription_name_slugify,
    zuora_subscription.subscription_status,
    zuora_subscription.version                                                AS subscription_version,
    zuora_subscription.auto_renew                                             AS is_auto_renew,
    zuora_subscription.zuora_renewal_subscription_name,
    zuora_subscription.zuora_renewal_subscription_name_slugify,
    zuora_subscription.renewal_term,
    zuora_subscription.renewal_term_period_type,
    zuora_subscription.eoa_starter_bronze_offer_accepted,
    zuora_subscription.subscription_start_date                                AS subscription_start_date,
    zuora_subscription.subscription_end_date                                  AS subscription_end_date,
    IFF(zuora_subscription.created_by_id = '2c92a0fd55822b4d015593ac264767f2', -- All Self-Service / Web direct subscriptions are identified by that created_by_id
      'Self-Service', 'Sales-Assisted')                                       AS subscription_sales_type,
    DATE_TRUNC('month', zuora_subscription.subscription_start_date)           AS subscription_start_month,
    DATE_TRUNC('month', zuora_subscription.subscription_end_date)             AS subscription_end_month
  FROM zuora_subscription
  INNER JOIN zuora_account
    ON zuora_subscription.account_id = zuora_account.account_id
  LEFT JOIN map_merged_crm_accounts
    ON zuora_account.crm_id = map_merged_crm_accounts.sfdc_account_id

)

{{ dbt_audit(
    cte_ref="joined",
    created_by="@ischweickartDD",
    updated_by="@iweeks",
    created_date="2021-01-07",
    updated_date="2021-02-10"
) }}
