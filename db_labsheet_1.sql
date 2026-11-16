-- ============================================================
-- Database Technologies Lab Sheet - 1 (MCA105P)
-- Solutions: DDL Commands (MySQL 8.x syntax)
-- Run top to bottom; later questions depend on earlier tables.
-- Where a question assumes a table that was never created in the
-- sheet (student_courses, inventory, raw_data), a setup statement
-- is provided just above the solution.
-- ============================================================

-- ============================================================
-- SECTION A - EASY
-- ============================================================

-- Q1
CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

-- Q2
CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    first_name VARCHAR(30),
    salary     DECIMAL(10,2)
);

-- Q3
CREATE TABLE projects (
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date   DATE
);

-- Q4
CREATE TABLE audit_logs (
    log_id     INT PRIMARY KEY,
    action     TEXT,
    created_at TIMESTAMP
);

-- Q5
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(50),
    is_available BOOLEAN
);

-- Q6
CREATE TABLE system_settings (
    setting_id    SMALLINT PRIMARY KEY,
    setting_key   VARCHAR(50),
    setting_value VARCHAR(100)
);

-- Q7
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

-- Q8
ALTER TABLE products DROP COLUMN is_available;

-- Q9
RENAME TABLE departments TO dept_units;
-- (equivalent: ALTER TABLE departments RENAME TO dept_units;)

-- Q10
TRUNCATE TABLE audit_logs;

-- Q11
CREATE TABLE user_profiles (
    user_id     INT PRIMARY KEY,
    bio         TEXT,
    profile_pic BLOB
);

-- Q12
CREATE TABLE ticket_orders (
    ticket_id      INT PRIMARY KEY,
    priority_level ENUM('Low', 'Medium', 'High')
);

-- Q13
DROP TABLE products;

-- Q14
ALTER TABLE employees MODIFY email VARCHAR(150);

-- Q15
CREATE TABLE sensor_data (
    read_id     BIGINT PRIMARY KEY,
    temperature FLOAT
);

-- Q16  (setup: table assumed to exist without a primary key)
CREATE TABLE student_courses (
    student_id INT,
    course_id  INT
);
ALTER TABLE student_courses ADD PRIMARY KEY (student_id, course_id);

-- Q17
ALTER TABLE employees RENAME COLUMN first_name TO given_name;
-- (older MySQL: ALTER TABLE employees CHANGE first_name given_name VARCHAR(30);)

-- Q18
ALTER TABLE system_settings DROP PRIMARY KEY;

-- Q19
CREATE TABLE clients (
    client_id         INT PRIMARY KEY,
    registration_time TIME
);

-- Q20  (the PK must be dropped first, otherwise ADD PRIMARY KEY fails
--       with "Multiple primary key defined")
ALTER TABLE clients DROP PRIMARY KEY;
ALTER TABLE clients ADD PRIMARY KEY (client_id);


-- ============================================================
-- SECTION B - MEDIUM
-- ============================================================

-- Q21
CREATE TABLE order_items (
    order_id   INT,
    item_id    INT,
    quantity   INT,
    unit_price DECIMAL(8,2),
    PRIMARY KEY (order_id, item_id)
);

-- Q22
CREATE TABLE event_schedules (
    event_id       INT,
    venue_id       INT,
    event_date     DATE,
    duration_hours TINYINT,
    PRIMARY KEY (event_id, venue_id)
);

-- Q23
ALTER TABLE employees
    ADD COLUMN hire_date DATE,
    ADD COLUMN is_active BOOLEAN;

-- Q24
ALTER TABLE employees
    DROP COLUMN email,
    MODIFY salary DECIMAL(12,2);

-- Q25  (setup: table assumed to exist without a primary key)
CREATE TABLE inventory (
    warehouse_id INT,
    sku          VARCHAR(20)
);
ALTER TABLE inventory ADD PRIMARY KEY (warehouse_id, sku);

-- Q26
ALTER TABLE user_profiles MODIFY bio MEDIUMTEXT;

-- Q27
ALTER TABLE employees ADD COLUMN middle_name VARCHAR(30) AFTER given_name;

-- Q28
CREATE TABLE geolocations (
    location_id INT PRIMARY KEY,
    latitude    DECIMAL(9,6),
    longitude   DECIMAL(9,6)
);

