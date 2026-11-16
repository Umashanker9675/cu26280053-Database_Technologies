-- ============================================================
-- Database Technologies Lab Sheet - 3 (MCA105P)
-- Solutions: DCL (GRANT / REVOKE / roles) and TCL (transactions)
-- Dialect: MySQL 8.x (roles and FOR SHARE need 8.0+)
--
-- HOW TO USE
--  * Run the whole file as an administrator (e.g. root). The
--    "As user X" in each question is context: the statements are
--    what that user would type in their own session. Privilege
--    notes are given where a user's grants would NOT be enough.
--  * Several questions change data (salary, budget, orders).
--    To go back to the original data, re-run the SETUP section.
--  * Procedures use DELIMITER, which works in the mysql client
--    and MySQL Workbench.
--  * The sheet title says 50 problems, but the PDF only contains
--    Q01-Q30, so this file solves those 30.
-- ============================================================


-- ============================================================
-- SETUP: database, tables, sample data, pre-created users
-- ============================================================
DROP DATABASE IF EXISTS company_db;
CREATE DATABASE company_db;
USE company_db;

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50),
    budget    DECIMAL(12,2)
) ENGINE=InnoDB;

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    dept_id    INT,
    salary     DECIMAL(10,2),
    hire_date  DATE,
    is_active  BOOLEAN,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_name VARCHAR(100),
    order_date    DATE,
    total_amount  DECIMAL(10,2),
    status        VARCHAR(20)
) ENGINE=InnoDB;

INSERT INTO departments VALUES
(10, 'Engineering',     'Building A', 500000.00),
(20, 'Marketing',       'Building B', 200000.00),
(30, 'Human Resources', 'Building A', 150000.00),
(40, 'Finance',         'Building C', 350000.00),
(50, 'Research',        'Building D', 600000.00);

INSERT INTO employees VALUES
(101, 'Alice',   'Smith',   10, 75000.00, '2021-03-15', TRUE),
(102, 'Bob',     'Johnson', 20, 52000.00, '2022-06-01', TRUE),
(103, 'Charlie', 'Brown',   10, 82000.00, '2019-11-20', TRUE),
(104, 'Diana',   'Prince',  30, 48000.00, '2023-01-10', FALSE),
(105, 'Evan',    'Wright',  20, 61000.00, '2020-08-05', TRUE);

INSERT INTO orders VALUES
(5001, 'TechCorp LLC', '2024-01-15', 1250.50, 'Completed'),
(5002, 'Global Media', '2024-01-18',  450.00, 'Pending'),
(5003, 'Alpha Retail', '2024-01-20', 3100.00, 'Completed'),
(5004, 'Beta Systems', '2024-01-22',  150.25, 'Cancelled'),
(5005, 'Gamma Inc',    '2024-01-25',  890.00, 'Shipped');

-- Level 0: no grants
CREATE USER IF NOT EXISTS 'john'@'localhost'        IDENTIFIED BY 'JohnPass2026!';
CREATE USER IF NOT EXISTS 'alice'@'localhost'       IDENTIFIED BY 'AlicePass2026!';
CREATE USER IF NOT EXISTS 'intern_user'@'localhost' IDENTIFIED BY 'InternPass2026!';
CREATE USER IF NOT EXISTS 'temp_user'@'localhost'   IDENTIFIED BY 'TempPass2026!';
CREATE USER IF NOT EXISTS 'sec_user'@'localhost'    IDENTIFIED BY 'SecPass2026!';
CREATE USER IF NOT EXISTS 'admin_user'@'%'          IDENTIFIED BY 'AdminPass2026!';

-- Level 1: read-only
CREATE USER IF NOT EXISTS 'auditor'@'localhost' IDENTIFIED BY 'AuditPass2026!';
GRANT SELECT ON company_db.* TO 'auditor'@'localhost';
CREATE USER IF NOT EXISTS 'analyst'@'localhost' IDENTIFIED BY 'AnalystPass2026!';
GRANT SELECT ON company_db.* TO 'analyst'@'localhost';

