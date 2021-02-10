WITH source AS (

    SELECT *
    FROM {{ ref('gitlab_dotcom_programming_languages_dedupe_source') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _uploaded_at DESC) = 1

), renamed AS (

    SELECT
      id::NUMBER                       AS programming_language_id,
      name::VARCHAR                     AS programming_language_name
    FROM source

)

SELECT *
FROM renamed
