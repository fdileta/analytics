WITH source AS (

    SELECT *
    FROM {{ source('sheetload', 'sales_funnel_targets_sales_territory') }}

), renamed AS (

    SELECT
      "KPI_Name"::VARCHAR                                   AS kpi_name,
      "Sales_Territory"::VARCHAR                            AS sales_territory,
      "Target"::VARCHAR                                     AS target,
      "Percent_Curve"::VARCHAR                              AS percent_curve,
      TO_TIMESTAMP(TO_NUMERIC("_UPDATED_AT"))::TIMESTAMP    AS last_updated_at
    FROM source

)

SELECT *
FROM renamed