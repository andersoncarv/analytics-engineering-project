-- Cria o schema raw e uma carga de exemplo de pedidos.
-- Idempotente: pode ser executado várias vezes com o mesmo resultado.

CREATE SCHEMA IF NOT EXISTS raw_sales;

DROP TABLE IF EXISTS raw_sales.orders;

CREATE TABLE raw_sales.orders (
    id            text,
    customer_id   text,
    order_date    text,
    total_amount  text,
    _loaded_at    timestamptz DEFAULT now()
);

INSERT INTO raw_sales.orders (id, customer_id, order_date, total_amount) VALUES
    ('1001', 'C01', '2026-09-01', '150.00'),
    ('1002', 'C02', '2026-09-01', '89.90'),
    ('1003', 'C01', '2026-09-03', '230.50'),
    ('1004', 'C03', '2026-09-05', '45.00'),
    ('1004', 'C03', '2026-09-05', '45.00'),
    ('1005', NULL,  '2026-09-07', '310.00');