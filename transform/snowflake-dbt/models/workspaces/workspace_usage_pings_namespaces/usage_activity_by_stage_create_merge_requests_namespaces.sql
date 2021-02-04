SELECT
    namespace_id,
    TO_DATE(CURRENT_DATE) AS run_day,
    COUNT(
        DISTINCT gitlab_dotcom_merge_requests_dedupe_source.author_id
    ) AS counter_value
FROM
    {{ref('gitlab_dotcom_merge_requests_dedupe_source')}}
LEFT JOIN
    {{ref('gitlab_dotcom_projects_dedupe_source')}} ON
        gitlab_dotcom_projects_dedupe_source.id = gitlab_dotcom_merge_requests_dedupe_source.target_project_id
LEFT JOIN
    {{ref('gitlab_dotcom_namespaces_dedupe_source')}} ON
        gitlab_dotcom_projects_dedupe_source.namespace_id = gitlab_dotcom_namespaces_dedupe_source.id
GROUP BY 1
