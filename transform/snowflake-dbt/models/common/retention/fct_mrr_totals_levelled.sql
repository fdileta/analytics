WITH mrr_totals AS (

    SELECT * FROM {{ ref('zuora_mrr_totals') }}

), billing_account AS (

    SELECT * FROM {{ ref('dim_billing_account') }}

), crm_account AS (

    SELECT * FROM {{ ref('dim_crm_account') }}

), joined AS (

    SELECT
           mrr_totals.*,
           billing_account.DIM_BILLING_ACCOUNT_ID AS zuora_account_id,
           billing_account.BILLING_ACCOUNT_NAME AS zuora_account_name,
           billing_account.BILLING_ACCOUNT_NAME as zuora_crm_id,
           crm_account.CRM_ACCOUNT_ID as sfdc_account_id,
           crm_account.ULTIMATE_PARENT_ACCOUNT_ID as ULTIMATE_PARENT_ACCOUNT_ID,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY zuora_account_id)                                AS zuora_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY zuora_account_id)                                AS zuora_account_cohort_quarter,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY sfdc_account_id)                     AS sfdc_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY sfdc_account_id)                     AS sfdc_account_cohort_quarter,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY ultimate_parent_account_id)                      AS parent_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY ultimate_parent_account_id)                      AS parent_account_cohort_quarter
    FROM mrr_totals
    LEFT JOIN billing_account
    ON billing_account.BILLING_ACCOUNT_NUMBER = mrr_totals.ACCOUNT_NUMBER
    LEFT JOIN crm_account
    ON crm_account.crm_account_id = billing_account.DIM_CRM_ACCOUNT_ID

), final_table AS (

   SELECT *,
      datediff(month, zuora_account_cohort_month, mrr_month) as months_since_zuora_account_cohort_start,
      datediff(quarter, zuora_account_cohort_quarter, mrr_month) as quarters_since_zuora_account_cohort_start,
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
