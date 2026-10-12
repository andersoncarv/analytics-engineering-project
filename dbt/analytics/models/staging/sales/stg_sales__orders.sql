with source as ( 
    
    select * from {{source('sales','orders')}}
),



renamed as (

    select
        id                                   as order_id,
        customer_id,
        cast(order_date as date)             as order_date,
        cast(total_amount as numeric(18, 2)) as total_amount,
        _loaded_at
    from source

),

deduplicated as (

    select 
        order_id,
        customer_id,
        order_date,
        total_amount,
        _loaded_at,
        row_number() over(partition by order_id order by _loaded_at desc) as rn
    from renamed
)


select 
    order_id,
    customer_id,
    order_date,
    total_amount,
    _loaded_at

from deduplicated where rn = 1

