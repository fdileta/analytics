{% docs sales_fy21_q1_requested_metrics %}
This macro contains the [list of metrics that the Sales CS team requested on FY21-Q1](https://docs.google.com/spreadsheets/d/1ZR7duYmjQ8x86iAJ1dCix88GTtPlOyNwiMgeG_85NiA/edit?ts=5fea3398#gid=0). 

This macro is used to support data models that the sales team is requesting these metrics in. 
{% enddocs %}

{% docs smau_gmau_metrics %}
This macro filters the information from the data model [sheetload_usage_ping_metrics_sections](https://dbt.gitlabdata.com/#!/model/model.gitlab_snowflake.sheetload_usage_ping_metrics_sections_source) to retrieve the latest list of smau and gmau metrics. 

This macro can be used in models to easily lift the columns necessary for any tables wishing to have a list of these metric values. 
{% enddocs %}

{% docs stage_mapping %}
This macro takes in a product stage name, such as 'Verify', and returns a SQL aggregation statement that sums the number of users using that stage, based on the ping data. Product metrics are mapped to stages using the [ping_metrics_to_stage_mapping_data.csv](https://gitlab.com/gitlab-data/analytics/blob/master/transform/snowflake-dbt/data/ping_metrics_to_stage_mapping_data.csv).
Used in:
{% enddocs %}
