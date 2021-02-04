SELECT
  'usage_activity_by_stage.plan.projects' AS counter_name,
  COUNT(DISTINCT projects.creator_id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
