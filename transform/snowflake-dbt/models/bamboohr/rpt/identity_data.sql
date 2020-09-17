WITH identity_data AS (

    SELECT *
    FROM "ANALYTICS"."ANALYTICS_SENSITIVE"."BAMBOOHR_ID_EMPLOYEE_NUMBER_MAPPING"
    WHERE termination_date IS NULL
      
), country_breakdown AS (

    SELECT
        'country_breakdown' AS breakdown_type,
        country AS breakdown_column_1,
        NULL AS breakdown_column_2,  
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3
     
), region_breakdown AS(

    SELECT
        'region_breakdown' AS breakdown_type,
        region AS breakdown_column_1,
        NULL AS breakdown_column_2,
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3

), gender_breakdown AS(

    SELECT
        'gender_breakdown' AS breakdown_type,
        gender AS breakdown_columnn_1,
        NULL AS breakdown_column_2,
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3

), ethnicity_breakdown AS (  

    SELECT
        'ethnicity_breakdown' AS breakdown_type,
        ethnicity AS breakdown_column_1,
        NULL AS breakdown_column_2,
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3
  
), age_breakdown AS (
  
    SELECT
        'age_breakdown' AS breakdown_type,
        age_cohort AS breakdown_column_1,
        NULL AS breakdown_column_2,
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3 
  
), gender_country AS (

    SELECT
        'gender_region_breakout' AS breakdown_type,
        gender AS breakdown_column_1,
        country AS breakdown_column_2,
        COUNT(employee_id) AS total_employees
    FROM identity_data
    GROUP BY 1,2,3         

), ethnicity_country AS (
  
  SELECT
        'ethnicity_country_breakout' AS breakdown_type,
        ethnicity AS breakdown_column_1,
        country AS breakdown_column_2,    
       COUNT(employee_id) AS total_employees
  FROM identity_data
  GROUP BY 1,2,3

), UNIONED AS (

SELECT *
FROM country_breakdown

UNION ALL

SELECT *
FROM region_breakdown

UNION ALL

SELECT *
FROM gender_breakdown

UNION ALL

SELECT *
FROM ethnicity_breakdown

UNION ALL

SELECT *
FROM age_breakdown

UNION ALL

SELECT *
FROM gender_country

UNION ALL

SELECT *
FROM ethnicity_country

)

SELECT *
FROM UNIONED
