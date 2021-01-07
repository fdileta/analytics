with zuora_mrr_totals AS (

    SELECT * FROM {{ref('zuora_mrr_totals')}}

), zuora_account AS (

    SELECT * FROM {{ref('zuora_account')}}

), sfdc_accounts_xf AS (

    SELECT * FROM {{ref('sfdc_accounts_xf')}}

), sfdc_deleted_accounts AS (

    SELECT * FROM {{ref('sfdc_deleted_accounts')}}

), initial_join_to_sfdc AS (

    SELECT
           zuora_mrr_totals.*,
           zuora_account.account_id AS zuora_account_id,
           zuora_account.account_name AS zuora_account_name,
           zuora_account.crm_id as zuora_crm_id,
           sfdc_accounts_xf.account_id as sfdc_account_id_int
    FROM zuora_mrr_totals
    LEFT JOIN zuora_account
    ON zuora_account.account_number = zuora_mrr_totals.account_number
    LEFT JOIN sfdc_accounts_xf
    ON sfdc_accounts_xf.account_id = zuora_account.crm_id

), replace_sfdc_account_id_with_master_record_id AS (

    SELECT coalesce(initial_join_to_sfdc.sfdc_account_id_int, sfdc_master_record_id) AS sfdc_account_id,
          initial_join_to_sfdc.*
    FROM initial_join_to_sfdc
    LEFT JOIN sfdc_deleted_accounts
    ON initial_join_to_sfdc.zuora_crm_id = sfdc_deleted_accounts.sfdc_account_id

)


{{ dbt_audit(
    cte_ref="replace_sfdc_account_id_with_master_record_id",
    created_by="@paul_armstrong",
    updated_by="@paul_armstrong",
    created_date="2021-01-07",
    updated_date="2021-01-07"
) }}
