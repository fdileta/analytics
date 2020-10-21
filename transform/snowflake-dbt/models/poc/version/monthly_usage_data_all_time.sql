WITH data AS ( 
  
    SELECT * 
    FROM {{ ref('usage_data_all_time_flattened')}}

)

, transformed AS (

    SELECT 
        *,
        DATE_TRUNC('month', created_at) AS created_month
    FROM data
    QUALIFY ROW_NUMBER() OVER (PARTITION BY instance_id, clean_metrics_name, created_month ORDER BY created_at DESC) = 1

)

, monthly AS (

    SELECT 
      *,
      metric_value 
        - COALESCE(LAG(metric_value) OVER (
                                            PARTITION BY instance_id, clean_metrics_name 
                                            ORDER BY created_month
                                          ), 0) AS monthly_metric_value
    FROM transformed

)

SELECT 
  ping_id,
  instance_id,
  created_month,
  metrics_path,
  group_name,
  stage_name,
  section_name,
  is_smau,
  is_gmau,
  clean_metrics_name,
  IFF(monthly_metric_value < 0, 0, monthly_metric_value) AS monthly_metric_value
FROM monthly
