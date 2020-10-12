WITH scorecards AS (

    SELECT *
    FROM "ANALYTICS"."GREENHOUSE"."GREENHOUSE_SCORECARDS_SOURCE"
  
), recruiting_xf AS (

    SELECT *
    FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."GREENHOUSE_RECRUITING_XF"

), users AS (

    SELECT *
    FROM "ANALYTICS"."GREENHOUSE"."GREENHOUSE_USERS_SOURCE"

), employee_directory AS (

    SELECT *
    FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."EMPLOYEE_DIRECTORY_INTERMEDIATE"

), asessment AS (

    SELECT *
    FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."GREENHOUSE_STAGE_INTERMEDIATE"
    WHERE application_stage = 'Take Home Assessment'
  
), discretionary_bonus AS (

    SELECT 
      bonus.employee_id,
      COUNT(*) AS total_discretionary_bonuses_within_6_months
    FROM "ANALYTICS"."ANALYTICS"."BAMBOOHR_DISCRETIONARY_BONUSES" bonus
    LEFT JOIN employee_directory 
      ON bonus.employee_id = employee_directory.employee_id
      AND bonus.bonus_date = employee_directory.date_actual
    WHERE bonus_type = 'Discretionary Bonus'
      AND discretionary_bonus <= 180 -- less 6 months  
    GROUP BY 1
  
), bamboo_mapping AS (

    SELECT *, DATEDIFF(day, hire_date, COALESCE(termination_date, CURRENT_DATE())) AS tenure
    FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."BAMBOOHR_ID_EMPLOYEE_NUMBER_MAPPING"
 
), scorecard_intermediate AS (

  SELECT
    scorecards.application_id,
        scorecards.scorecard_stage_name,
    interviewer_id,
    employee_directory.full_name AS interviewer,
    employee_directory.tenure_Days AS interviewer_tenure,
    employee_directory.job_role_modified AS interviewer_job_role,
    scorecard_overall_recommendation,
    scorecard_scheduled_interview_ended_at,
    scorecard_updated_at,
      recruiting_xf.division,
      recruiting_xf.department_name,
      recruiting_xf.source_type,
      recruiting_xf.source_name,
      recruiting_xf.job_name,
      recruiting_xf.application_status,
      recruiting_xf.application_date,
      recruiting_xf.offer_status,
      recruiting_xf.time_to_offer,
      recruiting_xf.is_hired_in_bamboo,
      IFF(asessment.application_id IS NULL,0,1) AS took_assessment,
      COUNT(interviewer_id) OVER (PARTITION BY scorecards.application_id) AS total_interviewers,
      bamboo_mapping.tenure AS hired_intervieweee_tenure,
      IFF(bamboo_mapping.termination_date IS NOT NULL,1,0) AS separated_interviewe,
       total_discretionary_bonuses_within_6_months,
      IFF(recruiting_xf.is_hired_in_bamboo = TRUE 
            AND total_discretionary_bonuses_within_6_months >0
            AND bamboo_mapping.tenure> 270,1,0) AS hired_and_active_for_nine_months_discretionary_bonus,  
      IFF(recruiting_xf.is_hired_in_bamboo = TRUE 
            AND bamboo_mapping.tenure> 270,1,0) AS hired_and_active_for_nine_months  
    FROM scorecards
    LEFT JOIN recruiting_xf
      ON scorecards.application_id = recruiting_xf.application_id
    LEFT JOIN  users
      ON users.user_id = scorecards.interviewer_id
    LEFT JOIN employee_directory
      ON employee_directory.employee_number = users.employee_id 
      AND DATE_TRUNC(day, scorecards.scorecard_scheduled_interview_ended_at) = employee_directory.date_actual
    LEFT JOIN asessment
      ON asessment.application_id = scorecards.application_id
    LEFT JOIN bamboo_mapping 
      ON bamboo_mapping.greenhouse_candidate_id = recruiting_xf.candidate_id
   LEFT JOIN discretionary_bonus
      ON discretionary_bonus.employee_id = bamboo_mapping.employee_id
    WHERE recruiting_xf.application_status NOT IN('active', 'converted')
    AND scorecard_stage_name = 'Team Interview'
    AND recruiting_xf.application_date BETWEEN '2019-01-01' AND '2019-12-31'

  
)

SELECT *
FROM scorecard_intermediate
