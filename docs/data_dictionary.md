# Data Dictionary

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(Kaggle). 9 CSVs, loaded as-is into `raw.*` tables in Postgres — see
`03_sql/ddl/01_create_tables.sql` and `02_python/src/load_to_postgres.py`.

## customers — `olist_customers_dataset.csv` (99,441 rows)

| Column | Notes |
|---|---|
| `customer_id` | Unique per order, not per person. Do not use for repeat-purchase analysis. |
| `customer_unique_id` | The actual person, stable across orders (96,096 distinct). Use this for any customer-level metric. |
| `customer_zip_code_prefix` | First 5 digits of zip code. |
| `customer_city` | |
| `customer_state` | Brazilian state code (e.g. `SP`, `RJ`, `AL`). Drives Q6. |

## orders — `olist_orders_dataset.csv` (99,441 rows)

| Column | Notes |
|---|---|
| `order_id` | Primary key. |
| `customer_id` | FK to `customers.customer_id`. |
| `order_status` | `delivered` (96,478), `shipped`, `unavailable`, `canceled`, `invoiced`, `processing`, `created`, `approved`. Delivery analysis scoped to `delivered` only. |
| `order_purchase_timestamp` | |
| `order_approved_at` | 160 nulls — orders never approved. |
| `order_delivered_carrier_date` | 1,783 nulls — never handed to carrier. |
| `order_delivered_customer_date` | 2,965 nulls — never delivered. Required (non-null) for delivery-delay analysis. |
| `order_estimated_delivery_date` | Compared against the actual delivery date to compute `delay_days` in Q2/Q6. |

## order_items — `olist_order_items_dataset.csv` (112,650 rows)

| Column | Notes |
|---|---|
| `order_id` | FK to `orders`. Not unique — one row per item, so an order with 3 items has 3 rows. Aggregate before joining to order-level tables. |
| `order_item_id` | Sequence number within the order (part of the item-level grain, along with `order_id`). |
| `product_id` | FK to `products`. |
| `seller_id` | FK to `sellers`. Drives Q4. |
| `shipping_limit_date` | |
| `price` | Item price. Sums to total revenue in Q1/Q4. |
| `freight_value` | Shipping cost for the item. Drives Q5. |

## order_payments — `olist_order_payments_dataset.csv` (103,886 rows)

| Column | Notes |
|---|---|
| `order_id` | FK to `orders`. Not unique — some orders have multiple payment rows (installments/split payment). |
| `payment_sequential` | Order of payment if split. |
| `payment_type` | `credit_card` (~74% of volume), `boleto`, `voucher`, `debit_card`, `not_defined`. |
| `payment_installments` | |
| `payment_value` | Sum per `order_id` to avoid double-counting split payments. Not used directly in the six business questions (revenue is computed from `order_items.price` instead). |

## order_reviews — `olist_order_reviews_dataset.csv` (99,224 rows)

| Column | Notes |
|---|---|
| `review_id` | **Not a reliable primary key** — 1,603 rows share a `review_id` with another row under a different `order_id` (identical score/comment/timestamp). Do not key on this. |
| `order_id` | FK to `orders`. ~550 orders have more than one review row — deduplicate on `order_id` (keep first) before joining to delivery data. |
| `review_score` | 1–5. Drives Q2. |
| `review_comment_title` | 88% null — comment is optional, score is mandatory. |
| `review_comment_message` | 59% null. |
| `review_creation_date` | |
| `review_answer_timestamp` | |

## products — `olist_products_dataset.csv` (32,951 rows)

| Column | Notes |
|---|---|
| `product_id` | Primary key. |
| `product_category_name` | In Portuguese — join to `category_translation` for the English name used throughout the analysis. 610 rows (1.9%) are null. |
| `product_name_lenght` | Null for the same 610 rows as category — one underlying defect (incomplete listing), not four independent ones. |
| `product_description_lenght` | Same 610-row null pattern. |
| `product_photos_qty` | Same 610-row null pattern. |
| `product_weight_g` | |
| `product_length_cm` | |
| `product_height_cm` | |
| `product_width_cm` | |

## sellers — `olist_sellers_dataset.csv` (3,095 rows)

| Column | Notes |
|---|---|
| `seller_id` | Primary key. Drives Q4 (seller concentration). |
| `seller_zip_code_prefix` | |
| `seller_city` | |
| `seller_state` | |

## geolocation — `olist_geolocation_dataset.csv` (1,000,163 rows)

| Column | Notes |
|---|---|
| `geolocation_zip_code_prefix` | Zip-code-prefix lookup, not a clean one-row-per-key dimension (many rows share a prefix with slightly different lat/lng). Not used in the six business questions — only relevant if a map visual is added later. |
| `geolocation_lat` | |
| `geolocation_lng` | |
| `geolocation_city` | |
| `geolocation_state` | |

## category_translation — `product_category_name_translation.csv` (71 rows)

| Column | Notes |
|---|---|
| `product_category_name` | Portuguese name, joins to `products.product_category_name`. |
| `product_category_name_english` | English name, used in all category-level reporting (Q1, Q5) and the Power BI dashboard. |

## Grain summary

| Table | Grain |
|---|---|
| customers | one row per order-customer instance (see `customer_id` vs `customer_unique_id` above) |
| orders | one row per order |
| order_items | one row per item within an order (`order_id` + `order_item_id`) |
| order_payments | one row per payment installment/method on an order |
| order_reviews | one row per review submission (dedupe to one per `order_id` before use) |
| products | one row per product |
| sellers | one row per seller |
| geolocation | one row per zip-prefix/lat-lng observation (many-to-one with zip prefix) |
| category_translation | one row per category |
