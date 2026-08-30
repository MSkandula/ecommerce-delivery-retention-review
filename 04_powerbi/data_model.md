# Power BI Data Model

Source tables are imported directly from the `raw` schema in Postgres (same tables used
in `03_sql/`), prefixed `raw <table>` in the model — e.g. `raw orders`, `raw order_items`,
`raw customers`, `raw products`, `raw sellers`, `raw reviews`.

## Structure

- **Fact tables:** `raw order_items` (price, freight_value — grain: one row per item),
  `raw orders` (one row per order, carries status and the delivery date fields used to
  compute `Delivery Bucket`).
- **Dimension tables:** `raw customers`, `raw products` (joined to
  `raw category_translation` for English category names), `raw sellers`.
- **`raw reviews`:** joins to `raw orders` on `order_id`, deduplicated the same way as
  the SQL and pandas versions (one row per order) — see `decisions_log.md`.
- **`DateTable`:** a calculated date table used for the time-intelligence visuals
  (revenue and order trend by month) on the Commercial Overview page.
- **`_Measures`:** a dedicated disconnected table holding every DAX measure (see
  `dax_measures.md`), kept separate from data tables per standard Power BI practice —
  confirmed as the pattern actually used in the report, not just documented intent.

## Relationships

Joins follow the same keys as the SQL layer:

| From | To | Key |
|---|---|---|
| `raw order_items` | `raw orders` | `order_id` |
| `raw order_items` | `raw products` | `product_id` |
| `raw order_items` | `raw sellers` | `seller_id` |
| `raw orders` | `raw customers` | `customer_id` |
| `raw orders` | `raw reviews` | `order_id` |
| `raw products` | `raw category_translation` | `product_category_name` |
| `raw orders` | `DateTable` | `order_purchase_timestamp` |

`customer_unique_id` (not `customer_id`) is the key used everywhere a customer-level
metric is needed (e.g. `Repeat Purchase Rate %`) — see `dax_measures.md` and
`decisions_log.md` for why.

## Report pages

Three pages, each backing one or more of the six business questions:

- **Commercial Overview** — revenue and order trend over time, average order value,
  repeat purchase rate, and revenue by category (Q1, Q3).
- **Delivery Performance** — late delivery rate by state, average review score by
  delivery bucket (Q2, Q6).
- **Customer & Seller** — revenue by seller (Q4).

## Validation

Every measure was checked against the equivalent Python and SQL result before being
added to a report page — see `dax_measures.md` → Validation and `decisions_log.md`.
