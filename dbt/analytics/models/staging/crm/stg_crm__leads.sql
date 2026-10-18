with source as (

    select * from {{ source('crm', 'leads') }}

),

renamed as (

    select
        lead_id,
        trim(nome)                                                  as lead_name,
        lower(trim(email))                                          as email,
        trim(origem)                                                as lead_source,
        lower(trim(status))                                         as status,
        to_date(criado_em, 'DD/MM/YYYY')                            as created_date,

        -- Premissa: o CRM exporta em horário de Brasília (a confirmar com o comercial).
        to_timestamp(atualizado_em, 'DD/MM/YYYY HH24:MI')::timestamp
            at time zone 'America/Sao_Paulo'                        as updated_at,

        -- Contrato: valores no formato do Excel brasileiro (1.299,90).
        cast(replace(replace(valor_estimado, '.', ''), ',', '.') as numeric(18, 2))
                                                                    as estimated_value,

        -- Data da exportação, extraída do nome do arquivo (leads_AAAAMMDD.csv).
        -- Se o padrão do nome mudar, vira nula e o teste not_null acusa.
        to_date(substring(_source_file from '(\d{8})'), 'YYYYMMDD') as source_file_date,

        _source_file,
        _row_number
    from source

),

with_latest as (

    select
        *,
        max(source_file_date) over ()                               as latest_file_date
    from renamed

),

flagged as (

    select
        *,
        bool_or(source_file_date = latest_file_date)
            over (partition by lead_id)                             as is_in_latest_file
    from with_latest

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by lead_id
            order by updated_at desc, source_file_date desc, _row_number desc
        ) as rn
    from flagged

)

select
    lead_id,
    lead_name,
    email,
    lead_source,
    status,
    created_date,
    updated_at,
    estimated_value,
    is_in_latest_file,
    source_file_date,
    _source_file
from deduplicated
where rn = 1