WITH date_details AS (

    SELECT
      *,
      DENSE_RANK() OVER (ORDER BY first_day_of_fiscal_quarter)        AS quarter_number,
      90 - DATEDIFF(day, date_actual, last_day_of_fiscal_quarter)     AS day_of_fiscal_quarter_normalised
    FROM {{ ref('date_details') }}
    ORDER BY 1 DESC

), sfdc_opportunity_snapshot_history_xf AS (
    
    SELECT *
    FROM {{ ref('sfdc_opportunity_snapshot_history_xf') }}
    -- remove lost & deleted deals
    WHERE is_deleted = 0
      -- remove incomplete quarters, data from beggining of Q4 FY20
      AND snapshot_date >= '2019-11-01'::DATE
      -- remove excluded deals
      AND is_excluded_flag = 0
      -- exclude order type stamped "other"
      AND order_type_stamped IN ('2. New - Connected','1. New - First Order','3. Growth','4. Churn')
      -- Lost deals have the forecast category name of ommitted, and we need to include them to correctly account for 
      -- churned deals
      AND (stage_name NOT IN ('9-Unqualified','10-Duplicate','Unqualified','00-Pre Opportunity','0-Pending Acceptance') 
          AND forecast_category_name != 'Omitted'
          OR stage_name = '8-Closed Lost')

), pipeline_snapshot_base AS (
    
    SELECT
      -- report keys
      COALESCE(adj_ultimate_parent_sales_segment,'n/a')     AS adj_ultimate_parent_sales_segment,
      COALESCE(sales_qualified_source, 'n/a')               AS sales_qualified_source,
      deal_category,
      deal_group,
    
      -- the account hierarchy can be related to the VP / ASM / RD levels
      -- and to an approximate region
      account_owner_min_team_level,

      close_fiscal_quarter,
      close_fiscal_quarter_date,
      close_fiscal_year,

      snapshot_date,
      snapshot_month,
      snapshot_fiscal_year,
      snapshot_fiscal_quarter,
      snapshot_fiscal_quarter_date,
      snapshot_day_of_fiscal_quarter_normalised      AS snapshot_day_of_fiscal_quarter,

      created_fiscal_quarter,
      created_fiscal_quarter_date,
      created_fiscal_year,

      stage_name_3plus,
      stage_name_4plus,
      is_excluded_flag,
      stage_name,
      forecast_category_name,
      order_type_stamped,
      is_renewal,

      -- sales team - region fields
      account_owner_team_stamped,
      account_owner_team_vp_level,
      account_owner_team_rd_level,
      account_owner_team_asm_level,
      account_owner_sales_region,

      COUNT(DISTINCT opportunity_id)                  AS opps,
      SUM(incremental_acv)                            AS incremental_acv,
      SUM(net_iacv)                                   AS net_iacv,
      SUM(churn_only)                                 AS churn_only,
      SUM(total_contract_value)                       AS tcv,

      SUM(created_in_quarter_iacv)                    AS created_in_quarter_iacv,
      SUM(created_and_won_iacv)                       AS created_and_won_iacv

    FROM sfdc_opportunity_snapshot_history_xf
     -- current day
    CROSS JOIN (SELECT *
                  FROM date_details
                  WHERE date_actual = DATEADD(day,-1,CURRENT_DATE)) today_date 
      -- exclude current quarter
    WHERE sfdc_opportunity_snapshot_history_xf.snapshot_fiscal_quarter != today_date.fiscal_quarter_name_fy 
    {{ dbt_utils.group_by(n=29) }} 

--NF: Is this accounting correctly for Churn?
), pipeline_snapshot AS (

    SELECT 
      -------------------------------------
      -- report keys
      pipeline_snapshot_base.adj_ultimate_parent_sales_segment,
      pipeline_snapshot_base.sales_qualified_source,
      pipeline_snapshot_base.deal_category,
      pipeline_snapshot_base.deal_group,

      -- sales team - region fields
      pipeline_snapshot_base.account_owner_min_team_level,
      pipeline_snapshot_base.account_owner_team_vp_level,
      pipeline_snapshot_base.account_owner_team_rd_level,
      pipeline_snapshot_base.account_owner_team_asm_level,
      pipeline_snapshot_base.account_owner_sales_region,

      -------------------------------------
      
      pipeline_snapshot_base.stage_name,
      pipeline_snapshot_base.forecast_category_name,
      pipeline_snapshot_base.is_renewal,
      pipeline_snapshot_base.is_excluded_flag,
      
      pipeline_snapshot_base.close_fiscal_quarter,
      pipeline_snapshot_base.close_fiscal_quarter_date,
      pipeline_snapshot_base.created_fiscal_quarter,
      pipeline_snapshot_base.created_fiscal_quarter_date,

      pipeline_snapshot_base.incremental_acv,
      pipeline_snapshot_base.net_iacv,
      pipeline_snapshot_base.opps                                                                           AS deal_count,

      CASE 
        WHEN LOWER(pipeline_snapshot_base.stage_name) not like '%lost%' 
          THEN pipeline_snapshot_base.opps  
        ELSE 0                                                                                              
      END                                                                                                   AS open_won_deal_count,

      CASE 
        WHEN LOWER(pipeline_snapshot_base.stage_name) not like '%lost%' 
          THEN pipeline_snapshot_base.incremental_acv
        ELSE 0                                                                                              
      END                                                                                                   AS open_won_iacv,

      CASE 
        WHEN pipeline_snapshot_base.stage_name_3plus IN ('3+ Pipeline','Closed Won')
          THEN pipeline_snapshot_base.incremental_acv
        ELSE 0
      END                                                                                                   AS open_won_3plus_iacv,
      CASE 
        WHEN pipeline_snapshot_base.stage_name_3plus IN ('3+ Pipeline','Closed Won')
          THEN pipeline_snapshot_base.opps
        ELSE 0
      END                                                                                                   AS open_won_3plus_deal_count,

      CASE 
        WHEN pipeline_snapshot_base.stage_name_4plus IN ('4+ Pipeline','Closed Won')
          THEN pipeline_snapshot_base.incremental_acv
        ELSE 0
      END                                                                                                   AS open_won_4plus_iacv,

      CASE 
        WHEN pipeline_snapshot_base.stage_name_4plus IN ('4+ Pipeline','Closed Won')
          THEN pipeline_snapshot_base.opps
        ELSE 0
      END                                                                                                   AS open_won_4plus_deal_count,

      CASE 
        WHEN LOWER(pipeline_snapshot_base.stage_name) LIKE '%won%'
          THEN pipeline_snapshot_base.incremental_acv
        ELSE 0  
      END                                                                                                   AS won_iacv,

      pipeline_snapshot_base.net_iacv                                                                       AS won_net_iacv,


      CASE 
        WHEN LOWER(pipeline_snapshot_base.stage_name) LIKE '%won%'
          THEN pipeline_snapshot_base.opps
        ELSE 0
      END                                                                                                   AS won_deal_count,
  
      -- created and closed
      pipeline_snapshot_base.created_and_won_iacv,
      pipeline_snapshot_base.created_in_quarter_iacv,

      -- snapshot date fields
      pipeline_snapshot_base.snapshot_date,
      pipeline_snapshot_base.snapshot_fiscal_year,
      pipeline_snapshot_base.snapshot_fiscal_quarter,
      pipeline_snapshot_base.snapshot_fiscal_quarter_date,
      pipeline_snapshot_base.snapshot_day_of_fiscal_quarter

    FROM pipeline_snapshot_base
    -- till end of quarter
    WHERE       
      pipeline_snapshot_base.snapshot_date <= DATEADD(month,3,pipeline_snapshot_base.close_fiscal_quarter_date)
      -- 1 quarters before start
      AND pipeline_snapshot_base.snapshot_date >= DATEADD(month,-3,pipeline_snapshot_base.close_fiscal_quarter_date)
     
), reported_quarter AS (
  
    -- daily snapshot of pipeline metrics per quarter within the quarter
    SELECT 
      pipeline_snapshot.close_fiscal_quarter,
      pipeline_snapshot.snapshot_fiscal_quarter,
      pipeline_snapshot.close_fiscal_quarter_date,
      pipeline_snapshot.snapshot_fiscal_quarter_date,

      pipeline_snapshot.adj_ultimate_parent_sales_segment,
      pipeline_snapshot.deal_category,
      pipeline_snapshot.deal_group,

      pipeline_snapshot.snapshot_day_of_fiscal_quarter,
  
      pipeline_snapshot.account_owner_min_team_level,
      pipeline_snapshot.sales_qualified_source,
      
      -- open / won pipeline in quarter
      SUM(pipeline_snapshot.open_won_iacv)                                            AS open_won_iacv,
      SUM(pipeline_snapshot.open_won_deal_count)                                      AS open_won_deal_count,

      SUM(pipeline_snapshot.open_won_3plus_iacv)                                      AS open_won_3plus_iacv,
      SUM(pipeline_snapshot.open_won_3plus_deal_count)                                AS open_won_3plus_deal_count,

      SUM(pipeline_snapshot.open_won_4plus_iacv)                                      AS open_won_4plus_iacv,
      SUM(pipeline_snapshot.open_won_4plus_deal_count)                                AS open_won_4plus_deal_count,

      SUM(pipeline_snapshot.won_iacv)                                                 AS won_iacv,
      SUM(pipeline_snapshot.won_net_iacv)                                             AS won_net_iacv,
      SUM(pipeline_snapshot.won_deal_count)                                           AS won_deal_count,

      SUM(pipeline_snapshot.created_and_won_iacv)                                     AS created_and_won_iacv

    FROM pipeline_snapshot
    -- restrict the rows to pipeline of the quarter the snapshot was taken
    WHERE pipeline_snapshot.snapshot_fiscal_quarter = pipeline_snapshot.close_fiscal_quarter
    -- to account for net iacv, it is needed to include lost renewal deals
    AND (LOWER(pipeline_snapshot.stage_name) NOT LIKE '%lost%' 
      OR (pipeline_snapshot.is_renewal = 1 AND LOWER(pipeline_snapshot.stage_name) LIKE '%lost%'))     
    {{ dbt_utils.group_by(n=10) }}
  
), next_quarter AS (
    
    SELECT 
      pipeline_snapshot.snapshot_fiscal_quarter,
      pipeline_snapshot.snapshot_fiscal_quarter_date,
      pipeline_snapshot.close_fiscal_quarter                                       AS next_close_fiscal_quarter,
      pipeline_snapshot.close_fiscal_quarter_date                                  AS next_close_fiscal_quarter_date,
     
      pipeline_snapshot.adj_ultimate_parent_sales_segment,
      pipeline_snapshot.deal_category,
      pipeline_snapshot.deal_group,

      pipeline_snapshot.snapshot_day_of_fiscal_quarter,
      pipeline_snapshot.account_owner_min_team_level,
      pipeline_snapshot.sales_qualified_source,
      
      SUM(pipeline_snapshot.incremental_acv)                                       AS next_open_iacv,
      SUM(pipeline_snapshot.deal_count)                                            AS next_open_deal_count,

      SUM(pipeline_snapshot.open_won_3plus_iacv)                                   AS next_open_3plus_iacv,
      SUM(pipeline_snapshot.open_won_3plus_deal_count)                             AS next_open_3plus_deal_count,

      SUM(pipeline_snapshot.open_won_4plus_iacv)                                   AS next_open_4plus_iacv,
      SUM(pipeline_snapshot.open_won_4plus_deal_count)                             AS next_open_4plus_deal_count

    FROM pipeline_snapshot
    -- restrict the report to show next quarter lines
    -- without this we would get results for multiple quarters
    WHERE pipeline_snapshot.snapshot_fiscal_quarter_date = DATEADD(month, -3,pipeline_snapshot.close_fiscal_quarter_date) 
    -- exclude lost deals from pipeline
    AND LOWER(pipeline_snapshot.stage_name) NOT LIKE '%lost%'   
    {{ dbt_utils.group_by(n=10) }}

), pipeline_gen AS (

    SELECT
      pipeline_snapshot_base.snapshot_fiscal_quarter_date,
      pipeline_snapshot_base.snapshot_day_of_fiscal_quarter,
      pipeline_snapshot_base.adj_ultimate_parent_sales_segment,
      pipeline_snapshot_base.deal_category, 
      pipeline_snapshot_base.deal_group,

      pipeline_snapshot_base.account_owner_min_team_level,
      pipeline_snapshot_base.sales_qualified_source,

      --created in quarter
      SUM(pipeline_snapshot_base.incremental_acv)           AS created_in_quarter_iacv,
      SUM(pipeline_snapshot_base.opps)                      AS created_in_quarter_count
    FROM pipeline_snapshot_base
    -- restrict the rows to pipeline of the quarter the snapshot was taken
    WHERE pipeline_snapshot_base.snapshot_fiscal_quarter = pipeline_snapshot_base.created_fiscal_quarter
    -- remove pre-opty deals
    -- remove pre-opty deals and stage 0
    AND pipeline_snapshot_base.stage_name NOT IN ('0-Pending Acceptance','10-Duplicate','00-Pre Opportunity','9-Unqualified')
    {{ dbt_utils.group_by(n=7) }}

), base_fields AS (
    
    SELECT DISTINCT 
      a.adj_ultimate_parent_sales_segment,
      b.deal_category,
      b.deal_group,
      e.account_owner_min_team_level,
      e.account_owner_sales_region,
      e.account_owner_team_vp_level,
      e.account_owner_team_rd_level,
      e.account_owner_team_asm_level,
      c.snapshot_fiscal_quarter_date,
      d.snapshot_fiscal_quarter,
      d.snapshot_day_of_fiscal_quarter,
      d.snapshot_next_fiscal_quarter_date,
      f.sales_qualified_source
    FROM (SELECT DISTINCT adj_ultimate_parent_sales_segment FROM pipeline_snapshot_base) a
    CROSS JOIN (SELECT DISTINCT deal_category,
                                deal_group 
                FROM pipeline_snapshot_base) b
    CROSS JOIN (SELECT DISTINCT snapshot_fiscal_quarter_date FROM pipeline_snapshot_base) c
    CROSS JOIN (SELECT DISTINCT sales_qualified_source FROM pipeline_snapshot_base) f
    CROSS JOIN (SELECT DISTINCT account_owner_min_team_level,
                                account_owner_sales_region,
                                account_owner_team_vp_level,
                                account_owner_team_rd_level,
                                account_owner_team_asm_level
                FROM pipeline_snapshot_base) e
    INNER JOIN (SELECT DISTINCT fiscal_quarter_name_fy                                                              AS snapshot_fiscal_quarter,
                              first_day_of_fiscal_quarter                                                           AS snapshot_fiscal_quarter_date, 
                              DATEADD(month,3,first_day_of_fiscal_quarter)                                          AS snapshot_next_fiscal_quarter_date,
                              day_of_fiscal_quarter_normalised                                                      AS snapshot_day_of_fiscal_quarter
              FROM date_details) d
      ON c.snapshot_fiscal_quarter_date = d.snapshot_fiscal_quarter_date 
)
  
