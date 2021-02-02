
  SELECT *
  FROM {{ source('gitlab_dotcom', 'merge_requests') }}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
