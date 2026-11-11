# Portfolio 2: Query Processing and Optimisation

## Case study
Rivers City Public Library Management System (simulated). See the main README.

## Files
- 01_sample_data.sql : synthetic data (500 books, 1,500 copies, 2,000 members, 100,000 loans)
- 02_queries.sql : the four business queries
- 03_explain_before.sql : EXPLAIN ANALYZE before indexing
- 04_q2_before_plan.txt, 05_q4_before_plan.txt, 06_q1_before_plan.txt : plans before indexes
- 07_indexes.sql : the three indexes created
- 08_q2_after_plan.txt, 09_q4_after_plan.txt, 10_q1_after_plan.txt : plans after indexes
- screenshots/ : query results and index sizes

## Queries tested
- Q1: 20 most overdue loans (joins loan, member, book_copy, book)
- Q2: loan history for one member
- Q3: top 10 most borrowed titles
- Q4: loans per day over one week

## Method
I ran EXPLAIN ANALYZE twice on each query and recorded the second run, so caching
does not distort the first result. I then created indexes and reran the same queries unchanged.

## Results
| Query | Before | After | Plan change |
|---|---|---|---|
| Q2 member history | 7.720 ms | 0.569 ms | Seq Scan to Bitmap Index Scan |
| Q4 loans in a week | 6.680 ms | 0.244 ms | Seq Scan to Index Only Scan |
| Q1 overdue loans | 8.333 ms | 2.526 ms | Seq Scan to Bitmap Index Scan (partial index) |

## Analysis
(Write 4 to 6 sentences in your own words. Cover: Seq Scan read all 100,000 rows to return
a few; what each index type does; why Q4 became an Index Only Scan; why Q1 improved less
because of the remaining joins; the sort in Q2 that the planner kept; the estimate versus
actual rows difference in Q1.)

## Trade-offs
Indexes use disk space (see screenshots/11_index_sizes.png) and slow inserts and updates
because each index must be maintained. The partial index on open loans is only 40 kB
because it holds just the loans still out.

## Note on data
The data is synthetic, generated with generate_series and random().