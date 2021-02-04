SELECT
  'counts.projects' AS counter_name,
  COUNT(projects.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
