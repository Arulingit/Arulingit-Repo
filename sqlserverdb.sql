
CREATE TABLE  productuser.products (
    product_id INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier with auto-increment
    product_name VARCHAR(100) NOT NULL, -- Name of the product
    product_type VARCHAR(50), -- Type or category of the product
    unit_price DECIMAL(10,2) NOT NULL, -- Price per unit of the product
    stock_quantity INT NOT NULL -- Current quantity in stock
);


CREATE TABLE productuser.sales_orders (
    order_id INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier with auto-increment
    customer_id INT, -- Foreign key linking to customers table
    order_date DATE NOT NULL, -- Date when the order was placed
    total_amount DECIMAL(10,2) NOT NULL, -- Total amount of the order
    status CHAR(10) DEFAULT 'pending', -- Order status
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Date and time when the record was created
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Date and time when the record was last updated
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE productuser.order_items (
    item_id INT PRIMARY KEY IDENTITY(1,1), -- Unique identifier with auto-increment
    order_id INT, -- Foreign key linking to sales_orders table
    product_id INT, -- Foreign key linking to products table
    quantity INT NOT NULL, -- Quantity of the product ordered
    unit_price DECIMAL(10,2) NOT NULL, -- Price per unit of the product
    total_price DECIMAL(10,2) NOT NULL, -- Total price of the order item (quantity * unit_price)
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

