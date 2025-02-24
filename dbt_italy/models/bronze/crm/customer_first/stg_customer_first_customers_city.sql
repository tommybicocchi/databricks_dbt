{{
    config({
        "materialized" : "incremental",
        "tags" : ["bronze", "crm"],
        "file_format" : "delta",
        "incremental_strategy" : "append"
    })
}}

-- MAIN PARAMETERS
{% set volume = var('volume') %}

-- DBT INGESTION SETTINGS
{% set dbt_ingestion_settings = get_dbt_ingestion_settings(2) %}
{% set gn_volume_name = dbt_ingestion_settings.gn_volume_name %}
{% set gn_volume_nested_folder_name = dbt_ingestion_settings.gn_volume_nested_folder_name %}
{% set gn_format_type = dbt_ingestion_settings.gn_format_type %}
{% set gn_csv_separator = dbt_ingestion_settings.gn_csv_separator %}
{% set fl_is_csv_with_header_flag = dbt_ingestion_settings.fl_is_csv_with_header_flag %}

SELECT
    CAST(customer_id AS LONG) AS customer_id,
    customer_name,
    city,
    TRY_CAST(last_updated AS DATE) AS last_updated,
    _metadata.file_path AS gn_file_path,
    _metadata.file_name AS gn_file_name,
    _metadata.file_modification_time AS dt_ingestion_timestamp
FROM read_files(
    '/{{volume}}/{{this.database}}/{{this.schema}}/{{gn_volume_name}}/{{gn_volume_nested_folder_name}}/*.{{gn_format_type}}',
    format => '{{gn_format_type}}',
    header => {{fl_is_csv_with_header_flag}},
    sep => '{{gn_csv_separator}}'
)
{% if is_incremental() %}
WHERE _metadata.file_modification_time > (
    SELECT max(dt_ingestion_timestamp) from {{ this }}
)
{% endif %}