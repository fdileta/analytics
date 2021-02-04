SELECT
    'usage_activity_by_stage.create.merge_requests' AS counter_name,
    COUNT(
        DISTINCT gitlab_dotcom_merge_requests_dedupe_source.author_id
    ) AS counter_value,
    TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_merge_requests_dedupe_source')}}