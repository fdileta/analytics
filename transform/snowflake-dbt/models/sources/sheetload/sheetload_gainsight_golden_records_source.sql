WITH source AS (

    SELECT *
    FROM {{ source('sheetload', 'gainsight_golden_records') }}

)

SELECT *
FROM source
