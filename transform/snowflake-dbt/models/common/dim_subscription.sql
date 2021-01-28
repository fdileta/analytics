WITH subscription AS (

    SELECT *
    FROM {{ ref('prep_subscription') }}

), subscription_lineage AS (

    SELECT *
    FROM {{ ref('prep_subscription_lineage') }}

), final AS (

  SELECT
    --ids & keys
    s.dim_subscription_id,
    s.dim_crm_account_id,
    s.dim_billing_account_id,
    s.dim_crm_person_id_invoice_owner,
    s.dim_crm_opportunity_id,
    s.dim_subscription_id_original,
    s.dim_subscription_id_previous,
    s.amendment_id,

    --info
    s.subscription_name,
    s.subscription_name_slugify,
    s.subscription_status,
    s.subscription_version,
    s.is_auto_renew,
    s.zuora_renewal_subscription_name,
    s.zuora_renewal_subscription_name_slugify,
    s.renewal_term,
    s.renewal_term_period_type,
    s.subscription_start_date,
    s.subscription_end_date,
    s.subscription_sales_type,
    s.subscription_start_month,
    s.subscription_end_month,
    sl.lineage,
    sl.oldest_subscription_in_cohort,
    sl.cohort_month,
    sl.cohort_quarter,
    sl.cohort_year
  FROM subscription s
  LEFT JOIN subscription_lineage sl on sl.dim_subscription_id = s.dim_subscription_id

)

{{ dbt_audit(
    cte_ref="final",
    created_by="@snalamaru",
    updated_by="@ischweickartDD",
    created_date="2020-12-16",
    updated_date="2021-01-07"
) }}
