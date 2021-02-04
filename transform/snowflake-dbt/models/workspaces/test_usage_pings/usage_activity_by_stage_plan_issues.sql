SELECT
  'usage_activity_by_stage.plan.issues' AS counter_name,
  COUNT(DISTINCT issues.author_id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
