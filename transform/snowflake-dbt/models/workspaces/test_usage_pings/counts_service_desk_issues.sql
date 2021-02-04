SELECT
    'counts.service_desk_issues' AS counter_name,
    COUNT(gitlab_dotcom_issues_dedupe_source.id) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_issues_dedupe_source')}}
WHERE
    gitlab_dotcom_issues_dedupe_source.project_id IN (
        SELECT
            gitlab_dotcom_projects_dedupe_source.id
        FROM
            {{ref('gitlab_dotcom_projects_dedupe_source')}}
        WHERE gitlab_dotcom_projects_dedupe_source.service_desk_enabled = TRUE
    ) AND gitlab_dotcom_issues_dedupe_source.author_id = 82 AND gitlab_dotcom_issues_dedupe_source.confidential = TRUE
