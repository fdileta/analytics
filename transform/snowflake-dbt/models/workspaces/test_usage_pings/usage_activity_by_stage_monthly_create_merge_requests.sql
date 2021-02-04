SELECT
    'usage_activity_by_stage_monthly.create.merge_requests' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_merge_requests_dedupe_source.author_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM
    {{ref('gitlab_dotcom_merge_requests_dedupe_source')}}
WHERE
    gitlab_dotcom_merge_requests_dedupe_source.created_at BETWEEN '2020-11-17 19:22:32.723497' AND '2020-12-15 19:22:32.723560'
