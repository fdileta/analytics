{{ config({
    "materialized": "incremental",
    "unique_key": "resource_label_event_id"
    })
}}

WITH source AS (

  SELECT *
  FROM {{ source('gitlab_dotcom', 'resource_label_events') }}
    {% if is_incremental() %}
      WHERE created_at >= (SELECT MAX(created_at) FROM {{this}} WHERE created_at < CURRENT_TIMESTAMP)
    {% endif %}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _uploaded_at DESC) = 1

)

, renamed AS (

    SELECT
      id                                             AS resource_label_event_id,
      action::NUMBER                                AS action_type_id,
      {{ resource_event_action_type('action') }}     AS action_type,
      issue_id::NUMBER                              AS issue_id,
      merge_request_id::NUMBER                      AS merge_request_id,
      epic_id::NUMBER                               AS epic_id,
      label_id::NUMBER                              AS label_id,
      user_id::NUMBER                               AS user_id,
      created_at::TIMESTAMP                          AS created_at,
      cached_markdown_version::VARCHAR               AS cached_markdown_version,
      reference::VARCHAR                             AS referrence,
      reference_html::VARCHAR                        AS reference_html  
    FROM source

)

SELECT *
FROM renamed
