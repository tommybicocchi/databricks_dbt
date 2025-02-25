{{
    config({
        "materialized" : "ephemeral",
        "tags" : ["silver", "sales"]
    })
}}

WITH stg_bakehouse_franchises
AS (
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
        dt_ingestion_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY franchiseID
            ORDER BY dt_ingestion_timestamp DESC
        ) AS row_number_franchiseID
    FROM {{ ref( 'stg_retail_bakehouse_sales_franchises' ) }}
)
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
    dt_ingestion_timestamp
FROM stg_bakehouse_franchises
WHERE row_number_franchiseID = 1