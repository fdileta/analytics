WITH sfdc_account AS (

    SELECT *
    FROM {{ ref('sfdc_account_source') }}
    WHERE account_id IS NOT NULL

)

SELECT DISTINCT
  {{ dbt_utils.surrogate_key(['tsp_territory']) }}  AS dim_sales_territory_id,
  tsp_territory                                     AS sales_territory_name
FROM sfdc_account
WHERE tsp_territory IS NOT NULL

UNION ALL

SELECT
  '-1'                                              AS dim_sales_territory_id,
  '(Missing Sales Territory)'                       AS sales_territory_name
