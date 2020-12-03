{%- macro grant_usage_to_schemas() -%}

	{%- set schema_name = 'analytics' -%}

    {#
        This works in conjunction with the Permifrost roles.yml file. 
        This will only run on production and mainly covers our bases so that
        new models created will be immediately available for querying to the 
        roles listed.

    #}

    {%- set non_sensitive = 'dbt_analytics' -%}
    {%- set sensitive = 'dbt_analytics_sensitive' -%}
    {%- set clones = 'dbt_analytics_clones' -%}

    {%- if target.name == 'prod' -%}
        grant usage on schema {{ schema_name }} to role {{ non_sensitive }};
        grant select on all tables in schema {{ schema_name }} to role {{ non_sensitive }};
        grant select on all views in schema {{ schema_name }} to role {{ non_sensitive }};

        grant usage on schema {{ schema_name }}_staging to role {{ non_sensitive }};
        grant select on all tables in schema {{ schema_name }}_staging to role {{ non_sensitive }};
        grant select on all views in schema {{ schema_name }}_staging to role {{ non_sensitive }};

        grant usage on schema {{ schema_name }}_clones to role {{ clones }};
        grant select on all tables in schema {{ schema_name }}_clones to role {{ clones }};
        grant select on all views in schema {{ schema_name }}_clones to role {{ clones }};

        grant usage on schema common to role {{ non_sensitive }};
        grant select on all tables in schema common to role {{ non_sensitive }};
        grant select on all views in schema common to role {{ non_sensitive }};
        
        grant usage on schema common_mapping to role {{ non_sensitive }};
        grant select on all tables in schema common_mapping to role {{ non_sensitive }};
        grant select on all views in schema common_mapping to role {{ non_sensitive }};

        grant usage on schema covid19 to role {{ non_sensitive }};
        grant select on all tables in schema covid19 to role {{ non_sensitive }};
        grant select on all views in schema covid19 to role {{ non_sensitive }};

        grant usage on schema prep.sensitive to role {{ sensitive }};
        grant select on all tables in schema prep.sensitive to role {{ sensitive }};
        grant select on all views in schema prep.sensitive to role {{ sensitive }};

        grant select on table prep.sensitive.bamboohr_id_employee_number_mapping to role lmai;
    {%- endif -%}

{%- endmacro -%} 
