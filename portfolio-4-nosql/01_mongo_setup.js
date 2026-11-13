// =====================================================================
// Portfolio 4: NoSQL and Advanced Data Models (MongoDB)
// Case study: Rivers City Public Library Management System (simulated)
// File: 01_mongo_setup.js
//
// PURPOSE
// Build a document model of the library in MongoDB:
//   books   : one document per title, with authors and physical copies embedded
//   members : one document per member, with their loans embedded
//
// HOW TO RUN (from PowerShell, with the library-mongo container running)
//   docker cp "<path to this file>" library-mongo:/tmp/01_mongo_setup.js
//   docker exec -it library-mongo mongosh --file /tmp/01_mongo_setup.js
//
// The script is safe to re-run: it drops both collections first.
// =====================================================================

// Select the database (the "use" shortcut does not work inside script files)
db = db.getSiblingDB("library_nosql");

// Start clean so re-running does not create duplicates
db.books.drop();
db.members.drop();

// ---------------------------------------------------------------------
// books collection
// Authors and copies are EMBEDDED, so one read returns everything
// about a title. In the relational design these were separate tables
// (author, book_author, book_copy) joined by keys.
// ---------------------------------------------------------------------
db.books.insertMany([
  {
    isbn: "9780000000001",
    title: "Things Fall Apart",
    publication_year: 1958,
    category: "Fiction",
    authors: [{ first_name: "Chinua", last_name: "Achebe" }],
    copies: [
      { copy_id: 1, shelf_location: "S2-1", status: "Available" },
      { copy_id: 2, shelf_location: "S2-2", status: "On Loan" },
      { copy_id: 3, shelf_location: "S2-3", status: "Available" }
    ]
  },
  {
    isbn: "9780000000002",
    title: "Half of a Yellow Sun",
    publication_year: 2006,
    category: "Fiction",
    authors: [{ first_name: "Chimamanda", last_name: "Adichie" }],
    copies: [
      { copy_id: 4, shelf_location: "S3-1", status: "Available" },
      { copy_id: 5, shelf_location: "S3-2", status: "Available" }
    ]
  },
  {
    isbn: "9780000000006",
    title: "Sapiens",
    publication_year: 2011,
    category: "History",
    authors: [{ first_name: "Yuval", last_name: "Harari" }],
    copies: [
      { copy_id: 6, shelf_location: "H1-1", status: "On Loan" },
      { copy_id: 7, shelf_location: "H1-2", status: "Available" }
    ]
  },
  {
    isbn: "9780000000010",
    title: "Designing Data-Intensive Applications",
    publication_year: 2017,
    category: "Technology",
    authors: [{ first_name: "Martin", last_name: "Kleppmann" }],
    copies: [
      { copy_id: 8, shelf_location: "T1-1", status: "Available" }
    ]
  }
]);

// ---------------------------------------------------------------------
// members collection
// Each member's loans are EMBEDDED, so a member's borrowing history
// is a single read. The book title is copied into each loan
// (deliberate duplication that favours fast reads).
// ---------------------------------------------------------------------
db.members.insertMany([
  {
    member_id: 1,
    first_name: "Chidi",
    last_name: "Okafor",
    email: "member1@riverslibrary.example",
    membership_status: "Active",
    loans: [
      {
        loan_id: 1,
        isbn: "9780000000001",
        title: "Things Fall Apart",
        loan_date: new Date("2026-10-20"),
        due_date: new Date("2026-11-03"),
        return_date: null
      }
    ]
  },
  {
    member_id: 2,
    first_name: "Amina",
    last_name: "Bello",
    email: "member2@riverslibrary.example",
    membership_status: "Active",
    loans: [
      {
        loan_id: 2,
        isbn: "9780000000006",
        title: "Sapiens",
        loan_date: new Date("2026-10-25"),
        due_date: new Date("2026-11-08"),
        return_date: null
      },
      {
        loan_id: 3,
        isbn: "9780000000002",
        title: "Half of a Yellow Sun",
        loan_date: new Date("2026-09-01"),
        due_date: new Date("2026-09-15"),
        return_date: new Date("2026-09-14")
      }
    ]
  },
  {
    member_id: 3,
    first_name: "Tunde",
    last_name: "Adebayo",
    email: "member3@riverslibrary.example",
    membership_status: "Suspended",
    loans: []
  }
]);

// ---------------------------------------------------------------------
// Verification: expect books = 4 and members = 3
// ---------------------------------------------------------------------
print("books: " + db.books.countDocuments());
print("members: " + db.members.countDocuments());
