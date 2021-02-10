WITH source AS (

    SELECT *
    FROM {{ ref('gitlab_dotcom_experiments_dedupe_source') }}

), renamed AS (

    SELECT
      id::NUMBER    AS experiment_id,
      name::VARCHAR AS experiment_name
    FROM source
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _uploaded_at DESC) = 1

)

SELECT *
FROM renamed
