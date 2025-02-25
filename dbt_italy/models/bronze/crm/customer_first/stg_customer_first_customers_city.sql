{{
    config({
        "materialized" : "streaming_table",
        "tags" : ["bronze", "crm", "online"]
    })
}}

SELECT
    *,
    CURRENT_TIMESTAMP AS dt_ingestion_timestamp,
    _metadata
FROM STREAM read_files(
    '/Volumes/bronze/crm/_bronze__sources/CUSTOMERS_FIRST_CITIES/*.csv',
    format => 'csv',
    header => true,
    sep => ';'
)