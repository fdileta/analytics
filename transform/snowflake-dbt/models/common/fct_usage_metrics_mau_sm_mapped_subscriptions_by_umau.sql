WITH prep_usage_metrics_mau_sm_mapped_subscriptions AS (
  
    SELECT *  
    FROM {{ ref('prep_usage_metrics_mau_sm_mapped_subscriptions') }}

), cleaned AS (
  
    SELECT 
      *, 
      LAST_VALUE(dim_usage_ping_id) OVER (PARTITION BY subscription_id, ping_created_at_month ORDER BY dim_usage_ping_id) AS latest_usage_ping_id_in_month
    FROM prep_usage_metrics_mau_sm_mapped_subscriptions
    WHERE subscription_id IS NOT NULL 
  
), final AS (

    SELECT *
    FROM cleaned
    QUALIFY ROW_NUMBER() over (PARTITION BY subscription_id, ping_created_at_month ORDER BY UMAU_28_DAYS_USER DESC) = 1

)

SELECT * 
FROM final
