WITH gitlab_db_users AS (
  
    SELECT *
    FROM {{ source('gitlab_dotcom', 'users') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
  
), sfdc_users AS (
  
    SELECT *
    FROM {{ ref('sfdc_users') }}

), dim_sfdc_contact AS (
    
    SELECT *
    FROM {{ ref('dim_crm_persons') }}
    WHERE sfdc_record_type = 'contact'
  
), sfdc_contact_ AS (
    
    SELECT
      contact_id,
      TRIM(contact_name)                                                       AS full_name,
      SPLIT_PART(TRIM(contact_name), ' ', 1)                                   AS first_name,
      ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(TRIM(contact_name), ' '), 1, 10), ' ') AS last_name,
      TRIM(contact_email)                                                      AS email
    FROM {{ ref('sfdc_contact_source') }}
    WHERE TRIM(contact_email) IS NOT NULL

), fct_charges AS (
  
    SELECT *
    FROM {{ ref('fct_charges') }}
    WHERE charge_type = 'Recurring'

), dim_accounts AS (
    
    SELECT *
    FROM {{ ref('dim_accounts') }}
  
), dim_subscriptions AS (
  
    SELECT *
    FROM {{ ref('dim_subscriptions') }}
    WHERE subscription_status NOT IN ('Draft','Expired')

), zuora_contact AS (
  
    SELECT *
    FROM {{ ref('zuora_contact') }}

), gitlab_dotcom_namespaces_xf AS (

    SELECT *
    FROM {{ ref('gitlab_dotcom_namespaces_xf') }}

), dim_customers AS (
  
    SELECT *
    FROM {{ ref('dim_customers') }}
  
), memberships AS (

    SELECT
      *,
      DECODE(gitlab_dotcom_memberships.access_level,
             10, 'Guest',
             20, 'Reporter',
             30, 'Developer',
             40, 'Maintainer',
             50, 'Owner'
      ) AS gitlab_user_access_level
    FROM {{ ref('gitlab_dotcom_memberships') }}
  
), subscription_to_latest_namespace AS (
  
    SELECT *
    FROM {{ ref('customers_db_orders') }}
    WHERE gitlab_namespace_id IS NOT NULL
      AND subscription_name IS NOT NULL
      AND order_is_trial = FALSE
    QUALIFY ROW_NUMBER() OVER(PARTITION BY subscription_name ORDER BY order_created_at DESC) = 1
  
), sfdc_contact AS (

    SELECT
      dim_sfdc_contact.sfdc_record_id,
      sfdc_contact_.full_name,
      sfdc_contact_.first_name,
      sfdc_contact_.last_name,
      sfdc_contact_.email,
      dim_sfdc_contact.has_opted_out_email  AS sfdc_has_opted_out_email,
      dim_sfdc_contact.account_id
    FROM dim_sfdc_contact
    LEFT JOIN sfdc_contact_
      ON sfdc_contact_.contact_id = dim_sfdc_contact.sfdc_record_id

), users_notification_contact AS (
  
    SELECT
      id                                                               AS user_id,
      TRIM(name)                                                       AS full_name,
      SPLIT_PART(TRIM(name), ' ', 1)                                   AS first_name,
      ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(TRIM(name), ' '), 1, 10), ' ') AS last_name,
      username,
      TRIM(notification_email)                                         AS email,
      state,
      role
    FROM gitlab_db_users
    WHERE notification_email IS NOT NULL AND TRIM(notification_email) != ''
    
), users_public_contact AS (

    SELECT
      id                                                                AS user_id,
      TRIM(name)                                                        AS full_name,
      SPLIT_PART(TRIM(name), ' ', 1)                                    AS first_name,
      ARRAY_TO_STRING(ARRAY_SLICE(SPLIT(TRIM(name), ' '), 1, 10), ' ')  AS last_name,
      username,
      TRIM(public_email)                                                AS email,
      state,
      role
    FROM gitlab_db_users
    WHERE TRIM(public_email) IS NOT NULL AND TRIM(public_email) != ''
  
), joined AS (
  
    SELECT DISTINCT
      fct_charges.product_category,
      fct_charges.delivery,
      dim_accounts.crm_id,
      dim_customers.ultimate_parent_account_id,
      dim_subscriptions.subscription_id,
      dim_subscriptions.subscription_name,
      dim_subscriptions.subscription_name_slugify,
      dim_accounts.sold_to_country                                          AS zuora_sold_to_country,
      dim_accounts.billing_contact_id,
      subscription_to_latest_namespace.gitlab_namespace_id::INT             AS gitlab_namespace_id,
      gitlab_dotcom_namespaces_xf.namespace_is_internal                     AS namespace_is_internal,
      dim_customers.customer_name,
      dim_customers.ultimate_parent_account_name,
      dim_customers.ultimate_parent_account_segment,
      sfdc_users.name                                                       AS account_owner_name,
      sfdc_users.email                                                      AS account_owner_email,
      LOWER(fct_charges.product_category)                                   AS zuora_product_category,
      LOWER(gitlab_dotcom_namespaces_xf.plan_title)                         AS gitlab_product_category

    FROM dim_accounts
    INNER JOIN dim_subscriptions
      ON dim_accounts.account_id = dim_subscriptions.account_id
    INNER JOIN fct_charges
      ON dim_subscriptions.subscription_id = fct_charges.subscription_id
    LEFT JOIN dim_customers
      ON dim_customers.crm_id = dim_accounts.crm_id
    LEFT JOIN sfdc_users
      ON dim_customers.account_owner_id = sfdc_users.id
    LEFT JOIN subscription_to_latest_namespace
      ON dim_subscriptions.subscription_name = subscription_to_latest_namespace.subscription_name
      AND fct_charges.delivery = 'SaaS'
    LEFT JOIN gitlab_dotcom_namespaces_xf
      ON gitlab_dotcom_namespaces_xf.namespace_id::VARCHAR = subscription_to_latest_namespace.gitlab_namespace_id::VARCHAR
    WHERE 
      (
        fct_charges.effective_start_month <= DATE_TRUNC('month', CURRENT_DATE)
        AND (fct_charges.effective_end_month > DATE_TRUNC('month', CURRENT_DATE) OR fct_charges.effective_end_month IS NULL)
      )
      
), with_billing_contact AS (

    SELECT
      joined.crm_id,
      joined.ultimate_parent_account_id,
      joined.subscription_id,
      joined.subscription_name,
      joined.gitlab_namespace_id,
      joined.namespace_is_internal,
      joined.customer_name,
      joined.ultimate_parent_account_name,
      joined.ultimate_parent_account_segment,
      joined.account_owner_name,
      joined.account_owner_email,
      joined.zuora_product_category,
      joined.gitlab_product_category,
      joined.delivery,
      joined.zuora_sold_to_country,
      NULL                                                                              AS gitlab_user_access_level,
      joined.billing_contact_id                                                         AS account_billing_contact_id,
      NULL                                                                              AS gitlab_user_id,
      NULL                                                                              AS sfdc_record_id,
      NULL                                                                              AS sfdc_has_opted_out_email,
      zuora_contact.first_name || ' ' ||  zuora_contact.last_name                       AS full_name,
      zuora_contact.first_name                                                          AS first_name,
      zuora_contact.last_name                                                           AS last_name,
      IFF(TRIM(zuora_contact.work_email) = '', NULL, TRIM(zuora_contact.work_email))    AS email,
      TRUE                                                                              AS is_account_billing_contact,
      FALSE                                                                             AS is_gitlab_user_notification_contact,
      FALSE                                                                             AS is_gitlab_user_public_contact,
      FALSE                                                                             AS is_sfdc_contact

    FROM joined
    INNER JOIN zuora_contact
      ON billing_contact_id = zuora_contact.contact_id

), with_gitlab_namespace_info AS (

    SELECT DISTINCT
      joined.crm_id,
      joined.ultimate_parent_account_id,
      joined.subscription_id,
      joined.subscription_name,
      memberships.namespace_id::INT                           AS gitlab_namespace_id,
      gitlab_dotcom_namespaces_xf.namespace_is_internal       AS namespace_is_internal,
      joined.customer_name,
      joined.ultimate_parent_account_name,
      joined.ultimate_parent_account_segment,
      joined.account_owner_name,
      joined.account_owner_email,
      joined.zuora_product_category,
      IFF(memberships.ULTIMATE_PARENT_PLAN_TITLE IS NULL, 'free', LOWER(memberships.ULTIMATE_PARENT_PLAN_TITLE))
                                                              AS gitlab_product_category,
      joined.delivery,
      joined.zuora_sold_to_country,
      memberships.gitlab_user_access_level,
      joined.billing_contact_id                               AS account_billing_contact_id,
      memberships.user_id                                     AS gitlab_user_id,
      NULL                                                    AS sfdc_record_id,
      NULL                                                    AS sfdc_has_opted_out_email,
      users_notification_contact.full_name,
      users_notification_contact.first_name,
      users_notification_contact.last_name,
      users_notification_contact.email,
      FALSE                                                   AS is_account_billing_contact,
      TRUE                                                    AS is_gitlab_user_notification_contact,
      FALSE                                                   AS is_gitlab_user_public_contact,
      FALSE                                                   AS is_sfdc_contact
    FROM memberships
    LEFT JOIN joined
      ON memberships.namespace_id = joined.gitlab_namespace_id
    LEFT JOIN gitlab_dotcom_namespaces_xf
      ON gitlab_dotcom_namespaces_xf.namespace_id::VARCHAR = memberships.namespace_id::VARCHAR
    LEFT JOIN users_notification_contact
      ON users_notification_contact.user_id = memberships.user_id

), sfdc_contacts AS (

    SELECT
      sfdc_contact.account_id                                                          AS crm_id,
      dim_customers.ultimate_parent_account_id                                         AS ultimate_parent_account_id,
      joined.subscription_id,
      joined.subscription_name,
      joined.gitlab_namespace_id::INT                                                  AS gitlab_namespace_id,
      joined.namespace_is_internal,
      dim_customers.customer_name,
      dim_customers.ultimate_parent_account_name                                       AS ultimate_parent_account_name,
      dim_customers.ultimate_parent_account_segment,
      sfdc_users.name                                                                   AS account_owner_name,
      sfdc_users.email                                                                  AS account_owner_email,
      joined.zuora_product_category,
      joined.gitlab_product_category,
      joined.delivery,
      joined.zuora_sold_to_country,
      NULL                                                                              AS gitlab_user_access_level,
      joined.billing_contact_id                                                         AS account_billing_contact_id,
      NULL                                                                              AS gitlab_user_id,
      sfdc_contact.sfdc_record_id                                                       AS sfdc_record_id,
      sfdc_contact.sfdc_has_opted_out_email,
      sfdc_contact.full_name,
      sfdc_contact.first_name,
      sfdc_contact.last_name,
      sfdc_contact.email,
      FALSE                                                                             AS is_account_billing_contact,
      FALSE                                                                             AS is_gitlab_user_notification_contact,
      FALSE                                                                             AS is_gitlab_user_public_contact,
      TRUE                                                                              AS is_sfdc_contact
    FROM sfdc_contact
    LEFT JOIN joined
      ON joined.crm_id = sfdc_contact.account_id
    LEFT JOIN dim_customers
      ON sfdc_contact.account_id = dim_customers.crm_id
    LEFT JOIN sfdc_users
      ON dim_customers.account_owner_id = sfdc_users.id

), gitlab_public_user_info AS (
  
    SELECT
      with_gitlab_namespace_info.crm_id,
      with_gitlab_namespace_info.ultimate_parent_account_id,
      with_gitlab_namespace_info.subscription_id,
      with_gitlab_namespace_info.subscription_name,
      with_gitlab_namespace_info.gitlab_namespace_id,
      with_gitlab_namespace_info.namespace_is_internal,
      with_gitlab_namespace_info.customer_name,
      with_gitlab_namespace_info.ultimate_parent_account_name,
      with_gitlab_namespace_info.ultimate_parent_account_segment,
      with_gitlab_namespace_info.account_owner_name,
      with_gitlab_namespace_info.account_owner_email,
      with_gitlab_namespace_info.zuora_product_category,
      with_gitlab_namespace_info.gitlab_product_category,
      with_gitlab_namespace_info.delivery,
      with_gitlab_namespace_info.zuora_sold_to_country,
      with_gitlab_namespace_info.gitlab_user_access_level,
      with_gitlab_namespace_info.account_billing_contact_id,
      with_gitlab_namespace_info.gitlab_user_id,
      with_gitlab_namespace_info.sfdc_record_id,
      with_gitlab_namespace_info.sfdc_has_opted_out_email,
      users_public_contact.full_name,
      users_public_contact.first_name,
      users_public_contact.last_name,
      users_public_contact.email,
      FALSE                                                    AS is_account_billing_contact,
      FALSE                                                    AS is_gitlab_user_notification_contact,
      TRUE                                                     AS is_gitlab_user_public_contact,
      FALSE                                                    AS is_sfdc_contact
    FROM with_gitlab_namespace_info
    INNER JOIN users_public_contact
      ON with_gitlab_namespace_info.gitlab_user_id = users_public_contact.user_id
   
), email_xf AS (

    SELECT *
    FROM with_billing_contact

    UNION

    SELECT *
    FROM with_gitlab_namespace_info

    UNION

    SELECT *
    FROM sfdc_contacts
    
    UNION
    
    SELECT *
    FROM gitlab_public_user_info
  
)

SELECT
  --primary_key
      {{ dbt_utils.surrogate_key(['crm_id', 'subscription_name', 'gitlab_namespace_id', 'account_billing_contact_id',
                      'zuora_product_category', 'sfdc_record_id', 'gitlab_user_id', 'gitlab_user_access_level',
                     'is_account_billing_contact', 'is_gitlab_user_notification_contact',
                      'is_gitlab_user_public_contact', 'is_sfdc_contact']) }}
                                      AS primary_key,
  *
FROM email_xf
