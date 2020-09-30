WITH license AS (

    SELECT *
    FROM {{ ref('license_db_licenses_source') }}

), product_rate_plan_charge AS (

    SELECT *
    FROM {{ ref('zuora_product_rate_plan_charge_source') }}

), rate_plan AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_source') }}
    WHERE is_deleted = FALSE

), subscription AS (

    SELECT *
    FROM {{ ref('zuora_subscription_source') }}
    WHERE is_deleted = FALSE
      AND exclude_from_analysis IN ('False', '')

), usage_data AS (

    SELECT {{ hash_sensitive_columns('version_usage_data_source') }}
    FROM {{ ref('version_usage_data_source') }}
    WHERE uuid IS NOT NULL

), ip_to_geo AS (

    SELECT *
    FROM {{ ref('dim_ip_to_geo') }}

), calculated AS (

    SELECT
      *,
      {{ get_date_id('created_at') }},
      REGEXP_REPLACE(NULLIF(version, ''), '\-.*')                AS cleaned_version,
      SPLIT_PART(cleaned_version, '.', 1)                        AS major_version,
      SPLIT_PART(cleaned_version, '.', 2)                        AS minor_version,
      IFF(
          version LIKE '%-pre%' OR version LIKE '%-rc%', 
          TRUE, FALSE
      )::BOOLEAN                                                 AS is_pre_release,
      IFF(edition = 'CE', 'CE', 'EE')                            AS main_edition,
      CASE
        WHEN edition IN ('CE', 'EE Free') THEN 'Core'
        WHEN edition IN ('EE', 'EES') THEN 'Starter'
        WHEN edition = 'EEP' THEN 'Premium'
        WHEN edition = 'EEU' THEN 'Ultimate'
      ELSE NULL END                                              AS product_tier,
      CASE
        WHEN uuid = 'ea8bf810-1d6f-4a6a-b4fd-93e8cbd8b57f' THEN 'SaaS'
        ELSE 'Self-Managed'
      END                                                        AS ping_source
    FROM usage_data

), license_product_details AS (

    SELECT
      license.license_md5,
      subscription.subscription_id,
      subscription.account_id,
      ARRAY_AGG(DISTINCT product_rate_plan_charge_id)            AS array_product_details_id
    FROM license
    INNER JOIN subscription
      ON license.zuora_subscription_id = subscription.subscription_id
    INNER JOIN rate_plan
      ON subscription.subscription_id = rate_plan.subscription_id
    INNER JOIN product_rate_plan_charge
      ON rate_plan.product_rate_plan_id = product_rate_plan_charge.product_rate_plan_id
    GROUP BY 1,2,3

), joined AS (

    SELECT
      calculated.*,
      subscription_id,
      account_id,
      array_product_details_id,
      ip_to_geo.location_id
    FROM calculated
    LEFT JOIN license_product_details
      ON calculated.license_md5 = license_product_details.license_md5
    LEFT JOIN ip_to_geo
      ON calculated.source_ip_hash = ip_to_geo.ip_address_hash

), renamed AS (

    SELECT
      id              AS usage_ping_id,
      date_id,
      uuid,
      host_id,
      source_ip_hash,
      location_id,
      license_md5,
      subscription_id,
      account_id,
      array_product_details_id,
      hostname,
      main_edition    AS edition,
      product_tier,
      ping_source,
      cleaned_version AS version,
      major_version,
      minor_version,
      is_pre_release,
      instance_user_count,
      license_plan,
      license_trial   AS is_trial,
      created_at,
      recorded_at
    FROM joined

)

{{ dbt_audit(
    cte_ref="renamed",
    created_by="@derekatwood",
    updated_by="@jjstark",
    created_date="2020-08-17",
    updated_date="2020-09-25"
) }}
