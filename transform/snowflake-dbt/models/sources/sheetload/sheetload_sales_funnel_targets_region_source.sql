WITH source AS (

    SELECT *
    FROM {{ source('sheetload', 'sales_funnel_targets_region') }}

), renamed AS (

    SELECT
      "Concat"::VARCHAR                                     AS fields_concatenated,
      "Region"::VARCHAR                                     AS region,
      "KPI_Name"::VARCHAR                                   AS kpi_name,
      "Target"::VARCHAR                                     AS target,
      "Percent_Curve"::VARCHAR                              AS percent_curve,
      TO_TIMESTAMP(TO_NUMERIC("_UPDATED_AT"))::TIMESTAMP    AS last_updated_at
    FROM source

)

SELECT *
FROM renamed