SELECT 
    orders.order_key, 
    orders.customer_key, 
    orders.order_date, 
    line_items.lineitem_key, 
    line_items.line_num, 
    line_items.part_key, 
    line_items.extended_price AS item_original_price, 
    {{ discounted_amount('line_items.extended_price', 'line_items.discount') }} AS item_discount_price
FROM 
    {{ ref('staging_tpch_orders') }} AS orders
JOIN 
    {{ ref('staging_tpch_line_items') }} AS line_items
ON
    orders.order_key = line_items.order_key
ORDER BY
    orders.order_date