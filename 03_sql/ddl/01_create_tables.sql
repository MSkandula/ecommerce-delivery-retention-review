CREATE SCHEMA IF NOT EXISTS raw;

DROP TABLE IF EXISTS raw.orders CASCADE;
CREATE TABLE raw.orders (
    order_id                        TEXT PRIMARY KEY,
    customer_id                     TEXT,
    order_status                    TEXT,
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);