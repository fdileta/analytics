SELECT
  'usage_activity_by_stage.create.projects_without_disable_overriding_approvers_per_merge_request' AS counter_name,
  COUNT(projects.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
WHERE
  (
    projects.disable_overriding_approvers_per_merge_request = FALSE OR projects.disable_overriding_approvers_per_merge_request IS NULL
  )
