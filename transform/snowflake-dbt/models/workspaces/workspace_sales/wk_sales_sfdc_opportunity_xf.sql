{{ config(alias='sfdc_opportunity_xf') }}

WITH sfdc_opportunity_xf AS (

    SELECT 
      sfdc_opportunity_xf.account_id,
      sfdc_opportunity_xf.opportunity_id,
      sfdc_opportunity_xf.opportunity_name,
      sfdc_opportunity_xf.owner_id,
      sfdc_opportunity_xf.close_date,
      sfdc_opportunity_xf.created_date,
      sfdc_opportunity_xf.days_in_stage,
      sfdc_opportunity_xf.deployment_preference,
      sfdc_opportunity_xf.generated_source,
      sfdc_opportunity_xf.lead_source,
      sfdc_opportunity_xf.lead_source_id,
      sfdc_opportunity_xf.lead_source_name,
      sfdc_opportunity_xf.lead_source_type,
      sfdc_opportunity_xf.merged_opportunity_id,
      sfdc_opportunity_xf.net_new_source_categories,
      sfdc_opportunity_xf.opportunity_business_development_representative,
      sfdc_opportunity_xf.opportunity_owner,
      sfdc_opportunity_xf.opportunity_owner_department,
      sfdc_opportunity_xf.opportunity_owner_manager,
      sfdc_opportunity_xf.opportunity_owner_role,
      sfdc_opportunity_xf.opportunity_owner_team,
      sfdc_opportunity_xf.opportunity_owner_title,
      sfdc_opportunity_xf.opportunity_sales_development_representative,
      sfdc_opportunity_xf.opportunity_development_representative,
      sfdc_opportunity_xf.account_owner_team_stamped,
      sfdc_opportunity_xf.opportunity_term,
      sfdc_opportunity_xf.primary_campaign_source_id,
      sfdc_opportunity_xf.sales_accepted_date,
      sfdc_opportunity_xf.sales_path,
      sfdc_opportunity_xf.sales_qualified_date,
      sfdc_opportunity_xf.sales_type,
      sfdc_opportunity_xf.sdr_pipeline_contribution,
      sfdc_opportunity_xf.source_buckets,
      sfdc_opportunity_xf.stage_name,
      sfdc_opportunity_xf.stage_is_active,
      sfdc_opportunity_xf.stage_is_closed,
      sfdc_opportunity_xf.technical_evaluation_date,
      sfdc_opportunity_xf.order_type,
      sfdc_opportunity_xf.deal_path,
      sfdc_opportunity_xf.acv,
      sfdc_opportunity_xf.amount,
      sfdc_opportunity_xf.closed_deals,
      sfdc_opportunity_xf.competitors,
      sfdc_opportunity_xf.critical_deal_flag,
      sfdc_opportunity_xf.deal_size,
      sfdc_opportunity_xf.forecast_category_name,
      sfdc_opportunity_xf.forecasted_iacv,
      sfdc_opportunity_xf.iacv_created_date,
      sfdc_opportunity_xf.incremental_acv,
      sfdc_opportunity_xf.pre_covid_iacv,
      sfdc_opportunity_xf.invoice_number,
      sfdc_opportunity_xf.is_refund,
      sfdc_opportunity_xf.is_downgrade,
      sfdc_opportunity_xf.is_risky,
      sfdc_opportunity_xf.is_swing_deal,
      sfdc_opportunity_xf.is_edu_oss,
      sfdc_opportunity_xf.is_won,
      sfdc_opportunity_xf.net_incremental_acv,
      sfdc_opportunity_xf.probability,
      sfdc_opportunity_xf.professional_services_value,
      sfdc_opportunity_xf.pushed_count,
      sfdc_opportunity_xf.reason_for_loss,
      sfdc_opportunity_xf.reason_for_loss_details,
      sfdc_opportunity_xf.refund_iacv,
      sfdc_opportunity_xf.downgrade_iacv,
      sfdc_opportunity_xf.renewal_acv,
      sfdc_opportunity_xf.renewal_amount,
      sfdc_opportunity_xf.sales_qualified_source,
      sfdc_opportunity_xf.solutions_to_be_replaced,
      sfdc_opportunity_xf.total_contract_value,
      sfdc_opportunity_xf.upside_iacv,
      sfdc_opportunity_xf.upside_swing_deal_iacv,
      sfdc_opportunity_xf.weighted_iacv,
      sfdc_opportunity_xf.is_web_portal_purchase,
      sfdc_opportunity_xf.partner_initiated_opportunity,
      sfdc_opportunity_xf.user_segment,
      sfdc_opportunity_xf.subscription_start_date,
      sfdc_opportunity_xf.subscription_end_date,
      sfdc_opportunity_xf.true_up_value,
      sfdc_opportunity_xf.order_type_live,
      sfdc_opportunity_xf.order_type_stamped,

      sfdc_opportunity_xf.net_arr                 AS raw_net_arr,
      sfdc_opportunity_xf.recurring_amount,
      sfdc_opportunity_xf.true_up_amount,
      sfdc_opportunity_xf.proserv_amount,
      sfdc_opportunity_xf.other_non_recurring_amount,
      sfdc_opportunity_xf.arr_basis,
      sfdc_opportunity_xf.arr,

      sfdc_opportunity_xf.opportunity_health,
      sfdc_opportunity_xf.risk_type,
      sfdc_opportunity_xf.risk_reasons,
      sfdc_opportunity_xf.tam_notes,
      sfdc_opportunity_xf.days_in_1_discovery,
      sfdc_opportunity_xf.days_in_2_scoping,
      sfdc_opportunity_xf.days_in_3_technical_evaluation,
      sfdc_opportunity_xf.days_in_4_proposal,
      sfdc_opportunity_xf.days_in_5_negotiating,
      sfdc_opportunity_xf.stage_0_pending_acceptance_date,
      sfdc_opportunity_xf.stage_1_discovery_date,
      sfdc_opportunity_xf.stage_2_scoping_date,
      sfdc_opportunity_xf.stage_3_technical_evaluation_date,
      sfdc_opportunity_xf.stage_4_proposal_date,
      sfdc_opportunity_xf.stage_5_negotiating_date,
      sfdc_opportunity_xf.stage_6_awaiting_signature_date,
      sfdc_opportunity_xf.stage_6_closed_won_date,
      sfdc_opportunity_xf.stage_6_closed_lost_date,
      sfdc_opportunity_xf.cp_champion,
      sfdc_opportunity_xf.cp_close_plan,
      sfdc_opportunity_xf.cp_competition,
      sfdc_opportunity_xf.cp_decision_criteria,
      sfdc_opportunity_xf.cp_decision_process,
      sfdc_opportunity_xf.cp_economic_buyer,
      sfdc_opportunity_xf.cp_identify_pain,
      sfdc_opportunity_xf.cp_metrics,
      sfdc_opportunity_xf.cp_risks,
      sfdc_opportunity_xf.cp_use_cases,
      sfdc_opportunity_xf.cp_value_driver,
      sfdc_opportunity_xf.cp_why_do_anything_at_all,
      sfdc_opportunity_xf.cp_why_gitlab,
      sfdc_opportunity_xf.cp_why_now,
      sfdc_opportunity_xf.division_sales_segment_stamped,
      sfdc_opportunity_xf.tsp_max_hierarchy_sales_segment,
      sfdc_opportunity_xf.division_sales_segment,
      sfdc_opportunity_xf.ultimate_parent_sales_segment,
      sfdc_opportunity_xf.segment,
      sfdc_opportunity_xf.sales_segment,
      sfdc_opportunity_xf.parent_segment,
      sfdc_opportunity_xf.dr_partner_deal_type,
      sfdc_opportunity_xf.dr_partner_engagement,
      sfdc_opportunity_xf.account_owner_team_level_2,
      sfdc_opportunity_xf.account_owner_team_level_3,
      sfdc_opportunity_xf.account_owner_team_level_4,
      sfdc_opportunity_xf.account_owner_team_vp_level,
      sfdc_opportunity_xf.account_owner_team_rd_level,
      sfdc_opportunity_xf.account_owner_team_asm_level,
      sfdc_opportunity_xf.account_owner_min_team_level,
      sfdc_opportunity_xf.account_owner_sales_region,
      sfdc_opportunity_xf.opportunity_owner_team_level_2,
      sfdc_opportunity_xf.opportunity_owner_team_level_3,
      sfdc_opportunity_xf.stage_name_3plus,
      sfdc_opportunity_xf.stage_name_4plus,
      sfdc_opportunity_xf.is_stage_3_plus,
      sfdc_opportunity_xf.is_lost,
      sfdc_opportunity_xf.is_open,
      sfdc_opportunity_xf.is_closed,
      sfdc_opportunity_xf.stage_category,
      sfdc_opportunity_xf.is_renewal,
      sfdc_opportunity_xf.close_fiscal_quarter_name,
      sfdc_opportunity_xf.close_fiscal_quarter_date,
      sfdc_opportunity_xf.close_fiscal_year,
      sfdc_opportunity_xf.close_date_month,
      sfdc_opportunity_xf.created_fiscal_quarter_name,
      sfdc_opportunity_xf.created_fiscal_quarter_date,
      sfdc_opportunity_xf.created_fiscal_year,
      sfdc_opportunity_xf.created_date_month,
      sfdc_opportunity_xf.subscription_start_date_fiscal_quarter_name,
      sfdc_opportunity_xf.subscription_start_date_fiscal_quarter_date,
      sfdc_opportunity_xf.subscription_start_date_fiscal_year,
      sfdc_opportunity_xf.subscription_start_date_month,
      sfdc_opportunity_xf.sales_accepted_fiscal_quarter_name,
      sfdc_opportunity_xf.sales_accepted_fiscal_quarter_date,
      sfdc_opportunity_xf.sales_accepted_fiscal_year,
      sfdc_opportunity_xf.sales_accepted_date_month,
      sfdc_opportunity_xf.sales_qualified_fiscal_quarter_name,
      sfdc_opportunity_xf.sales_qualified_fiscal_quarter_date,
      sfdc_opportunity_xf.sales_qualified_fiscal_year,
      sfdc_opportunity_xf.sales_qualified_date_month,
      sfdc_opportunity_xf.iacv_created_fiscal_quarter_name,
      sfdc_opportunity_xf.iacv_created_fiscal_quarter_date,
      sfdc_opportunity_xf.iacv_created_fiscal_year,
      sfdc_opportunity_xf.iacv_created_date_month,
      sfdc_opportunity_xf._last_dbt_run,
      sfdc_opportunity_xf.business_process_id,
      sfdc_opportunity_xf.days_since_last_activity,
      sfdc_opportunity_xf.is_deleted,
      sfdc_opportunity_xf.last_activity_date,
      sfdc_opportunity_xf.record_type_description,
      sfdc_opportunity_xf.record_type_id,
      sfdc_opportunity_xf.record_type_label,
      sfdc_opportunity_xf.record_type_modifying_object_type,
      sfdc_opportunity_xf.record_type_name,
      sfdc_opportunity_xf.region_quota_id,
      sfdc_opportunity_xf.sales_quota_id
    
    FROM {{ref('sfdc_opportunity_xf')}}

), sfdc_users_xf AS (

    SELECT * FROM {{ref('sfdc_users_xf')}}

), sfdc_account AS (

    SELECT * FROM {{ref('sfdc_account')}}

), date_details AS (
 
    SELECT
      *,
      DENSE_RANK() OVER (ORDER BY first_day_of_fiscal_quarter) AS quarter_number
    FROM {{ ref('date_details') }}
    ORDER BY 1 DESC

), net_iacv_to_net_arr_ratio AS (

    SELECT '2. New - Connected'       AS "ORDER_TYPE_STAMPED", 
          'Mid-Market'              AS "USER_SEGMENT_STAMPED", 
          1.001856868               AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '1. New - First Order'   AS "ORDER_TYPE_STAMPED", 
          'SMB'                     AS "USER_SEGMENT_STAMPED", 
          0.9879780801              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '1. New - First Order'   AS "ORDER_TYPE_STAMPED", 
          'PubSec'                  AS "USER_SEGMENT_STAMPED", 
          0.9999751852              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '1. New - First Order'   AS "ORDER_TYPE_STAMPED", 
          'Large'                   AS "USER_SEGMENT_STAMPED", 
          0.9983306793              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '3. Growth'              AS "ORDER_TYPE_STAMPED", 
          'SMB'                     AS "USER_SEGMENT_STAMPED", 
          0.9427320642              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '3. Growth'              AS "ORDER_TYPE_STAMPED", 
          'Large'                   AS "USER_SEGMENT_STAMPED", 
          0.9072734284              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '3. Growth'              AS "ORDER_TYPE_STAMPED", 
          'PubSec'                  AS "USER_SEGMENT_STAMPED", 
          1.035889715               AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '2. New - Connected'     AS "ORDER_TYPE_STAMPED", 
          'SMB'                     AS "USER_SEGMENT_STAMPED", 
          1                         AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '2. New - Connected'     AS "ORDER_TYPE_STAMPED", 
          'PubSec'                  AS "USER_SEGMENT_STAMPED", 
          1.002887983               AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '3. Growth'              AS "ORDER_TYPE_STAMPED", 
          'Mid-Market'              AS "USER_SEGMENT_STAMPED", 
          0.8504383811              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '1. New - First Order'   AS "ORDER_TYPE_STAMPED", 
          'Mid-Market'              AS "USER_SEGMENT_STAMPED", 
          0.9897881218              AS "RATIO_NET_IACV_TO_NET_ARR" 
    UNION 
    SELECT '2. New - Connected'     AS "ORDER_TYPE_STAMPED", 
          'Large'                   AS "USER_SEGMENT_STAMPED", 
          1.012723079               AS "RATIO_NET_IACV_TO_NET_ARR" 

), oppty_final AS (

    SELECT 

      sfdc_opportunity_xf.*,

      -- date helpers
      
      -- pipeline created, tracks the date pipeline value was created for the first time
      -- used for performance reporting on pipeline generation
      -- these fields might change, isolating the field from the purpose
      -- alternatives are a future net_arr_created_date
      sfdc_opportunity_xf.created_date_month                       AS pipeline_created_date_month,
      sfdc_opportunity_xf.created_fiscal_year                      AS pipeline_created_fiscal_year,
      sfdc_opportunity_xf.created_fiscal_quarter_name              AS pipeline_created_fiscal_quarter_name,
      sfdc_opportunity_xf.created_fiscal_quarter_date              AS pipeline_created_fiscal_quarter_date,
  
      -- medium level grouping of the order type field
      CASE 
        WHEN sfdc_opportunity_xf.order_type_stamped = '1. New - First Order' 
          THEN '1. New'
        WHEN sfdc_opportunity_xf.order_type_stamped IN ('2. New - Connected', '3. Growth') 
          THEN '2. Growth' 
        WHEN sfdc_opportunity_xf.order_type_stamped IN ('4. Churn','4. Contraction','6. Churn - Final')
          THEN '3. Churn'
        ELSE '4. Other' 
      END                                                                 AS deal_category,

      CASE 
        WHEN sfdc_opportunity_xf.order_type_stamped = '1. New - First Order' 
          THEN '1. New'
        WHEN sfdc_opportunity_xf.order_type_stamped IN ('2. New - Connected', '3. Growth', '4. Churn','4. Contraction','6. Churn - Final') 
          THEN '2. Growth' 
        ELSE '3. Other'
      END                                                                 AS deal_group,
   
      -- PIO Flag for PIO reporting dashboard
      CASE 
        WHEN (sfdc_opportunity_xf.partner_initiated_opportunity = TRUE -- up to the first half of the year 2020
            AND sfdc_opportunity_xf.created_date < '2020-08-01'::DATE)
          OR (sfdc_opportunity_xf.dr_partner_engagement = 'PIO' -- second half and moving forward  
            AND sfdc_opportunity_xf.created_date >= '2020-08-01'::DATE)
          THEN 1 
        ELSE 0 
      END                                                                 AS partner_engaged_opportunity_flag,

      CASE 
        WHEN sfdc_opportunity_xf.account_owner_team_vp_level = 'VP Ent'
          THEN 'Large'
        WHEN sfdc_opportunity_xf.account_owner_team_vp_level = 'VP Comm MM'
          THEN 'Mid-Market'
        WHEN sfdc_opportunity_xf.account_owner_team_vp_level = 'VP Comm SMB' 
          THEN 'SMB' 
        ELSE 'Other' 
      END                                                                 AS account_owner_cro_level,

      CASE 
        WHEN sfdc_opportunity_xf.user_segment   IS NULL 
          OR sfdc_opportunity_xf.user_segment   = 'Unknown' 
        THEN 'SMB' 
          ELSE sfdc_opportunity_xf.user_segment   
      END                                                                 AS user_segment_stamped,

       -- check if renewal was closed on time or not
      CASE 
        WHEN sfdc_opportunity_xf.is_renewal = 1 
          AND sfdc_opportunity_xf.subscription_start_date_fiscal_quarter_date >= sfdc_opportunity_xf.close_fiscal_quarter_date 
            THEN 'On-Time'
        WHEN sfdc_opportunity_xf.is_renewal = 1 
          AND sfdc_opportunity_xf.subscription_start_date_fiscal_quarter_date < sfdc_opportunity_xf.close_fiscal_quarter_date 
            THEN 'Late' 
      END                                                                 AS renewal_timing_status,

      --********************************************************
      -- calculated fields for pipeline velocity report
      
      -- 20201021 NF: This should be replaced by a table that keeps track of excluded deals for forecasting purposes
      CASE 
        WHEN sfdc_account.ultimate_parent_id IN ('001610000111bA3','0016100001F4xla','0016100001CXGCs','00161000015O9Yn','0016100001b9Jsc') 
          AND sfdc_opportunity_xf.close_date < '2020-08-01' 
            THEN 1
        ELSE 0
      END                                                                 AS is_excluded_flag

    FROM sfdc_opportunity_xf
    LEFT JOIN sfdc_account
      ON sfdc_account.account_id = sfdc_opportunity_xf.account_id
), add_calculated_net_arr_to_opty_final AS (

    SELECT 
      oppty_final.*,
      -- NF 2021-01-28 Not all historical opportunities have Net ARR set. To allow historical reporting 
      -- we apply a ratio by segment / order type to convert IACV to Net ARR      
      CASE
        WHEN oppty_final.raw_net_arr IS NULL 
          AND oppty_final.net_incremental_acv <> 0
          THEN oppty_final.net_incremental_acv * coalesce(net_iacv_to_net_arr_ratio.ratio_net_iacv_to_net_arr,0)
        WHEN oppty_final.raw_net_arr IS NULL 
          AND oppty_final.incremental_acv <> 0
          THEN oppty_final.incremental_acv * coalesce(net_iacv_to_net_arr_ratio.ratio_net_iacv_to_net_arr,0)
        ELSE oppty_final.raw_net_arr
     END                                                          AS net_arr,

      -- compound metrics to facilitate reporting
      -- created and closed within the quarter net arr
      CASE 
        WHEN oppty_final.pipeline_created_fiscal_quarter_date = oppty_final.close_fiscal_quarter_date
          AND oppty_final.stage_name IN ('Closed Won')  
            THEN net_arr
        ELSE 0
      END                                                         AS created_and_won_net_arr,

      -- booked net arr (won + renewals / lost)
      CASE
        WHEN oppty_final.stage_name = 'Closed Won'
          OR (oppty_final.stage_name = '8-Closed Lost'
            AND LOWER(oppty_final.sales_type) LIKE '%renewal%')
          THEN net_arr
        ELSE 0 
      END                                                         AS booked_net_arr   

    FROM oppty_final
    -- Net IACV to Net ARR conversion table
    LEFT JOIN net_iacv_to_net_arr_ratio
      ON net_iacv_to_net_arr_ratio.user_segment_stamped = oppty_final.user_segment_stamped
      AND net_iacv_to_net_arr_ratio.order_type_stamped = oppty_final.order_type_stamped

)
SELECT *
FROM add_calculated_net_arr_to_opty_final