{%- macro product_category(product_column, output_column_name = 'product_category') -%}

CASE
  WHEN LOWER({{product_column}}) LIKE '%gold%'
    THEN 'SaaS - Ultimate'
  WHEN LOWER({{product_column}}) LIKE '%silver%'
    THEN 'SaaS - Premium'
  WHEN LOWER({{product_column}}) LIKE '%ultimate%'
    THEN 'Self-Managed - Ultimate'
  WHEN LOWER({{product_column}}) LIKE '%premium%'
    THEN 'Self-Managed - Premium'
  WHEN LOWER({{product_column}}) LIKE 'bronze%'
    THEN 'SaaS - Bronze'
  WHEN LOWER({{product_column}}) LIKE '%starter%'
    THEN 'Self-Managed - Starter'
  WHEN LOWER({{product_column}}) LIKE 'gitlab enterprise edition%'
    THEN 'Self-Managed - Starter'
  WHEN {{product_column}} = 'Pivotal Cloud Foundry Tile for GitLab EE'
    THEN 'Self-Managed - Starter'
  WHEN LOWER({{product_column}}) LIKE 'plus%'
    THEN 'Plus'
  WHEN LOWER({{product_column}}) LIKE 'standard%'
    THEN 'Standard'
  WHEN LOWER({{product_column}}) LIKE 'basic%'
    THEN 'Basic'
  WHEN {{product_column}} = 'Trueup'
    THEN 'Trueup'
  WHEN LTRIM(LOWER({{product_column}})) LIKE 'githost%'
    THEN 'GitHost'
  WHEN LOWER({{product_column}}) LIKE '%quick start with ha%'
    THEN 'Support'
  WHEN TRIM({{product_column}}) IN (
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
  WHEN LOWER({{product_column}}) LIKE 'gitlab geo%'
    THEN 'Other'
  WHEN LOWER({{product_column}}) LIKE 'ci runner%'
    THEN 'Other'
  WHEN LOWER({{product_column}}) LIKE 'discount%'
    THEN 'Other'
  WHEN TRIM({{product_column}}) IN (
                                      '#movingtogitlab'
                                    , 'File Locking'
                                    , 'Payment Gateway Test'
                                    , 'Time Tracking'
                                    , '1,000 CI Minutes'
                                    , 'Gitlab Storage 10GB'
                                    )
    THEN 'Other'
  ELSE 'Not Applicable'
END AS {{output_column_name}}

{%- endmacro -%}
