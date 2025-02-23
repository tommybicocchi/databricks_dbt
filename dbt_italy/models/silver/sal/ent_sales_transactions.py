def model(dbt, session):
    dbt.config(
        materialized="incremental",
        submission_method="serverless_cluster"
    )
    
    import pyspark.sql.functions as F
    from pyspark.sql.window import Window
    
    pivoted_customers_first_transaction = (
        dbt.ref('stg_customer_first_transactions')
        .groupBy(
            'id_group_id'
        )
        .pivot(
            'gn_row_key'
        )
        .agg(
            F.first('gn_row_value')
        )
        .selectExpr(
            "CONCAT(item_id,'-',customer_id) AS id_transaction_id",
            'customer_id AS cd_customer_code',
            'customer_name AS gn_customer_name',
            '"CUSTOMERS_FIRST" AS gn_source_system_name', 
            'CURRENT_TIMESTAMP AS dt_ingestion_timestamp'
        )
    )
    
    all_transactions = (
        pivoted_customers_first_transaction
        .unionByName(
            dbt.ref('ent_retail_sales_transactions')
            .selectExpr(
                'CAST(id_source_system_transaction_id AS STRING) AS id_transaction_id',
                'cd_customer_code',
                'NULL AS gn_customer_name',
                '"RETAIL" AS gn_source_system_name',
                'dt_ingestion_timestamp'
            )
        )
        .distinct()
    )
    
    return all_transactions
    
    