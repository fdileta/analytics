WITH sfdc_accounts_xf AS (

      SELECT * FROM {{ref('sfdc_accounts_xf')}}

), bridge_table AS (

      SELECT * FROM {{ ref('bdg_account_levels') }}

), joined AS (

    SELECT
           replace_sfdc_account_id_with_master_record_id.account_number                     AS zuora_account_number,
           replace_sfdc_account_id_with_master_record_id.subscription_name_slugify,
           replace_sfdc_account_id_with_master_record_id.subscription_name,
           replace_sfdc_account_id_with_master_record_id.zuora_account_id,
           sfdc_accounts_xf.account_id                                              AS sfdc_account_id,
           sfdc_accounts_xf.account_name                                            AS sfdc_account_name,
           sfdc_accounts_xf.ultimate_parent_account_id,
           sfdc_accounts_xf.ultimate_parent_account_name,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY zuora_account_id)                                        AS zuora_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY zuora_account_id)                                        AS zuora_account_cohort_quarter,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY sfdc_accounts_xf.account_id)                             AS sfdc_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY sfdc_accounts_xf.account_id)                             AS sfdc_account_cohort_quarter,
           min(zuora_subscription_cohort_month) OVER (
              PARTITION BY ultimate_parent_account_id)                              AS parent_account_cohort_month,
           min(zuora_subscription_cohort_quarter) OVER (
              PARTITION BY ultimate_parent_account_id)                              AS parent_account_cohort_quarter
    FROM bridge_table
    LEFT JOIN sfdc_accounts_xf
    ON sfdc_accounts_xf.account_id = bridge_table.sfdc_account_id

), fct_mrr_totals_levelled AS (

    SELECT *,
           datediff(month, zuora_account_cohort_month, mrr_month)      as months_since_zuora_account_cohort_start,
           datediff(quarter, zuora_account_cohort_quarter, mrr_month)  as quarters_since_zuora_account_cohort_start,
           datediff(month, sfdc_account_cohort_month, mrr_month)       as months_since_sfdc_account_cohort_start,
           datediff(quarter, sfdc_account_cohort_quarter, mrr_month)   as quarters_since_sfdc_account_cohort_start,
           datediff(month, parent_account_cohort_month, mrr_month)     as months_since_parent_account_cohort_start,
           datediff(quarter, parent_account_cohort_quarter, mrr_month) as quarters_since_parent_account_cohort_start
    FROM joined

)


{{ dbt_audit(
    cte_ref="fct_mrr_totals_levelled",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-01-07",
    updated_date="2021-01-07"
) }}
