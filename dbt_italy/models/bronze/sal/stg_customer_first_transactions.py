def model(dbt, session):
    dbt.config(
        materialized = 'table',
        submission_method="serverless_cluster"
    )

    import pyspark.sql.functions as F
    from pyspark.sql.window import Window
    from pathlib import Path

    full_path = dbt.config.get('filename')

    target_model = (
        session
        .read.text(full_path)
        .withColumn(
            'group_marker',
            F.expr('''
                    CASE
                    WHEN value LIKE '%---%' THEN 1
                    ELSE 0
                    END
            ''')
        )
        .withColumn(
            'row_id',
            F.row_number().over(Window.orderBy(F.monotonically_increasing_id()))
        )
        .withColumn(
            'group_id',
            F.sum("group_marker").over(Window.orderBy("row_id"))
        )
        .where(
            F.expr("value NOT LIKE '%---%'")
        )
        .withColumn(
            "row_key",
            F.trim(F.split(F.col("value"), ":", 2).getItem(0))
        )
        .withColumn(
            "row_value",
            F.trim(F.split(F.col("value"), ":", 2).getItem(1))
        )
        .selectExpr(
            "row_id",
            "group_id",
            "row_key",
            "row_value"
        )
    )
    
    return target_model
