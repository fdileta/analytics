SELECT
    'usage_activity_by_stage.manage.issues_imported.phabricator' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_projects_dedupe_source.creator_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
WHERE
    gitlab_dotcom_projects_dedupe_source.import_type = 'phabricator' AND gitlab_dotcom_projects_dedupe_source.import_type IS NOT NULL
