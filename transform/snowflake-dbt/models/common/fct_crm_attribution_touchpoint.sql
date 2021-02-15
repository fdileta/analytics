WITH bizible_attribution_touchpoints AS (

    SELECT *
    FROM {{ ref('sfdc_bizible_attribution_touchpoint_source') }}
    WHERE is_deleted = 'FALSE'

), crm_person AS (

    SELECT *
    FROM {{ ref('prep_crm_person') }}

), opportunity_dimensions AS (

    SELECT *
    FROM {{ ref('map_crm_opportunity') }}

), final_attribution_touchpoint AS (

    SELECT
      touchpoint_id                                                 AS dim_crm_touchpoint_id,

      -- shared dimension keys
      campaign_id                                                   AS dim_campaign_id,
      opportunity_id                                                AS dim_crm_opportunity_id,
      bizible_account                                               AS dim_crm_account_id,
      crm_person.dim_crm_person_id,
      opportunity_dimensions.dim_crm_sales_rep_id                   AS dim_crm_sales_rep_id,
      opportunity_dimensions.dim_order_type_id                      AS dim_order_type_id,
      opportunity_dimensions.dim_opportunity_source_id              AS dim_opportunity_source_id,
      opportunity_dimensions.dim_purchase_channel_id                AS dim_purchase_channel_id,
      opportunity_dimensions.dim_sales_segment_id                   AS dim_sales_segment_id,
      opportunity_dimensions.dim_sales_territory_id                 AS dim_sales_territory_id,
      opportunity_dimensions.dim_industry_id                        AS dim_industry_id,

      -- attribution counts
      bizible_count_first_touch,
      bizible_count_lead_creation_touch,
      bizible_attribution_percent_full_path,
      bizible_count_u_shaped,
      bizible_count_w_shaped,

      -- touchpoint revenue info
      bizible_revenue_full_path,
      bizible_revenue_custom_model,
      bizible_revenue_first_touch,
      bizible_revenue_lead_conversion,
      bizible_revenue_u_shaped,
      bizible_revenue_w_shaped

    FROM bizible_attribution_touchpoints
    LEFT JOIN crm_person
      ON bizible_attribution_touchpoints.bizible_contact = crm_person.sfdc_record_id
    LEFT JOIN opportunity_dimensions
      ON bizible_attribution_touchpoints.opportunity_id = opportunity_dimensions.dim_crm_opportunity_id
)

{{ dbt_audit(
    cte_ref="final_attribution_touchpoint",
    created_by="@mcooperDD",
    updated_by="@mcooperDD",
    created_date="2021-01-21",
    updated_date="2021-01-21"
) }}
