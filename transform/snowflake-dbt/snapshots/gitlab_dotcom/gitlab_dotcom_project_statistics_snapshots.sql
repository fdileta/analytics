{% snapshot gitlab_dotcom_project_statistics_snapshots %}

    {{
        config(
          unique_key='id',
          strategy='check',
          check_cols=['snapshot_surrogate_key'],
        )
    }}
    
    SELECT *,
      {{ dbt_utils.surrogate_key([
              'repository_size', 
              'commit_count', 
              'storage_size', 
              'repository_size',
              'lfs_objects_size',
              'packages_size',
              'wiki_size',
              'build_artifacts_size', 
              'shared_runners_seconds', 
              'shared_runners_seconds_last_reset',
          ]) }} AS snapshot_surrogate_key
    FROM {{ source('gitlab_dotcom', 'project_statistics') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY _uploaded_at DESC) = 1
    
{% endsnapshot %}
