SELECT
    'counts.alert_bot_incident_issues' AS counter_name,
    COUNT(gitlab_dotcom_issues_dedupe_source.id) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_issues_dedupe_source')}}
WHERE gitlab_dotcom_issues_dedupe_source.author_id = 81
