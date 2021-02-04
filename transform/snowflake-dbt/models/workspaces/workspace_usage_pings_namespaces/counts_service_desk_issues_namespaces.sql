SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(issues.id) AS counter_value
FROM
  {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON
    namespaces.id = projects.namespace_id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
WHERE
  issues.project_id IN (
    SELECT
      projects.id
    FROM
      {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
    WHERE projects.service_desk_enabled = TRUE
  ) AND issues.author_id = 82 AND issues.confidential = TRUE
GROUP BY 1
