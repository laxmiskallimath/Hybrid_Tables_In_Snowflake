# Snowflake Hybrid Tables – Concept & Implementation Demo

## What Are Hybrid Tables?

**Hybrid Tables** in Snowflake are a new table type designed to handle **both transactional (OLTP)** and **analytical (OLAP)** workloads within the same platform.

They combine the best of both worlds:
**Row-based storage** → allows quick inserts, updates, and deletes
**Column-based querying** → supports analytical aggregation and reporting
**Index-based access** → makes single-row lookups super fast
**Supports unique & referential integrity constraints**

---

### Official Definition (From Snowflake Documentation)
A hybrid table is a Snowflake table type that is optimized for low latency and high throughput using index-based random reads and writes.
**Hybrid Tables** in Snowflake are a new table type designed to handle **both transactional (OLTP)** and **analytical (OLAP)** workloads within the same platform.
---

## Why Do We Need Hybrid Tables?
Snowflake was primarily built for **analytical queries**(OLAP), but when we need **real-time updates or frequent writes**, standard tables may not perform efficiently.

Hybrid Tables solve this by providing **low latency and high concurrency**, making them ideal for:
- Real-time applications
- API-based data serving
- Metadata/state tracking systems
- Fast lookup scenarios like “Get customer with ID = 12345”

---

## Architecture Overview

Hybrid Tables are part of **Snowflake’s Unistore** capability — a unified engine that supports **both operational and analytical workloads**.

**How It Works:**
- We connect to the same Snowflake service.
- Queries are optimized and executed using the same **virtual warehouses**.
- We can **join hybrid tables** with standard tables directly — no data movement or duplication needed.
- Hybrid tables inherit Snowflake’s **data governance, ACID transactions, and security controls**.

**Key Benefits:**
- Seamless integration into the Snowflake platform
- Run both **analytical and operational queries** together
- Perform **atomic transactions** across hybrid and standard tables

---

## When to Use Hybrid Tables

| Use Case | Description |
|-----------|-------------|
| **Fast random reads** | e.g., Fetching a single customer or order by ID |
| **High concurrency writes** | Thousands of small updates or merges per second |
| **Application metadata** | Tracking workflow state or ingestion status |
| **Low-latency serving** | Displaying precomputed aggregates via APIs or dashboards |

---

## Example Simulation (For Trial Account)
**Note:** Hybrid Tables are available in **Snowflake Enterprise Edition** and **not in trial/free accounts**.
> However, we can **simulate their behavior** using two separate tables — one “hot” (rowstore) for real-time transactions and one “cold” (columnstore) for analytical queries.

###SQL Simulation Example

```sql
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
