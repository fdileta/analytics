SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(projects.id) AS counter_value
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON
    namespaces.id = projects.namespace_id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
GROUP BY 1
