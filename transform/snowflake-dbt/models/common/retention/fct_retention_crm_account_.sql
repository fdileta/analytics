with fct_mrr_totals_levelled AS (

       SELECT *,
              to_date(cast(dim_date_id as varchar), 'YYYYMMDD')     AS  mrr_month
       FROM {{ref('fct_mrr_totals_levelled')}}

), current_arr_segmentation_all_levels AS (

       SELECT * FROM {{ref('fct_current_arr_segmentation_all_levels')}}
       WHERE level_ = 'dim_crm_account_id'

), list AS ( --get all the subscription + their lineage + the month we're looking for MRR for (12 month in the future)

       SELECT dim_crm_account_id,
              mrr_month as original_mrr_month,
              dateadd('year', 1, mrr_month) AS retention_month,
              sum(mrr) as mrr
       FROM fct_mrr_totals_levelled
       GROUP BY 1, 2, 3

), retention_subs AS ( --find which of those subscriptions are real and group them by their sub you're comparing to.

       SELECT list.dim_crm_account_id,
               list.retention_month,
               list.original_mrr_month,
               sum(list.mrr) AS original_mrr,
               sum(future.mrr) AS retention_mrr
       FROM list
       LEFT JOIN list AS future
       ON list.retention_month = future.original_mrr_month
       AND list.dim_crm_account_id = future.dim_crm_account_id
       GROUP BY 1, 2, 3

), finals AS (

       SELECT dim_crm_account_id,
              retention_mrr,
              coalesce(retention_mrr, 0) AS net_retention_mrr,
              CASE WHEN net_retention_mrr > 0
                  THEN least(net_retention_mrr, original_mrr)
                  ELSE 0 END AS gross_retention_mrr,
              retention_month,
              original_mrr_month,
              original_mrr
       FROM retention_subs

), joined as(

        SELECT finals.dim_crm_account_id,
               finals.dim_crm_account_id as salesforce_account_id,
               crm_account_name,
               dateadd('year', 1, finals.original_mrr_month) AS retention_month, --THIS IS THE RETENTION MONTH, NOT THE MRR MONTH!!
               original_mrr,
               net_retention_mrr,
               gross_retention_mrr,
               crm_account_cohort_month,
               crm_account_cohort_quarter,
               datediff(month, crm_account_cohort_month, original_mrr_month) as months_since_sfdc_account_cohort_start,
               datediff(quarter, crm_account_cohort_quarter, original_mrr_month) as quarters_since_sfdc_account_cohort_start,
               {{ churn_type('original_mrr', 'net_retention_mrr') }}
        FROM finals
        LEFT JOIN fct_mrr_totals_levelled
        ON finals.dim_crm_account_id = fct_mrr_totals_levelled.dim_crm_account_id
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

)

SELECT joined.*, 
        current_arr_segmentation_all_levels.arr_segmentation
FROM joined
LEFT JOIN current_arr_segmentation_all_levels
ON joined.dim_crm_account_id = current_arr_segmentation_all_levels.id
WHERE retention_month <= dateadd(month, -1, CURRENT_DATE)

--