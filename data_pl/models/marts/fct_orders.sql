SELECT 
    orders.*, 
    order_summary.totalPrice, 
    order_summary.totalPrice_Discounted
FROM 
    {{ ref('staging_tpch_orders') }} AS orders
JOIN 
    {{ ref('int_order_items_summary') }} AS order_summary
ON
    orders.order_key = order_summary.orderKey
ORDER BY 
    orders.order_date