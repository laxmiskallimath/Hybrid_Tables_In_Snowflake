-- Create Hot (Transactional) Table
CREATE OR REPLACE TABLE sales_hot (
  sale_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  sale_time TIMESTAMP_NTZ
);

-- Create Cold (Analytical) Table
CREATE OR REPLACE TABLE sales_cold (
  sale_id INT,
  customer_id INT,
  amount DECIMAL(10,2),
  sale_time TIMESTAMP_NTZ
);

-- Insert Transactions
INSERT INTO sales_hot VALUES
(1, 100, 49.99, CURRENT_TIMESTAMP()),
(2, 101, 19.99, CURRENT_TIMESTAMP());

-- Move older data from hot to cold
INSERT INTO sales_cold
SELECT * FROM sales_hot
WHERE sale_time < DATEADD(minute, -1, CURRENT_TIMESTAMP());

DELETE FROM sales_hot
WHERE sale_time < DATEADD(minute, -1, CURRENT_TIMESTAMP());

-- Combine both for unified analytics
SELECT customer_id, SUM(amount) AS total_sales
FROM (
  SELECT * FROM sales_hot
  UNION ALL
  SELECT * FROM sales_cold
)
GROUP BY customer_id;

-- Create View for easy access
CREATE OR REPLACE VIEW sales_all AS
SELECT * FROM sales_hot
UNION ALL
SELECT * FROM sales_cold;
