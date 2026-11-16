-- =====================================================================
-- Database Technologies Lab Sheet 4 (MCA105P-AS09)
-- Constraints, DML and Library DDL  -- Answers Q1 - Q55  (MySQL 8.0.16+)
-- Run top to bottom. Lines starting with "-- ERROR" are the message you
-- should see: those statements are SUPPOSED to fail.
-- =====================================================================
DROP DATABASE IF EXISTS sql_lab;
CREATE DATABASE sql_lab;
USE sql_lab;

-- ===================== PART B : PRIMARY KEY ==========================
-- Q1  The primary key of Department is DeptID. It is suitable because every
--     department has exactly one ID, the values are unique, never change and
--     can never be NULL (a primary key forbids NULL).

-- Q2
CREATE TABLE Department (
    DeptID   INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);
INSERT INTO Department VALUES
(10,'Computer Science'),(20,'Information Technology'),
(30,'Pharmacy'),(40,'Management');

-- Q3
CREATE TABLE Student (
    StudentID   INT PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Email       VARCHAR(100),
    Age         INT,
    DeptID      INT,
    JoiningDate DATE
);
INSERT INTO Student VALUES
(101,'Amit Sharma','amit@example.com',20,10,'2026-07-01'),
(102,'Priya Singh','priya@example.com',21,20,'2026-07-03'),
(103,'Rahul Verma','rahul@example.com',22,30,'2026-07-05'),
(104,'Neha Gupta','neha@example.com',20,10,'2026-07-08'),
(105,'Arjun Mehta','arjun@example.com',23,40,'2026-07-10');

-- Q4  duplicate primary key
INSERT INTO Student VALUES (101,'Karan Shah','karan@example.com',21,20,'2026-08-01');
-- ERROR 1062: Duplicate entry '101' for key 'student.PRIMARY'
-- A primary key value must be unique, so the row is rejected.

-- Q5
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY,
    StudentID    INT,
    CourseName   VARCHAR(100)
);
INSERT INTO Enrollment VALUES
(1,101,'DBMS'),(2,102,'Operating Systems'),
(3,103,'Pharmacology'),(4,104,'Python');

-- Q6
INSERT INTO Enrollment VALUES (1,105,'Data Mining');
-- ERROR 1062: Duplicate entry '1' for key 'enrollment.PRIMARY'

-- ===================== PART B : FOREIGN KEY ==========================
-- Q7
ALTER TABLE Student
  ADD CONSTRAINT fk_student_department
  FOREIGN KEY (DeptID) REFERENCES Department(DeptID);

-- Q8
ALTER TABLE Enrollment
  ADD CONSTRAINT fk_enrollment_student
  FOREIGN KEY (StudentID) REFERENCES Student(StudentID);

-- Q9
INSERT INTO Student VALUES (106,'Riya Das','riya@example.com',21,99,'2026-08-01');
-- ERROR 1452: Cannot add or update a child row: a foreign key constraint fails
-- Department 99 does not exist in the parent table, so the insert is refused.

-- Q10
INSERT INTO Enrollment VALUES (5,999,'DBMS');
-- ERROR 1452: Cannot add or update a child row: a foreign key constraint fails
-- Student 999 does not exist in the parent table Student.

-- Q11
SELECT s.StudentID, s.Name, d.DeptName
FROM Student s
INNER JOIN Department d ON s.DeptID = d.DeptID;

-- Q12
SELECT e.EnrollmentID, s.Name, e.CourseName
FROM Enrollment e
INNER JOIN Student s ON e.StudentID = s.StudentID;

-- ===================== PART C : OTHER CONSTRAINTS ====================
-- Q13  NOT NULL
CREATE TABLE Department2 (
    DeptID   INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);
INSERT INTO Department2 VALUES (50, NULL);
-- ERROR 1048: Column 'DeptName' cannot be null
INSERT INTO Department2 (DeptID) VALUES (50);
-- ERROR 1364: Field 'DeptName' doesn't have a default value   (omitting it also fails)

-- Q14
INSERT INTO Student (StudentID, Email, Age, DeptID)
VALUES (106,'riya@example.com',21,20);
-- ERROR 1364: Field 'Name' doesn't have a default value
-- (inserting Name = NULL explicitly gives: ERROR 1048 Column 'Name' cannot be null)

-- Q15  UNIQUE
ALTER TABLE Student ADD CONSTRAINT uq_student_email UNIQUE (Email);
INSERT INTO Student
VALUES (106,'Riya Das','amit@example.com',21,20,'2026-08-01');
-- ERROR 1062: Duplicate entry 'amit@example.com' for key 'student.uq_student_email'

