-- OLTP Q1
-- Top selling books by year

SELECT
    EXTRACT(YEAR FROM o.order_date) AS year,
    b.title,
    SUM(oi.quantity) AS total_books_sold
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
JOIN Books b
    ON oi.book_id = b.book_id
GROUP BY
    EXTRACT(YEAR FROM o.order_date),
    b.title
ORDER BY
    year,
    total_books_sold DESC;



------
-- OLTP Q2
-- Revenue by category

SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM OrderItems oi
JOIN Books b
    ON oi.book_id = b.book_id
JOIN Categories c
    ON b.category_id = c.category_id
GROUP BY
    c.category_name
ORDER BY
    revenue DESC;



-- OLTP Q3
-- Top customers by spending

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN OrderItems oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_spent DESC;