-- Level 2: operational users
CREATE USER IF NOT EXISTS 'manager'@'localhost' IDENTIFIED BY 'MgrPass2026!';
GRANT SELECT, INSERT, UPDATE ON company_db.orders TO 'manager'@'localhost';
CREATE USER IF NOT EXISTS 'dev_user'@'localhost' IDENTIFIED BY 'DevPass2026!';
GRANT SELECT, INSERT, UPDATE ON company_db.* TO 'dev_user'@'localhost';
CREATE USER IF NOT EXISTS 'hr_assistant'@'localhost' IDENTIFIED BY 'HrPass2026!';
GRANT SELECT, UPDATE ON company_db.employees TO 'hr_assistant'@'localhost';
CREATE USER IF NOT EXISTS 'finance_user'@'localhost' IDENTIFIED BY 'FinPass2026!';
GRANT SELECT, UPDATE ON company_db.departments TO 'finance_user'@'localhost';

-- Level 3: delegation rights
CREATE USER IF NOT EXISTS 'team_lead'@'localhost' IDENTIFIED BY 'LeadPass2026!';
GRANT SELECT, INSERT ON company_db.* TO 'team_lead'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;


-- ============================================================
-- SECTION A - EASY (Q01 - Q10)
-- ============================================================

-- Q01  Grant read access on the whole database
GRANT SELECT ON company_db.* TO 'john'@'localhost';

-- Q02  Multi-privilege grant on a single table
GRANT SELECT, INSERT ON company_db.employees TO 'alice'@'localhost';

-- Q03  Revoke one privilege (SELECT stays)
REVOKE INSERT ON company_db.employees FROM 'alice'@'localhost';

-- Q04  Explicitly begin a transaction (as dev_user)
START TRANSACTION;          -- BEGIN; does the same
ROLLBACK;                   -- only closes the demo block so the script stays clean

-- Q05  Commit the pending insert of department 60 (as dev_user)
START TRANSACTION;
INSERT INTO departments (dept_id, dept_name, location, budget)
VALUES (60, 'Quality Assurance', 'Building B', 250000.00);
COMMIT;

-- Q06  Undo an uncommitted DELETE (as hr_assistant)
-- (hr_assistant would also need DELETE privilege to run the DELETE itself;
--  the question only asks for the undo.)
START TRANSACTION;
DELETE FROM employees WHERE emp_id = 105;
ROLLBACK;                   -- employee 105 is back

-- Q07  Create a savepoint (as dev_user)
START TRANSACTION;
INSERT INTO departments (dept_id, dept_name, location, budget)
VALUES (70, 'Savepoint Demo', 'Building E', 1000.00);
SAVEPOINT sp_before_update;
ROLLBACK;                   -- demo cleanup (discards the demo insert)

-- Q08  Full administrator on every database, from any host
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'%';
-- (add WITH GRANT OPTION only if this admin must also delegate rights)

-- Q09  Reload the grant tables
FLUSH PRIVILEGES;
-- (not needed after GRANT/REVOKE/CREATE USER, only after editing mysql.* tables directly)

-- Q10  Revoke everything from intern_user on company_db.*
-- NOTE: in MySQL ALL PRIVILEGES does not include GRANT OPTION, so it is revoked separately.
-- If the account has no grant at that level yet, MySQL reports error 1141 (nothing to revoke).
REVOKE ALL PRIVILEGES ON company_db.* FROM 'intern_user'@'localhost';
REVOKE GRANT OPTION   ON company_db.* FROM 'intern_user'@'localhost';
-- Global form that strips privileges at EVERY level in one shot:
-- REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'intern_user'@'localhost';


-- ============================================================
-- SECTION B - MEDIUM (Q11 - Q20)
-- ============================================================

-- Q11  Audit the account, then add DELETE on orders
SHOW GRANTS FOR 'dev_user'@'localhost';
GRANT DELETE ON company_db.orders TO 'dev_user'@'localhost';

-- Q12  Multi-step savepoint workflow (as hr_assistant)
START TRANSACTION;
UPDATE employees SET salary = 80000.00 WHERE emp_id = 101;
SAVEPOINT sp_first;
UPDATE employees SET salary = 95000.00 WHERE emp_id = 102;
ROLLBACK TO SAVEPOINT sp_first;      -- undoes only the emp 102 change
COMMIT;                              -- result: 101 = 80000.00, 102 = 52000.00

-- Q13  Remove UPDATE but keep SELECT
REVOKE UPDATE ON company_db.employees FROM 'hr_assistant'@'localhost';
SHOW GRANTS FOR 'hr_assistant'@'localhost';

