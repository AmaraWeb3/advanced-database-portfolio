# Portfolio 4: NoSQL and Advanced Data Models

## Case study
Rivers City Public Library Management System (simulated). See the main README.

## Files
- 01_mongo_setup.js : creates the library_nosql database with books and members collections
- 02_mongo_queries.js : find, aggregation, index, query plan and update examples
- 03_query_output.txt : saved output of the query script
- screenshots/ : evidence of each step

## Database type
MongoDB (document database), run in a Docker container using the mongo:7 image and queried with mongosh.

## Data model
| Relational design (Portfolio 1) | MongoDB design |
|---|---|
| book, author, book_author, book_copy | books collection, with authors and copies embedded in each book document |
| member, loan | members collection, with each member's loans embedded |
| category | a category field inside each book document |
| staff, fine | not modelled in this prototype |

## Queries tested
| Query | What it shows |
|---|---|
| Q1 | Filter by category |
| Q2 | Filter inside an embedded array (books with an available copy) |
| Q3 | A member's full loan history in one read |
| Q4 | Aggregation pipeline for overdue loans ($unwind, $match, $project) |
| Q5 | Aggregation with grouping (available copies per category) |
| Index | Unique index on isbn; the plan used isbn_1 and examined 1 document |
| Q6 | Borrowing a book: two updates (copy status and the member's loans) |

## Why a document model suits this case study
(Write this in your own words. Points to cover:)
- A catalogue page needs a title, its authors and its copies together. Embedding returns them in one read, with no joins.
- A member's history is also one read.
- Documents can carry different fields, for example an e-book with a download link, without changing a table.

## Where it does not suit
(Write this in your own words. Points to cover:)
- Borrowing a book updates two documents. On a standalone MongoDB server each single-document write is atomic, but the pair is not, unlike the PostgreSQL transaction in Portfolio 3. Multi-document transactions need a replica set.
- The book title is copied into every loan, so a title change has to be updated in many places.
- A member's loans array grows without limit, and a document has a size cap, so a real system would store loans separately.
- Reports across all loans are easier in SQL.

## Conclusion
(1 or 2 sentences in your own words. For example: a hybrid design, with PostgreSQL for loans and fines
that need strict transactions, and MongoDB for catalogue search and member history reads.)

## Limitations
The dataset is small (4 books, 3 members), so I make no performance claims. The index plan only
shows that the index is used.

## How to reproduce
1. Start MongoDB: docker run -d --name library-mongo -p 27017:27017 mongo:7
2. Copy the scripts in with docker cp, then run: docker exec -it library-mongo mongosh --file /tmp/01_mongo_setup.js
3. Run the same command with 02_mongo_queries.js.

## Evidence
![Documents loaded](screenshots/01_documents_loaded.png)
![Find results](screenshots/02_q1_q3_find_results.png)
![Overdue aggregation](screenshots/03_q4_overdue_aggregation.png)
![Category aggregation](screenshots/04_q5_category_aggregation.png)
![Index and plan](screenshots/05_index_and_plan.png)
![Borrow update](screenshots/06_q6_borrow_update.png)