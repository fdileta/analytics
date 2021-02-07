with raw_fct_mrr_totals_levelled AS (

       SELECT * FROM {{ref('fct_mrr_totals_levelled')}}

), fct_mrr_totals_levelled AS (

      SELECT  dim_subscription_id,
              subscription_name,
              subscription_name_slugify,
              dim_crm_account_id,
              oldest_subscription_in_cohort,
              subscription_lineage,
              to_date(cast(dim_date_id as varchar), 'YYYYMMDD')     AS  mrr_month,
              subscription_cohort_month,
              subscription_cohort_quarter,
              months_since_subscription_cohort_start,
              quarters_since_subscription_cohort_start,
              sum(mrr) as mrr
      FROM raw_fct_mrr_totals_levelled
      {{ dbt_utils.group_by(n=11) }}

), current_arr_segmentation_all_levels AS (

       SELECT * FROM {{ref('fct_current_arr_segmentation_all_levels')}}
       WHERE level_ = 'dim_subscription_id'

), mapping AS (
      
       SELECT DISTINCT  subscription_name, dim_crm_account_id
       FROM fct_mrr_totals_levelled


), list AS ( --get all the subscription + their lineage + the month we're looking for MRR for (12 month in the future)

       SELECT subscription_name_slugify   AS original_sub,
                     c.value::VARCHAR     AS subscriptions_in_lineage,
                     mrr_month            AS original_mrr_month,
                     dateadd('year', 1, mrr_month) AS retention_month
       FROM fct_mrr_totals_levelled,
       lateral flatten(input =>split(subscription_lineage, ',')) C
       {{ dbt_utils.group_by(n=4) }}

), retention_subs AS ( --find which of those subscriptions are real and group them by their sub you're comparing to.

       SELECT original_sub,
               retention_month,
               original_mrr_month,
               sum(mrr) AS retention_mrr
       FROM list
       INNER JOIN fct_mrr_totals_levelled AS subs
       ON retention_month = mrr_month
       AND subscriptions_in_lineage = subscription_name_slugify
       {{ dbt_utils.group_by(n=3) }}

), finals AS (

       SELECT coalesce(retention_subs.retention_mrr, 0) AS net_retention_mrr,
              CASE WHEN net_retention_mrr > 0 
                  THEN least(net_retention_mrr, mrr)
                  ELSE 0 END AS gross_retention_mrr,
              retention_month, 
              fct_mrr_totals_levelled.*
       FROM fct_mrr_totals_levelled
       LEFT JOIN retention_subs
       ON subscription_name_slugify = original_sub
       AND retention_subs.original_mrr_month = fct_mrr_totals_levelled.mrr_month

), joined as (

      SELECT finals.dim_subscription_id
             finals.subscription_name             AS subscription_name,
             finals.oldest_subscription_in_cohort AS dim_subscription_id,
             mapping.dim_crm_account_id           AS dim_crm_account_id,
             dateadd('year', 1, finals.mrr_month) AS retention_month, --THIS IS THE RETENTION MONTH, NOT THE MRR MONTH!!
             finals.mrr                           AS original_mrr,
             finals.net_retention_mrr,
             finals.gross_retention_mrr,
             finals.subscription_cohort_month,
             finals.subscription_cohort_quarter,
             finals.months_since_subscription_cohort_start,
             finals.quarters_since_subscription_cohort_start,
             {{ churn_type('original_mrr', 'net_retention_mrr') }}
      FROM finals
      LEFT JOIN mapping
      ON mapping.subscription_name = finals.subscription_name

)

SELECT joined.*, 
        current_arr_segmentation_all_levels.arr_segmentation
FROM joined
LEFT JOIN current_arr_segmentation_all_levels
ON joined.dim_subscription_id = current_arr_segmentation_all_levels.id
WHERE retention_month <= dateadd(month, -1, CURRENT_DATE)
