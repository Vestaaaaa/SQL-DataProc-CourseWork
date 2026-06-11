DROP TABLE IF EXISTS stg_customers;
DROP TABLE IF EXISTS stg_books;
DROP TABLE IF EXISTS stg_authors;
DROP TABLE IF EXISTS stg_orders;
DROP TABLE IF EXISTS stg_order_items;

CREATE TABLE stg_customers (
    email VARCHAR(100),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    registration_date DATE
);

CREATE TABLE stg_books (
    isbn VARCHAR(20),
    title VARCHAR(255),
    price NUMERIC(10,2),
    publication_year INTEGER,
    publisher_name VARCHAR(100),
    category_name VARCHAR(100)
);

CREATE TABLE stg_authors (
    isbn VARCHAR(20),
    author_first_name VARCHAR(50),
    author_last_name VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE stg_orders (
    customer_email VARCHAR(100),
    order_date DATE,
    status VARCHAR(30)
);

CREATE TABLE stg_order_items (
    customer_email VARCHAR(100),
    order_date DATE,
    isbn VARCHAR(20),
    quantity INTEGER
);

--
COPY stg_customers
FROM '/Users/vestas/Desktop/SQLAndDataProc-CW/data/customers.csv'
DELIMITER ','
CSV HEADER;

COPY stg_books
FROM '/Users/vestas/Desktop/SQLAndDataProc-CW/data/books.csv'
DELIMITER ','
CSV HEADER;

COPY stg_authors
FROM '/Users/vestas/Desktop/SQLAndDataProc-CW/data/authors.csv'
DELIMITER ','
CSV HEADER;

COPY stg_orders
FROM '/Users/vestas/Desktop/SQLAndDataProc-CW/data/orders.csv'
DELIMITER ','
CSV HEADER;

COPY stg_order_items
FROM '/Users/vestas/Desktop/SQLAndDataProc-CW/data/order_items.csv'
DELIMITER ','
CSV HEADER;

--

INSERT INTO Customers
(
    first_name,
    last_name,
    email,
    phone,
    registration_date
)
SELECT
    s.first_name,
    s.last_name,
    s.email,
    s.phone,
    s.registration_date
FROM stg_customers s
WHERE NOT EXISTS
(
    SELECT 1
    FROM Customers c
    WHERE c.email = s.email
);

--
INSERT INTO Publishers (publisher_name)
SELECT DISTINCT publisher_name
FROM stg_books sb
WHERE NOT EXISTS
(
    SELECT 1
    FROM Publishers p
    WHERE p.publisher_name = sb.publisher_name
);

--
INSERT INTO Categories (category_name)
SELECT DISTINCT category_name
FROM stg_books sb
WHERE NOT EXISTS
(
    SELECT 1
    FROM Categories c
    WHERE c.category_name = sb.category_name
);

--
INSERT INTO Books
(
    isbn,
    title,
    price,
    publication_year,
    publisher_id,
    category_id
)
SELECT
    sb.isbn,
    sb.title,
    sb.price,
    sb.publication_year,
    p.publisher_id,
    c.category_id
FROM stg_books sb
JOIN Publishers p
    ON p.publisher_name = sb.publisher_name
JOIN Categories c
    ON c.category_name = sb.category_name
WHERE NOT EXISTS
(
    SELECT 1
    FROM Books b
    WHERE b.isbn = sb.isbn
);

--
INSERT INTO Authors
(
    first_name,
    last_name,
    country
)
SELECT DISTINCT
    sa.author_first_name,
    sa.author_last_name,
    sa.country
FROM stg_authors sa
WHERE NOT EXISTS
(
    SELECT 1
    FROM Authors a
    WHERE a.first_name = sa.author_first_name
      AND a.last_name = sa.author_last_name
);

--
INSERT INTO BookAuthors
(
    book_id,
    author_id
)
SELECT
    b.book_id,
    a.author_id
FROM stg_authors sa

JOIN Books b
    ON b.isbn = sa.isbn

JOIN Authors a
    ON a.first_name = sa.author_first_name
   AND a.last_name = sa.author_last_name

WHERE NOT EXISTS
(
    SELECT 1
    FROM BookAuthors ba
    WHERE ba.book_id = b.book_id
      AND ba.author_id = a.author_id
);

--
INSERT INTO Orders
(
    customer_id,
    order_date,
    status
)
SELECT
    c.customer_id,
    so.order_date,
    so.status
FROM stg_orders so

JOIN Customers c
    ON c.email = so.customer_email

WHERE NOT EXISTS
(
    SELECT 1
    FROM Orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_date = so.order_date
);

--
INSERT INTO OrderItems
(
    order_id,
    book_id,
    quantity,
    unit_price
)
SELECT
    o.order_id,
    b.book_id,
    soi.quantity,
    b.price
FROM stg_order_items soi

JOIN Customers c
    ON c.email = soi.customer_email

JOIN Orders o
    ON o.customer_id = c.customer_id
   AND o.order_date = soi.order_date

JOIN Books b
    ON b.isbn = soi.isbn

WHERE NOT EXISTS
(
    SELECT 1
    FROM OrderItems oi
    WHERE oi.order_id = o.order_id
      AND oi.book_id = b.book_id
);

--
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM Customers
UNION ALL
SELECT 'Books', COUNT(*) FROM Books
UNION ALL
SELECT 'Authors', COUNT(*) FROM Authors
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM OrderItems;