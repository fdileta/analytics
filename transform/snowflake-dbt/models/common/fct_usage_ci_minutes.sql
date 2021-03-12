WITH namespace_lineage_monthly_all AS (

    --namespace_lineage_monthly
    SELECT
      snapshot_month,
      namespace_id,
      ultimate_parent_id
    FROM {{ ref('gitlab_dotcom_namespace_lineage_historical_monthly') }}
    WHERE snapshot_month >= '2020-07-01'
      AND snapshot_month < DATE_TRUNC('month', CURRENT_DATE)

    UNION ALL
    
    --namespace_lineage_current
    SELECT
      DATE_TRUNC('month', CURRENT_DATE)                             AS snapshot_month,
      namespace_id,
      ultimate_parent_id
    FROM {{ ref('gitlab_dotcom_namespace_lineage_prep') }}

), namespace_snapshots_monthly_all AS (

    --namespace_snapshots_monthly
    SELECT
      snapshot_month,
      namespace_id,
      shared_runners_minutes_limit,
      extra_shared_runners_minutes_limit,
      shared_runners_enabled
    FROM {{ ref('gitlab_dotcom_namespace_historical_monthly') }}
    WHERE snapshot_month >= '2020-07-01'
      AND snapshot_month < DATE_TRUNC('month', CURRENT_DATE)

    UNION ALL
    
    --namespace_current
    SELECT 
      DATE_TRUNC('month', CURRENT_DATE)                             AS snapshot_month,
      namespace_id,
      shared_runners_minutes_limit,
      extra_shared_runners_minutes_limit,
      shared_runners_enabled
    FROM {{ ref('gitlab_dotcom_namespaces_source') }} 

), namespace_statistics_monthly_all AS (

    --namespace_statistics_monthly
    SELECT 
      snapshot_month,
      namespace_id,
      shared_runners_seconds
    FROM {{ ref('gitlab_dotcom_namespace_statistics_historical_monthly') }}
    WHERE snapshot_month >= '2020-07-01'
      AND snapshot_month < DATE_TRUNC('month', CURRENT_DATE)

    UNION ALL

    --namespace_statistics_current
    SELECT
      DATE_TRUNC('month', CURRENT_DATE)                             AS snapshot_month,
      namespace_id,
      shared_runners_seconds
    FROM {{ ref('gitlab_dotcom_namespace_statistics_source') }}
      
), namespace_statistics_monthly_top_level AS (

    SELECT 
      namespace_lineage_monthly_all.snapshot_month,
      namespace_lineage_monthly_all.ultimate_parent_id,                         -- Only top level namespaces
      SUM(namespace_statistics_monthly_all.shared_runners_seconds)  AS shared_runners_seconds
    FROM namespace_lineage_monthly_all
    LEFT JOIN namespace_statistics_monthly_all
      ON namespace_lineage_monthly_all.namespace_id = namespace_statistics_monthly_all.namespace_id
      AND namespace_lineage_monthly_all.snapshot_month = namespace_statistics_monthly_all.snapshot_month
    GROUP BY 1, 2
      
), ci_minutes_logic AS (
    
    SELECT
      namespace_statistics_monthly_top_level.snapshot_month,
      namespace_statistics_monthly_top_level.ultimate_parent_id     AS dim_namespace_id,
      namespace_statistics_monthly_top_level.ultimate_parent_id     AS ultimate_parent_namespace_id,
      namespace_snapshots_monthly_all.shared_runners_enabled,
      IFF(namespace_statistics_monthly_top_level.snapshot_month >= '2020-10-01',
          400, 2000)                                                AS gitlab_current_settings_shared_runners_minutes,
      IFNULL(namespace_snapshots_monthly_all.shared_runners_minutes_limit,
             gitlab_current_settings_shared_runners_minutes)        AS monthly_minutes, 
      IFNULL(namespace_snapshots_monthly_all.extra_shared_runners_minutes_limit,
             0)                                                     AS purchased_minutes,
      IFNULL(namespace_statistics_monthly_top_level.shared_runners_seconds / 60,
             0)                                                     AS total_minutes_used,
      IFF(purchased_minutes = 0
            OR total_minutes_used < monthly_minutes,
          0, total_minutes_used - monthly_minutes)                  AS purchased_minutes_used,
      total_minutes_used - purchased_minutes_used                   AS monthly_minutes_used,    
      IFF(shared_runners_enabled
            AND monthly_minutes != 0,
          True, False)                                              AS shared_runners_minutes_limit_enabled,
      CASE 
        WHEN shared_runners_minutes_limit_enabled
          THEN monthly_minutes::VARCHAR
        WHEN monthly_minutes = 0
          THEN 'Unlimited minutes'
        ELSE 'Not supported minutes'
      END                                                           AS limit,
      IFF(monthly_minutes != 0,
          monthly_minutes, NULL)                                    AS limit_based_plan,
      CASE
        WHEN NOT shared_runners_minutes_limit_enabled
          THEN 'Disabled'
        WHEN monthly_minutes_used < monthly_minutes
          THEN 'Under Quota'
        ELSE 'Over Quota'
      END                                                           AS status,
      IFF(monthly_minutes_used < monthly_minutes
            OR monthly_minutes = 0,
          'Under Quota', 'Over Quota')                              AS status_based_plan,
      IFF(purchased_minutes_used <= purchased_minutes
            OR NOT shared_runners_minutes_limit_enabled,
          'Under Quota', 'Over Quota')                              AS status_purchased
    FROM namespace_statistics_monthly_top_level
    LEFT JOIN namespace_snapshots_monthly_all
      ON namespace_statistics_monthly_top_level.ultimate_parent_id = namespace_snapshots_monthly_all.namespace_id
      AND namespace_statistics_monthly_top_level.snapshot_month = namespace_snapshots_monthly_all.snapshot_month

), final AS (

    SELECT
      snapshot_month,
      dim_namespace_id,
      ultimate_parent_namespace_id,
      limit,
      total_minutes_used                                            AS shared_runners_minutes_used_overall,  
      status,
      limit_based_plan,
      monthly_minutes_used                                          AS used,
      status_based_plan,
      purchased_minutes                                             AS limit_purchased,
      purchased_minutes_used                                        AS used_purchased, 
      status_purchased
    FROM ci_minutes_logic

)

{{ dbt_audit(
    cte_ref="final",
    created_by="@ischweickartDD",
    updated_by="@ischweickartDD",
    created_date="2020-12-31",
    updated_date="2021-03-11"
) }}