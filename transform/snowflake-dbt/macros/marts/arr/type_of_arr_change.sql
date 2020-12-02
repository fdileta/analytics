{%- macro type_of_arr_change(arr, previous_arr) -%}

   CASE
     WHEN {{ previous_arr }} = 0 AND {{ arr }} > 0 AND {{ days_between_arr }} IS NULL OR {{ days_between_arr }} >= 180
       THEN 'New'
     WHEN {{ arr }} = 0 AND {{ previous_arr }} > 0
       THEN 'Churn'
     WHEN {{ arr }} < {{ previous_arr }} AND {{ arr }} > 0
       THEN 'Contraction'
     WHEN {{ arr }} > {{ previous_arr }} AND {{ days_between_arr }} < 180
       THEN 'Expansion'
     WHEN {{ arr }} = {{ previous_arr }}
       THEN 'No Impact'
     ELSE NULL
   END                 AS type_of_arr_change

{%- endmacro -%}