SELECT 
  base_fields.adj_ultimate_parent_sales_segment                                                                     AS sales_segment, 
  base_fields.deal_category,
  base_fields.account_owner_min_team_level,
  base_fields.account_owner_team_vp_level,
  base_fields.account_owner_team_rd_level,
  base_fields.account_owner_team_asm_level,
  base_fields.account_owner_sales_region,
  base_fields.sales_qualified_source,
  LOWER(base_fields.deal_category) || '_' || LOWER(base_fields.adj_ultimate_parent_sales_segment)                   AS key_segment_report,
  LOWER(base_fields.sales_qualified_source) || '_' || LOWER(base_fields.adj_ultimate_parent_sales_segment)          AS key_sqs_report,
  base_fields.snapshot_fiscal_quarter                                                                               AS close_fiscal_quarter,
  base_fields.snapshot_fiscal_quarter,
  base_fields.snapshot_day_of_fiscal_quarter,
  COALESCE(reported_quarter.open_won_iacv,0) - COALESCE(reported_quarter.won_iacv,0)                                AS open_pipeline_iacv,
  COALESCE(reported_quarter.open_won_3plus_iacv,0) - COALESCE(reported_quarter.won_iacv,0)                          AS open_3plus_pipeline_iacv, 
  COALESCE(reported_quarter.open_won_4plus_iacv,0) - COALESCE(reported_quarter.won_iacv,0)                          AS open_4plus_pipeline_iacv, 

  COALESCE(reported_quarter.won_net_iacv,0)                                                                         AS won_net_iacv,
  COALESCE(reported_quarter.won_iacv,0)                                                                             AS won_iacv,

  COALESCE(reported_quarter.open_won_deal_count,0) - COALESCE(reported_quarter.won_deal_count,0)                    AS open_pipeline_deal_count,
  COALESCE(reported_quarter.open_won_3plus_deal_count,0) - COALESCE(reported_quarter.won_deal_count,0)              AS open_3plus_deal_count,
  COALESCE(reported_quarter.open_won_4plus_deal_count,0) - COALESCE(reported_quarter.won_deal_count,0)              AS open_4plus_deal_count, 

  COALESCE(reported_quarter.won_deal_count,0)                                                                       AS won_deal_count,

  -- created and closed
  reported_quarter.created_and_won_iacv,
  pipeline_gen.created_in_quarter_iacv,
  pipeline_gen.created_in_quarter_count,
          
  -- next quarter 
  next_quarter_date.fiscal_quarter_name_fy                AS next_close_fiscal_quarter,
  next_quarter_date.first_day_of_fiscal_quarter           AS next_close_fiscal_quarter_date,                   

  COALESCE(next_quarter.next_open_iacv,0)                 AS next_open_iacv,
  COALESCE(next_quarter.next_open_3plus_iacv,0)           AS next_open_3plus_iacv,
  COALESCE(next_quarter.next_open_4plus_iacv,0)           AS next_open_4plus_iacv,

  COALESCE(next_quarter.next_open_deal_count,0)           AS next_open_deal_count,
  COALESCE(next_quarter.next_open_3plus_deal_count,0)     AS next_open_3plus_deal_count,
  COALESCE(next_quarter.next_open_4plus_deal_count,0)     AS next_open_4plus_deal_count

