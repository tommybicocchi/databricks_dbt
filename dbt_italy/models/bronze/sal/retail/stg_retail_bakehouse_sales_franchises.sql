{{
    config({
        "materialized" : "table",
        "tags" : ["bronze", "sales", "retail"],
        "file_format" : "delta"
    })
}}

SELECT
    *,
    CURRENT_TIMESTAMP AS dt_ingestion_timestamp
FROM {{ source( 'sales', 'sales_franchises' ) }}