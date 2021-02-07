{%- macro map_delivery(column_name) -%}

  CASE
  WHEN LOWER({{column_name}}) LIKE '%saas%'
    THEN 'SaaS'
  WHEN LOWER({{column_name}}) LIKE '%self-managed%'
    THEN 'Self-Managed'
  WHEN {{column_name}} IN      (
                                        'Basic'
                                      , 'GitHost'
                                      , 'Other'
                                      , 'Plus'
                                      , 'Standard'
                                      , 'Support'
                                      , 'Trueup'
                                      )
    THEN 'Others'
  ELSE NULL
  END

{% endmacro %}
