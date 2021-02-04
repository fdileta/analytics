SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(DISTINCT projects.creator_id) AS counter_value
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON
    namespaces.id = projects.namespace_id
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
WHERE
  projects.import_type = 'phabricator' AND projects.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560' AND projects.import_type IS NOT NULL
GROUP BY 1
