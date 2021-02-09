{{ simple_cte([
    ('locality','bamboohr_locality'),
    ('location_factor_yaml','location_factors_yaml_historical'),
    ('geozones_yaml','geozones_yaml'),
    ('temporary_sheetload', 'sheetload_location_factor_temporary_2020_december')
]) }}

, location_factor_yaml_everywhere_else AS (

    SELECT *
    FROM location_factor_yaml
    WHERE LOWER(area) LIKE '%everywhere else%'

), location_factor_mexico AS (

    SELECT *
    FROM location_factor_yaml
    WHERE country ='Mexico'
      AND area IN ('Everywhere else','All')

), geozones_region AS (

    SELECT DISTINCT 
      geozone_title, 
      geozone_factor, 
      valid_from_date,
      valid_to_date
    FROM geozones_yaml

), geozones_countries AS (

    SELECT DISTINCT 
      countries, 
      geozone_factor, 
      valid_from_date,
      valid_to_date
    FROM geozones_yaml
    WHERE state_or_province IS NULL
      AND countries != 'United States'

), geozones_states AS (

    SELECT *
    FROM geozones_yaml
    WHERE state_or_province IS NOT NULL

), temporary_sheetload AS (

    SELECT *
    FROM  {{ ref('sheetload_location_factor_temporary_2020_december') }}

), final AS (

    SELECT 
      locality.*,
      IFF(DATE_TRUNC(month, updated_at) = '2020-12-01',
          temporary_sheetload.location_factor,
          COALESCE(location_factor_yaml.location_factor/100, 
              location_factor_yaml_everywhere_else.location_factor/100,
              location_factor_mexico.location_factor/100))              AS yaml_location_factor,
      COALESCE(geozones_region.geozone_factor,
               geozones_countries.geozone_factor,
               geozones_states.geozone_factor)                          AS geozone_location_factor
    FROM locality
    LEFT JOIN location_factor_yaml
      ON LOWER(locality.bamboo_locality) = LOWER(CONCAT(location_factor_yaml.area,', ', location_factor_yaml.country))
      AND locality.updated_at = location_factor_yaml.snapshot_date
    LEFT JOIN location_factor_yaml_everywhere_else
      ON LOWER(locality.bamboo_locality) = LOWER(CONCAT(location_factor_yaml_everywhere_else.area,', ', location_factor_yaml_everywhere_else.country))
      AND locality.updated_at = location_factor_yaml_everywhere_else.snapshot_date
    --The naming convention for Mexico is all in bamboohr and everywhere else in the location factor yaml file accounting for these cases by making this the last coalesce
    LEFT JOIN location_factor_mexico
      ON IFF(locality.bamboo_locality LIKE '%Mexico%', 'Mexico',NULL) = location_factor_mexico.country

    --with the move to geozones -- we first look to map on geozone title, then country in the case title doesn't exist, then states  
   LEFT JOIN geozones_region
      ON locality.geozone = geozones_region.geozone_title
      AND locality.updated_at BETWEEN geozones_region.valid_from_date AND geozones_region.valid_to_date
    LEFT JOIN geozones_countries
      ON locality.country = geozones_countries.countries
      AND locality.updated_at BETWEEN geozones_countries.valid_from_date AND geozones_countries.valid_to_date
    LEFT JOIN geozones_states
      ON locality.state_or_province = geozones_states.state_or_province
      AND locality.updated_at BETWEEN geozones_states.valid_from_date AND geozones_states.valid_to_date
     LEFT JOIN temporary_sheetload
      ON locality.employee_number = temporary_sheetload.employee_number
      AND DATE_TRUNC(month, locality.updated_at) = '2020-12-01'
)

SELECT *,
  IFF(updated_at <='2020-12-31', yaml_location_factor, geozone_location_factor) AS location_factor
  ---prior 2021 we were using the location factor yaml file, and 2021 going forward we moved to using geo-zones
FROM final
