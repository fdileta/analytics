SELECT
    'usage_activity_by_stage.manage.projects_imported.bitbucket_server' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_projects_dedupe_source.creator_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
WHERE
    gitlab_dotcom_projects_dedupe_source.import_type = 'bitbucket_server' AND gitlab_dotcom_projects_dedupe_source.import_type IS NOT NULL
