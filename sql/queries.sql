-- Example queries for the `onlinestoredb` database.
-- Run against MySQL after loading sql/schema.sql or sql/onlinestoredb.sql.
-- Note: if you loaded the original dump, the customers column is
-- spelled `adress`, not `address`.

-- 1. Customers, their orders and payments (JOIN across 3 tables)
--    One row per order, with who ordered it and how they paid.
SELECT
  c.name AS customer_name,
  c.email,
  o.order_id,
  o.order_date,
  o.order_status,
  p.payment_method,
  p.amount
FROM customers c
JOIN orders o
  ON c.customer_id = o.customer_id
JOIN payments p
  ON o.order_id = p.order_id
ORDER BY o.order_date;

-- 2. Order totals from the line items (JOIN across orders + order_items + products)
SELECT
  o.order_id,
  c.name AS customer_name,
  pr.product_name,
  oi.quantity,
  oi.unit_price_at_purchase,
  oi.quantity * oi.unit_price_at_purchase AS line_total
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
JOIN order_items oi
  ON o.order_id = oi.order_id
JOIN products pr
  ON oi.product_id = pr.product_id
ORDER BY o.order_id, oi.item_id;

-- 3. Previous-order comparison (the analysis in data/onlinestoredb.csv)
--    LAG() gives each customer's previous order amount next to the
--    current one. The first order per customer has NULL as
--    previous_order_amount — that is expected, there was no previous order.
SELECT
  customer_id,
  order_id,
  order_date,
  current_order_amount,
  LAG(current_order_amount) OVER (
    PARTITION BY customer_id ORDER BY order_date
  ) AS previous_order_amount
FROM (
  SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    p.amount AS current_order_amount
  FROM orders o
  JOIN payments p ON o.order_id = p.order_id
) AS order_amounts
ORDER BY customer_id, order_date;

-- 4. Reading the same JOIN back into Pandas (Python, not SQL)
--    Run this in Python after installing the requirements:
--
--    import pandas as pd
--    import mysql.connector
--
--    conn = mysql.connector.connect(
--        host="localhost", user="root", password="YOUR_PASSWORD",
--        database="onlinestoredb"
--    )
--    df = pd.read_sql(
--        "SELECT c.name, o.order_id, o.order_date, p.amount "
--        "FROM customers c "
--        "JOIN orders o ON c.customer_id = o.customer_id "
--        "JOIN payments p ON o.order_id = p.order_id",
--        conn
--    )
--    print(df.head())
