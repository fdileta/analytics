SELECT
    'counts.projects_creating_incidents' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_issues_dedupe_source.project_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_issues_dedupe_source')}}
WHERE gitlab_dotcom_issues_dedupe_source.issue_type = 1
