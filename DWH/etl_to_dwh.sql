--DimDate
INSERT INTO DimDate (date_sk, full_date, day, month, quarter, year)
SELECT DISTINCT
    TO_CHAR(order_date, 'YYYYMMDD')::INT,
    order_date,
    EXTRACT(DAY FROM order_date),
    EXTRACT(MONTH FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(YEAR FROM order_date)
FROM Orders o
WHERE NOT EXISTS (
    SELECT 1 FROM DimDate d
    WHERE d.full_date = o.order_date
);

--DimCustomer

--DimDate
INSERT INTO DimDate (date_sk, full_date, day, month, quarter, year)
SELECT DISTINCT
    TO_CHAR(order_date, 'YYYYMMDD')::INT,
    order_date,
    EXTRACT(DAY FROM order_date),
    EXTRACT(MONTH FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(YEAR FROM order_date)
FROM Orders
WHERE NOT EXISTS (
    SELECT 1 FROM DimDate d
    WHERE d.full_date = Orders.order_date
);

--DimCustomer

-- закрываем старую запись
UPDATE DimCustomer
SET end_date = CURRENT_DATE,
    is_current = FALSE
FROM Customers c
WHERE DimCustomer.customer_id = c.customer_id
  AND DimCustomer.is_current = TRUE
  AND (
      DimCustomer.email <> c.email
      OR DimCustomer.phone <> c.phone
      OR DimCustomer.first_name <> c.first_name
      OR DimCustomer.last_name <> c.last_name
  );

-- вставляем новую версию
INSERT INTO DimCustomer (
    customer_id, first_name, last_name, email, phone,
    start_date, end_date, is_current
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    CURRENT_DATE,
    NULL,
    TRUE
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM DimCustomer d
    WHERE d.customer_id = c.customer_id
      AND d.is_current = TRUE
);

--DimBook
INSERT INTO DimBook (
    book_id, isbn, title, price, category_name, publisher_name
)
SELECT DISTINCT
    b.book_id,
    b.isbn,
    b.title,
    b.price,
    cat.category_name,
    pub.publisher_name
FROM Books b
JOIN Categories cat ON b.category_id = cat.category_id
JOIN Publishers pub ON b.publisher_id = pub.publisher_id
WHERE NOT EXISTS (
    SELECT 1 FROM DimBook d WHERE d.book_id = b.book_id
);

--FactSales
INSERT INTO FactSales (
    book_sk, customer_sk, date_sk, quantity, total_amount
)
SELECT
    db.book_sk,
    dc.customer_sk,
    dd.date_sk,
    oi.quantity,
    (oi.quantity * oi.unit_price)
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN DimCustomer dc ON dc.customer_id = c.customer_id AND dc.is_current = TRUE
JOIN DimBook db ON db.book_id = oi.book_id
JOIN DimDate dd ON dd.full_date = o.order_date
WHERE NOT EXISTS (
    SELECT 1 FROM FactSales f
    WHERE f.book_sk = db.book_sk
      AND f.customer_sk = dc.customer_sk
      AND f.date_sk = dd.date_sk
);

--FactPayments
INSERT INTO FactPayments (
    customer_sk, date_sk, amount, payment_method
)
SELECT
    dc.customer_sk,
    dd.date_sk,
    p.amount,
    p.payment_method
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN DimCustomer dc ON dc.customer_id = c.customer_id AND dc.is_current = TRUE
JOIN DimDate dd ON dd.full_date = p.payment_date
WHERE NOT EXISTS (
    SELECT 1 FROM FactPayments f
    WHERE f.customer_sk = dc.customer_sk
      AND f.date_sk = dd.date_sk
);

--Bridge table
INSERT INTO BridgeBookAuthor (
    book_sk, author_id
)
SELECT DISTINCT
    db.book_sk,
    a.author_id
FROM BookAuthors ba
JOIN Books b ON ba.book_id = b.book_id
JOIN DimBook db ON db.book_id = b.book_id
JOIN Authors a ON ba.author_id = a.author_id
WHERE NOT EXISTS (
    SELECT 1 FROM BridgeBookAuthor br
    WHERE br.book_sk = db.book_sk
      AND br.author_id = a.author_id
);


-- 2. вставляем новую версию (НО ТОЛЬКО если нет такой же актуальной)
INSERT INTO DimCustomer (
    customer_id, first_name, last_name, email, phone,
    start_date, end_date, is_current
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    CURRENT_DATE,
    NULL,
    TRUE
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM DimCustomer d
    WHERE d.customer_id = c.customer_id
      AND d.is_current = TRUE
      AND d.email = c.email
      AND d.phone = c.phone
      AND d.first_name = c.first_name
      AND d.last_name = c.last_name
);

--DimBook
INSERT INTO DimBook (
    book_id, isbn, title, price, category_name, publisher_name
)
SELECT DISTINCT
    b.book_id,
    b.isbn,
    b.title,
    b.price,
    cat.category_name,
    pub.publisher_name
FROM Books b
JOIN Categories cat ON b.category_id = cat.category_id
JOIN Publishers pub ON b.publisher_id = pub.publisher_id
WHERE NOT EXISTS (
    SELECT 1 FROM DimBook d WHERE d.book_id = b.book_id
);

--FactSales
INSERT INTO FactSales (
    book_sk, customer_sk, date_sk, quantity, total_amount
)
SELECT
    db.book_sk,
    dc.customer_sk,
    dd.date_sk,
    oi.quantity,
    (oi.quantity * oi.unit_price)
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN DimCustomer dc ON dc.customer_id = c.customer_id AND dc.is_current = TRUE
JOIN DimBook db ON db.book_id = oi.book_id
JOIN DimDate dd ON dd.full_date = o.order_date
WHERE NOT EXISTS (
    SELECT 1 FROM FactSales f
    WHERE f.book_sk = db.book_sk
      AND f.customer_sk = dc.customer_sk
      AND f.date_sk = dd.date_sk
);

--FactPayments
INSERT INTO FactPayments (
    customer_sk, date_sk, amount, payment_method
)
SELECT
    dc.customer_sk,
    dd.date_sk,
    p.amount,
    p.payment_method
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN DimCustomer dc ON dc.customer_id = c.customer_id AND dc.is_current = TRUE
JOIN DimDate dd ON dd.full_date = p.payment_date
WHERE NOT EXISTS (
    SELECT 1 FROM FactPayments f
    WHERE f.customer_sk = dc.customer_sk
      AND f.date_sk = dd.date_sk
);

--Bridge table
INSERT INTO BridgeBookAuthor (
    book_sk, author_id
)
SELECT DISTINCT
    db.book_sk,
    a.author_id
FROM BookAuthors ba
JOIN Books b ON ba.book_id = b.book_id
JOIN DimBook db ON db.book_id = b.book_id
JOIN Authors a ON ba.author_id = a.author_id
WHERE NOT EXISTS (
    SELECT 1 FROM FactSales f
    WHERE f.book_sk = db.book_sk
      AND f.customer_sk = dc.customer_sk
      AND f.date_sk = dd.date_sk
      AND f.quantity = oi.quantity
      AND f.total_amount = (oi.quantity * oi.unit_price)
);

