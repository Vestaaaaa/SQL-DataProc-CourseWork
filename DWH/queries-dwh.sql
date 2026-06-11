-- OLAP Q1
-- Top selling books by year

SELECT
    dd.year,
    db.title,
    SUM(fs.quantity) AS total_books_sold
FROM FactSales fs
JOIN DimBook db
    ON fs.book_sk = db.book_sk
JOIN DimDate dd
    ON fs.date_sk = dd.date_sk
GROUP BY
    dd.year,
    db.title
ORDER BY
    dd.year,
    total_books_sold DESC;


--
-- OLAP Q2
-- Revenue by category

SELECT
    db.category_name,
    SUM(fs.total_amount) AS revenue
FROM FactSales fs
JOIN DimBook db
    ON fs.book_sk = db.book_sk
GROUP BY
    db.category_name
ORDER BY
    revenue DESC;


--
-- OLAP Q3
-- Top customers by spending

SELECT
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    SUM(fs.total_amount) AS total_spent
FROM FactSales fs
JOIN DimCustomer dc
    ON fs.customer_sk = dc.customer_sk
WHERE dc.is_current = TRUE
GROUP BY
    dc.customer_id,
    dc.first_name,
    dc.last_name
ORDER BY
    total_spent DESC;