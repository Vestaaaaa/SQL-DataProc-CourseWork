-- OLAP / DWH SCHEMA (SNOWFLAKE)

CREATE TABLE DimCustomer (
    customer_sk SERIAL PRIMARY KEY,
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),

    start_date DATE,
    end_date DATE,
    is_current BOOLEAN
);

CREATE TABLE DimBook (
    book_sk SERIAL PRIMARY KEY,
    book_id INT,
    isbn VARCHAR(20),
    title VARCHAR(255),
    price NUMERIC(10,2),
    category_name VARCHAR(100),
    publisher_name VARCHAR(100)
);

CREATE TABLE DimDate (
    date_sk INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    quarter INT,
    year INT
);


-- FACT TABLES

CREATE TABLE FactSales (
    sales_id SERIAL PRIMARY KEY,
    book_sk INT,
    customer_sk INT,
    date_sk INT,
    quantity INT,
    total_amount NUMERIC(10,2)
);

CREATE TABLE FactPayments (
    payment_id SERIAL PRIMARY KEY,
    customer_sk INT,
    date_sk INT,
    amount NUMERIC(10,2),
    payment_method VARCHAR(30)
);

-- BRIDGE TABLE

CREATE TABLE BridgeBookAuthor (
    book_sk INT,
    author_id INT
);