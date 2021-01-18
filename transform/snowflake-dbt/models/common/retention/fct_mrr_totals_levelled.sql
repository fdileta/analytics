WITH bridge_table AS (

      SELECT * FROM {{ ref('bdg_account_levels') }}

), fct_mrr_totals_levelled AS (

    SELECT *,
           datediff(month, zuora_account_cohort_month, mrr_month)      as months_since_zuora_account_cohort_start,
           datediff(quarter, zuora_account_cohort_quarter, mrr_month)  as quarters_since_zuora_account_cohort_start,
           datediff(month, sfdc_account_cohort_month, mrr_month)       as months_since_sfdc_account_cohort_start,
           datediff(quarter, sfdc_account_cohort_quarter, mrr_month)   as quarters_since_sfdc_account_cohort_start,
           datediff(month, parent_account_cohort_month, mrr_month)     as months_since_parent_account_cohort_start,
           datediff(quarter, parent_account_cohort_quarter, mrr_month) as quarters_since_parent_account_cohort_start
    FROM bridge_table

)


{{ dbt_audit(
    cte_ref="fct_mrr_totals_levelled",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-01-07",
    updated_date="2021-01-07"
) }}
