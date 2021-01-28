WITH mrr_totals AS (

    SELECT * FROM {{ ref('fct_mrr') }}

), subscription AS (

    SELECT * FROM {{ ref('dim_subscription') }}

), billing_account AS (

    SELECT * FROM {{ ref('dim_billing_account') }}

), crm_account AS (

    SELECT * FROM {{ ref('dim_crm_account') }}

), joined AS (

     SELECT
           mrr_totals.*,
           billing_account.dim_billing_account_id                           AS billing_account_id,
           billing_account.billing_account_name                             AS billing_account_name,
           billing_account.billing_account_name                             AS billing_crm_id,
           crm_account.crm_account_id                                       AS sfdc_account_id,
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
    LEFT JOIN subscription ON subscription.dim_subscription_id = mrr_totals.dim_subscription_id

), final_table AS (

   SELECT *,
      datediff(month, billing_account_cohort_month, mrr_month) as months_since_billing_account_cohort_start,
      datediff(quarter, billing_account_cohort_quarter, mrr_month) as quarters_since_billing_account_cohort_start,
      datediff(month, sfdc_account_cohort_month, mrr_month) as months_since_sfdc_account_cohort_start,
      datediff(quarter, sfdc_account_cohort_quarter, mrr_month) as quarters_since_sfdc_account_cohort_start,
      datediff(month, parent_account_cohort_month, mrr_month) as months_since_parent_account_cohort_start,
      datediff(quarter, parent_account_cohort_quarter, mrr_month) as quarters_since_parent_account_cohort_start
    FROM joined

)

{{ dbt_audit(
    cte_ref="final_table",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-01-07",
    updated_date="2021-01-07"
) }}
