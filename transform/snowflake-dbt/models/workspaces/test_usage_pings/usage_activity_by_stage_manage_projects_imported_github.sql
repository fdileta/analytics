SELECT
  'usage_activity_by_stage.manage.projects_imported.github' AS counter_name,
  COUNT(DISTINCT projects.creator_id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM
  {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects
WHERE projects.import_type = 'github' AND projects.import_type IS NOT NULL
