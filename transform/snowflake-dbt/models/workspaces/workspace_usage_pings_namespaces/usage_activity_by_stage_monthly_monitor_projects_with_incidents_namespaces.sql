SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(DISTINCT issues.project_id) AS counter_value
FROM
  {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
LEFT JOIN
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects ON
    projects.id = issues.project_id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON
    projects.namespace_id = namespaces.id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
WHERE
  issues.issue_type = 1 AND issues.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560'
GROUP BY 1
