WITH applications AS (

    SELECT *
    FROM  {{ ref ('greenhouse_applications') }}

), offers AS (

    SELECT * 
    FROM  {{ ref ('greenhouse_offers') }}

), job_posts AS (

    SELECT * 
    FROM  {{ ref ('greenhouse_job_posts') }}

), jobs AS (

    SELECT * 
    FROM  {{ ref ('greenhouse_jobs') }}

), greenhouse_departments AS (

    SELECT * 
    FROM  {{ ref ('greenhouse_departments') }}

), greenhouse_sources AS (

    SELECT * 
    FROM  {{ ref ('greenhouse_sources') }}

), cost_center AS (

    SELECT DISTINCT division, department
    FROM {{ref('cost_center_division_department_mapping')}}

)

SELECT 
    applications.application_id, 
    offer_id,
    candidate_id, 
    application_status,
    stage_name, 
    offer_status,
    applied_at                                                                      AS application_date,
    sent_at                                                                         AS offer_sent_date,
    resolved_at                                                                     AS offer_resolved_date,
    job_name,
    department_name,
    CASE WHEN lower(department_name) LIKE '%sales%' THEN 'Sales'
         WHEN department_name = 'Dev' THEN 'Engineering'
         WHEN department_name = 'Customer Success Management' THEN 'Sales'
         ELSE COALESCE(cost_center.division, department_name) END                   AS division,
    greenhouse_sources.source_name,
    greenhouse_sources.source_type,
    IFF(offer_status ='accepted',
            DATEDIFF('day', applications.applied_at, offers.resolved_at),
            NULL)                                                                   AS time_to_offer
FROM applications 
LEFT JOIN job_posts 
  ON job_posts.job_post_id = applications.job_post_id
LEFT JOIN jobs 
  ON job_posts.job_id = jobs.job_id
LEFT JOIN  greenhouse_departments 
  ON jobs.department_id = greenhouse_departments.department_id
  AND jobs.organization_id = greenhouse_departments.organization_id
LEFT JOIN greenhouse_sources 
  ON greenhouse_sources.source_id = applications.source_id 
LEFT JOIN offers 
  ON applications.application_id = offers.application_id
LEFT JOIN cost_center
  ON TRIM(greenhouse_departments.department_name)=TRIM(cost_center.department)



