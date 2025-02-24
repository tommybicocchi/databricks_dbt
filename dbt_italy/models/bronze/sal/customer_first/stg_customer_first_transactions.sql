{{
    config({
        "materialized" : "incremental",
        "tags" : ["bronze", "sales"],
        "file_format" : "delta",
        "incremental_strategy" : "append"
    })
}}

-- MAIN PARAMETERS
{% set volume = var('volume') %}

-- DBT INGESTION SETTINGS
{% set dbt_ingestion_settings = get_dbt_ingestion_settings(1) %}
{% set gn_volume_name = dbt_ingestion_settings.gn_volume_name %}
{% set gn_volume_nested_folder_name = dbt_ingestion_settings.gn_volume_nested_folder_name %}
{% set gn_format_type = dbt_ingestion_settings.gn_format_type %}

WITH txt_parsing
AS (
    SELECT
        value AS gn_txt_content,
        CASE
            WHEN upper(trim(value)) LIKE '%CUSTOMER_ID%' THEN 1
            ELSE 0
        END AS gn_group_marker,
        ROW_NUMBER() OVER (ORDER BY NULL) AS id_row_id,
        _metadata.file_path AS gn_file_path,
        _metadata.file_name AS gn_file_name,
        _metadata.file_modification_time AS dt_ingestion_timestamp
    FROM read_files(
        '/{{volume}}/{{this.database}}/{{this.schema}}/{{gn_volume_name}}/{{gn_volume_nested_folder_name}}/*.{{gn_format_type}}'
    )
    {% if is_incremental() %}
    WHERE _metadata.file_modification_time > (
        SELECT max(dt_ingestion_timestamp) from {{ this }}
    )
    {% endif %}
)
SELECT
    id_row_id,
    SUM(gn_group_marker) OVER (ORDER BY id_row_id) AS id_group_id,
    TRIM(SPLIT(gn_txt_content, ':')[0]) AS gn_row_key,
    TRIM(SPLIT(gn_txt_content, ':')[1]) AS gn_row_value,
    gn_file_path,
    gn_file_name,
    dt_ingestion_timestamp
FROM txt_parsing
WHERE TRIM(UPPER(gn_txt_content)) NOT LIKE '%---%'