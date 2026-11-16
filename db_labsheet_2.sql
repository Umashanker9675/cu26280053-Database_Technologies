-- ============================================================
-- Database Technologies Lab Sheet - 2 (MCA105P)
-- Solutions: DML, Subqueries, Aggregations & Conditional Logic
-- Dialect: MySQL 8.x
--
-- NOTE: Questions are written to run in order. Many of them
-- (UPDATE / DELETE / INSERT) change the data, so later results
-- depend on earlier statements. To re-test any single query on
-- the original data, re-run the SETUP section first.
-- ============================================================


-- ============================================================
-- SETUP: tables + reference sample data
-- ============================================================
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS orders;

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name  VARCHAR(30),
    dept_id    INT,
    salary     DECIMAL(10,2),
    hire_date  DATE,
    is_active  BOOLEAN
);

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50),
    budget    DECIMAL(12,2)
);

-- order_id is AUTO_INCREMENT because Q03 inserts an order without an id
CREATE TABLE orders (
    order_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date    DATE,
    total_amount  DECIMAL(10,2),
    status        VARCHAR(20)
);

INSERT INTO employees VALUES
(101, 'Alice',   'Smith',   10, 75000.00, '2021-03-15', TRUE),
(102, 'Bob',     'Johnson', 20, 52000.00, '2022-06-01', TRUE),
(103, 'Charlie', 'Brown',   10, 82000.00, '2019-11-20', TRUE),
(104, 'Diana',   'Prince',  30, 48000.00, '2023-01-10', FALSE),
(105, 'Evan',    'Wright',  20, 61000.00, '2020-08-05', TRUE);

INSERT INTO departments VALUES
(10, 'Engineering',     'Building A', 500000.00),
(20, 'Marketing',       'Building B', 200000.00),
(30, 'Human Resources', 'Building A', 150000.00),
(40, 'Finance',         'Building C', 350000.00),
(50, 'Research',        'Building D', 600000.00);

INSERT INTO orders VALUES
(5001, 'TechCorp LLC', '2024-01-15', 1250.50, 'Completed'),
(5002, 'Global Media', '2024-01-18',  450.00, 'Pending'),
(5003, 'Alpha Retail', '2024-01-20', 3100.00, 'Completed'),
(5004, 'Beta Systems', '2024-01-22',  150.25, 'Cancelled'),
(5005, 'Gamma Inc',    '2024-01-25',  890.00, 'Shipped');


-- ============================================================
-- SECTION A - EASY
-- ============================================================

-- Q01
INSERT INTO employees (emp_id, first_name, last_name, dept_id, salary, hire_date, is_active)
VALUES (106, 'Fiona', 'Gallagher', 10, 65000.00, '2024-02-01', TRUE);

-- Q02
INSERT INTO departments (dept_id, dept_name, location, budget)
VALUES (60, 'Quality Assurance', 'Building B', 250000.00);

-- Q03  (order_id is auto-generated)
INSERT INTO orders (customer_name, order_date, total_amount, status)
VALUES ('Delta Retail', '2024-01-28', 2100.00, 'Pending');

-- Q04
SELECT * FROM employees;

-- Q05
SELECT first_name, last_name, salary FROM employees;

-- Q06
SELECT * FROM employees WHERE dept_id = 10;

-- Q07
SELECT * FROM orders WHERE status = 'Completed';

-- Q08
UPDATE employees SET salary = 55000.00 WHERE emp_id = 102;

-- Q09
UPDATE orders SET status = 'Shipped' WHERE order_id = 5002;

-- Q10
UPDATE departments SET budget = budget + 20000.00 WHERE dept_id = 20;

-- Q11
DELETE FROM orders WHERE order_id = 5004;

-- Q12
DELETE FROM employees WHERE emp_id = 104;

-- Q13
SELECT * FROM employees WHERE salary > 60000.00;

-- Q14
SELECT * FROM orders WHERE order_date BETWEEN '2024-01-15' AND '2024-01-20';

-- Q15
SELECT * FROM departments WHERE location IN ('Building A', 'Building B');

-- Q16
SELECT * FROM employees WHERE last_name LIKE 'S%';

-- Q17
SELECT * FROM employees ORDER BY salary DESC;

-- Q18
SELECT * FROM departments ORDER BY dept_name ASC;

-- Q19
SELECT COUNT(*) AS total_employees FROM employees;

-- Q20
SELECT AVG(total_amount) AS avg_order_amount FROM orders;


