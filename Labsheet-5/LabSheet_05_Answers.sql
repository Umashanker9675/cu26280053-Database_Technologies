-- =====================================================================
-- Database Technologies Lab Sheet 5 (MCA105P-AS12) - Inner, Equi, Theta
-- and Natural Joins  -- Answers Q1 - Q25   (MySQL / MariaDB)
-- Each answer shows the SQL and the output for the sample data (the outputs
-- were produced by running the same queries on the sample rows).
-- =====================================================================
CREATE DATABASE CollegeJoinDB;
USE CollegeJoinDB;
CREATE TABLE Departments (DeptID INT PRIMARY KEY, DeptName VARCHAR(50), Location VARCHAR(50));
CREATE TABLE Employees (EmpID INT PRIMARY KEY, EmpName VARCHAR(50), DeptID INT, Salary DECIMAL(10,2), City VARCHAR(50));
CREATE TABLE SalaryGrades (Grade CHAR(2) PRIMARY KEY, MinSalary DECIMAL(10,2), MaxSalary DECIMAL(10,2));
INSERT INTO Departments VALUES (10,'Computer Science','Block A'),(20,'Pharmacy','Block B'),(30,'Management','Block C'),(40,'Civil Engineering','Block D');
INSERT INTO Employees VALUES (101,'Aarav',10,65000,'Delhi'),(102,'Priya',20,72000,'Mumbai'),(103,'Rahul',10,48000,'Delhi'),(104,'Sneha',30,91000,'Pune'),(105,'Vikram',20,55000,'Jaipur'),(106,'Neha',50,80000,'Bengaluru'),(107,'Kabir',30,43000,'Pune');
INSERT INTO SalaryGrades VALUES ('G1',0,49999),('G2',50000,69999),('G3',70000,89999),('G4',90000,120000);

-- Q1 Basic Inner Join
SELECT e.EmpName, d.DeptName, d.Location
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID;
-- Output:
--   EmpName | DeptName | Location
--   Aarav | Computer Science | Block A
--   Priya | Pharmacy | Block B
--   Rahul | Computer Science | Block A
--   Sneha | Management | Block C
--   Vikram | Pharmacy | Block B
--   Kabir | Management | Block C

-- Q2 Employee and Department IDs
SELECT e.EmpID, e.EmpName, e.DeptID, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID;
-- Output:
--   EmpID | EmpName | DeptID | DeptName
--   101 | Aarav | 10 | Computer Science
--   102 | Priya | 20 | Pharmacy
--   103 | Rahul | 10 | Computer Science
--   104 | Sneha | 30 | Management
--   105 | Vikram | 20 | Pharmacy
--   107 | Kabir | 30 | Management

-- Q3 Pharmacy Employees
SELECT e.EmpID, e.EmpName, e.Salary, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE d.DeptName = 'Pharmacy';
-- Output:
--   EmpID | EmpName | Salary | DeptName
--   102 | Priya | 72000 | Pharmacy
--   105 | Vikram | 55000 | Pharmacy

-- Q4 Salary Filter (> 60000)
SELECT e.EmpName, e.Salary, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE e.Salary > 60000;
-- Output:
--   EmpName | Salary | DeptName
--   Aarav | 65000 | Computer Science
--   Priya | 72000 | Pharmacy
--   Sneha | 91000 | Management

-- Q5 Equi Join
SELECT e.EmpID, e.EmpName, e.DeptID, d.DeptID AS Dept_DeptID, d.DeptName
FROM Employees e
JOIN Departments d ON e.DeptID = d.DeptID;
-- Output:
--   EmpID | EmpName | DeptID | Dept_DeptID | DeptName
--   101 | Aarav | 10 | 10 | Computer Science
--   102 | Priya | 20 | 20 | Pharmacy
--   103 | Rahul | 10 | 10 | Computer Science
--   104 | Sneha | 30 | 30 | Management
--   105 | Vikram | 20 | 20 | Pharmacy
--   107 | Kabir | 30 | 30 | Management
-- Observation: an equi join uses only '=' in the condition. Both DeptID columns are shown (they are equal in every row).

-- Q6 Equi Join, multiple columns
SELECT e.EmpName, e.City, d.DeptName, d.Location
FROM Employees e
JOIN Departments d ON e.DeptID = d.DeptID;
-- Output:
--   EmpName | City | DeptName | Location
--   Aarav | Delhi | Computer Science | Block A
--   Priya | Mumbai | Pharmacy | Block B
--   Rahul | Delhi | Computer Science | Block A
--   Sneha | Pune | Management | Block C
--   Vikram | Jaipur | Pharmacy | Block B
--   Kabir | Pune | Management | Block C

-- Q7 Computer Science employees
SELECT e.EmpID, e.EmpName, e.Salary
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE d.DeptName = 'Computer Science';
-- Output:
--   EmpID | EmpName | Salary
--   101 | Aarav | 65000
--   103 | Rahul | 48000

