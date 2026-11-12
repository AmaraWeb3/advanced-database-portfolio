INSERT INTO book_copy (book_id, shelf_location, status)
VALUES (1, 'DEMO-1', 'Available');

SELECT copy_id, book_id, shelf_location, status
FROM book_copy
WHERE shelf_location = 'DEMO-1';

BEGIN;

INSERT INTO loan (copy_id, member_id, staff_id, loan_date, due_date)
VALUES ((SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1'),
        1, 1, CURRENT_DATE, CURRENT_DATE + 14);

UPDATE book_copy SET status = 'On Loan'
WHERE shelf_location = 'DEMO-1';

COMMIT;

SELECT bc.status, l.loan_id, l.member_id, l.loan_date, l.due_date, l.return_date
FROM book_copy bc
JOIN loan l ON l.copy_id = bc.copy_id
WHERE bc.shelf_location = 'DEMO-1';

BEGIN;

UPDATE loan SET return_date = CURRENT_DATE
WHERE copy_id = (SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1')
  AND return_date IS NULL;

UPDATE book_copy SET status = 'Available'
WHERE shelf_location = 'DEMO-1';

SELECT status FROM book_copy WHERE shelf_location = 'DEMO-1';


ROLLBACK;

SELECT bc.status, l.return_date
FROM book_copy bc
JOIN loan l ON l.copy_id = bc.copy_id
WHERE bc.shelf_location = 'DEMO-1';

BEGIN;

UPDATE book_copy SET status = 'Lost'
WHERE shelf_location = 'DEMO-1';

INSERT INTO loan (copy_id, member_id, staff_id, due_date)
VALUES ((SELECT copy_id FROM book_copy WHERE shelf_location = 'DEMO-1'),
        999999, 1, CURRENT_DATE + 14);

ROLLBACK;

SELECT status FROM book_copy WHERE shelf_location = 'DEMO-1';