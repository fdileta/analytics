/* grain: one record per subscription per month */
WITH mrr AS (

    SELECT
      mrr_id,
      dim_date_id,
      dim_billing_account_id,
      dim_crm_account_id,
      dim_subscription_id,
      dim_product_detail_id,
      mrr,
      arr,
      quantity,
      unit_of_measure
    FROM {{ ref('prep_recurring_charge') }}
    WHERE mrr != 0 /* This excludes Education customers (charge name EDU or OSS) with free subscriptions */

), opportunity_dimensions AS (

    SELECT *
    FROM {{ ref('map_crm_opportunity') }}

), subscription AS (

    SELECT *
    FROM {{ ref('zuora_subscription_source' )}}
    WHERE is_deleted = 'FALSE'

), final AS (

    SELECT
      --ids
      mrr.mrr_id,

      --shared dimension keys
      mrr.dim_date_id,
      mrr.dim_billing_account_id,
      mrr.dim_crm_account_id,
      mrr.dim_subscription_id,
      mrr.dim_product_detail_id,
      subscription.sfdc_opportunity_id                                             AS dim_crm_opportunity_id,
      opportunity_dimensions.dim_crm_sales_rep_id,
      opportunity_dimensions.dim_order_type_id,
      opportunity_dimensions.dim_opportunity_source_id,
      opportunity_dimensions.dim_purchase_channel_id,
      opportunity_dimensions.dim_sales_segment_id,
      opportunity_dimensions.dim_geo_region_id,
      opportunity_dimensions.dim_geo_sub_region_id,
      opportunity_dimensions.dim_geo_area_id,
      opportunity_dimensions.dim_sales_territory_id,
      opportunity_dimensions.dim_industry_id,
      opportunity_dimensions.dim_crm_sales_hierarchy_sales_segment_stamped_id,
      opportunity_dimensions.dim_crm_sales_hierarchy_location_region_stamped_id,
      opportunity_dimensions.dim_crm_sales_hierarchy_sales_region_stamped_id,
      opportunity_dimensions.dim_crm_sales_hierarchy_sales_area_stamped_id,

      --additive fields
      mrr.mrr,
      mrr.arr,
      mrr.quantity,
      mrr.unit_of_measure
    FROM mrr
    LEFT JOIN subscription
      ON mrr.dim_subscription_id = subscription.subscription_id
    LEFT JOIN opportunity_dimensions
      ON subscription.subscription_id = opportunity_dimensions.dim_crm_opportunity_id
)

{{ dbt_audit(
    cte_ref="final",
    created_by="@msendal",
    updated_by="@mcooperDD",
    created_date="2020-09-10",
    updated_date="2021-01-21",
) }}
