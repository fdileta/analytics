WITH source AS (

    SELECT *,
      RANK() OVER (PARTITION BY DATE_TRUNC('day', uploaded_at) ORDER BY uploaded_at DESC) AS rank
    FROM {{ source('gitlab_data_yaml', 'geo_zones') }}
    ORDER BY uploaded_at DESC

), intermediate AS (

    SELECT 
      geozones.value['title']::VARCHAR  AS geozone_title, 
      geozones.value['factor']::VARCHAR AS geozone_factor, 
      geozones.index                    AS geozone_index,
      additional_fields.key::VARCHAR    AS info_key,
      field_info.value::VARCHAR         AS field_value,
      uploaded_at
    FROM source,
    LATERAL FLATTEN(INPUT => parse_json(jsontext), OUTER => TRUE) geozones,
    LATERAL FLATTEN(INPUT => parse_json(geozones.value), OUTER => TRUE) additional_fields,
    TABLE(FLATTEN(input => additional_fields.value, RECURSIVE => TRUE))  field_info

), unioned AS (

    SELECT DISTINCT
      geozone_title,
      geozone_factor,
      'United States'              AS countries,
      field_value                  AS state_or_province,
      DATE_TRUNC(day, uploaded_at) AS uploaded_at
    FROM intermediate
    WHERE info_key IN ('states_or_provinces')

    UNION ALL 

    SELECT DISTINCT
      geozone_title,
      geozone_factor,
      field_value                 AS countries,
      NULL                        AS state_or_province,
      DATE_TRUNC(day, uploaded_at) AS uploaded_at
    FROM intermediate
    WHERE info_key IN ('countries')  
  
)

SELECT 
  {{ dbt_utils.surrogate_key(['geozone_title', 'geozone_factor', 'countries', 'state_or_province','geozone_factor']) }}        AS unique_key,
  unioned.*
FROM unioned


