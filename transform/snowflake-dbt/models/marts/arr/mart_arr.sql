/* This table needs to be permanent to allow zero cloning at specific timestamps */
{{ config(materialized='table',
  transient=false)}}

WITH dim_billing_account AS (

    SELECT *
    FROM {{ ref('dim_billing_account') }}

), dim_crm_account AS (

    SELECT *
    FROM {{ ref('dim_crm_account') }}

), dim_crm_sales_hierarchy_stamped AS (

    SELECT *
    FROM {{ ref('dim_crm_sales_hierarchy_stamped') }}

), dim_date AS (

    SELECT *
    FROM {{ ref('dim_date') }}

), dim_industry AS (

    SELECT *
    FROM {{ ref('dim_industry') }}

), dim_opportunity_source AS (

    SELECT *
    FROM {{ ref('dim_opportunity_source') }}

), dim_order_type AS (

    SELECT *
    FROM {{ ref('dim_order_type') }}

), dim_product_detail AS (

    SELECT *
    FROM {{ ref('dim_product_detail') }}

), dim_purchase_channel AS (

    SELECT *
    FROM {{ ref('dim_purchase_channel') }}

), dim_sales_segment AS (

    SELECT *
    FROM {{ ref('dim_sales_segment') }}

), dim_sales_territory AS (

    SELECT *
    FROM {{ ref('dim_sales_territory') }}

), dim_subscription AS (

    SELECT *
    FROM {{ ref('dim_subscription') }}

), fct_mrr AS (

    SELECT *
    FROM {{ ref('fct_mrr') }}

)

SELECT
  --primary_key
  fct_mrr.mrr_id                                                                        AS primary_key,

  --date info
  dim_date.date_actual                                                                  AS arr_month,
  IFF(is_first_day_of_last_month_of_fiscal_quarter, fiscal_quarter_name_fy, NULL)       AS fiscal_quarter_name_fy,
  IFF(is_first_day_of_last_month_of_fiscal_year, fiscal_year, NULL)                     AS fiscal_year,
  dim_subscription.subscription_start_month,
  dim_subscription.subscription_end_month,

  --account info
  dim_billing_account.dim_billing_account_id                                            AS zuora_account_id,
  dim_billing_account.sold_to_country                                                   AS zuora_sold_to_country,
  dim_billing_account.billing_account_name                                              AS zuora_account_name,
  dim_billing_account.billing_account_number                                            AS zuora_account_number,
  dim_crm_account.crm_account_id                                                        AS crm_id,
  dim_crm_account.crm_account_name,
  dim_crm_account.ultimate_parent_account_id,
  dim_crm_account.ultimate_parent_account_name,
  dim_crm_account.ultimate_parent_billing_country,
  dim_crm_account.ultimate_parent_account_segment,
  dim_crm_account.ultimate_parent_industry,
  dim_crm_account.ultimate_parent_account_owner_team,
  dim_crm_account.ultimate_parent_territory,

  -- shared dimension attributes
  dim_order_type.order_type_name,
  dim_opportunity_source.opportunity_source_name,
  dim_purchase_channel.purchase_channel_name,
  dim_sales_segment.sales_segment_name,
  dim_sales_territory.sales_territory_name,
  dim_industry.industry_name,
  dim_crm_sales_hierarchy_sales_segment_stamped.sales_segment_name_stamped,
  dim_crm_sales_hierarchy_location_region_stamped.location_region_name_stamped,
  dim_crm_sales_hierarchy_sales_region_stamped.sales_region_name_stamped,
  dim_crm_sales_hierarchy_sales_area_stamped.sales_area_name_stamped,

  --subscription info
  dim_subscription.subscription_name,
  dim_subscription.subscription_status,
  dim_subscription.subscription_sales_type,

  --product info
  dim_product_detail.product_tier_name                                                   AS product_category,
  dim_product_detail.product_delivery_type                                               AS delivery,
  dim_product_detail.service_type,
  dim_product_detail.product_rate_plan_name                                              AS rate_plan_name,
  --  not needed as all charges in fct_mrr are recurring
  --  fct_mrr.charge_type,
  fct_mrr.unit_of_measure,

  fct_mrr.mrr,
  fct_mrr.arr,
  fct_mrr.quantity
  FROM fct_mrr
  INNER JOIN dim_subscription
    ON dim_subscription.dim_subscription_id = fct_mrr.dim_subscription_id
  INNER JOIN dim_product_detail
    ON dim_product_detail.dim_product_detail_id = fct_mrr.dim_product_detail_id
  INNER JOIN dim_billing_account
    ON dim_billing_account.dim_billing_account_id = fct_mrr.dim_billing_account_id
  INNER JOIN dim_date
    ON dim_date.date_id = fct_mrr.dim_date_id
  LEFT JOIN dim_crm_account
    ON dim_billing_account.dim_crm_account_id = dim_crm_account.crm_account_id
  LEFT JOIN dim_order_type
    ON fct_mrr.dim_order_type_id = dim_order_type.dim_order_type_id
  LEFT JOIN dim_opportunity_source
    ON fct_mrr.dim_opportunity_source_id = dim_opportunity_source.dim_opportunity_source_id
  LEFT JOIN dim_purchase_channel
    ON fct_mrr.dim_purchase_channel_id = dim_purchase_channel.dim_purchase_channel_id
  LEFT JOIN dim_sales_segment
    ON fct_mrr.dim_sales_segment_id = dim_sales_segment.dim_sales_segment_id
  LEFT JOIN dim_sales_territory
    ON fct_mrr.dim_sales_territory_id = dim_sales_territory.dim_sales_territory_id
  LEFT JOIN dim_industry
    ON fct_mrr.dim_industry_id = dim_industry.dim_industry_id
  LEFT JOIN dim_crm_sales_hierarchy_stamped AS dim_crm_sales_hierarchy_sales_segment_stamped
    ON fct_mrr.dim_crm_sales_hierarchy_sales_segment_stamped_id = dim_crm_sales_hierarchy_sales_segment_stamped.dim_crm_sales_hierarchy_sales_segment_stamped_id
  LEFT JOIN dim_crm_sales_hierarchy_stamped AS dim_crm_sales_hierarchy_location_region_stamped
    ON fct_mrr.dim_crm_sales_hierarchy_location_region_stamped_id = dim_crm_sales_hierarchy_location_region_stamped.dim_crm_sales_hierarchy_location_region_stamped_id
  LEFT JOIN dim_crm_sales_hierarchy_stamped AS dim_crm_sales_hierarchy_sales_region_stamped
    ON fct_mrr.dim_crm_sales_hierarchy_sales_region_stamped_id = dim_crm_sales_hierarchy_sales_region_stamped.dim_crm_sales_hierarchy_sales_region_stamped_id
  LEFT JOIN dim_crm_sales_hierarchy_stamped AS dim_crm_sales_hierarchy_sales_area_stamped
    ON fct_mrr.dim_crm_sales_hierarchy_sales_area_stamped_id = dim_crm_sales_hierarchy_sales_area_stamped.dim_crm_sales_hierarchy_sales_area_stamped_id
