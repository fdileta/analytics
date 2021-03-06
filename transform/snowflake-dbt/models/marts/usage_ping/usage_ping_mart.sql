WITH dim_billing_account AS (

    SELECT *
    FROM {{ ref('dim_billing_account') }}

), dim_crm_account AS (

    SELECT *
    FROM {{ ref('dim_crm_account') }}

), dim_date AS (

    SELECT *
    FROM {{ ref('dim_date') }}

), dim_location AS (

    SELECT *
    FROM {{ ref('dim_location_country') }}

), dim_product_detail AS (

    SELECT *
    FROM {{ ref('dim_product_detail') }}

), fct_usage_ping_payloads AS (

    SELECT *
    FROM {{ ref('fct_usage_ping_payloads') }}

), flattened AS (

    SELECT
      usage_ping_id,
      f.value AS product_details_id
    FROM fct_usage_ping_payloads,
      LATERAL FLATTEN(input => fct_usage_ping_payloads.array_product_details_id) AS f

), product_details AS (

    SELECT
      usage_ping_id,
      ARRAY_AGG(DISTINCT product_rate_plan_name) AS product_rate_plans,
      ARRAY_AGG(DISTINCT product_tier_name)      AS product_categories
    FROM flattened
    LEFT JOIN dim_product_detail
      ON flattened.product_details_id = dim_product_detail.dim_product_detail_id
    GROUP BY 1

), joined AS (

    SELECT
      fct_usage_ping_payloads.*,
      dim_crm_account.dim_crm_account_id,
      dim_crm_account.crm_account_name,
      dim_crm_account.crm_account_billing_country,
      dim_crm_account.dim_parent_crm_account_id,
      dim_crm_account.parent_crm_account_sales_segment,
      dim_crm_account.parent_crm_account_billing_country,
      dim_crm_account.parent_crm_account_industry,
      dim_crm_account.parent_crm_account_owner_team,
      dim_crm_account.parent_crm_account_sales_territory,
      dim_date.date_actual,
      dim_date.first_day_of_month,
      dim_date.fiscal_quarter_name_fy,
      dim_location.country_name,
      dim_location.iso_2_country_code,
      product_details.product_rate_plans,
      product_details.product_categories
    FROM fct_usage_ping_payloads
    LEFT JOIN dim_billing_account
      ON fct_usage_ping_payloads.account_id = dim_billing_account.dim_billing_account_id
    LEFT JOIN dim_crm_account
      ON dim_billing_account.dim_crm_account_id = dim_crm_account.dim_crm_account_id
    LEFT JOIN dim_date
      ON fct_usage_ping_payloads.date_id = dim_date.date_id
    LEFT JOIN dim_location
      ON fct_usage_ping_payloads.location_id = dim_location.dim_location_country_id
    LEFT JOIN product_details
      ON fct_usage_ping_payloads.usage_ping_id = product_details.usage_ping_id

), renamed AS (

    SELECT
      -- keys
      usage_ping_id,
      hostname,
      host_id,
      uuid,

      -- date info
      date_id,
      created_at              AS ping_created_at,
      recorded_at             AS ping_recorded_at,
      date_actual             AS ping_date,
      first_day_of_month      AS ping_month,
      fiscal_quarter_name_fy  AS ping_fiscal_quarter,
      IFF(ROW_NUMBER() OVER (
          PARTITION BY uuid, ping_month
          ORDER BY usage_ping_id DESC
          ) = 1, TRUE, FALSE) AS is_last_ping_in_month,
      IFF(ROW_NUMBER() OVER (
          PARTITION BY uuid, fiscal_quarter_name_fy
          ORDER BY usage_ping_id DESC
          ) = 1, TRUE, FALSE) AS is_last_ping_in_quarter,

      -- customer info
      account_id,
      dim_crm_account_id,
      crm_account_name,
      crm_account_billing_country,
      dim_parent_crm_account_id,
      parent_crm_account_billing_country,
      parent_crm_account_industry,
      parent_crm_account_owner_team,
      parent_crm_account_sales_segment,
      parent_crm_account_sales_territory,

      -- product info
      license_md5,
      is_trial                AS ping_is_trial_license,
      product_tier            AS ping_product_tier,
      product_categories,
      product_rate_plans,
      subscription_id,

      -- location info
      location_id,
      country_name            AS ping_country_name,
      iso_2_country_code      AS ping_country_code,

      -- metadata
      IFF(uuid = 'ea8bf810-1d6f-4a6a-b4fd-93e8cbd8b57f', 'SaaS', 'Self-Managed')
                              AS ping_source,
      edition,
      version,
      is_pre_release,
      instance_user_count
    FROM joined
    WHERE hostname NOT IN ('staging.gitlab.com', 'dr.gitlab.com')

)

SELECT *
FROM renamed
