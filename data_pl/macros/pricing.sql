{% macro discounted_amount(extended_price, discount_pc, scale=2) %}
    ({{extended_price}} * (1 - {{discount_pc}}))::decimal(16, {{ scale }})
{% endmacro %}