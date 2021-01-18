{% docs prep_usage_ping %}
This data model is a prep model that supports a new dimension model, dim_usage_ping, that will replace PROD.legacy.version_usage_data, dim_usage_pings, version_usage_data_source, and version_raw_usage_data_source in the future . 

This is currently a WIP but inherits a lot of code from PROD.legacy.version_usage_data. See https://gitlab.com/gitlab-data/analytics/-/merge_requests/4064/diffs#bc1d7221ae33626053b22854f3ecbbfff3ffe633 for rationale. This curent version is for Sales team only. 

This is a sensitive model that should not be surfaced into Sisense because it contains IP Address. It also contains a mapping to remove the dependency on the IP Address. 

By the end of the data model, we have set up additional columns that clean up the data and ensures there is one SSOT for any given metric on a usage ping. 
{% enddocs %}


{% docs prep_usage_ping_full_name %}
This data model is a prep model that supports a future mapping data model, called map_usage_ping_information, that will join this model to the data model that is created from metrics.yml. 

This data model inherits a lot of code from the Sisense chart `All Usage Ping Metrics` (https://app.periscopedata.com/app/gitlab/658340/Usage-Ping-Exploration?widget=8727904&udv=0). It's purpose is to get all the available 
{% enddocs %}

{% docs prep_usage_ping_no_license_key_sales_fy21_q1 %}
This data model is a prep model that depends on prep_usage_ping and supports the creation of dim_usage_ping that will replace PROD.legacy.version_usage_data, dim_usage_pings, version_usage_data_source, and version_raw_usage_data_source in the future. 

This curent version is for Sales team only and contains the metrics outlined in the Sales FY21-Q1 request. In a future iteration, we will create a version of this that parses it by stage or groups. 

Ideally, the purpose of this data model is to unpack all the metrics from the `raw_usage_data_payload` column, strips all the sensitive data out, and has one value for each metric in that column. 
{% enddocs %}

{% docs prep_usage_ping_saas_dates %}
This data model is a prep model that contains the dates of the usage pings for the self-managed instances that powers our SaaS GitLab.com data model. 
{% enddocs %}

{% docs prep_usage_ping_subscription_mapped_sales_fy21_q1 %}
This data model is a prep model that depends on prep_usage_ping and supports the creation of dim_usage_ping that will replace PROD.legacy.version_usage_data, dim_usage_pings, version_usage_data_source, and version_raw_usage_data_source in the future. 

This curent version is for Sales team only and contains the metrics outlined in the Sales FY21-Q1 request. In a future iteration, we will create a version of this that parses it by stage or groups. 

Ideally, the purpose of this data model is to unpack all the metrics from the `raw_usage_data_payload` column, strips all the sensitive data out, and has one value for each metric in that column. 
{% enddocs %}
