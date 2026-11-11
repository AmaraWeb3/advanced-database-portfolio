-- Q2: find one member's loans, already sorted by date
CREATE INDEX idx_loan_member_date ON loan (member_id, loan_date DESC);

-- Q4: find loans in a date range
CREATE INDEX idx_loan_loan_date ON loan (loan_date);

-- Q1: only indexes loans that are still out (partial index)
CREATE INDEX idx_loan_open_due ON loan (due_date) WHERE return_date IS NULL;

ANALYZE loan;