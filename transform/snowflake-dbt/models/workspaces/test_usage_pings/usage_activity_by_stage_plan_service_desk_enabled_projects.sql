SELECT
    'usage_activity_by_stage.plan.service_desk_enabled_projects' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_projects_dedupe_source.creator_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
WHERE gitlab_dotcom_projects_dedupe_source.service_desk_enabled = TRUE
