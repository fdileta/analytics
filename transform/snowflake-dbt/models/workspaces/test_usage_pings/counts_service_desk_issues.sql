SELECT
  'counts.service_desk_issues' AS counter_name,
  COUNT(issues.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues
WHERE
  issues.project_id IN (
    SELECT
      projects.id
    FROM
      {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
    WHERE projects.service_desk_enabled = TRUE
  ) AND issues.author_id = 82 AND issues.confidential = TRUE
