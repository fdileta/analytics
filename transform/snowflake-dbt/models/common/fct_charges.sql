{{config({
    "schema": "legacy"
  })
}}

WITH zuora_rate_plan AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_source') }}

), zuora_rate_plan_charge AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_charge_source') }}

), base_charges AS (

    SELECT
      zuora_rate_plan_charge.rate_plan_charge_id            AS charge_id,
      zuora_rate_plan_charge.product_rate_plan_charge_id    AS product_details_id,
      zuora_rate_plan.subscription_id,
      zuora_rate_plan_charge.account_id,
      zuora_rate_plan_charge.rate_plan_charge_number,
      zuora_rate_plan_charge.rate_plan_charge_name,
      zuora_rate_plan_charge.effective_start_month,
      zuora_rate_plan_charge.effective_end_month,
      TO_NUMBER(TO_CHAR(zuora_rate_plan_charge.effective_start_date, 'YYYYMMDD'),'99999999')
                                                            AS effective_start_date_id,
      TO_NUMBER(TO_CHAR(zuora_rate_plan_charge.effective_end_date, 'YYYYMMDD'), '99999999')
                                                            AS effective_end_date_id,
      TO_NUMBER(TO_CHAR(zuora_rate_plan_charge.effective_start_month, 'YYYYMMDD'),'99999999')
                                                            AS effective_start_month_id,
      TO_NUMBER(TO_CHAR(zuora_rate_plan_charge.effective_end_month, 'YYYYMMDD'), '99999999')
                                                            AS effective_end_month_id,
      zuora_rate_plan_charge.unit_of_measure,
      zuora_rate_plan_charge.quantity,
      zuora_rate_plan_charge.mrr,
      zuora_rate_plan_charge.delta_tcv,
      zuora_rate_plan.rate_plan_name                        AS rate_plan_name,
      {{ product_category('zuora_rate_plan.rate_plan_name') }},
      {{ delivery('product_category')}},
      CASE
        WHEN lower(rate_plan_name) like '%support%'
          THEN 'Support Only'
        ELSE 'Full Service'
      END                                                   AS service_type,
      zuora_rate_plan_charge.discount_level,
      zuora_rate_plan_charge.segment                        AS rate_plan_charge_segment,
      zuora_rate_plan_charge.version                        AS rate_plan_charge_version,
      zuora_rate_plan_charge.charge_type
    FROM zuora_rate_plan
    INNER JOIN zuora_rate_plan_charge
      ON zuora_rate_plan.rate_plan_id = zuora_rate_plan_charge.rate_plan_id

)

{{ dbt_audit(
    cte_ref="base_charges",
    created_by="@msendal",
    updated_by="@msendal",
    created_date="2020-06-01",
    updated_date="2020-09-17"
) }}