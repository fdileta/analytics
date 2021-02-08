WITH source AS (

    SELECT *
    FROM "PREP".zuora.zuora_rate_plan_source

), with_product_category AS (

    SELECT *,
      CASE
  WHEN LOWER(rate_plan_name) LIKE '%gold%'
    THEN 'SaaS - Ultimate'
  WHEN LOWER(rate_plan_name) LIKE '%silver%'
    THEN 'SaaS - Premium'
  WHEN LOWER(rate_plan_name) LIKE '%ultimate%'
    THEN 'Self-Managed - Ultimate'
  WHEN LOWER(rate_plan_name) LIKE '%premium%'
    THEN 'Self-Managed - Premium'
  WHEN LOWER(rate_plan_name) LIKE 'bronze%'
    THEN 'SaaS - Bronze'
  WHEN LOWER(rate_plan_name) LIKE '%starter%'
    THEN 'Self-Managed - Starter'
  WHEN LOWER(rate_plan_name) LIKE 'gitlab enterprise edition%'
    THEN 'Self-Managed - Starter'
  WHEN rate_plan_name = 'Pivotal Cloud Foundry Tile for GitLab EE'
    THEN 'Self-Managed - Starter'
  WHEN LOWER(rate_plan_name) LIKE 'plus%'
    THEN 'Plus'
  WHEN LOWER(rate_plan_name) LIKE 'standard%'
    THEN 'Standard'
  WHEN LOWER(rate_plan_name) LIKE 'basic%'
    THEN 'Basic'
  WHEN rate_plan_name = 'Trueup'
    THEN 'Trueup'
  WHEN LTRIM(LOWER(rate_plan_name)) LIKE 'githost%'
    THEN 'GitHost'
  WHEN LOWER(rate_plan_name) LIKE '%quick start with ha%'
    THEN 'Support'
  WHEN TRIM(rate_plan_name) IN (
                                      'GitLab Service Package'
                                    , 'Implementation Services Quick Start'
                                    , 'Implementation Support'
                                    , 'Support Package'
                                    , 'Admin Training'
                                    , 'CI/CD Training'
                                    , 'GitLab Project Management Training'
                                    , 'GitLab with Git Basics Training'
                                    , 'Travel Expenses'
                                    , 'Training Workshop'
                                    , 'GitLab for Project Managers Training - Remote'
                                    , 'GitLab with Git Basics Training - Remote'
                                    , 'GitLab for System Administrators Training - Remote'
                                    , 'GitLab CI/CD Training - Remote'
                                    , 'InnerSourcing Training - Remote for your team'
                                    , 'GitLab DevOps Fundamentals Training'
                                    , 'Self-Managed Rapid Results Consulting'
                                    , 'Gitlab.com Rapid Results Consulting'
                                    )
    THEN 'Support'
  WHEN LOWER(rate_plan_name) LIKE 'gitlab geo%'
    THEN 'Other'
  WHEN LOWER(rate_plan_name) LIKE 'ci runner%'
    THEN 'Other'
  WHEN LOWER(rate_plan_name) LIKE 'discount%'
    THEN 'Other'
  WHEN TRIM(rate_plan_name) IN (
                                      '#movingtogitlab'
                                    , 'File Locking'
                                    , 'Payment Gateway Test'
                                    , 'Time Tracking'
                                    , '1,000 CI Minutes'
                                    , 'Gitlab Storage 10GB'
                                    )
    THEN 'Other'
  ELSE 'Not Applicable'
END AS product_category,
      CASE
  WHEN LOWER(product_category) LIKE '%saas%'
    THEN 'SaaS'
  WHEN LOWER(product_category) LIKE '%self-managed%'
    THEN 'Self-Managed'
  WHEN product_category IN (
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
  END AS delivery
    FROM source

)

{{ dbt_audit(
    cte_ref="with_product_category",
    created_by="@msendal",
    updated_by="@mcooperDD",
    created_date="2020-11-05",
    updated_date="2020-12-18"
) }}