-- ============================================================
-- SECTION B - MEDIUM
-- ============================================================

-- Q21  (emp_id values 107 and 108 chosen as the next free ids)
INSERT INTO employees (emp_id, first_name, last_name, dept_id, salary, hire_date, is_active)
VALUES
(107, 'George', 'Clark',  30, 50000.00, '2024-02-05', TRUE),
(108, 'Hannah', 'Abbott', 10, 71000.00, '2024-02-10', TRUE);

-- Q22
UPDATE employees SET salary = salary * 1.10 WHERE dept_id = 10;

-- Q23
UPDATE employees SET is_active = FALSE WHERE hire_date < '2021-01-01';

-- Q24
SELECT * FROM employees WHERE is_active = TRUE AND salary > 60000.00;

-- Q25
SELECT * FROM orders WHERE status = 'Cancelled' OR total_amount > 2000.00;

-- Q26
SELECT * FROM employees WHERE dept_id NOT IN (10, 30);

-- Q27  (LOWER() makes it case-insensitive on any collation)
SELECT * FROM employees WHERE LOWER(first_name) LIKE '%a%';

-- Q28
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id;

-- Q29
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id;

-- Q30
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id
HAVING SUM(salary) > 100000.00;

-- Q31
SELECT status, MAX(total_amount) AS max_amount, MIN(total_amount) AS min_amount
FROM orders
GROUP BY status;

-- Q32
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Q33
SELECT * FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'Building A');

-- Q34  (MySQL error 1093 forbids selecting from the table being deleted
--       in a plain subquery, so it is wrapped in a derived table)
DELETE FROM orders
WHERE customer_name IN (
    SELECT customer_name
    FROM (SELECT customer_name FROM orders WHERE status = 'Cancelled') AS cancelled_customers
);

-- Q35
SELECT * FROM employees WHERE last_name IS NULL;

-- Q36
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;

-- Q37
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;

-- Q38
SELECT * FROM employees ORDER BY dept_id ASC, salary DESC;

-- Q39
DELETE FROM departments WHERE budget < 200000.00;

-- Q40
UPDATE orders SET status = 'Cancelled' WHERE total_amount < 200.00;


-- ============================================================
-- SECTION C - HARD / ADVANCED
-- ============================================================

-- Q41
UPDATE employees
SET salary = salary * 1.15
WHERE dept_id = (
    SELECT dept_id FROM departments
    WHERE budget = (SELECT MAX(budget) FROM departments)
);

-- Q42
SELECT d.dept_id, d.dept_name, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > (SELECT AVG(salary) FROM employees);

-- Q43
SELECT * FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE budget > 300000.00);

-- Q44  (method 1: OFFSET; DISTINCT handles duplicate salaries)
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;
-- (method 2: nested subqueries)
SELECT MAX(salary) AS third_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees
                WHERE salary < (SELECT MAX(salary) FROM employees));

-- Q45
UPDATE employees
SET salary = CASE
                 WHEN salary < 60000 THEN salary * 1.10
                 ELSE salary * 1.05
             END;

-- Q46  (MySQL cannot use a correlated subquery on the same table in DELETE,
--       so the per-department average is computed in a derived table and joined.
--       Standard SQL form would be:
--       DELETE FROM employees e WHERE is_active = FALSE
--         AND salary < (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id); )
DELETE e
FROM employees e
JOIN (
    SELECT dept_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY dept_id
) d ON e.dept_id = d.dept_id
WHERE e.is_active = FALSE
  AND e.salary < d.avg_sal;

-- Q47
SELECT d.dept_name,
       (SELECT COUNT(*) FROM employees e WHERE e.dept_id = d.dept_id) AS total_employees
FROM departments d;

-- Q48
SELECT customer_name
FROM orders
GROUP BY customer_name
HAVING COUNT(*) > 1 OR SUM(total_amount) > 1000.00;

-- Q49
INSERT INTO employees (emp_id, first_name, last_name, dept_id, salary, hire_date, is_active)
SELECT emp_id + 500, first_name, last_name, 50, salary, hire_date, is_active
FROM employees
WHERE dept_id = 10;

-- Q50
UPDATE orders
SET status = CASE
                 WHEN total_amount > 1000                  THEN 'Completed'
                 WHEN total_amount BETWEEN 500 AND 1000    THEN 'Shipped'
                 ELSE 'Pending'
             END;

-- ============================ END ============================
