SELECT 
    * 
FROM 
    {{ ref('fct_orders') }}
WHERE
    totalPrice < totalPrice_Discounted