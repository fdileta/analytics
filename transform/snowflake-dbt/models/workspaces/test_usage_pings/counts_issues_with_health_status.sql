SELECT
  'counts.issues_with_health_status' AS counter_name,
  COUNT(issues.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
WHERE issues.health_status IS NOT NULL
