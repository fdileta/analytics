SELECT
  namespaces_xf.namespace_id,
  TO_DATE(CURRENT_DATE) AS run_day,
  COUNT(namespaces.id) AS counter_value
FROM
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces
LEFT JOIN
  {{ref('gitlab_dotcom_namespaces_xf')}} AS namespaces_xf ON
    namespaces.id = namespaces_xf.namespace_id
WHERE namespaces.type = 'Group' GROUP BY 1
