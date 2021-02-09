WITH source AS (
    
    SELECT *
    FROM {{ ref('geozones_yaml_source') }}

), final AS (

    SELECT
      unique_key,
      geozone_title,
      countries,
      state_or_province,
      geozone_factor,
      IFF(uploaded_at ='2021-01-04','2021-01-01', uploaded_at)                                      AS valid_from_date,
    ---we started capturing data on 2021.01.04 but defaulting this to 2021.01.01 for downstream models
      LAG(DATEADD(day,-1,uploaded_at)) OVER (PARTITION BY unique_key ORDER BY uploaded_at DESC)     AS valid_to_date
    FROM source

)

SELECT *
FROM final