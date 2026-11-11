-- Sample data for Rivers City Public Library
-- Safe to re-run: it clears the tables first

TRUNCATE fine, loan, book_copy, book_author, book, author, category, member, staff
RESTART IDENTITY CASCADE;

-- Categories
INSERT INTO category (category_name) VALUES
('Fiction'),('Science'),('History'),('Technology'),
('Biography'),('Children'),('Business'),('Poetry');

-- Authors
INSERT INTO author (first_name, last_name) VALUES
('Chinua','Achebe'),('Chimamanda','Adichie'),('Wole','Soyinka'),
('Buchi','Emecheta'),('Ben','Okri'),('Yuval','Harari'),
('Walter','Isaacson'),('Eric','Ries'),('Andrew','Hunt'),('Martin','Kleppmann');

-- 10 hand-written books
INSERT INTO book (isbn, title, publication_year, category_id) VALUES
('9780000000001','Things Fall Apart',1958,1),
('9780000000002','Half of a Yellow Sun',2006,1),
('9780000000003','Death and the King''s Horseman',1975,1),
('9780000000004','The Joys of Motherhood',1979,1),
('9780000000005','The Famished Road',1991,1),
('9780000000006','Sapiens',2011,3),
('9780000000007','Steve Jobs',2011,5),
('9780000000008','The Lean Startup',2011,7),
('9780000000009','The Pragmatic Programmer',1999,4),
('9780000000010','Designing Data-Intensive Applications',2017,4);

INSERT INTO book_author (book_id, author_id) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10);

-- 490 generated books, to reach 500 titles
INSERT INTO book (isbn, title, publisher, publication_year, category_id)
SELECT '97800000' || LPAD(g::text, 5, '0'),
       'Sample Title ' || g,
       'Heritage Press',
       1980 + (g % 45),
       1 + (g % 8)
FROM generate_series(11, 500) g;

INSERT INTO book_author (book_id, author_id)
SELECT book_id, 1 + (book_id % 10) FROM book WHERE book_id > 10;

-- 3 physical copies of every title (1500 copies)
INSERT INTO book_copy (book_id, shelf_location, status)
SELECT b.book_id, 'S' || ((b.book_id % 20) + 1) || '-' || c, 'Available'
FROM book b CROSS JOIN generate_series(1,3) c;

-- Staff
INSERT INTO staff (first_name, last_name, email, role) VALUES
('Adaeze','Okoro','adaeze.okoro@riverslibrary.example','Head Librarian'),
('Tamuno','Briggs','tamuno.briggs@riverslibrary.example','Librarian'),
('Emeka','Nwosu','emeka.nwosu@riverslibrary.example','Librarian'),
('Ngozi','Eze','ngozi.eze@riverslibrary.example','Assistant'),
('Ibinabo','Harry','ibinabo.harry@riverslibrary.example','Assistant');

-- 2000 members
INSERT INTO member (first_name, last_name, email, phone, join_date)
SELECT (ARRAY['Chidi','Ngozi','Emeka','Amina','Tunde','Ife','Blessing','Ibrahim','Grace','Obinna'])[1 + (g % 10)],
       (ARRAY['Okafor','Adebayo','Briggs','Eze','Bello','Nwosu','Harry','Okoro','Musa','Peterside'])[1 + ((g / 10) % 10)],
       'member' || g || '@riverslibrary.example',
       '0803' || LPAD(g::text, 7, '0'),
       CURRENT_DATE - (g % 1000)
FROM generate_series(1, 2000) g;

-- 100000 loans over the last 2 years
INSERT INTO loan (copy_id, member_id, staff_id, loan_date, due_date, return_date)
SELECT 1 + (random() * 1499)::int,
       1 + (random() * 1999)::int,
       1 + (random() * 4)::int,
       d,
       d + 14,
       CASE
         WHEN d >= CURRENT_DATE - 14 THEN NULL
         WHEN d >= CURRENT_DATE - 60 AND r < 0.10 THEN NULL
         WHEN r < 0.85 THEN d + (random() * 14)::int
         ELSE LEAST(d + 15 + (random() * 20)::int, CURRENT_DATE)
       END
FROM (SELECT CURRENT_DATE - (random() * 730)::int AS d, random() AS r
      FROM generate_series(1, 100000)) t;

-- Fines: 50 per day late, for loans returned late
INSERT INTO fine (loan_id, amount, fine_date, paid)
SELECT loan_id, (return_date - due_date) * 50, return_date, random() < 0.7
FROM loan
WHERE return_date > due_date;

-- Mark copies that are currently out
UPDATE book_copy SET status = 'On Loan'
WHERE copy_id IN (SELECT copy_id FROM loan WHERE return_date IS NULL);

ANALYZE;