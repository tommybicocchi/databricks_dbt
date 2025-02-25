{{
    config({
        "materialized" : "streaming_table",
        "tags" : ["bronze", "sales", "online"]
    })
}}

SELECT
    ROW_NUMBER() OVER ( ORDER BY NULL ) AS id_row_id,
    *,
    CURRENT_TIMESTAMP AS dt_ingestion_timestamp,
    _metadata
FROM STREAM read_files(
    '/Volumes/bronze/sal/_bronze__sources/CUSTOMERS_FIRST/*.txt',
    format => 'text'
)