-- Q16
CREATE TABLE Library (
    BookID INT UNIQUE,
    Title  VARCHAR(150) NOT NULL
);
INSERT INTO Library VALUES
(1,'Database Systems'),(2,'Operating Systems'),(3,'Computer Networks'),
(4,'Python Programming'),(5,'Data Mining');

-- Q17  CHECK
ALTER TABLE Student ADD CONSTRAINT chk_student_age CHECK (Age > 18);
INSERT INTO Student
VALUES (106,'Riya Das','riya@example.com',17,20,'2026-08-01');
-- ERROR 3819: Check constraint 'chk_student_age' is violated.

-- Q18
CREATE TABLE Course (
    CourseID   INT PRIMARY KEY,
    CourseName VARCHAR(100),
    Credits    INT CHECK (Credits BETWEEN 1 AND 6)
);
INSERT INTO Course VALUES (1,'DBMS',8);
-- ERROR 3819: Check constraint 'course_chk_1' is violated.
INSERT INTO Course VALUES (1,'DBMS',4);     -- a valid row for comparison

-- Q19  DEFAULT   (JoiningDate already exists, so MODIFY it to add the default)
ALTER TABLE Student MODIFY COLUMN JoiningDate DATE DEFAULT (CURRENT_DATE);
INSERT INTO Student (StudentID, Name, Email, Age, DeptID)
VALUES (106,'Riya Das','riya@example.com',21,20);
SELECT * FROM Student;           -- Riya's JoiningDate = today's date

-- Q20
CREATE TABLE Faculty (
    FacultyID   INT PRIMARY KEY,
    FacultyName VARCHAR(100) NOT NULL,
    Designation VARCHAR(50) DEFAULT 'Lecturer'
);
INSERT INTO Faculty (FacultyID, FacultyName) VALUES (1,'Dr. Meera Sharma');
SELECT * FROM Faculty;           -- Designation = Lecturer

-- ===================== PART D : DML EXERCISES ========================
-- Exercise 1 - INSERT
-- Q21
CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    name       VARCHAR(80),
    department VARCHAR(50),
    salary     DECIMAL(10,2),
    hire_date  DATE
);
-- Q22
INSERT INTO employees VALUES (101,'John Smith','IT',55000,'2024-01-15');
-- Q23
INSERT INTO employees VALUES
(102,'Sarah Johnson','HR',48000,'2024-02-10'),
(103,'Mike Davis','Finance',52000,'2024-01-20'),
(104,'Lisa Wilson','Marketing',45000,'2024-03-01');
-- Q24
INSERT INTO employees (emp_id, name, department) VALUES (107,'David Clark','Sales');
-- Q25
SELECT * FROM employees;

-- Exercise 2 - SELECT
-- Q26
SELECT * FROM employees;
-- Q27
SELECT name, salary FROM employees;
-- Q28
SELECT * FROM employees WHERE department = 'IT';
-- Q29
SELECT * FROM employees WHERE salary > 50000;
-- Q30
SELECT * FROM employees WHERE hire_date BETWEEN '2024-01-01' AND '2024-01-31';
-- Q31
SELECT DISTINCT department FROM employees;
-- Q32
SELECT COUNT(*) AS total_employees FROM employees;
-- Q33
SELECT MAX(salary) AS maximum_salary,
       MIN(salary) AS minimum_salary,
       AVG(salary) AS average_salary
FROM employees;

-- Exercise 3 - UPDATE
-- Q34
UPDATE employees SET salary = 58000 WHERE name = 'John Smith';
-- Q35
UPDATE employees SET salary = salary * 1.05 WHERE department = 'HR';
-- Q36
UPDATE employees SET salary = 47000, hire_date = '2024-03-05' WHERE name = 'Lisa Wilson';
-- Q37
UPDATE employees SET department = 'Operations' WHERE salary < 50000;
-- Q38
UPDATE employees SET salary = salary + 2000 WHERE department = 'Finance';
-- Q39
UPDATE employees SET department = 'Senior Staff' WHERE hire_date < '2024-02-01';
-- (Run SELECT * FROM employees; after each step to see the effect.
--  If Workbench complains about safe-update mode: SET SQL_SAFE_UPDATES = 0;)

