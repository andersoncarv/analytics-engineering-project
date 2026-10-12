-- Raw do domínio de vendas: 4 tabelas, tudo em text (espelho fiel da fonte).
-- Idempotente: pode ser executado várias vezes com o mesmo resultado.

CREATE SCHEMA IF NOT EXISTS raw_sales;

-- Clientes (simula um CSV exportado do CRM)
DROP TABLE IF EXISTS raw_sales.customers CASCADE;
CREATE TABLE raw_sales.customers (
    id          text,
    name        text,
    email       text,
    city        text,
    state       text,
    created_at  text,
    _loaded_at  timestamptz DEFAULT now()
);
INSERT INTO raw_sales.customers (id, name, email, city, state, created_at) VALUES
    ('C01', 'Ana Souza',    ' ANA.SOUZA@EMAIL.COM ', 'Recife',    'pe', '2025-03-10'),
    ('C02', 'Bruno Lima',   'bruno.lima@email.com',  'Olinda',    'PE', '2025-06-22'),
    ('C03', 'Carla Mendes', 'carla@email.com',       'Fortaleza', 'CE', '2026-01-15'),
    ('C04', 'Diego Rocha',  'diego.rocha@email.com', 'Natal',     'rn', '2026-02-02');

-- Produtos (simula uma planilha do comercial)
DROP TABLE IF EXISTS raw_sales.products CASCADE;
CREATE TABLE raw_sales.products (
    sku           text,
    product_name  text,
    category      text,
    unit_price    text,
    _loaded_at    timestamptz DEFAULT now()
);
INSERT INTO raw_sales.products (sku, product_name, category, unit_price) VALUES
    ('SKU-001', 'Fone Bluetooth',   'Eletrônicos', '89,90'),
    ('SKU-002', 'Carregador USB-C', 'Eletrônicos', '45,00'),
    ('SKU-003', 'Camiseta Básica',  '  Vestuário', '59,90'),
    ('SKU-004', 'Garrafa Térmica',  'Casa',        '79,90'),
    ('SKU-005', 'Mochila Notebook', 'acessórios',  '149,00');

-- Pedidos (simula o banco do e-commerce)
DROP TABLE IF EXISTS raw_sales.orders CASCADE;
CREATE TABLE raw_sales.orders (
    id               text,
    customer_id      text,
    order_date       text,
    status           text,
    shipping_amount  text,
    total_amount     text,
    _loaded_at       timestamptz DEFAULT now()
);
INSERT INTO raw_sales.orders (id, customer_id, order_date, status, shipping_amount, total_amount) VALUES
    ('1001', 'C01', '2026-09-01', 'aprovado',  '15.00', '149.90'),
    ('1002', 'C02', '2026-09-01', 'aprovado',  '0.00',  '109.80'),
    ('1003', 'C01', '2026-09-03', 'aprovado',  '20.00', '230.50'),
    ('1004', 'C03', '2026-09-05', 'aprovado',  '10.00', '45.00'),
    ('1004', 'C03', '2026-09-05', 'aprovado',  '10.00', '45.00'),
    ('1005', NULL,  '2026-09-07', 'aprovado',  '12.00', '310.00'),
    ('1006', 'C04', '2026-09-08', 'cancelado', '15.00', '104.90');

-- Itens de pedido (simula o banco do e-commerce)
DROP TABLE IF EXISTS raw_sales.order_items CASCADE;
CREATE TABLE raw_sales.order_items (
    order_id         text,
    line_number      text,
    sku              text,
    quantity         text,
    unit_price       text,
    discount_amount  text,
    _loaded_at       timestamptz DEFAULT now()
);
INSERT INTO raw_sales.order_items (order_id, line_number, sku, quantity, unit_price, discount_amount) VALUES
    ('1001', '1', 'SKU-001', '1', '89.90',  '0.00'),
    ('1001', '2', 'SKU-002', '1', '45.00',  '0.00'),
    ('1002', '1', 'SKU-003', '2', '59.90',  '10.00'),
    ('1003', '1', 'SKU-005', '1', '149.00', '0.00'),
    ('1003', '2', 'SKU-004', '1', '79.90',  '0.00'),
    ('1004', '1', 'SKU-999', '1', '35.00',  '0.00'),
    ('1005', '1', 'SKU-005', '2', '149.00', '0.00'),
    ('1006', '1', 'SKU-001', '1', '89.90',  '0.00');    