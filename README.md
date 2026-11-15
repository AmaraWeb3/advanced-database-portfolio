# Advanced Database Systems Portfolio (MIT 8103)

**Student:** Amarachi Ene | **Student ID:** 301928557
**Programme:** MSc Information Technology, Miva Open University (September 2026 cohort)

## Selected Case Study
Rivers City Public Library Management System (simulated organisation)

## Nature of the System
A relational database that manages a public library's catalogue, memberships, book lending, returns, and overdue fines.

## Users
Librarians (staff), library members, and a library administrator who runs reports.

## Major Data
Books (titles), authors, categories, physical book copies, members, staff, loans, and fines.

## Key Operations
Borrow a book, return a book, calculate fines, search the catalogue, and report on overdue loans and popular titles.

## Repository Structure

| Folder | Focus | What it shows |
|---|---|---|
| [portfolio-1-database-design](portfolio-1-database-design) | Database design | ER design, normalisation to 3NF, tables with PK, FK, CHECK and UNIQUE constraints |
| [portfolio-2-query-optimisation](portfolio-2-query-optimisation) | Query optimisation | Synthetic data, EXPLAIN ANALYZE before and after adding indexes |
| [portfolio-3-transactions-concurrency](portfolio-3-transactions-concurrency) | Transactions and concurrency | BEGIN / COMMIT / ROLLBACK, isolation level, row locking with SELECT ... FOR UPDATE |
| [portfolio-4-nosql](portfolio-4-nosql) | NoSQL | MongoDB design (embedding vs referencing), aggregation queries, unique index |
| [portfolio-5-distributed-cloud](portfolio-5-distributed-cloud) | Distributed and cloud | 3-node MongoDB replica set, majority writes, failover, eventual consistency |

Each portfolio folder contains its own `README.md`, the scripts used, saved outputs, and a `screenshots` folder as evidence.

## Tools Used
- PostgreSQL 18 and pgAdmin 4 (Portfolios 1 to 3)
- MongoDB 7 running in Docker, accessed with mongosh (Portfolios 4 and 5)
- GitHub Desktop for version control (progressive commits)

## How to Review This Repository
1. Open a portfolio folder and read its `README.md` first.
2. SQL scripts (`.sql`) are run in pgAdmin Query Tool, in the numbered order of the file names.
3. MongoDB scripts (`.js`) are run with mongosh, for example:
   `docker exec -it mongo1 mongosh --quiet --file /tmp/<script>.js`
4. Screenshots in each `screenshots` folder show the results of the scripts.

## Summary of Findings
- **Portfolio 1:** The design is normalised to 3NF, so each fact is stored once and constraints protect data quality.
- **Portfolio 2:** Indexes changed the query plans from sequential scans to index-based access on the tested queries. Before and after plans are in the folder.
- **Portfolio 3:** Transactions keep borrowing and returning all-or-nothing, and row locking stops two users taking the last copy at the same time.
- **Portfolio 4:** MongoDB suits flexible catalogue data. Embedding was used where data is read together, and the aggregation pipeline answered reporting questions.
- **Portfolio 5:** The replica set kept the data available when a node was stopped, and a new primary was elected.

## AI Use Declaration
Claude (Anthropic) was used as a learning guide and for drafting help on scripts and explanations. 
I ran every script myself, took the screenshots, and wrote the analysis and reflection sections in my own words. 
I understand the work and can explain it.

## Notes
The organisation, members and data in this project are simulated for academic purposes only.
