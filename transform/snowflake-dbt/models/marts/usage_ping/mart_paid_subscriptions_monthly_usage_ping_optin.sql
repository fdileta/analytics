WITH self_managed_active_subscriptions AS (
  
    SELECT
      date_id,
      subscription_id,
      product_details_id,
      mrr,
      quantity
    FROM {{ ref('fct_mrr')}}
  
), dim_dates AS (
  
    SELECT DISTINCT
      date_id,
      first_day_of_month
    FROM {{ ref('dim_dates')}}
    WHERE first_day_of_month < CURRENT_DATE
  
), dim_product_details AS (

  SELECT *
  FROM {{ ref('dim_product_details') }}

), active_subscriptions AS (
  
    SELECT *
    FROM {{ ref('dim_subscriptions') }}
  
), all_subscriptions AS (
  
    SELECT *
    FROM {{ ref('zuora_subscription_source') }}
  
), fct_payloads AS (
  
    SELECT *
    FROM {{ ref('fct_usage_ping_payloads') }}
  
), transformed AS (
  
    SELECT 
      {{ dbt_utils.surrogate_key(['first_day_of_month', 'self_managed_active_subscriptions.subscription_id']) }}        AS month_subscription_id,
      first_day_of_month                                                              AS reporting_month,
      self_managed_active_subscriptions.subscription_id,
      active_subscriptions.subscription_name_slugify,
      active_subscriptions.subscription_start_date,
      active_subscriptions.subscription_end_date,
      SUM(self_managed_active_subscriptions.mrr) * 12                                 AS arr,
      SUM(self_managed_active_subscriptions.quantity)                                 AS quantity,
      MAX(fct_payloads.subscription_id) IS NOT NULL                                   AS has_sent_payloads,
      COUNT(DISTINCT fct_payloads.subscription_id)                                    AS monthly_payload_counts,
      COUNT(DISTINCT host_id)                                                         AS monthly_host_counts
    FROM self_managed_active_subscriptions  
    INNER JOIN dim_product_details
      ON self_managed_active_subscriptions.product_details_id = dim_product_details.product_details_id
        AND delivery='Self-Managed'
    INNER JOIN dim_dates ON self_managed_active_subscriptions.date_id = dim_dates.date_id
    LEFT JOIN active_subscriptions ON self_managed_active_subscriptions.subscription_id = active_subscriptions.subscription_id
    LEFT JOIN all_subscriptions ON active_subscriptions.subscription_name_slugify = all_subscriptions.subscription_name_slugify
    LEFT JOIN fct_payloads ON all_subscriptions.subscription_id = fct_payloads.subscription_id AND first_day_of_month = DATE_TRUNC('month', fct_payloads.created_at)
    GROUP BY 1,2,3,4,5,6

), latest_versions AS (

    SELECT DISTINCT
      first_day_of_month AS reporting_month,
      self_managed_active_subscriptions.subscription_id,
      active_subscriptions.subscription_name_slugify,
      FIRST_VALUE(major_minor_version) OVER (
        PARTITION BY first_day_of_month, active_subscriptions.subscription_name_slugify
        ORDER BY major_version DESC, minor_version
      ) AS latest_major_minor_version
    FROM self_managed_active_subscriptions  
    INNER JOIN dim_product_details
      ON self_managed_active_subscriptions.product_details_id = dim_product_details.product_details_id
        AND delivery='Self-Managed'
    INNER JOIN dim_dates ON self_managed_active_subscriptions.date_id = dim_dates.date_id
    INNER JOIN active_subscriptions ON self_managed_active_subscriptions.subscription_id = active_subscriptions.subscription_id
    INNER JOIN all_subscriptions ON active_subscriptions.subscription_name_slugify = all_subscriptions.subscription_name_slugify
    INNER JOIN fct_payloads ON all_subscriptions.subscription_id = fct_payloads.subscription_id AND first_day_of_month = DATE_TRUNC('month', fct_payloads.created_at)

), joined AS (

    SELECT
      transformed.*,
      latest_versions.latest_major_minor_version
    FROM transformed
    LEFT JOIN latest_versions
      ON transformed.reporting_month = latest_versions.reporting_month
        AND transformed.subscription_name_slugify = latest_versions.subscription_name_slugify

)

{{ dbt_audit(
    cte_ref="joined",
    created_by="@mpeychet_",
    updated_by="@mpeychet_",
    created_date="2020-10-16",
    updated_date="2020-10-16"
) }}

