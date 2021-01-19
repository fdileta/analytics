{{ config({
    "materialized": "table"
    })
}}

WITH prep_usage_ping AS (

    SELECT * 
    FROM {{ ref('prep_usage_ping') }}
    WHERE license_md5 IS NOT NULL 

), dim_licenses AS (
  
    SELECT DISTINCT 
        license_md5, 
        subscription_id, 
        license_user_count, 
        is_trial, 
        license_start_date,
        license_expire_date 
    FROM {{ ref('dim_licenses') }}

), dim_subscription AS (
  
    SELECT
      dim_subscription_id, 
      dim_crm_account_id, 
      subscription_name, 
      subscription_status
    FROM {{ ref('dim_subscription') }}

), license_mapped_to_subscription AS (

    SELECT 
      dim_licenses.license_md5    AS dim_licenses_license_md5, 
      license_user_count, 
      subscription_id, 
      subscription_name, 
      subscription_status, 
      IFF(subscription_id IS NULL, TRUE, FALSE)     AS is_license_mapped_to_subscription
    FROM dim_licenses
    LEFT JOIN dim_subscription 
      ON dim_licenses.subscription_id = dim_subscription.dim_subscription_id
  
), usage_pings_with_license_md5 AS (

    {{ sales_fy21_q1_requested_metrics() }}
  
), usage_ping_mapped_to_subscription AS (

    SELECT 
      usage_pings_with_license_md5.*, 
      license_mapped_to_subscription.license_user_count, 
      license_mapped_to_subscription.subscription_id, 
      license_mapped_to_subscription.subscription_name, 
      license_mapped_to_subscription.subscription_status,
      license_mapped_to_subscription.is_license_mapped_to_subscription,
      IFF(dim_licenses_license_md5 IS NULL, FALSE, TRUE)    AS is_license_md5_missing_in_licenseDot 
    FROM usage_pings_with_license_md5
    LEFT JOIN license_mapped_to_subscription
      ON usage_pings_with_license_md5.license_md5 = license_mapped_to_subscription.dim_licenses_license_md5
  
)

{{ dbt_audit(
    cte_ref="usage_ping_mapped_to_subscription",
    created_by="@kathleentam",
    updated_by="@kathleentam",
    created_date="2021-01-11",
    updated_date="2021-01-11"
) }}

