// =====================================================================
// Portfolio 4: NoSQL and Advanced Data Models (MongoDB)
// Case study: Rivers City Public Library Management System (simulated)
// File: 02_mongo_queries.js
//
// PURPOSE
// Query and update the library documents created by 01_mongo_setup.js.
//
// HOW TO RUN (from PowerShell, with the library-mongo container running)
//   docker cp "<path to this file>" library-mongo:/tmp/02_mongo_queries.js
//   docker exec -it library-mongo mongosh --file /tmp/02_mongo_queries.js
//
// NOTE: the update section (Q6) changes data. To run the file again,
// first re-run 01_mongo_setup.js, which resets the collections.
// =====================================================================

db = db.getSiblingDB("library_nosql");

// A fixed "today" so the overdue query gives the same answer every run
const today = ISODate("2026-11-12");


// ---------------------------------------------------------------------
// Q1: Find books in one category (filter on a top-level field)
// ---------------------------------------------------------------------
print("\n--- Q1: Fiction books ---");
printjson(db.books.find({ category: "Fiction" }, { _id: 0, title: 1, publication_year: 1 }).toArray());


// ---------------------------------------------------------------------
// Q2: Books with at least one available copy (filter inside an embedded array)
// In SQL this needed a join between book and book_copy
// ---------------------------------------------------------------------
print("\n--- Q2: Books with an available copy ---");
printjson(db.books.find({ "copies.status": "Available" }, { _id: 0, title: 1 }).toArray());


// ---------------------------------------------------------------------
// Q3: Full loan history of one member in a single read
// In SQL this joined loan, book_copy and book
// ---------------------------------------------------------------------
print("\n--- Q3: Loan history of member 2 ---");
printjson(db.members.findOne({ member_id: 2 }, { _id: 0, first_name: 1, last_name: 1, loans: 1 }));


// ---------------------------------------------------------------------
// Q4: Overdue loans (aggregation pipeline)
// $unwind turns each embedded loan into its own row,
// $match keeps unreturned loans past their due date,
// $project shapes the output
// ---------------------------------------------------------------------
print("\n--- Q4: Overdue loans as of 2026-11-12 ---");
printjson(db.members.aggregate([
  { $unwind: "$loans" },
  { $match: { "loans.return_date": null, "loans.due_date": { $lt: today } } },
  { $project: {
      _id: 0,
      member: { $concat: ["$first_name", " ", "$last_name"] },
      title: "$loans.title",
      due_date: "$loans.due_date",
      days_overdue: { $dateDiff: { startDate: "$loans.due_date", endDate: today, unit: "day" } }
  } },
  { $sort: { days_overdue: -1 } }
]).toArray());


// ---------------------------------------------------------------------
// Q5: Available copies per category (aggregation with grouping)
// ---------------------------------------------------------------------
print("\n--- Q5: Available copies per category ---");
printjson(db.books.aggregate([
  { $unwind: "$copies" },
  { $match: { "copies.status": "Available" } },
  { $group: { _id: "$category", available_copies: { $sum: 1 } } },
  { $sort: { available_copies: -1 } }
]).toArray());


// ---------------------------------------------------------------------
// Index and query plan
// A unique index on isbn mirrors the UNIQUE constraint in PostgreSQL
// ---------------------------------------------------------------------
print("\n--- Index on isbn ---");
print(db.books.createIndex({ isbn: 1 }, { unique: true }));

print("\n--- Query plan for an ISBN lookup ---");
const plan = db.books.find({ isbn: "9780000000006" }).explain("executionStats");
print("Index used: " + JSON.stringify(plan.queryPlanner.winningPlan.inputStage.indexName));
print("Documents examined: " + plan.executionStats.totalDocsExamined);


// ---------------------------------------------------------------------
// Q6: Update (member 1 borrows copy 4 of Half of a Yellow Sun)
// This takes TWO writes on TWO documents: one in books, one in members.
// A single-document write is atomic in MongoDB, but these two writes
// are not atomic together on a standalone server. This is a key
// difference from the PostgreSQL transaction in Portfolio 3.
// ---------------------------------------------------------------------
print("\n--- Q6: Borrow a book (two updates) ---");

// 1) Mark the copy as on loan, using arrayFilters to target one array element
printjson(db.books.updateOne(
  { isbn: "9780000000002" },
  { $set: { "copies.$[c].status": "On Loan" } },
  { arrayFilters: [{ "c.copy_id": 4 }] }
));

// 2) Add the loan to the member's embedded loans array
printjson(db.members.updateOne(
  { member_id: 1 },
  { $push: { loans: {
      loan_id: 4,
      isbn: "9780000000002",
      title: "Half of a Yellow Sun",
      loan_date: today,
      due_date: ISODate("2026-11-26"),
      return_date: null
  } } }
));

// Verify both changes
print("\n--- Q6 check: copy 4 status and member 1 loans ---");
printjson(db.books.findOne({ isbn: "9780000000002" }, { _id: 0, title: 1, copies: 1 }));
printjson(db.members.findOne({ member_id: 1 }, { _id: 0, first_name: 1, loans: 1 }));
