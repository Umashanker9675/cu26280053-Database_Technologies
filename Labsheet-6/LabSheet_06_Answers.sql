-- =====================================================================
-- Database Technologies Lab Sheet 6 (MCA105P-AS11)
-- Stored Procedures & Functions (CollegeDB)  -- Answers Q1 - Q20
-- MySQL / MariaDB.  Every routine is created between DELIMITER // ... //
-- =====================================================================
-- STEP 0: run the setup from the lab sheet first
-- (CollegeDB with Department, Student, Course tables and the sample rows).
-- =====================================================================
USE CollegeDB;

-- ==================== STORED PROCEDURES (Q1 - Q10) ====================
DELIMITER //

-- Q1
CREATE PROCEDURE ShowStudents()
BEGIN
    SELECT * FROM Student;
END //

-- Q2
CREATE PROCEDURE ShowDepartments()
BEGIN
    SELECT * FROM Department;
END //

-- Q3
CREATE PROCEDURE ShowCourses()
BEGIN
    SELECT * FROM Course;
END //

-- Q4
CREATE PROCEDURE GetStudent(IN p_StudentID INT)
BEGIN
    SELECT * FROM Student WHERE StudentID = p_StudentID;
END //

-- Q5
CREATE PROCEDURE GetStudentsByDept(IN p_DeptID INT)
BEGIN
    SELECT * FROM Student WHERE DeptID = p_DeptID;
END //

-- Q6
CREATE PROCEDURE StudentsAboveMarks(IN p_Marks DECIMAL(5,2))
BEGIN
    SELECT * FROM Student WHERE Marks > p_Marks;
END //

-- Q7
CREATE PROCEDURE TotalStudents()
BEGIN
    SELECT COUNT(*) AS TotalStudents FROM Student;
END //

-- Q8
CREATE PROCEDURE CheckResult(IN p_StudentID INT)
BEGIN
    DECLARE v_Marks DECIMAL(5,2);
    SELECT Marks INTO v_Marks FROM Student WHERE StudentID = p_StudentID;
    IF v_Marks IS NULL THEN
        SELECT 'Student not found' AS Result;
    ELSEIF v_Marks >= 50 THEN
        SELECT 'Pass' AS Result;
    ELSE
        SELECT 'Fail' AS Result;
    END IF;
END //

-- Q9
CREATE PROCEDURE GetStudentsByGender(IN p_Gender VARCHAR(10))
BEGIN
    SELECT * FROM Student WHERE Gender = p_Gender;
END //

-- Q10
CREATE PROCEDURE StudentsBetweenMarks(IN p_Low DECIMAL(5,2), IN p_High DECIMAL(5,2))
BEGIN
    SELECT * FROM Student WHERE Marks BETWEEN p_Low AND p_High;
END //

DELIMITER ;

-- Tests for Q1 - Q10
CALL ShowStudents();                  -- 8 rows
CALL ShowDepartments();               -- 4 rows
CALL ShowCourses();                   -- 5 rows
CALL GetStudent(3);                   -- Rahul
CALL GetStudentsByDept(102);          -- Priya, Sneha
CALL StudentsAboveMarks(80);          -- Amit 85.5, Priya 92, Neha 88, Sneha 95, Pooja 81
CALL TotalStudents();                 -- 8
CALL CheckResult(5);                  -- Pass  (69.5)
CALL GetStudentsByGender('Female');   -- Priya, Neha, Sneha, Pooja
CALL StudentsBetweenMarks(70, 90);    -- Amit, Rahul, Neha, Arjun, Rohit, Pooja

-- ======================== FUNCTIONS (Q11 - Q20) =======================
-- A function must RETURN a value. DETERMINISTIC tells MySQL the same input
-- always gives the same output (needed unless log_bin_trust_function_creators=1).
DELIMITER //

-- Q11
CREATE FUNCTION AddTwoNumbers(a INT, b INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN a + b;
END //

-- Q12
CREATE FUNCTION FindSquare(n INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN n * n;
END //

-- Q13
CREATE FUNCTION ResultStatus(p_Marks DECIMAL(5,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF p_Marks >= 50 THEN
        RETURN 'Pass';
    END IF;
    RETURN 'Fail';
END //

-- Q14
CREATE FUNCTION StudentGrade(p_Marks DECIMAL(5,2))
RETURNS CHAR(1)
DETERMINISTIC
BEGIN
    DECLARE g CHAR(1);
    IF p_Marks >= 90 THEN
        SET g = 'A';
    ELSEIF p_Marks >= 75 THEN
        SET g = 'B';
    ELSEIF p_Marks >= 60 THEN
        SET g = 'C';
    ELSE
        SET g = 'D';
    END IF;
    RETURN g;
END //

-- Q15
CREATE FUNCTION AgeCategory(p_Age INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF p_Age >= 18 THEN
        RETURN 'Adult';
    END IF;
    RETURN 'Minor';
END //

-- Q16
CREATE FUNCTION CalculateBonus(p_Marks DECIMAL(5,2))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE bonus INT;
    IF p_Marks >= 90 THEN
        SET bonus = 1000;
    ELSEIF p_Marks >= 75 THEN
        SET bonus = 500;
    ELSE
        SET bonus = 200;
    END IF;
    RETURN bonus;
END //

-- Q17
CREATE FUNCTION HigherNumber(a INT, b INT)
RETURNS INT
DETERMINISTIC
BEGIN
    IF a >= b THEN
        RETURN a;
    END IF;
    RETURN b;
END //

-- Q18
CREATE FUNCTION DoubleMarks(p_Marks DECIMAL(5,2))
RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    RETURN p_Marks * 2;
END //

-- Q19
CREATE FUNCTION AgeAfterFiveYears(p_Age INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN p_Age + 5;
END //

DELIMITER ;

-- Tests for Q11 - Q19
SELECT AddTwoNumbers(10, 20)  AS Sum_Result;        -- 30
SELECT FindSquare(5)          AS Square_Result;     -- 25
SELECT ResultStatus(49.5)     AS Status_49_5,       -- Fail
       ResultStatus(50)       AS Status_50;         -- Pass
SELECT StudentGrade(95) AS g95, StudentGrade(80) AS g80,
       StudentGrade(65) AS g65, StudentGrade(40) AS g40;   -- A B C D
SELECT AgeCategory(17) AS a17, AgeCategory(18) AS a18;     -- Minor Adult
SELECT CalculateBonus(92) AS b92, CalculateBonus(80) AS b80,
       CalculateBonus(60) AS b60;                          -- 1000 500 200
SELECT HigherNumber(7, 12) AS Higher;               -- 12
SELECT DoubleMarks(85.50)     AS Double_Result;     -- 171.00
SELECT AgeAfterFiveYears(20)  AS Age_In_5_Years;    -- 25

-- Q20  (uses StudentGrade from Q14)
SELECT StudentName, Marks, StudentGrade(Marks) AS Grade
FROM Student;
-- Expected:
-- Amit 85.50 B | Priya 92.00 A | Rahul 76.50 B | Neha 88.00 B
-- Arjun 69.50 C | Sneha 95.00 A | Rohit 72.00 C | Pooja 81.00 B
