# DAX Measures — Commercial Overview, Delivery Performance, Customer & Seller

All measures live in a dedicated `_Measures` table, kept separate from data
tables per standard Power BI practice.

## Core
- **Total Revenue** = `SUM('raw order_items'[price])`
- **Total Orders** = `DISTINCTCOUNT('raw orders'[order_id])`
- **Average Order Value** = `DIVIDE([Total Revenue], [Total Orders])`
- **Total Freight** = `SUM('raw order_items'[freight_value])`
- **Freight % of Price** = `DIVIDE([Total Freight], [Total Revenue]) * 100`

## Delivery & satisfaction
- **Delivery Bucket** (calculated column on `raw orders`) — buckets each
  order into Early / On Time / 1-3 Days Late / 4+ Days Late / Not Delivered,
  based on `DATEDIFF` between estimated and actual delivery date.
- **Avg Review Score** = `AVERAGE('raw reviews'[review_score])`
- **On-Time Delivery %** — share of delivered orders in the Early/On Time
  buckets.
- **Late Delivery Rate %** — share of delivered orders in the 4+ Days Late
  bucket. Used for the by-state comparison; filtered to states with 100+
  orders to match the SQL methodology (avoids small-sample distortion).

## Customer & seller
- **Total Unique Customers** = `DISTINCTCOUNT('raw customers'[customer_unique_id])`
  — keyed on customer_unique_id, not customer_id, since customer_id is
  generated fresh per order (see decisions_log.md).
- **Repeat Customers** — count of unique customers with more than one order,
  via SUMMARIZE over customer_unique_id.
- **Repeat Purchase Rate %** = `DIVIDE([Repeat Customers], [Total Unique Customers]) * 100`
- **Seller Revenue Rank** — RANKX over sellers by total revenue, used to
  drive the seller concentration chart (Top 10 by Total Revenue).

## Validation
Every measure's output was checked against the equivalent Python and SQL
result before being added to a report page. See docs/decisions_log.md and
03_sql/analysis/ for the cross-tool validation history.
