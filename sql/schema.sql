-- Schema for the `onlinestoredb` MySQL database.
-- Cleaned-up version of sql/onlinestoredb.sql (the original mysqldump,
-- kept unchanged in this folder for reference).
--
-- One fix vs. the original dump: the customers column was spelled
-- `adress` in the dump. It is spelled `address` here. If you load the
-- original dump instead, use `adress` in your queries.
--
-- MySQL 8.0. Run with:
--   mysql -u root -p < sql/schema.sql

CREATE DATABASE IF NOT EXISTS onlinestoredb;
USE onlinestoredb;

CREATE TABLE IF NOT EXISTS customers (
  customer_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL,
  email VARCHAR(50) NOT NULL,
  address VARCHAR(50) DEFAULT NULL,
  signup_date DATE NOT NULL,
  PRIMARY KEY (customer_id),
  UNIQUE KEY email (email)
);

CREATE TABLE IF NOT EXISTS products (
  product_id INT NOT NULL AUTO_INCREMENT,
  product_name VARCHAR(50) NOT NULL,
  category VARCHAR(20) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL,
  PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS orders (
  order_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  order_date DATETIME NOT NULL,
  order_status VARCHAR(20) DEFAULT 'Completed',
  PRIMARY KEY (order_id),
  KEY customer_id (customer_id),
  CONSTRAINT orders_ibfk_1 FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id)
);

CREATE TABLE IF NOT EXISTS order_items (
  item_id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price_at_purchase DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (item_id),
  KEY order_id (order_id),
  KEY product_id (product_id),
  CONSTRAINT order_items_ibfk_1 FOREIGN KEY (order_id)
    REFERENCES orders (order_id),
  CONSTRAINT order_items_ibfk_2 FOREIGN KEY (product_id)
    REFERENCES products (product_id)
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'Completed',
  amount DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (payment_id),
  KEY order_id (order_id),
  CONSTRAINT payments_ibfk_1 FOREIGN KEY (order_id)
    REFERENCES orders (order_id)
);

-- Sample data in the original dump (sql/onlinestoredb.sql):
--   customers: 5   (Alice, Bob, Charlie, Diana, Ethan)
--   orders:    6   (order_id 1001-1006)
--   order_items: 7
--   payments:  6
--   products:  5   (Wireless Mouse, Mechanical Keyboard, Standing Desk,
--                    Ergonomic Chair, USB-C Hub)
