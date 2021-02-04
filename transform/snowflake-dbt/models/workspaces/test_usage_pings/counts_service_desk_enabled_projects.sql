SELECT
  'counts.service_desk_enabled_projects' AS counter_name,
  COUNT(projects.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
WHERE projects.service_desk_enabled = TRUE
