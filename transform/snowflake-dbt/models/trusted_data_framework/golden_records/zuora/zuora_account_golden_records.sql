WITH source AS (

    SELECT *
    FROM {{ source('sheetload','zuora_account_golden_records') }}

)

SELECT *
FROM source