-- Exercise 4 - DELETE
CREATE TABLE products (
    product_id     INT PRIMARY KEY,
    product_name   VARCHAR(50),
    category       VARCHAR(30),
    price          DECIMAL(10,2),
    stock_quantity INT
);
INSERT INTO products VALUES
(1,'Laptop','Electronics',999.99,5),
(2,'Mouse','Electronics',25.5,0),
(3,'Desk Chair','Furniture',150.0,3),
(4,'Monitor','Electronics',1200.0,2),
(5,'Keyboard','Electronics',75.0,0),
(6,'Coffee Mug','Office',12.99,10),
(7,'Notebook','Office',5.99,8),
(8,'Smartphone','Electronics',1500.0,1);

-- Q40   removes Mouse (2) and Keyboard (5)
DELETE FROM products WHERE stock_quantity = 0;
-- Q41   removes Monitor (4) and Smartphone (8)
DELETE FROM products WHERE category = 'Electronics' AND price > 1000;
-- Q42   removes Desk Chair (3)
DELETE FROM products WHERE product_name = 'Desk Chair';
-- Q43   removes Coffee Mug (6) and Notebook (7)
DELETE FROM products WHERE price < 100;
-- Only Laptop (999.99) is left after Q43.

-- Exercise 5 - SORT / LIKE / LIMIT
CREATE TABLE students (
    student_id   INT PRIMARY KEY,
    student_name VARCHAR(50),
    course       VARCHAR(50),
    marks        INT,
    city         VARCHAR(30)
);
INSERT INTO students VALUES
(1,'Alice Brown','Computer Science',85,'Mumbai'),
(2,'Bob Wilson','Mathematics',92,'Delhi'),
(3,'Carol Davis','Computer Science',78,'Mumbai'),
(4,'David Miller','Physics',88,'Chennai'),
(5,'Eva Garcia','Mathematics',95,'Delhi'),
(6,'Frank Johnson','Computer Science',82,'Bangalore'),
(7,'Grace Lee','Physics',90,'Mumbai'),
(8,'Henry Smith','Mathematics',76,'Chennai'),
(9,'Ivy Chen','Computer Science',89,'Delhi'),
(10,'Jack Taylor','Physics',84,'Bangalore');

-- Q44
SELECT * FROM students ORDER BY marks DESC;
-- Q45
SELECT * FROM students ORDER BY marks DESC LIMIT 5;      -- Eva 95, Bob 92, Grace 90, Ivy 89, David 88
-- Q46
SELECT * FROM students WHERE course = 'Computer Science' ORDER BY student_name ASC;
-- Q47
SELECT * FROM students ORDER BY marks ASC LIMIT 3;       -- Henry 76, Carol 78, Frank 82
-- Q48
SELECT * FROM students WHERE marks BETWEEN 80 AND 90;    -- BETWEEN includes 80 and 90
-- Q49
SELECT * FROM students WHERE student_name LIKE 'A%';     -- Alice Brown
-- Q50
SELECT * FROM students WHERE city IN ('Mumbai','Delhi');

-- ===================== PART E : LIBRARY DATABASE =====================
-- Q51
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title   VARCHAR(255) NOT NULL,
    author  VARCHAR(255),
    isbn    VARCHAR(13) UNIQUE,
    genre   VARCHAR(50)
);
-- Q52
CREATE TABLE Members (
    member_id    INT PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    email        VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);
-- Q53
CREATE TABLE Loans (
    loan_id     INT PRIMARY KEY,
    book_id     INT,
    member_id   INT,
    loan_date   DATE,
    return_date DATE NULL,
    FOREIGN KEY (book_id)   REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);
-- Q54
INSERT INTO Books VALUES
(1,'Database System Concepts','Korth','9780073523323','Database'),
(2,'Operating System Concepts','Silberschatz','9781119456339','OS'),
(3,'Python Crash Course','Eric Matthes','9781718502703','Programming');
INSERT INTO Members VALUES
(101,'Amit Sharma','amit.lib@example.com','9876500001'),
(102,'Priya Singh','priya.lib@example.com','9876500002'),
(103,'Rahul Verma','rahul.lib@example.com','9876500003');
INSERT INTO Loans VALUES
(1,1,101,'2026-09-01',NULL),
(2,2,102,'2026-09-02','2026-09-06'),
(3,3,103,'2026-09-04',NULL);
-- Q55
SELECT l.loan_id, b.title, m.name, l.loan_date, l.return_date
FROM Loans l
INNER JOIN Books   b ON l.book_id   = b.book_id
INNER JOIN Members m ON l.member_id = m.member_id;
