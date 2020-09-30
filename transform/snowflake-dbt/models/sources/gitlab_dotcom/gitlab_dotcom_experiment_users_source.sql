WITH source AS (

    SELECT *
    FROM {{ source('gitlab_dotcom', 'experiment_users') }}

), renamed AS (

    SELECT
      created_at::TIMESTAMP AS created_at,
      experiment_id::NUMBER AS experiment_id,
      id::NUMBER            AS experiment_user_id,
      group_type::NUMBER    AS group_type,
      updated_at::TIMESTAMP AS updated_at,
      user_id::NUMBER       AS user_id
    FROM source

)

SELECT *
FROM renamed