-- Q8 Theta Join - Greater Than (salary > grade MinSalary)
SELECT e.EmpName, e.Salary, g.Grade, g.MinSalary
FROM Employees e
JOIN SalaryGrades g ON e.Salary > g.MinSalary
ORDER BY e.EmpName, g.Grade;
-- Output:
--   EmpName | Salary | Grade | MinSalary
--   Aarav | 65000 | G1 | 0
--   Aarav | 65000 | G2 | 50000
--   Kabir | 43000 | G1 | 0
--   Neha | 80000 | G1 | 0
--   Neha | 80000 | G2 | 50000
--   Neha | 80000 | G3 | 70000
--   Priya | 72000 | G1 | 0
--   Priya | 72000 | G2 | 50000
--   Priya | 72000 | G3 | 70000
--   Rahul | 48000 | G1 | 0
--   Sneha | 91000 | G1 | 0
--   Sneha | 91000 | G2 | 50000
--   Sneha | 91000 | G3 | 70000
--   Sneha | 91000 | G4 | 90000
--   Vikram | 55000 | G1 | 0
--   Vikram | 55000 | G2 | 50000
-- Observation: a theta join with '>' returns several rows per employee (one for every grade whose minimum is below the salary).

-- Q9 Theta Join - Salary Range
SELECT e.EmpName, e.Salary, g.Grade
FROM Employees e
JOIN SalaryGrades g ON e.Salary >= g.MinSalary AND e.Salary <= g.MaxSalary
ORDER BY e.EmpID;
-- Output:
--   EmpName | Salary | Grade
--   Aarav | 65000 | G2
--   Priya | 72000 | G3
--   Rahul | 48000 | G1
--   Sneha | 91000 | G4
--   Vikram | 55000 | G2
--   Neha | 80000 | G3
--   Kabir | 43000 | G1
-- Observation: each employee falls in exactly one grade because the ranges do not overlap. Neha (80000) is included because SalaryGrades is joined by salary, not by department.

-- Q10 Theta Join - Less Than (salary < grade MaxSalary)
SELECT e.EmpName, e.Salary, g.Grade, g.MaxSalary
FROM Employees e
JOIN SalaryGrades g ON e.Salary < g.MaxSalary
ORDER BY e.EmpName, g.Grade;
-- Output:
--   EmpName | Salary | Grade | MaxSalary
--   Aarav | 65000 | G2 | 69999
--   Aarav | 65000 | G3 | 89999
--   Aarav | 65000 | G4 | 120000
--   Kabir | 43000 | G1 | 49999
--   Kabir | 43000 | G2 | 69999
--   Kabir | 43000 | G3 | 89999
--   Kabir | 43000 | G4 | 120000
--   Neha | 80000 | G3 | 89999
--   Neha | 80000 | G4 | 120000
--   Priya | 72000 | G3 | 89999
--   Priya | 72000 | G4 | 120000
--   Rahul | 48000 | G1 | 49999
--   Rahul | 48000 | G2 | 69999
--   Rahul | 48000 | G3 | 89999
--   Rahul | 48000 | G4 | 120000
--   Sneha | 91000 | G4 | 120000
--   Vikram | 55000 | G2 | 69999
--   Vikram | 55000 | G3 | 89999
--   Vikram | 55000 | G4 | 120000

-- Q11 Theta Join - Greater Than or Equal
SELECT e.EmpName, e.Salary, g.Grade
FROM Employees e
JOIN SalaryGrades g ON e.Salary >= g.MinSalary
ORDER BY e.EmpName, g.Grade;
-- Output:
--   EmpName | Salary | Grade
--   Aarav | 65000 | G1
--   Aarav | 65000 | G2
--   Kabir | 43000 | G1
--   Neha | 80000 | G1
--   Neha | 80000 | G2
--   Neha | 80000 | G3
--   Priya | 72000 | G1
--   Priya | 72000 | G2
--   Priya | 72000 | G3
--   Rahul | 48000 | G1
--   Sneha | 91000 | G1
--   Sneha | 91000 | G2
--   Sneha | 91000 | G3
--   Sneha | 91000 | G4
--   Vikram | 55000 | G1
--   Vikram | 55000 | G2

-- Q12 Natural Join
SELECT EmpName, DeptID, DeptName
FROM Employees
NATURAL JOIN Departments;
-- Output:
--   EmpName | DeptID | DeptName
--   Aarav | 10 | Computer Science
--   Priya | 20 | Pharmacy
--   Rahul | 10 | Computer Science
--   Sneha | 30 | Management
--   Vikram | 20 | Pharmacy
--   Kabir | 30 | Management
-- Observation: no ON clause. MySQL joins on the only column name the two tables share (DeptID) and shows DeptID once.

