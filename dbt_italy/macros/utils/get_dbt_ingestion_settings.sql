{% macro get_dbt_ingestion_settings(id_dbt_ingestion_flow_id) -%}

    {% set query_ingestion_settings %}
        SELECT
            id_dbt_ingestion_flow_id,
            gn_volume_name,
            gn_volume_nested_folder_name,
            gn_format_type,
            gn_spark_format_type,
            gn_csv_separator,
            fl_is_csv_with_header_flag
        FROM {{ ref('cfg_dbt_ingestion_settings') }}
        WHERE id_dbt_ingestion_flow_id = {{ id_dbt_ingestion_flow_id }}
    {% endset %}

  {% set results = run_query(query_ingestion_settings) %}

  {% if execute %}
    {% set row = results.rows[0] %}
    {% set dbt_ingestion_settings = {
        'id_dbt_ingestion_flow_id': row[0],
        'gn_volume_name': row[1],
        'gn_volume_nested_folder_name': row[2],
        'gn_format_type': row[3],
        'gn_spark_format_type': row[4],
        'gn_csv_separator': row[5],
        'fl_is_csv_with_header_flag': row[6]
    } %}

    {{ return(dbt_ingestion_settings) }}
  {% endif %}

{%- endmacro %}