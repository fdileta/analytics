{% macro smau_gmau_metrics() %} 

WITH base AS (

    SELECT *
    FROM {{ ref(sheetload_usage_ping_metrics_sections_source) }}

), final AS (

    SELECT DISTINCT 
      'raw_usage_data_payload:' || REPLACE(metrics_path, '.',':') AS all_metrics_path,
      clean_metrics_name
    FROM base 
    WHERE is_smau = TRUE OR is_gmau = TRUE OR is_umau = TRUE OR is_paid_gmau 

) 

SELECT * 
FROM final 

{% endmacro %}

