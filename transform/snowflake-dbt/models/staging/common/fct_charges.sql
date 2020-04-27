WITH zuora_rate_plan AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_source') }}

), zuora_rate_plan_charge AS (

    SELECT *
    FROM {{ ref('zuora_rate_plan_charge_source') }}

), zuora_invoice_item AS (

    SELECT *
    FROM {{ ref('zuora_invoice_item_source') }}

), zuora_invoice AS (

    SELECT *
    FROM {{ ref('zuora_invoice_source') }}

), base_charges AS (

    SELECT
      zuora_rate_plan_charge.rate_plan_charge_id        AS charge_id,
      zuora_rate_plan_charge.product_id,
      zuora_rate_plan.subscription_id,
      zuora_rate_plan_charge.account_id,
      zuora_rate_plan_charge.rate_plan_charge_number,
      zuora_rate_plan_charge.rate_plan_charge_name,
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
      zuora_rate_plan.rate_plan_name                    AS rate_plan_name,
      {{ product_category('zuora_rate_plan.rate_plan_name') }},
      {{ delivery('product_category')}},
      zuora_rate_plan_charge.discount_level,
      zuora_rate_plan_charge.segment                    AS rate_plan_charge_segment,
      zuora_rate_plan_charge.version                    AS rate_plan_charge_version
    FROM zuora_rate_plan
    INNER JOIN zuora_rate_plan_charge
      ON zuora_rate_plan.rate_plan_id = zuora_rate_plan_charge.rate_plan_id

), final AS (

    SELECT
      base_charges.*
    FROM base_charges
    INNER JOIN zuora_invoice_item AS invoice_item_source
      ON base_charges.charge_id = invoice_item_source.rate_plan_charge_id
    INNER JOIN zuora_invoice AS invoice_source
      ON invoice_item_source.invoice_id = invoice_source.invoice_id
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY
          rate_plan_charge_number,
          rate_plan_charge_segment
        ORDER BY
          rate_plan_charge_version DESC,
          service_start_date DESC)= 1

)

SELECT *
FROM final