with source as (

    select * from {{ source('sales', 'order_items') }}

),

renamed as (

    select
        order_id,
        cast(line_number as integer)              as line_number,
        sku,
        cast(quantity as integer)                 as quantity,
        cast(unit_price as numeric(18, 2))        as unit_price,
        cast(discount_amount as numeric(18, 2))   as discount_amount,
        _loaded_at
    from source

)

select * from renamed