-- Rivers City Public Library: schema

CREATE TABLE category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE author (
    author_id  SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL
);

CREATE TABLE book (
    book_id          SERIAL PRIMARY KEY,
    isbn             VARCHAR(20)  NOT NULL UNIQUE,
    title            VARCHAR(200) NOT NULL,
    publisher        VARCHAR(100),
    publication_year INT CHECK (publication_year BETWEEN 1400 AND 2100),
    category_id      INT NOT NULL REFERENCES category(category_id)
);

CREATE TABLE book_author (
    book_id   INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES author(author_id),
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_copy (
    copy_id        SERIAL PRIMARY KEY,
    book_id        INT NOT NULL REFERENCES book(book_id),
    shelf_location VARCHAR(20),
    status         VARCHAR(15) NOT NULL DEFAULT 'Available'
                   CHECK (status IN ('Available','On Loan','Lost','Damaged'))
);

CREATE TABLE member (
    member_id         SERIAL PRIMARY KEY,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    phone             VARCHAR(20),
    join_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    membership_status VARCHAR(15) NOT NULL DEFAULT 'Active'
                      CHECK (membership_status IN ('Active','Suspended','Expired'))
);

CREATE TABLE staff (
    staff_id   SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    role       VARCHAR(30) NOT NULL
);

CREATE TABLE loan (
    loan_id     SERIAL PRIMARY KEY,
    copy_id     INT NOT NULL REFERENCES book_copy(copy_id),
    member_id   INT NOT NULL REFERENCES member(member_id),
    staff_id    INT NOT NULL REFERENCES staff(staff_id),
    loan_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date    DATE NOT NULL,
    return_date DATE,
    CHECK (due_date >= loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);

CREATE TABLE fine (
    fine_id   SERIAL PRIMARY KEY,
    loan_id   INT NOT NULL UNIQUE REFERENCES loan(loan_id),
    amount    NUMERIC(8,2) NOT NULL CHECK (amount >= 0),
    fine_date DATE NOT NULL DEFAULT CURRENT_DATE,
    paid      BOOLEAN NOT NULL DEFAULT FALSE
);