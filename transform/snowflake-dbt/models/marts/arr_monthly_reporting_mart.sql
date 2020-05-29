WITH charges_base AS (

    SELECT *
    FROM {{ ref('charges_base') }}

), dim_dates AS (

   SELECT *
   FROM {{ ref('dim_dates') }}

), charges_month_by_month AS (

  SELECT
    charges_base.*,
    dim_dates.date_id,
    dateadd('month', -1, dim_dates.date_actual)  AS reporting_month
  FROM charges_base
  INNER JOIN dim_dates
    ON charges_base.effective_start_date_id <= dim_dates.date_id
    AND (charges_base.effective_end_date_id > dim_dates.date_id OR charges_base.effective_end_date_id IS NULL)
    AND dim_dates.day_of_month = 1
  WHERE subscription_status NOT IN ('Draft', 'Expired')
    AND mrr IS NOT NULL
    AND mrr != 0
)

SELECT
  --primary_key
  {{ dbt_utils.surrogate_key('reporting_month', 'subscription_name_slugify', 'product_category', 'unit_of_measure') }}
                               AS primary_key,

  --date info
  reporting_month,
  subscription_start_month,
  subscription_end_month,

  --account info
  zuora_account_id,
  zuora_sold_to_country,
  zuora_account_name,
  zuora_account_number,
  crm_id,
  ultimate_parent_account_id,
  ultimate_parent_account_name,
  ultimate_parent_billing_country,

  --subscription info
  subscription_name_slugify,
  subscription_status,

  --charge info
  product_category,
  delivery,
  service_type,
  charge_type,
  unit_of_measure,
  array_agg(product_name)       AS product_name,
  array_agg(rate_plan_name)     AS rate_plan_name,
  SUM(mrr)                      AS mrr,
  SUM(arr)                      AS arr,
  SUM(quantity)                 AS quantity
FROM charges_month_by_month
{{ dbt_utils.group_by(n=19) }}
