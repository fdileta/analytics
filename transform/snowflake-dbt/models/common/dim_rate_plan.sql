WITH source AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_source') }}

), with_product_category AS (

    SELECT
      rate_plan_id                                  AS dim_rate_plan_id,
      subscription_id                               AS dim_subscription_id,
      product_rate_plan_id                          AS product_rate_plan_id,
      product_id                                    AS product_id,
      created_by_id                                 AS created_by_id,
      amendement_type                               AS amendement_type,
      rate_plan_name                                AS rate_plan_name,
      {{ map_product_category('rate_plan_name')}}   AS product_category,
      {{ map_delivery('product_category')}}         AS delivery,
      amendement_id                                 AS amendement_id,
      is_deleted                                    AS is_deleted,
      updated_by                                    AS updated_by,
      updated_by_id                                 AS updated_by_id,
      created_by                                    AS created_by
    FROM source

)

{{ dbt_audit(
    cte_ref="with_product_category",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-02-05",
    updated_date="2021-02-08"
) }}