-- ONLINE BOOK STORE OLTP DATABASE

-- Customers

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    registration_date DATE NOT NULL
);

-- Authors

CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country VARCHAR(50)
);

-- Publishers

CREATE TABLE Publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50)
);

-- Categories

CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Books

CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK(price >= 0),
    publication_year INTEGER,
    publisher_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,

    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id)
        REFERENCES Publishers(publisher_id),

    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
);


-- Book Authors
-- many-to-many

CREATE TABLE BookAuthors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,

    PRIMARY KEY (book_id, author_id),

    CONSTRAINT fk_bookauthors_book
        FOREIGN KEY (book_id)
        REFERENCES Books(book_id),

    CONSTRAINT fk_bookauthors_author
        FOREIGN KEY (author_id)
        REFERENCES Authors(author_id)
);

-- Orders

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,

    CONSTRAINT chk_order_status
        CHECK (
            status IN
            (
                'Pending',
                'Processing',
                'Shipped',
                'Delivered',
                'Cancelled'
            )
        ),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id)
);

-- Order items

CREATE TABLE OrderItems (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK(unit_price >= 0),

    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT fk_orderitems_book
        FOREIGN KEY (book_id)
        REFERENCES Books(book_id)
);


-- Payments

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK(amount >= 0),

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
);


-- Reviews

CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,

    rating INTEGER NOT NULL
        CHECK (rating BETWEEN 1 AND 5),

    review_text TEXT,
    review_date DATE NOT NULL,

    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT fk_reviews_book
        FOREIGN KEY (book_id)
        REFERENCES Books(book_id)
);


-- Indexes

CREATE INDEX idx_books_title
ON Books(title);

CREATE INDEX idx_orders_order_date
ON Orders(order_date);

CREATE INDEX idx_reviews_rating
ON Reviews(rating);

CREATE INDEX idx_customers_email
ON Customers(email);

--
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

--
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';