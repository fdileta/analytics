WITH source AS (

    SELECT *
	FROM {{ source('bamboohr', 'directory') }}
	
), intermediate AS (

    SELECT 
      value['id']::NUMBER 				        AS employee_id,
	    value['displayName']::VARCHAR 	    AS full_name,
      value['jobTitle']::VARCHAR 			    AS job_title,
	    value['supervisor']::VARCHAR 		    AS supervisor,
	    value['workEmail']::VARCHAR			    AS work_email,
      uploaded_at                         AS uploaded_at
    FROM source,
    LATERAL FLATTEN(INPUT => parse_json(jsontext), outer => true)

), final AS (

    SELECT *
    FROM intermediate
    WHERE work_email != 't2test@gitlab.com'
      AND (LOWER(full_name) NOT LIKE '%greenhouse test%'
            AND LOWER(full_name) NOT LIKE '%test profile%'
            AND LOWER(full_name) != 'test-gitlab')
      AND employee_id  NOT IN (42039, 42043)

    
)

SELECT *
FROM final
