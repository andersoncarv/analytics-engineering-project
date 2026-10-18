-- Profiling do raw de vendas. Somente leitura: pode rodar quantas vezes quiser.

\echo '== 1. Unicidade: linhas x pedidos distintos'
select count(*) as linhas, count(distinct id) as pedidos_distintos
from raw_sales.orders;

\echo '== 2. Integridade: SKUs vendidos que não existem no cadastro'
select distinct oi.sku
from raw_sales.order_items oi
left join raw_sales.products p on p.sku = oi.sku
where p.sku is null;

\echo '== 3. Padronização: textos com espaço ou caixa fora do padrão'
select 'email' as coluna, email as valor from raw_sales.customers where email <> lower(trim(email))
union all
select 'state', state from raw_sales.customers where state <> upper(trim(state))
union all
select 'category', category from raw_sales.products where category <> trim(category) or category = lower(category);

\echo '== 4. Formato numérico: preços que não convertem direto para número'
select sku, unit_price
from raw_sales.products
where unit_price !~ '^[0-9]+(\.[0-9]+)?$';

\echo '== 5. Reconciliação: total do pedido x soma dos itens + frete'
with items as (
    select order_id,
           sum(quantity::int * unit_price::numeric - discount_amount::numeric) as items_amount
    from raw_sales.order_items
    group by order_id
),
orders as (
    select distinct id, shipping_amount::numeric as shipping, total_amount::numeric as total
    from raw_sales.orders
)
select o.id,
       i.items_amount,
       o.shipping,
       i.items_amount + o.shipping           as total_esperado,
       o.total                               as total_informado,
       o.total - (i.items_amount + o.shipping) as diferenca
from orders o
join items i on i.order_id = o.id
order by o.id;