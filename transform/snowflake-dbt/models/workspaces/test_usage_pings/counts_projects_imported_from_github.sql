SELECT
    'counts.projects_imported_from_github' AS counter_name,
    COUNT(gitlab_dotcom_projects_dedupe_source.id) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
WHERE gitlab_dotcom_projects_dedupe_source.import_type = 'github'