-- created a list of all options to avoid having blanks when attaching totals in the reporting phase
FROM base_fields
-- historical quarter
LEFT JOIN reported_quarter
  ON base_fields.adj_ultimate_parent_sales_segment = reported_quarter.adj_ultimate_parent_sales_segment
  AND base_fields.snapshot_fiscal_quarter_date = reported_quarter.snapshot_fiscal_quarter_date
  AND base_fields.deal_category = reported_quarter.deal_category
  AND base_fields.snapshot_day_of_fiscal_quarter = reported_quarter.snapshot_day_of_fiscal_quarter
  AND base_fields.account_owner_min_team_level = reported_quarter.account_owner_min_team_level
  AND base_fields.sales_qualified_source = reported_quarter.sales_qualified_source
  AND base_fields.deal_group = reported_quarter.deal_group
-- next quarter in relation to the considered reported quarter
LEFT JOIN  next_quarter
  ON next_quarter.snapshot_fiscal_quarter_date = base_fields.snapshot_fiscal_quarter_date
  AND next_quarter.adj_ultimate_parent_sales_segment = base_fields.adj_ultimate_parent_sales_segment
  AND next_quarter.deal_category = base_fields.deal_category
  AND next_quarter.snapshot_day_of_fiscal_quarter = base_fields.snapshot_day_of_fiscal_quarter
  AND next_quarter.account_owner_min_team_level = base_fields.account_owner_min_team_level
  AND next_quarter.sales_qualified_source = base_fields.sales_qualified_source
  AND next_quarter.deal_group = base_fields.deal_group
LEFT JOIN date_details next_quarter_date
  ON next_quarter_date.date_actual = base_fields.snapshot_next_fiscal_quarter_date
LEFT JOIN pipeline_gen 
  ON pipeline_gen.snapshot_fiscal_quarter_date = base_fields.snapshot_fiscal_quarter_date
  AND pipeline_gen.adj_ultimate_parent_sales_segment = base_fields.adj_ultimate_parent_sales_segment
  AND pipeline_gen.deal_category = base_fields.deal_category
  AND pipeline_gen.snapshot_day_of_fiscal_quarter = base_fields.snapshot_day_of_fiscal_quarter
  AND pipeline_gen.account_owner_min_team_level = base_fields.account_owner_min_team_level
  AND pipeline_gen.sales_qualified_source = base_fields.sales_qualified_source
  AND pipeline_gen.deal_group = base_fields.deal_group
