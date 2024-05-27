SELECT 
    order_key AS orderKey,
    sum(item_original_price) AS totalPrice,
    sum(item_discount_price) AS totalPrice_Discounted
FROM 
    {{ ref('int_order_items') }}
GROUP BY 
    order_key