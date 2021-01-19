{{ config({
    "materialized": "table"
    })
}}

WITH prep_usage_ping AS (

    SELECT * 
    FROM {{ ref('prep_usage_ping') }}
    WHERE license_md5 IS NULL 

), usage_pings_no_license AS (

    {{ sales_fy21_q1_requested_metrics() }}
  
)

{{ dbt_audit(
    cte_ref="usage_pings_no_license",
    created_by="@kathleentam",
    updated_by="@kathleentam",
    created_date="2021-01-18",
    updated_date="2021-01-18"
) }}
