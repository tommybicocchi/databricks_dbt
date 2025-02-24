{{
    config({
        "materialized" : "incremental",
        "tags" : ["silver", "sales"],
        "file_format" : "delta",
        "unique_key" : "id_source_system_transaction_id",
        "incremental_strategy" : "merge"
    })
}}

SELECT
    transac.transactionID AS id_source_system_transaction_id,
    transac.customerID AS cd_customer_code,
    transac.franchiseID AS cd_franchise_code,
    transac.product AS gn_product_name,
    transac.quantity AS nm_quantity_of_product_sold_number,
    transac.unitPrice AS nm_price_per_unit_number,
    transac.totalPrice AS nm_total_price_number,
    transac.paymentMethod AS gn_payment_method,
    CAST(transac.cardNumber AS STRING) AS gn_card_number,
    franch.city AS gn_city_name,
    transac.dateTime AS dt_source_system_ingestion_timestamp,
    transac.dateTime AS dt_ingestion_timestamp
FROM {{ ref( 'stg_retail_bakehouse_sales_transactions' )}} transac
LEFT JOIN {{ ref( 'eph_bakehouse_sales_franchises_deduplicated' )}} franch
ON transac.franchiseID = franch.franchiseID