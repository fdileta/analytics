SELECT
    namespace_id,
    TO_DATE(CURRENT_DATE) AS run_day,
    COUNT(gitlab_dotcom_projects_dedupe_source.id) AS counter_value
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
LEFT JOIN
    {{ref('gitlab_dotcom_namespaces_dedupe_source')}} ON
        gitlab_dotcom_namespaces_dedupe_source.id = gitlab_dotcom_projects_dedupe_source.namespace_id
WHERE
    gitlab_dotcom_projects_dedupe_source.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560' AND (
        gitlab_dotcom_projects_dedupe_source.disable_overriding_approvers_per_merge_request = FALSE OR gitlab_dotcom_projects_dedupe_source.disable_overriding_approvers_per_merge_request IS NULL
    )
GROUP BY 1
