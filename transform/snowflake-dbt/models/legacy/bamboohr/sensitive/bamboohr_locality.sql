WITH source AS (

    SELECT *
    FROM {{ ref ('bamboohr_id_employee_number_mapping_source') }}
    WHERE uploaded_at >= '2020-03-24'
    --1st time we started capturing locality

), intermediate AS (

    SELECT 
      employee_number,
      employee_id,
      locality                                                           AS original_locality,
      CASE
        WHEN locality IN ('US New England, United States',
                          'US Middle Atlantic, United States',
                          'US South Atlantic, United States', 
                          'US Pacific, United States',
                          'US Mountain, United States',
                          'US Central, United States')
          THEN SPLIT_PART(locality,',',1)
        ELSE locality END                                                 AS bamboo_locality,
      REGEXP_COUNT(bamboo_locality, ', ', 1)                              AS comma_count,
      CASE
        WHEN comma_count = 2 
          THEN TRIM(split_part(bamboo_locality,',',2))
        WHEN comma_count = 1 AND LEFT(bamboo_locality,3) != 'All' 
          THEN TRIM(split_part(bamboo_locality,',',1))
        ELSE NULL END                                                     AS state_or_province,
      CASE
        WHEN comma_count = 2 
          THEN TRIM(split_part(bamboo_locality,',',3))
        WHEN comma_count = 1
          THEN TRIM(split_part(bamboo_locality,',',2))
        ELSE NULL END                                                     AS country,
      IFF(comma_count = 0, bamboo_locality, NULL)                         AS geozone,
      DATE_TRUNC(day, uploaded_at)                                        AS updated_at
    FROM source
    WHERE locality IS NOT NULL

)
 
SELECT *
FROM intermediate

