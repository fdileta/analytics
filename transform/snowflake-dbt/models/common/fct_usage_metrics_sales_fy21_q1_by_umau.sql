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
    QUALIFY ROW_NUMBER() over (PARTITION BY subscription_id, ping_created_at_month ORDER BY UMAU_28_DAYS_USER DESC) = 1

)

SELECT * 
FROM final
