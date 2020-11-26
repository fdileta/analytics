/*
Original issue: 
https://gitlab.com/gitlab-data/analytics/-/issues/6069

*/

WITH sfdc_opportunity_snapshot_history_xf AS (
    
    SELECT *
    FROM {{ ref('sfdc_opportunity_snapshot_history_xf') }}
    -- remove lost & deleted deals
    WHERE stage_name NOT IN ('9-Unqualified','10-Duplicate','Unqualified')
      AND is_deleted = 0

), final AS (

    SELECT
      snapshot_date,
      30 - DATEDIFF(day, snapshot_date, DATEADD(month,1,close_month))     AS snapshot_day_of_month_normalised,
      close_month,
      close_fiscal_year,
      forecast_category_name,            
      owner_id,
      opportunity_owner_manager,
      tsp_region,
      tsp_sub_region,
      stage_name,
      opportunity_owner_team_level_2                                      AS opportunity_segment,
      account_owner_team_level_2                                          AS account_segment,
      opportunity_owner_is_lvl_2_vp_flag, 
      account_owner_is_lvl_2_vp_flag, 
      COUNT(DISTINCT opportunity_id)                                      AS opps,
      SUM(net_iacv)                                                       AS net_iacv,
      SUM(incremental_acv)                                                AS incremental_acv
    FROM sfdc_opportunity_snapshot_history_xf
    -- filter only deals at the VP level 2 hierarchy
    -- we might want to filter using opportunity owner or account hierarchy
    WHERE (opportunity_owner_is_lvl_2_vp_flag = 1
      OR account_owner_is_lvl_2_vp_flag = 1)
      -- one month before
      AND snapshot_date >= DATEADD(month,-1, close_month)
      -- till end of the month
      AND snapshot_date <= DATEADD(month, 1, close_month)
    {{ dbt_utils.group_by(n=14) }}
)

SELECT *
FROM final
