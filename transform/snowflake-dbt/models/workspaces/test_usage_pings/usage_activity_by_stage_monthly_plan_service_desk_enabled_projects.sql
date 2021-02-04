SELECT
    'usage_activity_by_stage_monthly.plan.service_desk_enabled_projects' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_projects_dedupe_source.creator_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_projects_dedupe_source')}}
WHERE
    gitlab_dotcom_projects_dedupe_source.service_desk_enabled = TRUE AND gitlab_dotcom_projects_dedupe_source.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560'
