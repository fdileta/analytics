WITH prep_usage_ping_subscription_mapped_sales_fy21_q1 AS (
  
    SELECT *  
    FROM {{ ref('prep_usage_ping_subscription_mapped_sales_fy21_q1') }}

), cleaned AS (
  
    SELECT 
      *, 
      LAST_VALUE(dim_usage_ping_id) OVER (PARTITION BY subscription_id, ping_created_at_month ORDER BY dim_usage_ping_id) AS latest_usage_ping_id_in_month
    FROM prep_usage_ping_subscription_mapped_sales_fy21_q1
    WHERE subscription_id IS NOT NULL 
  
), final AS (

    SELECT *
    FROM cleaned
    WHERE dim_usage_ping_id = latest_usage_ping_id_in_month
  
)

{{ dbt_audit(
    cte_ref="final",
    created_by="@kathleentam",
    updated_by="@kathleentam",
    created_date="2021-01-18",
    updated_date="2021-01-18"
) }}
