WITH detailed_orders AS (
    SELECT 
        o.o_orderkey,
        o.o_custkey,
        l.l_suppkey,
        o.o_orderdate,
        o.o_totalprice,
        l.l_extendedprice,
        l.l_discount,
        l.l_shipdate,
        c.c_name,
        c.c_nationkey,
        n.n_name as customer_nation_name,
        s.s_name as supplier_name,
        sn.n_name as supplier_nation_name,
        CASE 
            WHEN o.o_orderdate < '1995-01-01' THEN 'Old Order'
            WHEN o.o_orderdate >= '1995-01-01' THEN 'New Order'
            ELSE 'Unknown'
        END as order_age,
        CASE 
            WHEN l.l_shipdate > o.o_orderdate THEN 'Shipped Late'
            WHEN l.l_shipdate <= o.o_orderdate THEN 'Shipped On Time'
            ELSE 'Unknown'
        END as shipping_status,
        CASE 
            WHEN l.l_discount > 0 AND l.l_extendedprice > 10000 THEN 'High Value Discounted'
            ELSE 'Regular'
        END as order_category
    FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".orders o
    JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".lineitem l ON o.o_orderkey = l.l_orderkey
    JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".customer c ON o.o_custkey = c.c_custkey
    JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".nation n ON c.c_nationkey = n.n_nationkey
    JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".supplier s ON l.l_suppkey = s.s_suppkey
    JOIN "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF10".nation sn ON s.s_nationkey = sn.n_nationkey
)
SELECT 
    *,
    CASE
        WHEN customer_nation_name = supplier_nation_name THEN 'Domestic Order'
        ELSE 'International Order'
    END as order_type
FROM detailed_orders
ORDER BY o_orderkey DESC