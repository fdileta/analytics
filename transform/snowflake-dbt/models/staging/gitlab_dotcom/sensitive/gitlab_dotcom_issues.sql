WITH source AS (

    SELECT *
    FROM {{ ref('gitlab_dotcom_issues_source') }}

)

SELECT *
FROM source
