SELECT namespace_id, COUNT(issues.id) AS counter_value  FROM {{ref('gitlab_dotcom_issues_dedupe_source')}} AS issues  LEFT JOIN {{ref('gitlab_dotcom_projects_dedupe_source')}} AS projects ON projects.id = issues.project_id LEFT JOIN {{ref('gitlab_dotcom_namespaces_dedupe_source')}} AS namespaces ON projects.namespace_id = namespaces.id WHERE issues.author_id = 81 GROUP BY 1