{%- set smau_metrics = dbt_utils.get_query_results_as_dict(
    "SELECT
       REPLACE(periscope_metrics_name, '.', '_')                                    AS name,
       'raw_usage_data_payload[''' || REPLACE(metrics_path, '.', '''][''') || ''']' AS path
    FROM " ~ ref('fct_key_xmau_metrics') ~
    " WHERE is_smau"
    )
-%}

WITH prep_usage_ping AS (

    SELECT *
    FROM {{ ref('prep_usage_ping_subscription_mapped') }}
    WHERE license_md5 IS NOT NULL

), pivoted AS (

    SELECT 

    {{ default_usage_ping_information() }}

    -- subscription_info
    is_usage_ping_license_in_licenseDot,
    dim_license_id,
    dim_subscription_id,
    is_license_mapped_to_subscription,
    is_license_subscription_id_valid,
    dim_crm_account_id,
    dim_parent_crm_account_id,

    {%- for metric in smau_metrics.PATH %}
    {{ metric }} AS {{ smau_metrics.NAME[loop.index0] }}
    {%- if not loop.last %},{% endif -%}
    {% endfor %}

    FROM prep_usage_ping

)

{{ dbt_audit(
    cte_ref="pivoted",
    created_by="@ischweickartDD",
    updated_by="@ischweickartDD",
    created_date="2021-03-10",
    updated_date="2021-03-10"
) }}