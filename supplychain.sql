CREATE TABLE products (
  product_id VARCHAR PRIMARY KEY,
  product_name VARCHAR,
  category VARCHAR,
  unit_price FLOAT
);

CREATE TABLE suppliers (
  supplier_id VARCHAR PRIMARY KEY,
  supplier_name VARCHAR,
  region VARCHAR,
  rating FLOAT
);

CREATE TABLE warehouses (
  warehouse_id VARCHAR PRIMARY KEY,
  city VARCHAR,
  capacity INT
);

CREATE TABLE orders (
  order_id VARCHAR PRIMARY KEY,
  product_id VARCHAR REFERENCES products(product_id),
  supplier_id VARCHAR REFERENCES suppliers(supplier_id),
  warehouse_id VARCHAR REFERENCES warehouses(warehouse_id),
  order_date DATE,
  delivery_date DATE,
  quantity INT,
  order_status VARCHAR,
  stock_level INT
);

COPY products FROM 'F:\products.csv' DELIMITER ',' CSV HEADER;
COPY suppliers FROM 'F:\suppliers.csv' DELIMITER ',' CSV HEADER;
COPY warehouses FROM 'F:\warehouses.csv' DELIMITER ',' CSV HEADER;
COPY orders FROM 'F:\orders.csv' DELIMITER ',' CSV HEADER;


------------ Queries -----------------

--QUS1. Total Orders by Month:
CREATE VIEW Total_Orders_by_Month AS 
SELECT DATE_TRUNC('month', order_date) AS month, COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

SELECT * FROM Total_Orders_by_Month;

--QUS2. Average Delivery Time per Supplier
CREATE VIEW Avg_delivery_time AS
SELECT s.supplier_name, AVG(delivery_date - order_date) AS avg_delivery_days
FROM orders o
JOIN suppliers s
ON s.supplier_id = o.supplier_id
WHERE order_status = 'Delivered'
GROUP BY s.supplier_name;

SELECT * FROM Avg_delivery_time;

--QUS3. Delayed Orders %:
CREATE VIEW Delayed_orders_pct AS 
SELECT COUNT(*) FILTER(WHERE order_status='Delayed')*100.00/COUNT(*) AS Delayed_orders
FROM orders;

SELECT * FROM Delayed_orders_pct;

--QUS4. Low Stock Alert (threshold = 50):
CREATE VIEW Low_stock_alert AS
SELECT product_id, stock_level
FROM orders
WHERE stock_level <50 ;

SELECT * FROM Low_stock_alert;

--QUS5. Top 5 Delayed Suppliers:
CREATE VIEW delayed_suppliers AS
SELECT s.supplier_name,COUNT(*) AS Orders_Delayed
FROM orders o
JOIN suppliers s ON s.supplier_id = o.supplier_id
WHERE order_status ='Delayed'
GROUP BY s.supplier_name
ORDER BY Orders_Delayed DESC LIMIT 5;

SELECT * FROM delayed_suppliers;

--QUS6. Inventory Value per Warehouse:
CREATE VIEW Inventory_value_per_warehouse AS 
SELECT w.city ,SUM(o.stock_level * p.unit_price) AS Inventory_Value
FROM orders o
JOIN products p ON p.product_id = o.product_id
JOIN warehouses w ON w.warehouse_id = o.warehouse_id
GROUP BY w.city ;

SELECT * FROM Inventory_value_per_warehouse;

--QUS7. Window Function: Rank Suppliers by Performance:
CREATE VIEW Rank_supplier_by_performance AS 
SELECT supplier_id ,AVG(delivery_date - order_date) AS Total_days,
RANK() OVER (ORDER BY AVG(delivery_date - order_date)) AS Rank
FROM orders 
GROUP BY supplier_id;

SELECT * FROM Rank_supplier_by_performance;

--QUS8. Out-of-Stock Frequency:
CREATE VIEW stock_frequency AS 
SELECT product_id, COUNT(*) AS out_of_stock_count
FROM orders
WHERE stock_level = 0
GROUP BY product_id;

SELECT * FROM stock_frequency;

--QUS9. Warehouse Utilization:
CREATE VIEW warehouse_utilization AS 
SELECT w.city,
SUM(o.stock_level)/w.capacity*100 AS utilization_percent
FROM orders o
JOIN warehouses w ON o.warehouse_id=w.warehouse_id
GROUP BY w.city, w.capacity;

SELECT * FROM warehouse_utilization;

--QUS10. Supplier Rating vs Delay:
CREATE VIEW supplier_ratings_vs_delay AS 
SELECT s.rating, COUNT(*) AS delayed_orders
FROM orders o
JOIN suppliers s ON o.supplier_id=s.supplier_id 
WHERE order_status='Delayed'
GROUP BY s.rating;

SELECT * FROM supplier_ratings_vs_delay ;
