{{config({
    "schema": "common"
  })
}}

WITH location_region AS (

    SELECT *
    FROM {{ ref('dim_location_region') }}

), maxmind_countries_source AS (

    SELECT *
    FROM {{ ref('sheetload_maxmind_countries_source') }}

), zuora_country_geographic_region AS (

    SELECT *
    FROM {{ ref('zuora_country_geographic_region') }}

), joined AS (

    SELECT

      geoname_id                                                AS dim_location_country_id,
      country_name                                              AS country_name,
      UPPER(country_iso_code)                                   AS iso_2_country_code,
      UPPER(iso_alpha_3_code)                                   AS iso_3_country_code,
      CASE
        WHEN continent_name IN ('Africa', 'Europe') THEN 'EMEA'
        WHEN continent_name IN ('North America')    THEN 'AMER'
        WHEN continent_name IN ('South America')    THEN 'LATAM'
        WHEN continent_name IN ('Oceania','Asia')   THEN 'APAC'
        ELSE 'Missing location_region_name'
       END                                                      AS location_geo_name_map

    FROM maxmind_countries_source
    LEFT JOIN  zuora_country_geographic_region
      ON UPPER(maxmind_countries_source.country_iso_code) = UPPER(zuora_country_geographic_region.iso_alpha_2_code)
    WHERE country_iso_code IS NOT NULL

), final AS (

    SELECT
      joined.*,
      location_region.dim_location_region_id
    FROM joined
    LEFT JOIN location_region
      ON joined.location_geo_name_map = location_region.location_region_name

)

{{ dbt_audit(
    cte_ref="final",
    created_by="@m_walker",
    updated_by="@mcooperDD",
    created_date="2020-08-25",
    updated_date="2020-12-15"
) }}
