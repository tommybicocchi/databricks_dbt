{{
    config({
        "materialized" : "table",
        "tags" : ["bronze", "sales"],
        "file_format" : "delta"
    })
}}

SELECT
      franchiseID,
      name,
      city,
      district,
      zipcode,
      country,
      size,
      longitude,
      latitude,
      supplierID,
      CURRENT_TIMESTAMP AS dt_ingestion_timestamp
FROM {{ source( 'sales', 'sales_franchises' ) }}