WITH source AS (

    SELECT *
    FROM {{ source('sheetload', 'pricing_email_list') }}

)

SELECT *
FROM source
