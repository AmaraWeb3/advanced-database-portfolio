-- =====================================================================
-- Portfolio 3: Transactions and Concurrency (part 2)
-- Case study: Rivers City Public Library Management System (simulated)
--
-- PURPOSE
-- Show what happens when two librarians try to lend the same physical copy at the same time, first with no locking, then with a row lock (SELECT ... FOR UPDATE).
--
-- HOW TO RUN
-- I ran the queries in 2 separate tabs of the PgAdmin labelled SECTION_A and SECTION_B which serves as 2 separate users/connections
-- 
-- connections:
--   Session A = first Query Tool tab
--   Session B = second Query Tool tab
-- I Ran each block in the session named in its heading, in the order shown
-- The demo copy is the row in book_copy with shelf_location
-- 'DEMO-1' (created in the basic transaction tests).
-- =====================================================================


-- =====================================================================
-- RESETING THE DEMO COPY AND CHECKING THE ISOLATION LEVEL
-- Session A
-- =====================================================================

-- Close any open loan on the demo copy
UPDATE loan SET return_date = CURRENT_DATE
WHERE copy_id = (SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1')
  AND return_date IS NULL;

-- Mark the demo copy as available again
UPDATE book_copy SET status = 'Available'
WHERE shelf_location = 'DEMO-1';

-- PostgreSQL default is READ COMMITTED: a session only sees committed data
SHOW transaction_isolation;


-- =====================================================================
-- TEST 4: THE PROBLEM (NO LOCKING)
-- Expected result: two open loans for one physical book
-- =====================================================================

-- ---- Session A ----
-- Librarian A starts a transaction and checks the copy
BEGIN;
SELECT copy_id, status FROM book_copy WHERE shelf_location = 'DEMO-1';
-- Result: Available

-- ---- Session B ----
-- Librarian B starts a transaction and checks the same copy
BEGIN;
SELECT copy_id, status FROM book_copy WHERE shelf_location = 'DEMO-1';
-- Result: Available (A has not committed yet, so B still sees the old state)

-- ---- Session A ----
-- A lends the book to member 1 and commits
INSERT INTO loan (copy_id, member_id, staff_id, due_date)
VALUES ((SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1'),
        1, 1, CURRENT_DATE + 14);
UPDATE book_copy SET status = 'On Loan' WHERE shelf_location = 'DEMO-1';
COMMIT;

-- ---- Session B ----
-- B acted on its earlier read and lends the same copy to member 2
INSERT INTO loan (copy_id, member_id, staff_id, due_date)
VALUES ((SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1'),
        2, 2, CURRENT_DATE + 14);
UPDATE book_copy SET status = 'On Loan' WHERE shelf_location = 'DEMO-1';
COMMIT;

-- ---- Either session ----
-- Check the damage: this returns TWO open loans for the same copy
SELECT l.loan_id, l.member_id, l.return_date
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
WHERE bc.shelf_location = 'DEMO-1' AND l.return_date IS NULL;


-- =====================================================================
-- RESETING AGAIN BEFORE THE FIX
-- To be Run in: either session, but I ran this in SECTION_B
-- =====================================================================

-- Close all open loans on the demo copy (the double loan from Test 4)
UPDATE loan SET return_date = CURRENT_DATE
WHERE copy_id = (SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1')
  AND return_date IS NULL;

-- Mark the demo copy as available again
UPDATE book_copy SET status = 'Available'
WHERE shelf_location = 'DEMO-1';


-- =====================================================================
-- TEST 5: THE FIX (ROW LOCKING WITH FOR UPDATE)
-- Expected result: B waits for A, then sees On Loan, so only one loan
-- =====================================================================

-- Session A
-- A reads the copy AND locks the row
BEGIN;
SELECT copy_id, status FROM book_copy
WHERE shelf_location = 'DEMO-1' FOR UPDATE;
-- Result: Available, returned straight away. A now holds the lock.

-- Session B
-- B tries to read and lock the same row
BEGIN;
SELECT copy_id, status FROM book_copy
WHERE shelf_location = 'DEMO-1' FOR UPDATE;
-- This HANGS (spinner, no result) because B is waiting for A's lock

-- Session A (while B is still waiting)
-- A lends the book and commits, which releases the lock
INSERT INTO loan (copy_id, member_id, staff_id, due_date)
VALUES ((SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1'),
        1, 1, CURRENT_DATE + 14);
UPDATE book_copy SET status = 'On Loan' WHERE shelf_location = 'DEMO-1';
COMMIT;

-- Session B
-- B's SELECT now completes and shows status = 'On Loan'.
-- B knows the copy is unavailable, so it cancels its transaction.
ROLLBACK;

-- Either session, BUT RAN IN SECTION_B
-- Final check: only ONE open loan for the demo copy
SELECT l.loan_id, l.member_id, l.return_date
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
WHERE bc.shelf_location = 'DEMO-1' AND l.return_date IS NULL;


-- Screenshot evidence is in my screenshots folder for portfolio 3