-- Q14  Read-only transaction (as analyst)
SET TRANSACTION READ ONLY;           -- applies to the next transaction
START TRANSACTION;
SELECT dept_id, SUM(salary) AS total_salary FROM employees GROUP BY dept_id;
SELECT status, COUNT(*) AS order_count FROM orders GROUP BY status;
COMMIT;
-- Shorter equivalent:  START TRANSACTION READ ONLY;

-- Q15  Implicit commit caused by DDL (as dev_user)
-- NOTE: dev_user only has SELECT/INSERT/UPDATE; running ALTER needs the ALTER privilege too.
START TRANSACTION;
UPDATE employees SET salary = 85000 WHERE emp_id = 101;   -- uncommitted
ALTER TABLE employees ADD COLUMN bonus DECIMAL(10,2) DEFAULT 0;  -- DDL: MySQL COMMITS the open transaction first
ROLLBACK;                                                 -- too late, nothing left to roll back
SELECT emp_id, salary FROM employees WHERE emp_id = 101;  -- still 85000: the UPDATE was committed
-- cleanup so later questions see the original structure/data
ALTER TABLE employees DROP COLUMN bonus;
UPDATE employees SET salary = 75000.00 WHERE emp_id = 101;

-- Q16  Atomic budget transfer of 10000 from dept 10 to dept 20 (as finance_user)
START TRANSACTION;
UPDATE departments SET budget = budget - 10000.00 WHERE dept_id = 10;
UPDATE departments SET budget = budget + 10000.00 WHERE dept_id = 20;
COMMIT;                              -- both changes become permanent together
-- result: dept 10 = 490000.00, dept 20 = 210000.00
-- On any error, issue ROLLBACK; instead of COMMIT; so neither update applies.

-- Q17  Audit delegation rights of team_lead
SHOW GRANTS FOR 'team_lead'@'localhost';        -- look for WITH GRANT OPTION
SELECT user, host, db, Grant_priv
FROM mysql.db
WHERE user = 'team_lead' AND host = 'localhost';  -- Grant_priv = 'Y'

-- Q18  Remove only the delegation right
REVOKE GRANT OPTION ON company_db.* FROM 'team_lead'@'localhost';
SHOW GRANTS FOR 'team_lead'@'localhost';        -- SELECT, INSERT remain

-- Q19  Ship order 5002, roll back if total_amount < 500 (as manager)
-- Plain SQL has no IF outside programs, so the check lives in a stored procedure.
DROP PROCEDURE IF EXISTS sp_ship_order_5002;
DELIMITER $$
CREATE PROCEDURE sp_ship_order_5002()
BEGIN
    DECLARE v_amount DECIMAL(10,2);

    START TRANSACTION;
    UPDATE orders SET status = 'Shipped' WHERE order_id = 5002;

    SELECT total_amount INTO v_amount FROM orders WHERE order_id = 5002;

    IF v_amount < 500 THEN
        ROLLBACK;
        SELECT 'Rolled back: total_amount below 500' AS result;
    ELSE
        COMMIT;
        SELECT 'Committed: order shipped' AS result;
    END IF;
END$$
DELIMITER ;
CALL sp_ship_order_5002();           -- order 5002 is 450.00, so this rolls back

-- Q20  Role-based access control
CREATE ROLE IF NOT EXISTS 'reporter_role';
GRANT SELECT ON company_db.* TO 'reporter_role';
GRANT 'reporter_role' TO 'analyst'@'localhost';
SET DEFAULT ROLE 'reporter_role' TO 'analyst'@'localhost';   -- active automatically at login


-- ============================================================
-- SECTION C - HARD (Q21 - Q30)
-- ============================================================

-- Q21  Conditional multi-table transaction with savepoint (as dev_user)
DROP PROCEDURE IF EXISTS sp_dept10_raise;
DELIMITER $$
CREATE PROCEDURE sp_dept10_raise()
BEGIN
    DECLARE v_budget DECIMAL(12,2);

    START TRANSACTION;

    UPDATE employees SET salary = salary * 1.15 WHERE dept_id = 10;
    SAVEPOINT sp_salary_done;

    UPDATE departments SET budget = budget + 50000.00 WHERE dept_id = 10;
    SELECT budget INTO v_budget FROM departments WHERE dept_id = 10;

    IF v_budget > 520000.00 THEN
        ROLLBACK TO SAVEPOINT sp_salary_done;   -- keeps the raise, undoes the budget increase
    END IF;

    COMMIT;
    SELECT 'Done' AS result;
