{{ config({
    "materialized": "incremental",
    "unique_key": "user_id"
    })
}}

WITH source AS (

  SELECT *
  FROM {{ source('gitlab_dotcom','user_custom_attributes') }}
  {% if is_incremental() %}
  WHERE created_at IS NOT NULL
    AND updated_at >= (SELECT MAX(updated_at) FROM {{this}})
  {% endif %}

), renamed AS (
  
  SELECT
    user_id::NUMBER       AS user_id,
    created_at::TIMESTAMP AS created_at,
    updated_at::TIMESTAMP AS updated_at,
    key::VARCHAR          AS user_custom_key,
    value::VARCHAR        AS user_custom_value
  FROM source
  QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
  

)

SELECT *
FROM renamed
ORDER BY updated_at
