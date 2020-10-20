{{ config({
    "materialized": "view"
    })
}}

{{ dbt_utils.union_relations(
    relations=[ref('sheetload_cert_customer_segmentation_dashboard_source'),
               ref('sheetload_cert_customer_segmentation_sql_source'),
               ref('sheetload_cert_product_geo_dashboard_source'),
               ref('sheetload_cert_product_geo_sql_source'),
               ref('sheetload_cert_product_geo_dashboard_user_source'),
               ref('sheetload_cert_customer_segmentation_dashboard_user_source')]
) }}

