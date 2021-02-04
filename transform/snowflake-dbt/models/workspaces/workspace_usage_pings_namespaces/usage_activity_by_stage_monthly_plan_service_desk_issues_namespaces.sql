SELECT
    namespace_id,
    TO_DATE(CURRENT_DATE) AS run_day,
    COUNT(gitlab_dotcom_issues_dedupe_source.id) AS counter_value
FROM
    {{ref('gitlab_dotcom_issues_dedupe_source')}}
LEFT JOIN
    {{ref('gitlab_dotcom_projects_dedupe_source')}} ON
        gitlab_dotcom_projects_dedupe_source.id = gitlab_dotcom_issues_dedupe_source.project_id
LEFT JOIN
    {{ref('gitlab_dotcom_namespaces_dedupe_source')}} ON
        gitlab_dotcom_projects_dedupe_source.namespace_id = gitlab_dotcom_namespaces_dedupe_source.id
WHERE
    gitlab_dotcom_issues_dedupe_source.author_id = 82 AND gitlab_dotcom_issues_dedupe_source.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560'
GROUP BY 1
