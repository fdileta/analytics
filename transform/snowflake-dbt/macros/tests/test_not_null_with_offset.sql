{% macro test_not_null_with_offset(model, offset_column, offset_period, offset_value, column_name) %}

WITH parent AS (

    SELECT
        {{ column_name }} AS column_name

    FROM {{ model }}
    WHERE {{ offset_column}} < DATEADD({{ offset_period}}, -{{offset_value}}, CURRENT_DATE)

)

SELECT COUNT(*)
FROM parent
WHERE column_name IS NULL

{% endmacro %}
