WITH zuora_product AS (

    SELECT *
    FROM {{ ref('zuora_product_source') }}

), zuora_product_rate_plan AS (
    
    SELECT *
    FROM {{ ref('zuora_product_rate_plan_source') }}

), zuora_product_rate_plan_charge AS (

    SELECT *
    FROM {{ ref('zuora_product_rate_plan_charge_source') }}

), zuora_product_rate_plan_charge_tier AS (

    SELECT *
    FROM {{ ref('zuora_product_rate_plan_charge_tier_source') }}
    
), joined AS (

    SELECT
      -- ids
      zuora_product_rate_plan_charge.product_rate_plan_charge_id                AS product_details_id,
      zuora_product.product_id                                                  AS product_id,
      
      -- fields
      zuora_product_rate_plan.product_rate_plan_name                            AS product_rate_plan_name,
      zuora_product_rate_plan_charge.product_rate_plan_charge_name              AS product_rate_plan_charge_name,
      zuora_product.product_name                                                AS product_name,
      zuora_product.sku                                                         AS product_sku,
      {{ product_category('zuora_product_rate_plan.product_rate_plan_name') }},
      {{ delivery('product_category')}},
      CASE
        WHEN lower(product_rate_plan_name) like '%support%'
          THEN 'Support Only'
        ELSE 'Full Service'
      END                                                                       AS service_type,
      zuora_product_rate_plan.product_rate_plan_name like '%reporter_access%'   AS is_reporter_license,
      zuora_product.effective_start_date                                        AS effective_start_date,
      zuora_product.effective_end_date                                          AS effective_end_date,
      {{ product_ranking('product_category') }}                                 AS product_ranking,
      MIN(zuora_product_rate_plan_charge_tier.price)                            AS billing_list_price
    FROM zuora_product
    INNER JOIN zuora_product_rate_plan 
      ON zuora_product.product_id = zuora_product_rate_plan.product_id
    INNER JOIN zuora_product_rate_plan_charge
      ON zuora_product_rate_plan.product_rate_plan_id = zuora_product_rate_plan_charge.product_rate_plan_id
    INNER JOIN zuora_product_rate_plan_charge_tier
      ON zuora_product_rate_plan_charge.product_rate_plan_charge_id = zuora_product_rate_plan_charge_tier.product_rate_plan_charge_id
    WHERE zuora_product.is_deleted = FALSE
      AND zuora_product_rate_plan_charge_tier.currency = 'USD'
    {{ dbt_utils.group_by(n=12) }}
    ORDER BY 1, 3

)

{{ dbt_audit(
    cte_ref="joined",
    created_by="@msendal",
    updated_by="@msendal",
    created_date="2020-06-01",
    updated_date="2020-10-16"
) }}



