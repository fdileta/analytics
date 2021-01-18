
WITH milestones AS (

    SELECT *
    FROM {{ref('gitlab_dotcom_milestones')}}

),projects AS (

    -- A milestone joins to a namespace through EITHER a project or group
    SELECT *
    FROM {{ref('gitlab_dotcom_projects')}}

), internal_namespaces AS (

    SELECT
      namespace_id
    FROM {{ref('gitlab_dotcom_namespace_lineage')}}
    WHERE namespace_is_internal = True

), final AS (

    SELECT
      milestones.milestone_id,
      milestones.milestone_title, 
      milestones.milestone_description,
      {% for field in fields_to_mask %}
      IFF(internal_namespaces.namespace_id IS NULL,
          'private - masked', {{field}})                     AS {{field}},
      {% endfor %}
      
      milestones.due_date,
      milestones.group_id,
      milestones.created_at                                  AS milestone_created_at,
      milestones.updated_at                                  AS milestone_updated_at,
      milestones.milestone_status,
      COALESCE(milestones.group_id, projects.namespace_id)   AS namespace_id,
      milestones.project_id,
      milestones.start_date

    FROM milestones
      LEFT JOIN projects
        ON milestones.project_id = projects.project_id
      LEFT JOIN internal_namespaces
        ON projects.namespace_id = internal_namespaces.namespace_id
        OR milestones.group_id = internal_namespaces.namespace_id
        
)

SELECT *
FROM final
