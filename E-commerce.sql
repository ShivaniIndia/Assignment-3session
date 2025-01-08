CREATE TABLE MyCustomers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create Categories table
CREATE TABLE ProductCategories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create Products table
CREATE TABLE MyProducts (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) CHECK (price > 0),
    stock INT CHECK (stock >= 0),
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES ProductCategories(category_id)
);

-- Create Orders table
CREATE TABLE MyOrders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES MyCustomers(customer_id)
);

-- Create Order_Items table
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES MyOrders(order_id),
    FOREIGN KEY (product_id) REFERENCES MyProducts(product_id)
);

-- Insert sample categories
INSERT INTO ProductCategories (category_name) VALUES
('Smartphones'), ('Laptops'), ('Accessories'), ('Tablets'), ('Cameras');

-- Insert sample products
INSERT INTO MyProducts (product_name, description, price, stock, category_id) VALUES
('Bharat Phone 15', 'Latest Bharat smartphone', 899.99, 15, 1),
('Akshay Galaxy S23', 'Flagship Akshay phone', 799.99, 20, 1),
('Krishna Air', 'Lightweight Krishna laptop', 1099.99, 5, 2),
('Ganga XPS 14', 'High-performance laptop', 999.99, 8, 2),
('Wireless Headphones', 'Wireless audio device', 149.99, 50, 3),
('Indus Pad', 'Krishna tablet', 499.99, 10, 4),
('Himalaya A8 Camera', 'Professional camera', 1799.99, 7, 5),
('Camera Stand', 'Sturdy tripod', 39.99, 25, 5),
('USB-C Cable', 'Fast charging cable', 14.99, 30, 3),
('Laptop Dock', 'Adjustable laptop stand', 29.99, 12, 3);

-- Insert sample customers
INSERT INTO MyCustomers (first_name, last_name, email, phone, address) VALUES
('Shivani', 'Sharma', 'shivani.sharma@example.com', '1234567890', '123 MG Road, Bangalore'),
('Neha', 'Vihal', 'neha.vishal@example.com', '9876543210', '456 Residency Road, Chennai'),
('Rohit', 'K', 'rohit.k@example.com', '1112223333', '789 Marine Drive, Mumbai'),
('Priya', 'Patel', 'priya.patel@example.com', '4445556666', '101 Park Street, Kolkata'),
('Vikram', 'Singh', 'vikram.singh@example.com', '7778889999', '202 Connaught Place, Delhi'),
('Avanshi', 'Gupta', 'avanshi.gupta@example.com', '3334445555', '303 Residency Road, Bangalore'),
('Rahul', 'Guptha', 'rahul.guptha@example.com', '8889990000', '404 Marine Drive, Mumbai'),
('Sarika', 'Kapoor', 'sarika.kapoor@example.com', '5556667777', '505 Park Street, Kolkata');

-- Insert sample orders
INSERT INTO MyOrders (customer_id, order_date) VALUES
(1, '2025-01-01 10:00:00'),
(2, '2025-01-02 11:30:00'),
(3, '2025-01-03 14:45:00'),
(4, '2025-01-04 16:20:00');

-- Insert sample order items
INSERT INTO OrderItems (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 899.99),
(1, 5, 2, 149.99),
(2, 3, 1, 1099.99),
(2, 7, 1, 1799.99),
(3, 4, 2, 999.99),
(3, 8, 1, 39.99),
(4, 6, 1, 499.99),
(4, 10, 2, 29.99);

-- Find Top 3 Customers by Order Value
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    SUM(oi.quantity * oi.price) AS total_order_value
FROM MyCustomers c
JOIN MyOrders o ON c.customer_id = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY total_order_value DESC
LIMIT 3;

-- List Products with Low Stock (Below 10)
SELECT 
    product_id, 
    product_name, 
    stock 
FROM MyProducts
WHERE stock < 10;

-- Calculate Revenue by Category
SELECT 
    cat.category_name, 
    SUM(oi.quantity * oi.price) AS total_revenue
FROM ProductCategories cat
JOIN MyProducts p ON cat.category_id = p.category_id
JOIN OrderItems oi ON p.product_id = oi.product_id
GROUP BY cat.category_name
ORDER BY total_revenue DESC;

-- Show Orders with Items and Total Amount
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    SUM(oi.quantity * oi.price) AS total_order_amount
FROM MyOrders o
JOIN MyCustomers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- Advanced Tasks: View - order_summary
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT oi.product_id) AS unique_products_count,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.price) AS total_order_amount,
    o.order_date
FROM MyOrders o
JOIN MyCustomers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN MyProducts p ON oi.product_id = p.product_id
GROUP BY o.order_id;

-- Stored Procedure: Update Stock Levels
DELIMITER $$

CREATE PROCEDURE update_stock_level(IN p_product_id INT, IN p_quantity INT)
BEGIN
    UPDATE MyProducts
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;
END $$

DELIMITER ;

-- Trigger on Insert (to update stock when a new order item is added)
DELIMITER $$

CREATE TRIGGER update_stock_on_insert
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    CALL update_stock_level(NEW.product_id)