/*
Original issue: 
https://gitlab.com/gitlab-data/analytics/-/issues/6069

*/

WITH sfdc_opportunity_snapshot_history_xf AS (
    
    SELECT *
    FROM {{ ref('sfdc_opportunity_snapshot_history_xf') }}
    -- remove lost & deleted deals
    WHERE is_deleted = 0
      -- Lost deals have the forecast category name of ommitted, and we need to include them to correctly account for 
      -- churned deals
      AND (stage_name NOT IN ('9-Unqualified','10-Duplicate','Unqualified','00-Pre Opportunity','0-Pending Acceptance') 
          AND forecast_category_name != 'Omitted'
          OR stage_name = '8-Closed Lost')
      AND is_excluded_flag = 0									

), final AS (

    SELECT
      order_type_stamped,
      adj_ultimate_parent_sales_segment                                                 AS sales_segment,
      90 - DATEDIFF(day, snapshot_date, DATEADD(month,3,close_fiscal_quarter_date))     AS snapshot_day_of_fiscal_quarter_normalised,
      snapshot_date,
      close_fiscal_quarter,
      close_fiscal_quarter_date,
      close_fiscal_year,
      stage_name_3plus,
      stage_name_4plus,
      is_excluded_flag,
      stage_name,
      forecast_category_name,
      COUNT(DISTINCT opportunity_id)                          AS opps,
      SUM(net_iacv)                                           AS net_iacv,
      SUM(churn_only)                                         AS churn_only,
      SUM(forecasted_iacv)                                    AS forecasted_iacv,
      SUM(total_contract_value)                               AS tcv
    FROM sfdc_opportunity_snapshot_history_xf 
    WHERE 
      -- 2 quarters before start and full quarter, total rolling 9 months at end of quarter
      -- till end of quarter
      snapshot_date <= DATEADD(month,3,close_fiscal_quarter_date)
      -- 2 quarters before start
      AND snapshot_date >= DATEADD(month,-6,close_fiscal_quarter_date)
      -- remove forecast category Omitted
      AND forecast_category_name != 'Omitted'
    {{ dbt_utils.group_by(n=11) }}
)

SELECT *
FROM final