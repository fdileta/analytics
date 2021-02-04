SELECT
  'counts.issues' AS counter_name,
  COUNT(issues.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
