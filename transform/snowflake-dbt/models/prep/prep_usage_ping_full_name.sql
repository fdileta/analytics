{{ 
    config({
        "materialized": "incremental",
        "unique_key": "full_ping_name_for_column_name"
    })
}}

WITH prep_usage_ping AS (
  
    SELECT * 
    FROM {{ ref('prep_usage_ping') }}
    
), usage_ping_full_name AS (

    {% if is_incremental() %}
    
        SELECT DISTINCT 
        TRIM(LOWER(f.path))                                                     AS ping_name,
        REPLACE(ping_name, '.','_')                                             AS full_ping_name_for_column_name,
        'raw_usage_data_payload:' || REPLACE(ping_name, '.',':')                AS full_ping_name_for_raw_usage_data_payload,
        SPLIT_PART(ping_name, '.', 1)                                           AS main_json_name, 
        SPLIT_PART(ping_name, '.', -1)                                          AS feature_name
        FROM prep_usage_ping,
        lateral flatten(input => prep_usage_ping.raw_usage_data_payload, recursive => True) f
        WHERE ping_created_at_date, > (select max(ping_created_at_date) from {{ this }})
            AND 
    
    {% endif %}

), final AS (

    SELECT * 
    FROM usage_ping_full_name
    WHERE feature_name NOT IN ('source_ip')

)

{{ dbt_audit(
    cte_ref="final",
    created_by="@kathleentam",
    updated_by="@kathleentam",
    created_date="2021-01-18",
    updated_date="2021-01-18"
) }}
