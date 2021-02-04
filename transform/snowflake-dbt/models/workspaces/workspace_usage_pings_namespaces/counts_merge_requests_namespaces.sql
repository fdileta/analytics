SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(merge_requests.id) AS counter_value
FROM
  {{ref('gitlab_dotcom_merge_requests_dedupe_source')}} AS merge_requests
LEFT JOIN
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects ON
    projects.id = merge_requests.target_project_id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON
    projects.namespace_id = namespaces.id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
GROUP BY 1
