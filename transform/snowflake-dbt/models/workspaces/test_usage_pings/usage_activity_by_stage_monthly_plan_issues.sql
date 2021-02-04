SELECT
  'usage_activity_by_stage_monthly.plan.issues' AS counter_name,
  COUNT(DISTINCT issues.author_id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
WHERE
  issues.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560'
