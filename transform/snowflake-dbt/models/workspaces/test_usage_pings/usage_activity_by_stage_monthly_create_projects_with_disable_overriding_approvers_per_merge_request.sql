SELECT
  'usage_activity_by_stage_monthly.create.projects_with_disable_overriding_approvers_per_merge_request' AS counter_name,
  COUNT(projects.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
WHERE
  projects.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560' AND projects.disable_overriding_approvers_per_merge_request = TRUE
