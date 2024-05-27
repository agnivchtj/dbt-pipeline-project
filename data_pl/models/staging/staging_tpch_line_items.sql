SELECT 
    {{
        dbt_utils.generate_surrogate_key([
            'l_orderkey', 
            'l_linenumber'
        ])
    }} as lineitem_key, 
    l_orderkey AS order_key, 
    l_partkey AS part_key, 
    l_suppkey AS supplier_key, 
    l_linenumber AS line_num, 
    l_quantity AS quantity, 
    l_extendedprice AS extended_price, 
    l_discount AS discount, 
    l_tax AS tax, 
    l_returnflag AS return_flag, 
    l_linestatus AS line_status, 
    l_shipdate AS shipping_date, 
    l_commitdate AS date_committed, 
    l_receiptdate AS date_of_receipt, 
    l_shipinstruct AS shipping_instruct, 
    l_shipmode AS shipping_mode, 
    l_comment AS comment
FROM {{ source('tpch', 'lineitem') }}