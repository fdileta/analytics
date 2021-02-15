WITH source AS (

    SELECT *
    FROM {{ ref('location_factors_yaml_historical') }}

), max_date AS (

    SELECT *
    FROM source
    WHERE snapshot_date = (SELECT max(valid_from_date) FROM source)

)

SELECT *
FROM max_date