-- Q29
CREATE TABLE user_accounts (
    user_id           BIGINT PRIMARY KEY,
    account_type      ENUM('Standard', 'Premium', 'Admin'),
    created_timestamp TIMESTAMP
);

-- Q30
CREATE TABLE device_logs (
    log_id     BIGINT PRIMARY KEY,
    ip_address VARCHAR(45),
    payload    LONGBLOB
);

-- Q31  (AUTO_INCREMENT fills unique values for existing rows, so the
--       new column can safely become the primary key)
ALTER TABLE order_items
    DROP PRIMARY KEY,
    ADD COLUMN order_item_id INT NOT NULL AUTO_INCREMENT FIRST,
    ADD PRIMARY KEY (order_item_id);

-- Q32  (existing DATE values are converted to their year part)
ALTER TABLE projects CHANGE start_date project_year YEAR;

-- Q33
CREATE TABLE document_store (
    doc_id    INT PRIMARY KEY,
    doc_title VARCHAR(255),
    content   LONGTEXT
);

-- Q34
ALTER TABLE document_store CHANGE content doc_body LONGTEXT;

-- Q35
CREATE TABLE employees_archive LIKE employees;

-- Q36
DROP TABLE IF EXISTS employees_archive;

-- Q37
CREATE TABLE financial_ledger (
    entry_id BIGINT PRIMARY KEY,
    debit    DECIMAL(15,4),
    credit   DECIMAL(15,4)
);

-- Q38
ALTER TABLE financial_ledger ADD COLUMN transaction_date DATETIME FIRST;

-- Q39
CREATE TABLE measurements (
    sample_id INT PRIMARY KEY,
    `value`   DOUBLE
);

-- Q40
CREATE TABLE app_users (
    user_id     INT PRIMARY KEY,
    status_code TINYINT
);


-- ============================================================
-- SECTION C - HARD
-- ============================================================

-- Q41
CREATE TABLE transactions (
    xact_id   BIGINT PRIMARY KEY,
    user_id   INT,
    amount    DECIMAL(10,2),
    channel   ENUM('Web', 'Mobile', 'ATM'),
    status    VARCHAR(20),
    xact_time TIMESTAMP
);

-- Q42
CREATE TABLE system_events (
    event_id      BIGINT,
    node_id       SMALLINT,
    event_payload TEXT,
    logged_time   TIMESTAMP,
    PRIMARY KEY (event_id, node_id)
);

-- Q43  (region_code must be NOT NULL because it becomes part of the PK)
ALTER TABLE clients
    DROP PRIMARY KEY,
    ADD COLUMN region_code CHAR(3) NOT NULL,
    ADD PRIMARY KEY (client_id, region_code);

-- Q44  (setup: table assumed to exist)
CREATE TABLE raw_data (
    temp_val VARCHAR(50)
);
ALTER TABLE raw_data
    CHANGE temp_val converted_val DECIMAL(6,3),
    ADD COLUMN processed_at TIMESTAMP AFTER converted_val;

-- Q45
CREATE TABLE student_enrollments (
    student_id      INT,
    course_id       INT,
    semester        VARCHAR(10),
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id, semester)
);

-- Q46
ALTER TABLE student_enrollments
    DROP PRIMARY KEY,
    ADD COLUMN enrollment_id BIGINT NOT NULL AUTO_INCREMENT FIRST,
    ADD PRIMARY KEY (enrollment_id);

-- Q47
CREATE TABLE file_metadata (
    file_id         INT PRIMARY KEY,
    file_path       VARCHAR(500),
    file_size_bytes BIGINT,
    checksum        CHAR(64)
);

-- Q48
ALTER TABLE file_metadata
    MODIFY file_id BIGINT,
    MODIFY file_path TEXT,
    DROP COLUMN checksum;

-- Q49
-- (1)
CREATE TABLE sensor_readings (
    sensor_id   INT,
    recorded_at TIMESTAMP,
    reading     FLOAT,
    PRIMARY KEY (sensor_id, recorded_at)
);
-- (2)
RENAME TABLE sensor_readings TO historical_sensor_readings;

-- Q50
-- (1)
CREATE TABLE application_logs (
    log_id         BIGINT PRIMARY KEY,
    level          ENUM('DEBUG', 'INFO', 'WARN', 'ERROR'),
    message        TEXT,
    execution_time DOUBLE,
    created_at     DATETIME
);
-- (2)
ALTER TABLE application_logs MODIFY level VARCHAR(10);

-- ============================ END ============================
