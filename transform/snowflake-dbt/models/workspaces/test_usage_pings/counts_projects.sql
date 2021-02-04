SELECT
    'counts.projects' AS counter_name,
    COUNT(gitlab_dotcom_projects_dedupe_source.id) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_projects_dedupe_source')}}