-- Q13 Natural Join with Filter (Block B)
SELECT EmpName, DeptName, Location
FROM Employees
NATURAL JOIN Departments
WHERE Location = 'Block B';
-- Output:
--   EmpName | DeptName | Location
--   Priya | Pharmacy | Block B
--   Vikram | Pharmacy | Block B

-- Q14 Natural Join with Salary (>= 70000)
SELECT EmpName, DeptName, Salary
FROM Employees
NATURAL JOIN Departments
WHERE Salary >= 70000;
-- Output:
--   EmpName | DeptName | Salary
--   Priya | Pharmacy | 72000
--   Sneha | Management | 91000

-- Q15 Inner Join + ORDER BY
SELECT e.EmpName, d.DeptName, e.Salary
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
ORDER BY e.Salary DESC;
-- Output:
--   EmpName | DeptName | Salary
--   Sneha | Management | 91000
--   Priya | Pharmacy | 72000
--   Aarav | Computer Science | 65000
--   Vikram | Pharmacy | 55000
--   Rahul | Computer Science | 48000
--   Kabir | Management | 43000

-- Q16 DISTINCT Departments
SELECT DISTINCT d.DeptName
FROM Departments d
INNER JOIN Employees e ON d.DeptID = e.DeptID;
-- Output:
--   DeptName
--   Computer Science
--   Pharmacy
--   Management

-- Q17 Employee Count
SELECT d.DeptName, COUNT(e.EmpID) AS EmployeeCount
FROM Departments d
INNER JOIN Employees e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName;
-- Output:
--   DeptName | EmployeeCount
--   Computer Science | 2
--   Pharmacy | 2
--   Management | 2

-- Q18 Average Salary
SELECT d.DeptName, AVG(e.Salary) AS AvgSalary
FROM Departments d
INNER JOIN Employees e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName;
-- Output:
--   DeptName | AvgSalary
--   Computer Science | 56500.00
--   Pharmacy | 63500.00
--   Management | 67000.00

-- Q19 HAVING (avg salary > 60000)
SELECT d.DeptName, AVG(e.Salary) AS AvgSalary
FROM Departments d
INNER JOIN Employees e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
HAVING AVG(e.Salary) > 60000;
-- Output:
--   DeptName | AvgSalary
--   Pharmacy | 63500.00
--   Management | 67000.00

-- Q20 Highest Paid Employee (matched only)
SELECT e.EmpName, d.DeptName, e.Salary
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE e.Salary = (SELECT MAX(e2.Salary)
                  FROM Employees e2
                  INNER JOIN Departments d2 ON e2.DeptID = d2.DeptID);
-- Output:
--   EmpName | DeptName | Salary
--   Sneha | Management | 91000

-- Q21 IN Condition
SELECT e.EmpName, d.DeptName, e.Salary
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE d.DeptName IN ('Computer Science', 'Pharmacy');
-- Output:
--   EmpName | DeptName | Salary
--   Aarav | Computer Science | 65000
--   Priya | Pharmacy | 72000
--   Rahul | Computer Science | 48000
--   Vikram | Pharmacy | 55000

-- Q22 Multiple WHERE conditions
SELECT e.EmpName, e.City, e.Salary, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID
WHERE e.City IN ('Delhi', 'Pune') AND e.Salary >= 50000;
-- Output:
--   EmpName | City | Salary | DeptName
--   Aarav | Delhi | 65000 | Computer Science
--   Sneha | Pune | 91000 | Management

-- Q23 Matched Rows Observation
SELECT e.EmpID, e.EmpName, e.DeptID, d.DeptName
FROM Employees e
INNER JOIN Departments d ON e.DeptID = d.DeptID;
-- Output:
--   EmpID | EmpName | DeptID | DeptName
--   101 | Aarav | 10 | Computer Science
--   102 | Priya | 20 | Pharmacy
--   103 | Rahul | 10 | Computer Science
--   104 | Sneha | 30 | Management
--   105 | Vikram | 20 | Pharmacy
--   107 | Kabir | 30 | Management
-- Observation: 6 of 7 employees appear. Neha (EmpID 106, DeptID 50) is missing because no department has DeptID 50; INNER JOIN drops unmatched rows.
--    Department 40 (Civil Engineering) has no employees, so it also never appears.

-- Q24 Natural Join + GROUP BY
SELECT DeptName, COUNT(*) AS EmployeeCount
FROM Employees
NATURAL JOIN Departments
GROUP BY DeptID, DeptName;
-- Output:
--   DeptName | EmployeeCount
--   Computer Science | 2
--   Pharmacy | 2
--   Management | 2

-- Q25 Final Challenge (total salary > 100000)
SELECT d.DeptName, SUM(e.Salary) AS TotalSalary
FROM Departments d
INNER JOIN Employees e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
HAVING SUM(e.Salary) > 100000;
-- Output:
--   DeptName | TotalSalary
--   Computer Science | 113000
--   Pharmacy | 127000
--   Management | 134000
