SELECT
  'usage_activity_by_stage.monitor.projects_with_incidents' AS counter_name,
  COUNT(DISTINCT issues.project_id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues WHERE issues.issue_type = 1
