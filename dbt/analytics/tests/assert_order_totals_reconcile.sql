-- Regra: o total informado pela fonte deve ser igual à soma
-- dos itens (líquidos de desconto) mais o frete do pedido.
-- Severidade warn: a divergência é investigada com a fonte, não bloqueia o build.

{{ config(severity = 'warn') }}

with items as (

    select
        order_id,
        sum(net_amount) as items_amount
    from {{ ref('fct_sales') }}            -- LACUNA 1: de qual modelo vêm os itens?
    group by order_id

),

orders as (

    select
        order_id,
        shipping_amount,
        reported_total_amount
    from {{ ref('stg_sales__orders') }}            -- LACUNA 2: qual modelo tem frete e total informado?

)

select
    orders.order_id,
    items.items_amount,
    orders.shipping_amount,
    items.items_amount + orders.shipping_amount                          as expected_total,
    orders.reported_total_amount,
    orders.reported_total_amount - (items.items_amount + orders.shipping_amount) as difference
from orders
join items
    on items.order_id = orders.order_id
where abs(orders.reported_total_amount - (items.items_amount + orders.shipping_amount)) > 0.01