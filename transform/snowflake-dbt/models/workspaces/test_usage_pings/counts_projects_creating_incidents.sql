SELECT 'counts.projects_creating_incidents' AS counter_name,  COUNT(DISTINCT issues.project_id) AS counter_value  FROM {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues WHERE issues.issue_type = 1