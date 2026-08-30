# Excel First Look — Olist E-Commerce Dataset

**Purpose:** initial profiling of the 9 raw tables — scale, keys, and data quality issues —
before any cleaning or modelling. Observations only, no edits to source data.

---

## 1. Customers — `olist_customers_dataset`

| Metric | Value |
|---|---|
| Total rows | 99,441 |
| Distinct `customer_id` | 99,441 (unique) |
| Distinct `customer_unique_id` | 96,096 |

**Finding:** `customer_id` is generated fresh per order; `customer_unique_id` identifies the
actual person across orders. The gap (3,345) means at least 3,345 orders belong to a
customer who has ordered before.

**So what:** this is the first read on repeat purchase behaviour — a business cares whether
it's acquiring new customers or retaining existing ones, and on this raw cut, repeat orders
are a small minority. Worth quantifying precisely and asking why retention is this low.

**Carried forward:** any customer-level analysis must key on `customer_unique_id`, not
`customer_id` — using the wrong key understates repeat rate.

---

## 2. Orders — `olist_orders_dataset`

| Metric | Value |
|---|---|
| Total rows | 99,441 |
| Distinct `order_id` | 99,441 (unique) |
| Blank `order_delivered_customer_date` | 2,965 |

**`order_status` breakdown:**

| Status | Count |
|---|---|
| delivered | 96,478 |
| shipped | 1,107 |
| unavailable | 609 |
| canceled | 625 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |
| **Total** | **99,441** |

**Finding:** non-delivered statuses sum to 2,963 against 2,965 blank delivery dates — the
two independent fields agree almost exactly, a good sign the data is internally consistent.

**So what:** roughly 3% of orders never completed. That's a fulfilment leakage rate worth
flagging on its own — before even asking about *late* delivery, some orders don't deliver
at all.

**Decision:** delivery-performance analysis scoped to delivered orders only, since "late"
isn't meaningful for a cancelled order. Logged in `docs/decisions_log.md`.

---

## 3. Order Items — `olist_order_items_dataset`

| Metric | Value |
|---|---|
| Total rows | 112,650 |
| Distinct `order_id` | 98,666 |
| Freight-to-price ratio (aggregate) | ~22.6% |

**Finding:** 98,666 orders produce 112,650 item rows — a meaningful share of orders contain
multiple items. Joining this table to `orders` and summing an order-level figure without
aggregating first will overstate results.

**So what:** freight running at ~22.6% of item price, in aggregate, is a real margin
question — if that ratio is concentrated in a handful of categories rather than spread
evenly, that's a pricing or shipping-strategy conversation.

**Also noted:** 98,666 is below the 99,441 total orders — roughly 775 orders have no item
rows at all, plausibly the cancelled/unavailable ones from the orders table above.

---

## 4. Payments — `olist_order_payments_dataset`

| Metric | Value |
|---|---|
| Total rows | 103,886 |

**`payment_type` breakdown:**

| Type | Count |
|---|---|
| credit_card | 76,795 |
| boleto | 19,784 |
| voucher | 5,775 |
| debit_card | 1,529 |
| not_defined | 3 |
| **Total** | **103,886** |

**Finding:** 103,886 payment rows against 99,441 orders — some orders carry more than one
payment record, likely installments or a split payment method.

**So what:** credit card accounts for ~74% of payment volume. That's the dominant channel
to design any payment-experience or fee-cost analysis around.

**Open item:** confirm the exact distinct-order count inside this table before summing
`payment_value` per order, to avoid double-counting split payments.

---

## 5. Reviews — `olist_order_reviews_dataset`

| Metric | Value |
|---|---|
| Total rows | 99,224 |
| Distinct `order_id` | 98,674 |
| Rows with blank review comment | 59,022 |

**Finding:** ~550 orders carry more than one review record — needs handling before
joining review score to delivery data, so scores aren't double-counted per order.

**So what:** ~59% of reviews have no written comment, which is expected — the numeric
score is mandatory, the comment isn't. Not a data quality problem, just means any
text-based analysis has a smaller usable base than the full review count.

**Open item:** score distribution needs recalculating correctly (count of reviews per
score, not sum of the score values) — first fix to carry into the next stage.

---

## 6–9. Products, Sellers, Geolocation, Category Translation

Lighter pass — structural checks only, since these carry less weight for the core
business questions:

- **Products** (~33K rows): key `product_id`. Category names are in Portuguese; a
  translation lookup table is present and will be joined in so category names are
  readable in the final analysis and dashboard.
- **Sellers** (~3K rows): key `seller_id`. Feeds the seller-concentration question —
  what share of revenue sits with a small number of sellers.
- **Geolocation** (~1M rows): a zip-code-prefix lookup, not a clean dimension. Only
  needed if a map visual is built later.
- **Category translation** (~70 rows): confirmed present, straightforward lookup.

---

## Why this moves beyond Excel

Excel answered one-table questions well but couldn't go further, for three reasons that
matter for how the analysis is framed going forward:

1. **No multi-table joins at this scale.** Every real business question here — delivery
   timing against review score, revenue against seller — needs two or more tables
   combined, which a spreadsheet can't do cleanly at 100K rows.
2. **No auditable logic.** A pivot table gives a number but no record of how it was
   derived. Code does — which matters for reproducing results and explaining them later.
3. **No transformation layer.** Cleaning, standardising, and joining need to happen
   somewhere that keeps a trail — the next stage of the analysis.

---

## Findings carried forward

- Repeat-customer signal: 96,096 unique customers across 99,441 orders — low repeat rate,
  to be quantified precisely
- ~3% of orders never complete (cancelled/unavailable/etc.) — a fulfilment metric on its own
- Order fan-out confirmed: 98,666 orders → 112,650 item rows — join logic must aggregate
  before combining tables
- Freight at ~22.6% of item price in aggregate — needs breaking down by category
- Payments and reviews both show multiple rows per order in places — must be handled
  before any per-order summary
- Review score distribution needs correcting (count, not sum) — first fix carried forward