END$$
DELIMITER ;
CALL sp_dept10_raise();      -- 500000 + 50000 = 550000 > 520000, so the budget change is undone

-- Q22  Exclusive lock with FOR UPDATE (as hr_assistant)
-- NOTE: Q13 revoked UPDATE from hr_assistant. For this to work as that user, run
--       GRANT UPDATE ON company_db.employees TO 'hr_assistant'@'localhost'; first.
--       FOR UPDATE needs SELECT plus UPDATE (or DELETE / LOCK TABLES).
START TRANSACTION;
SELECT * FROM employees WHERE emp_id = 101 FOR UPDATE;   -- other sessions now block on this row
UPDATE employees SET salary = 88000.00 WHERE emp_id = 101;
COMMIT;                                                  -- lock released

-- Q23  Shared lock with FOR SHARE (as analyst)
-- NOTE: a locking read needs SELECT plus one of UPDATE / DELETE / LOCK TABLES.
--       analyst only has SELECT, so MySQL would reject this with error 1142 until
--       one of those privileges is added.
START TRANSACTION;
SELECT * FROM departments WHERE dept_id = 10 FOR SHARE;  -- others can read but not modify the row
SELECT d.dept_name, COUNT(e.emp_id) AS headcount, SUM(e.salary) AS payroll
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
WHERE d.dept_id = 10
GROUP BY d.dept_name;
COMMIT;
-- (MySQL 5.7 and older: SELECT ... LOCK IN SHARE MODE)

-- Q24  Audit auditor, then throttle it
SHOW GRANTS FOR 'auditor'@'localhost';
ALTER USER 'auditor'@'localhost'
    WITH MAX_QUERIES_PER_HOUR 100
         MAX_USER_CONNECTIONS 2;
SELECT user, host, max_questions, max_user_connections
FROM mysql.user
WHERE user = 'auditor';

-- Q25  Guarded order cancellation with budget refund (as manager)
-- NOTE: manager only has rights on orders. The procedure runs with its creator's
--       rights (SQL SECURITY DEFINER), so manager just needs EXECUTE on it:
--       GRANT EXECUTE ON PROCEDURE company_db.sp_cancel_order_5002 TO 'manager'@'localhost';
DROP PROCEDURE IF EXISTS sp_cancel_order_5002;
DELIMITER $$
CREATE PROCEDURE sp_cancel_order_5002()
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_amount DECIMAL(10,2);

    START TRANSACTION;

    -- lock the order row and read its current state
    SELECT status, total_amount INTO v_status, v_amount
    FROM orders WHERE order_id = 5002 FOR UPDATE;

    IF v_status = 'Pending' THEN                      -- guard: only pending orders can be cancelled
        UPDATE orders      SET status = 'Cancelled'       WHERE order_id = 5002;
        UPDATE departments SET budget = budget + v_amount WHERE dept_id = 20;
        COMMIT;
        SELECT 'Order cancelled and budget refunded' AS result;
    ELSE
        ROLLBACK;
        SELECT 'Skipped: order is not Pending' AS result;
    END IF;
END$$
DELIMITER ;
CALL sp_cancel_order_5002();

-- Q26  Role hierarchy: admin_role -> write_role -> read_role
CREATE ROLE IF NOT EXISTS 'read_role', 'write_role', 'admin_role';

GRANT SELECT                         ON company_db.* TO 'read_role';
GRANT INSERT, UPDATE, DELETE         ON company_db.* TO 'write_role';
GRANT ALL PRIVILEGES                 ON company_db.* TO 'admin_role';

GRANT 'read_role'  TO 'write_role';    -- write_role inherits read_role
GRANT 'write_role' TO 'admin_role';    -- admin_role inherits write_role (and so read_role)

CREATE USER IF NOT EXISTS 'super_dev'@'localhost' IDENTIFIED BY 'SuperDev2026!';
GRANT 'admin_role' TO 'super_dev'@'localhost';
SET DEFAULT ROLE 'admin_role' TO 'super_dev'@'localhost';
SHOW GRANTS FOR 'super_dev'@'localhost' USING 'admin_role';

