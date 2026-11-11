-- Q1: Overdue loans report (the 20 worst)
SELECT l.loan_id,
       m.first_name || ' ' || m.last_name AS member,
       b.title,
       l.due_date,
       CURRENT_DATE - l.due_date AS days_overdue
FROM loan l
JOIN member m     ON m.member_id = l.member_id
JOIN book_copy bc ON bc.copy_id  = l.copy_id
JOIN book b       ON b.book_id   = bc.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC
LIMIT 20;

-- Q2: Loan history of one member
SELECT l.loan_id, b.title, l.loan_date, l.due_date, l.return_date
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b       ON b.book_id  = bc.book_id
WHERE l.member_id = 1234
ORDER BY l.loan_date DESC;

-- Q3: Top 10 most borrowed titles
SELECT b.title, COUNT(*) AS times_borrowed
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b       ON b.book_id  = bc.book_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;
LIMIT 10;

-- Q4: Loans per day for one week
SELECT loan_date, COUNT(*) AS loans
FROM loan
WHERE loan_date BETWEEN '2026-03-01' AND '2026-03-07'
GROUP BY loan_date
ORDER BY loan_date;