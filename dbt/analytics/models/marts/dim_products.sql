with products as (

    select * from {{ ref('stg_sales__products') }}
),


unknown_member as (

    select
        '-1'                          as sku,
        'Produto não identificado'    as product_name,
        'Não identificado'            as category,
        cast(null as numeric(18,2))   as list_price
),

final as (

    select
        sku,
        product_name,
        category,
        list_price
    from products 

    union all

    select * from unknown_member

)

select * from final