-- Q27  Deadlock simulation (two sessions, run in two separate windows)
-- Written as comments, because the statements must be run alternately by hand.
--
-- Step 1  Session 1 (dev_user)       : START TRANSACTION;
--                                      UPDATE employees SET salary = salary + 1 WHERE emp_id = 101;  -- locks 101
-- Step 2  Session 2 (hr_assistant)   : START TRANSACTION;
--                                      UPDATE employees SET salary = salary + 1 WHERE emp_id = 102;  -- locks 102
-- Step 3  Session 1 (dev_user)       : UPDATE employees SET salary = salary + 1 WHERE emp_id = 102;  -- waits for Session 2
-- Step 4  Session 2 (hr_assistant)   : UPDATE employees SET salary = salary + 1 WHERE emp_id = 101;  -- waits for Session 1 = cycle
--
-- InnoDB detects the cycle and rolls back one session (the "victim") with:
--     ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
-- The surviving session then gets its lock and can COMMIT. The victim must restart its transaction.
--
-- Inspect the details afterwards with:
--     SHOW ENGINE INNODB STATUS;      -- see "LATEST DETECTED DEADLOCK"
-- Prevention: always lock rows in the same order (e.g. ascending emp_id) in every session.

-- Q28  Remote user that must use SSL/TLS
CREATE USER IF NOT EXISTS 'cloud_user'@'%'
    IDENTIFIED BY 'CloudPass2026!'
    REQUIRE SSL;
GRANT SELECT, INSERT ON company_db.* TO 'cloud_user'@'%';
-- (stricter option: REQUIRE X509 or REQUIRE SUBJECT/ISSUER to demand a client certificate)
-- Verify: SELECT user, host, ssl_type FROM mysql.user WHERE user = 'cloud_user';

-- Q29  Batch insert with savepoints (as manager)
-- Business rule used here: an order must have total_amount > 0.
DROP PROCEDURE IF EXISTS sp_insert_orders_5008_5009;
DELIMITER $$
CREATE PROCEDURE sp_insert_orders_5008_5009(IN p_amount_5009 DECIMAL(10,2))
BEGIN
    START TRANSACTION;

    INSERT INTO orders (order_id, customer_name, order_date, total_amount, status)
    VALUES (5008, 'Omega Traders', '2024-02-01', 1500.00, 'Pending');
    SAVEPOINT sp_5008;

    INSERT INTO orders (order_id, customer_name, order_date, total_amount, status)
    VALUES (5009, 'Sigma Corp', '2024-02-02', p_amount_5009, 'Pending');
    SAVEPOINT sp_5009;

    IF p_amount_5009 <= 0 THEN                      -- order 5009 fails the business rule
        ROLLBACK TO SAVEPOINT sp_5008;              -- 5008 is kept, 5009 is discarded
    END IF;

    COMMIT;
END$$
DELIMITER ;
CALL sp_insert_orders_5008_5009(-100.00);           -- invalid 5009: only 5008 is saved
SELECT * FROM orders WHERE order_id IN (5008, 5009);

-- Q30  Complete maintenance script
-- 1) create the account
CREATE USER IF NOT EXISTS 'test_maint'@'localhost' IDENTIFIED BY 'MaintPass2026!';

-- 2) grant privileges
GRANT SELECT, INSERT, UPDATE ON company_db.* TO 'test_maint'@'localhost';

-- 3) transaction that changes emp_104's active status, then rolls back
START TRANSACTION;
UPDATE employees SET is_active = TRUE WHERE emp_id = 104;
SELECT emp_id, is_active FROM employees WHERE emp_id = 104;   -- shows TRUE inside the transaction
ROLLBACK;
SELECT emp_id, is_active FROM employees WHERE emp_id = 104;   -- back to FALSE

-- 4) audit grants
SHOW GRANTS FOR 'test_maint'@'localhost';

-- 5) revoke permissions
REVOKE SELECT, INSERT, UPDATE ON company_db.* FROM 'test_maint'@'localhost';

-- 6) lock the account
ALTER USER 'test_maint'@'localhost' ACCOUNT LOCK;

-- final check
SHOW GRANTS FOR 'test_maint'@'localhost';
SELECT user, host, account_locked FROM mysql.user WHERE user = 'test_maint';

-- ============================ END ============================
