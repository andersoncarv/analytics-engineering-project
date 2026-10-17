with order_items as (

    select * from {{ ref('int_order_items_enriched') }}

),

products as (

    select sku from {{ ref('dim_products') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['order_items.order_id', 'order_items.line_number']) }}     as sales_key,
        order_items.order_id,
        order_items.line_number,
        order_items.order_date,
        coalesce(order_items.customer_id, '-1')     as customer_id,
        case
            when products.sku is null then '-1'
            else order_items.sku
        end                                         as sku,
        order_items.status,
        order_items.is_cancelled,
        order_items.quantity,
        order_items.unit_price,
        order_items.discount_amount,
        order_items.gross_amount,
        order_items.net_amount
    from order_items
    left join products
        on products.sku = order_items.sku

)

select * from final