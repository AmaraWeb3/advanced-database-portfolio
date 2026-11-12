# Portfolio 3: Transactions and Concurrency

## Case study
Rivers City Public Library Management System (simulated). See the main README.

## Files
- 01_transactions_basic.sql : commit, rollback and error-triggered rollback tests
- 02_concurrency.sql : two-session concurrency demo (problem and fix)
- screenshots/ : output evidence for every test

## Why transactions matter here
Borrowing a book needs two changes: a new loan row and the copy status set to On Loan.
If only one happened, the data would be inconsistent.

## Tests
| Test | What it shows | Evidence |
|---|---|---|
| 1 COMMIT | Loan inserted and copy marked On Loan, saved permanently | screenshots/01 |
| 2 ROLLBACK | Changes visible inside the transaction, then undone | screenshots/02, 03 |
| 3 Error | A foreign key violation aborts the transaction, so the earlier UPDATE did not survive (atomicity) | screenshots/04, 05 |
| 4 No locking | Two sessions both read Available, so both lent the same copy | screenshots/06, 07 |
| 5 Row lock | SELECT ... FOR UPDATE made the second session wait, so only one loan existed | screenshots/08, 09, 10 |

## Isolation level
PostgreSQL default is READ COMMITTED. A session sees only committed data, but that alone
does not stop two sessions acting on the same stale read. Test 4 shows this.

## Concurrency control used
Pessimistic row locking with SELECT ... FOR UPDATE. A real borrow operation should lock the
copy row before checking its status.

## Lessons
I was surprised when my SECTION_B hanged after the user in SECTION_A locked the loan. 
I would want to try this out with a real world case senario, using real world dataset and have a feel of how it will look when real transactions and applied in the database. 
If possible I will develop an app for this. Though this is out of scope for this course.