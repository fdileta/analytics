<!-- Note: This is for initial review for Data team and will need to be moved to http://www-gitlab-com/sites/handbook/source/handbook/business-ops/data-team/data-catalog/ project to merge -->

Update the MR template with where it says `!update_here`
_---
layout: handbook-page-toc
title: "Update with handbook title"

---
<link rel="stylesheet" type="text/css" href="/stylesheets/biztech.css" />

## On this page

- TOC
{:toc}

{::options parse_block_html="true" /}

---
## <Update With Title Name>

<!-- !Update_here: Add description of the topic and goal -->

The goal of this page:

* Help you understand how to navigate through the [Dashboard](!update_here)
* Help you understand the data models used to create the dashboard.
* Have you asess your understanding by taking a certification most applicable to your role at GitLab.
    * To learn more about how to use the dashboard, take the [Dashboard user certification](!update_here).
    * To learn more about developing Sisense dashboards, take the [Dashboard Developer certification](!Update_here)
* And overall help everyone contribute!

### Quick Links
<div class="flex-row" markdown="0" style="height:80px">
  <a href="!update_here" class="btn btn-purple" style="width:33%;height:100%;margin:5px;float:left;display:flex;justify-content:center;align-items:center;">`!update_here with dashboard name`</a>
  <a href="https://www.youtube.com/watch?v=F4FwRcKb95w&feature=youtu.be" class="btn btn-purple" style="width:33%;height:100%;margin:5px;float:left;display:flex;justify-content:center;align-items:center;">Getting started using SiSense Discovery</a>
</div>

<style> #headerformat {
background-color: #6666c4; color: black; padding: 5px; text-align: center;
}
</style>
<h1 id="headerformat">Getting Started </h1>

To get started we want to make sure you understand:

* What KPIs/PIs are supported using this dashboard
* Key terms that will explain how we account for the metrics
* The data source behind the dashboard
* To explore further, you can create visual and analysis yourself in Sisense. A great way to start is using the Sisense Discovery tool. Want to get started in Sisense head [here](https://about.gitlab.com/handbook/business-ops/data-team/platform/periscope/).
* To go even deeper, you can explore data in snowflake. The benefit of exploring in Snowflake is you can join to additional information (i.e. other data sources. Additional information on exploring in Snowflake can be found [here](https://about.gitlab.com/handbook/business-ops/data-team/platform/#warehouse-access).


<style> #headerformat {
background-color: #6666c4; color: black; padding: 5px; text-align: center;
}
</style>
<h1 id="headerformat">Key Terms, Metrics, KPIs/PIs, and Key Field and Business Logic </h1>

<details>
<summary markdown='span'>
  Key Terms
</summary>
* `!Update_here with relevant handbook definitions`

</details>

<details>
<summary markdown='span'>
  Key Metrics, KPIs, and PIs
</summary>
*  `!Update_here with relevant KPI definitions`
</details>

<details>
<summary markdown='span'>
  Key Fields and Business Logic
</summary>
*  `!Update_here to include the following: Source system we capture data from, definitions for calculated fields in data models or definitions as defined by business`
</details>

<style> #headerformat {
background-color: #6666c4; color: black; padding: 5px; text-align: center;}
</style>
<h1 id="headerformat">Understanding the Data Sources and Data Models</h1>
<br>
```!Update_here to (1) identify data model used to create dashboard; (2) any relevant Sisense views/snippets users should know about; (3) what table/view/snippet should users use if they're looking to query data.`

This dashboard is created off the `!update_here with data model/sisense view`. `!update_here to provide explanation of data source`

To create your own dashboards off this model you'll simply be able to type the following in your query in Sisense:
>`!update_here with select statement to get data or view`


This data model takes into account the data models as seen in the Entity Relationship Diagram (ERD):

`!update_here with lucidchart embed`



<details>
<summary markdown='span'>
  dbt documentation
</summary>
* `Update_here to include GitLab dbt docs documentation`
</details>

<details>
<summary markdown='span'>
  Example Query
</summary>
`!Update_here with what the query's goal`
<br>
```
`!update with sisense query to achieve goal
```
</details>
<br>



<style> #headerformat {
background-color: #6666c4; color: black; padding: 5px; text-align: center;
}
</style>
<h1 id="headerformat">Additional Resources </h1>

<details>
<summary markdown='span'>
  Trusted Data Solution
</summary>
See overview at [Trusted Data Framework](https://about.gitlab.com/handbook/business-ops/data-team/direction/trusted-data/)

[dbt guide examples](https://about.gitlab.com/handbook/business-ops/data-team/platform/dbt-guide/#trusted-data-framework) for
details and examples on implementing further tests
</details>

<details>
<summary markdown='span'>
  EDM Enterprise Dimensional Model Validations
</summary>
The [(WIP) Enterprise Dimensional Model Validation Dashboard](https://app.periscopedata.com/app/gitlab/760445/WIP:-Enterprise-Dimensional-Model-Validation-Dashboard) reports on latest Enterprise Dimensional model test and runs.
</details>

<details>
<summary markdown='span'>
  RAW Source Data Pipeline validations
</summary>
[Data Pipeline Health Validations](https://app.periscopedata.com/app/gitlab/715938/Data-Pipeline-Health-Dashboard)
</details>


<details>
<summary markdown='span'>
  Solution Ownership
</summary>
`!Update_here with dashboard creator and other SMEs`
</details>

