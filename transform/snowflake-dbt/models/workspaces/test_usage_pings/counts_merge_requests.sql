SELECT
  'counts.merge_requests' AS counter_name,
  COUNT(merge_requests.id) AS counter_value,
  TO_DATE(CURRENT_DATE) AS run_day
FROM {{ref('gitlab_dotcom_merge_requests_dedupe_source')}} AS merge_requests
