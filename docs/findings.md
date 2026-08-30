# Findings

Six business questions, answered in pandas (`02_python/notebooks/02_eda_findings.ipynb`)
and independently reproduced in SQL (`03_sql/analysis/`). Four matched exactly; two
surfaced real methodology errors that were corrected — see
[`decisions_log.md`](decisions_log.md) for the root cause on both. All figures below are
the final, SQL-confirmed numbers.

## 1. Revenue concentration

**Top 10 of 71 categories generate 62.4% of revenue.** `health_beauty`, `watches_gifts`
and `bed_bath_table` alone account for over a quarter of total revenue. Concentrated, but
not extreme — a commercial team would still get outsized return focusing on the top 10,
worth roughly 2.7x their "fair share" if revenue were spread evenly across categories.

## 2. Delivery vs. satisfaction — the headline finding

**Review scores fall sharply and consistently as delivery lateness increases:**

| Delivery bucket | Avg. review score | Share of delivered orders |
|---|---|---|
| Early | 4.29 | 92.0% |
| On time | 4.03 | 1.3% |
| 1–3 days late | 3.29 | 1.9% |
| 4+ days late | 1.85 | 4.7% |

That's a drop of nearly 2.5 stars between the best and worst bucket. The 4,529 orders
(4.7% of delivered orders) landing 4+ days late are scoring under 2 stars on average —
the range that drives public negative reviews and return-customer loss. Delivery
lateness is the single clearest driver of dissatisfaction found in this dataset, and
"4+ days late" behaves like its own SLA breach category, not a graduation of "late"
generally.

## 3. Repeat purchase rate

**Only 3.12% of customers (2,997 of 96,096) place more than one order.** The
overwhelming majority — 93,099 customers — buy exactly once. This marketplace is running
on near-total customer acquisition, not retention. A 3% repeat rate is low for e-commerce
generally, and combined with finding 2, poor delivery experience is a plausible
contributing factor to why customers aren't coming back — not proven by this analysis,
but a real pattern worth putting in front of leadership.

## 4. Seller concentration

**The top 10% of sellers (310 of 3,095) generate 67.6% of revenue** — more concentrated
than the category split above. This is a seller-dependency risk: if any of the top
handful of sellers churned off the platform, the revenue impact would be immediate and
large.

## 5. Freight cost by category

**Aggregate freight-to-price ratio: 16.6%** (corrected from an initial 22.6% estimate —
see the methodology note below). By category, freight burden is far from evenly spread:

| Category | Freight as % of price | Items |
|---|---|---|
| christmas_supplies | 36.7% | 153 |
| signaling_and_security | 30.3% | 199 |
| food_drink | 29.7% | 278 |
| electronics | 29.1% | 2,767 |
| furniture_living_room | 26.1% | 503 |

`electronics` combines high volume ($160K in item price) with high freight burden,
making it the strongest candidate for a shipping-cost review — a category-specific
margin problem, not a flat operational overhead.

## 6. Delivery by geography

**National late rate (4+ days): 4.8%.** Delivery delay is not evenly distributed:

| State | Orders | Late rate |
|---|---|---|
| AL | 397 | 17.4% |
| SE | 335 | 12.8% |
| MA | 717 | 12.8% |
| CE | 1,279 | 11.4% |
| RJ | 12,350 | 9.7% |

AL runs at more than 3.5x the national rate. RJ is the standout on volume — 12,350
orders at nearly double the national rate, not a small-sample outlier. This is a
regional logistics problem, not a national one; a fix targeted at the carrier routes
serving AL, SE, MA, CE and RJ would address a disproportionate share of the
dissatisfaction found in finding 2.

## Connected narrative for leadership

Delivery performance (finding 2) is concentrated in specific regions (finding 6) and is
plausibly linked to the low repeat-purchase rate (finding 3) — three findings that
individually look like separate metrics but together point at one lever worth
prioritising: fixing delivery in a handful of underperforming states first.

## Methodology corrections (self-caught during SQL cross-check)

Two of six questions needed correction after independent SQL reproduction — both are a
strength of the process (an error caught before it reached a dashboard), not a flaw in
the final numbers:

- **Q1 — Revenue denominator:** pandas' default `groupby()` drops rows with a null
  grouping key, silently excluding 1,627 order_items rows with no matched category
  (worth $185,049.76) from the revenue total. This inflated the top-10 share to 63.2%.
  The SQL version uses a `LEFT JOIN`, keeping those rows in the denominator — the
  correct figure is **62.4%**.
- **Q5 — Freight ratio:** the Excel first-look figure (~22.6%) was a naive ratio of two
  column sums taken in isolation. The corrected method sums freight and price
  per category first, weighted by actual item volume — the true aggregate is **16.6%**.

Full root-cause detail for both is in [`decisions_log.md`](decisions_log.md).
