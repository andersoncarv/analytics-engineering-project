with customers as (

    select * from {{ ref('stg_sales__customers') }}

),

unknown_member as (

    select
        '-1'                          as customer_id,
        'Cliente não identificado'    as customer_name,
        cast(null as text)            as email,
        cast(null as text)            as city,
        cast(null as text)            as state,
        cast(null as date)            as customer_created_at

),

final as (

    select
        customer_id,
        customer_name,
        email,
        city,
        state,
        customer_created_at
    from customers

    union all

    select * from unknown_member

)

select * from final