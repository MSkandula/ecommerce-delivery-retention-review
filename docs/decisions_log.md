## Date columns loaded as text, not timestamp

`load_to_postgres.py` uses `to_sql(if_exists="replace")`, which drops and
recreates each table with pandas-inferred types rather than an explicit
schema. All five date columns in `orders` landed as `text` in Postgres.
This is the same defect identified in PayScope's `load_clean.py`
(§17.5 of that project's documentation).

**Fix:** rather than repeat the mistake, this project defines explicit DDL
with correct types before loading (see `03_sql/ddl/01_create_tables.sql`),
so pandas' `to_sql` appends to an existing typed table instead of creating
one from inference.



**Status: Fixed.** `raw.orders` now created via explicit DDL
(`03_sql/ddl/01_create_tables.sql`) before loading; `load_to_postgres.py`
loads into it with `if_exists="append"` instead of `"replace"`, so pandas
type-inference never runs. Confirmed via `information_schema.columns` —
all five date columns now show `timestamp without time zone`.
## Revenue concentration percentages: SQL vs pandas discrepancy (Q1)

pandas' `groupby()` drops rows with a null grouping key by default. The 1,627
order_items rows with no matched category (products missing category data,
worth $185,049.76) were silently excluded from pandas' total revenue
denominator, producing artificially higher percentages (top 10 categories =
63.2% of a smaller base).

The SQL version (`q1_revenue_concentration.sql`) uses a LEFT JOIN, keeping
those rows in the SUM() OVER() denominator — the more accurate figure.

**Resolution:** SQL's numbers are authoritative going forward (top 10
categories = 62.4% of true total revenue, not 63.2%). Findings and the
README should cite the SQL figure. Noted as the second self-caught
methodology correction in this project, alongside the freight-ratio fix
in Q5.

## Q2 (delivery vs. satisfaction) — SQL confirms pandas exactly

review_score by delivery_bucket matches pandas precisely (4.29 / 4.03 / 3.29
/ 1.85, same order counts). The dedup tie-break method differs between the
two (pandas: first row in file order; SQL: lowest review_id) but produced
identical results here — the ~550 orders with duplicate reviews evidently
don't have meaningfully different scores across their duplicate rows, so
the tie-break method doesn't affect the outcome.

## SQL stage — cross-tool validation summary

All six business questions reproduced independently in SQL after being
first computed in pandas. Four questions matched exactly (Q2, Q3, Q4, Q6).
Two surfaced real discrepancies that were investigated and resolved in
SQL's favour (Q1: NULL-category revenue excluded by pandas' default
groupby behaviour; Q5: naive vs. category-weighted freight ratio). Both
corrections are documented above with root cause. Final figures for the
project use the SQL-confirmed numbers throughout.
