with order_items as (

    select * from {{ ref('stg_sales__order_items') }}

),

orders as (

    select * from {{ ref('stg_sales__orders') }}

),

joined as (

    select
        order_items.order_id,
        order_items.line_number,
        order_items.sku,
        orders.customer_id,
        orders.order_date,
        orders.status,
        orders.is_cancelled,
        order_items.quantity,
        order_items.unit_price,
        order_items.discount_amount,
        order_items.quantity * order_items.unit_price                    as gross_amount,
        order_items.quantity * order_items.unit_price
            - order_items.discount_amount                                as net_amount
    from order_items
    left join orders
        on orders.order_id = order_items.order_id

)

select * from joined