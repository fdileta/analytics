{% docs map_bizible_marketing_channel_path %}
 Intermediate table to expose the mapped marketing channel data.
{% enddocs %}

{% docs map_bizible_campaign_grouping %}
 Mapping table for Bizible marketing campaigns which groups the campaigns based on the touchpoint type, ad campaign name, parent campaign id, among other attributes. This generates the `bizible_itegrated_campaign_grouping`, `integrated_campaign_grouping`, `touchpoint_segment`, and `gtm_motion` mapping.
{% enddocs %}

{% docs map_crm_account %}
 Mapping table for dimension keys related to crm accounts so they can be reused in fact tables containing account ids.
{% enddocs %}

{% docs map_crm_opportunity %}
 Mapping table for dimension keys related to opportunities so they can be reused in fact tables containing quotes.
{% enddocs %}

{% docs map_ip_to_country %}
Table for mapping ip address ranges to location ids.
{% enddocs %}

{% docs map_license_subscription_account%}
Table with mapping keys for license_md5 to subscription_id to crm (Salesforce) account ids
{% enddocs %}

{% docs map_merged_crm_account%}

Table mapping current crm account ids to accounts merged in the past.

{% enddocs %}

{% docs map_product_tier %}

 Table for mapping Zuora Product Rate Plans to Product Tier, Delivery Type, and Ranking.

{% enddocs %}

{% docs map_namespace_internal %}

This View contains the list of ultimate parent namespace ids that are internal to gitlab. In the future this list should be sourced from an upstream data sources or determined based on billing account in customer db if possible.

{% enddocs %}

{% docs map_team_member_bamboo_gitlab_dotcom_gitlab_ops %}
Table for mapping GitLab team members across bambooHR, GitLab.com Postgres DB, and GitLab Ops

{% enddocs %}
