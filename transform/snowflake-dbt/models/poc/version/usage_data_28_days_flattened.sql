
{% set metric_type = '28_days' %}
{% set columns_to_parse = ['analytics_unique_visits', 'usage_activity_by_stage_monthly', 'stats_used', 'usage_activity_by_stage_monthly', 'redis_hll_counters'] %}

WITH data AS ( 
  
    SELECT * FROM {{ ref('version_usage_data')}}

)

, flattened AS (
    {% for column in columns_to_parse %}
      (

        SELECT 
          uuid                          AS instance_id, 
          id                            AS ping_id,
          created_at,
          path                          AS metric_path, 
          value                         AS metric_value
        FROM data,
        lateral flatten(input => raw_usage_data_payload, path => '{{ column }}',
        recursive => true) 
        WHERE typeof(value) IN ('INTEGER', 'DECIMAL')
        ORDER BY created_at DESC

      )
      {% if not loop.last %}
        UNION 
      {% endif %}
      {% endfor %}

)

SELECT 
  flattened.instance_id,
  flattened.ping_id,
  created_at,
  metrics.*, 
  flattened.metric_value
FROM flattened
INNER JOIN {{ ref('sheetload_usage_ping_metrics_sections' )}} AS metrics 
  ON flattened.metric_path = metrics.metrics_path
    AND time_period = '{{metric_type}}'
