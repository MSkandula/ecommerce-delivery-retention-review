# Business Brief

**Role:** first data analyst hired by an online marketplace (Olist-style, ~100K orders
across 71 product categories, ~3,095 sellers).

**The ask from leadership:** two open questions, no prior analytics function to draw on:

1. Why aren't customers coming back?
2. Is delivery performance actually costing us anything — or is that just a hunch?

**Scope:** an end-to-end first pass answering both, using whatever tool actually fits
each step of the work — not committing to one tool up front. See
[`decisions_log.md`](decisions_log.md) for why the toolset changed shape partway through.

## The six questions this analysis answers

1. **Revenue concentration** — which categories drive revenue vs. volume?
2. **Delivery vs. satisfaction** — does late delivery actually lower review scores, and
   by how much?
3. **Repeat purchase rate** — what share of customers order more than once?
4. **Seller concentration** — what share of revenue comes from the top 10% of sellers?
5. **Freight cost by category** — which categories have freight eating the most into
   item price?
6. **Delivery by geography** — are delays clustered in particular states?

Individually these read as separate operational metrics. Read together (see
[`findings.md`](findings.md)), they connect into one narrative: delivery lateness is the
strongest satisfaction driver found in the data, it clusters in specific states rather
than being a national problem, and the repeat-purchase rate is low enough that poor
delivery experience is a plausible contributing cause — not proven, but a real pattern
leadership hadn't seen laid out side by side before.

## Why this matters as a portfolio piece

The two self-caught methodology corrections during the SQL cross-check
(revenue denominator handling in Q1, freight ratio calculation in Q5 — both detailed in
`decisions_log.md`) are treated as a feature of the process, not a flaw: independently
reproducing every pandas result in SQL caught two real errors before they reached a
dashboard or a stakeholder.
