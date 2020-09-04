WITH scorecards AS (

SELECT *
FROM "RAW"."GREENHOUSE"."SCORECARDS"

), recruiting_xf AS (

SELECT *
  FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."GREENHOUSE_RECRUITING_XF"

)

SELECT
    division,
    department_name,
    source_type,
    source_name,
    job_name,
    application_status,
    submitted_at,
    application_date,
    offer_status,
    time_to_offer,
    is_hired_in_bamboo,
    scorecards.application_id,
    overall_recommendation,
    IFF(completed_focus_attributes = 0, NULL, ROUND(completed_focus_attributes / total_focus_attributes, 2)) AS focused_attributes,
    stage_name
  FROM scorecards
  LEFT JOIN recruiting_xf
  ON scorecards.application_id = recruiting_xf.application_id
  WHERE application_status NOT IN('active', 'converted')
  AND stage_name = 'Team Interview'
  AND submitted_at BETWEEN '2019-01-01' AND '2019-12-31'

