SELECT
  'counts.groups' AS counter_name,
  COUNT(namespaces.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces
WHERE namespaces.type = 'Group'
