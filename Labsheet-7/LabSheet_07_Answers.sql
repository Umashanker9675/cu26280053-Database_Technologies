-- =====================================================================
-- Database Technologies Lab Sheet 7 (MCA105P-AS14)
-- Cursors (Q1-Q10) and Triggers (Q1-Q10)  -- Hospital_Cursor_Trigger_Lab
-- MySQL 5.7+ / 8.x
-- =====================================================================
-- Part C of the sheet (database + tables + dataset) must be run first.
-- Data-changing questions depend on earlier ones, so the expected values are
-- noted in comments. To start clean, re-run the Part C script.
-- =====================================================================
USE Hospital_Cursor_Trigger_Lab;

-- ============================ PART D : CURSORS =======================
-- Declaration order inside a routine is fixed:
--   1) variables   2) CURSOR   3) HANDLER   4) executable statements
-- Display-style cursors collect rows into a TEMPORARY table, then SELECT it
-- once at the end (a SELECT inside the loop would return one result set per row).
DELIMITER //

-- Cursor Q1  - DoctorID and DoctorName for every doctor
CREATE PROCEDURE cur_show_doctors()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(50);
    DECLARE v_count INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT DoctorID, DoctorName FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS tmp_doctors;
    CREATE TEMPORARY TABLE tmp_doctors (DoctorID INT, DoctorName VARCHAR(50));

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id, v_name;
        IF done THEN LEAVE read_loop; END IF;
        INSERT INTO tmp_doctors VALUES (v_id, v_name);
        SET v_count = v_count + 1;
    END LOOP;
    CLOSE cur;

    SELECT * FROM tmp_doctors;
    SELECT v_count AS DoctorsProcessed;          -- 6
END //

-- Cursor Q2  - fee greater than 1000
CREATE PROCEDURE cur_fee_above_1000()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(50);
    DECLARE v_fee DECIMAL(10,2);
    DECLARE cur CURSOR FOR SELECT DoctorID, DoctorName, ConsultationFee FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS tmp_high_fee;
    CREATE TEMPORARY TABLE tmp_high_fee (DoctorID INT, DoctorName VARCHAR(50), ConsultationFee DECIMAL(10,2));

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id, v_name, v_fee;
        IF done THEN LEAVE read_loop; END IF;
        IF v_fee > 1000 THEN
            INSERT INTO tmp_high_fee VALUES (v_id, v_name, v_fee);
        END IF;
    END LOOP;
    CLOSE cur;

    SELECT * FROM tmp_high_fee;    -- Anil 1200, Chirag 1500, Eshan 1300
END //

-- Cursor Q3  - total fee through an OUT parameter
CREATE PROCEDURE cur_total_fee(OUT p_total DECIMAL(12,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_fee DECIMAL(10,2);
    DECLARE cur CURSOR FOR SELECT ConsultationFee FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET p_total = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_fee;
        IF done THEN LEAVE read_loop; END IF;
        SET p_total = p_total + v_fee;
    END LOOP;
    CLOSE cur;
END //

-- Cursor Q4  - count of Cardiology doctors
CREATE PROCEDURE cur_count_cardiology(OUT p_count INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_dept VARCHAR(40);
    DECLARE cur CURSOR FOR SELECT Department FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET p_count = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_dept;
        IF done THEN LEAVE read_loop; END IF;
        IF v_dept = 'Cardiology' THEN
            SET p_count = p_count + 1;
        END IF;
    END LOOP;
    CLOSE cur;
END //

-- Cursor Q5  - average fee, safe when the table is empty
CREATE PROCEDURE cur_avg_fee(OUT p_avg DECIMAL(10,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_fee DECIMAL(10,2);
    DECLARE v_sum DECIMAL(12,2) DEFAULT 0;
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT ConsultationFee FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_fee;
        IF done THEN LEAVE read_loop; END IF;
        SET v_sum = v_sum + v_fee;
        SET v_cnt = v_cnt + 1;
    END LOOP;
    CLOSE cur;

    IF v_cnt = 0 THEN
        SET p_avg = NULL;                       -- no rows: avoid division by zero
        SELECT 'No doctor records available' AS Message;
    ELSE
        SET p_avg = v_sum / v_cnt;
    END IF;
END //

-- Cursor Q6  - Pediatrics fees +10%  (900 -> 990, 850 -> 935)
CREATE PROCEDURE cur_raise_pediatrics()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE cur CURSOR FOR SELECT DoctorID FROM Doctors WHERE Department = 'Pediatrics';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done THEN LEAVE read_loop; END IF;
        UPDATE Doctors SET ConsultationFee = ConsultationFee * 1.10 WHERE DoctorID = v_id;
    END LOOP;
    CLOSE cur;
END //

-- Cursor Q7  - Status = 'Review' for fee below 1000
CREATE PROCEDURE cur_mark_review()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_fee DECIMAL(10,2);
    DECLARE cur CURSOR FOR SELECT DoctorID, ConsultationFee FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id, v_fee;
        IF done THEN LEAVE read_loop; END IF;
        IF v_fee < 1000 THEN
            UPDATE Doctors SET Status = 'Review' WHERE DoctorID = v_id;
        END IF;
    END LOOP;
    CLOSE cur;
END //

-- Cursor Q8  - report ordered by Department, DoctorName
CREATE PROCEDURE cur_doctor_report()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_name VARCHAR(50);
    DECLARE v_dept VARCHAR(40);
    DECLARE v_fee DECIMAL(10,2);
    DECLARE cur CURSOR FOR
        SELECT DoctorName, Department, ConsultationFee
        FROM Doctors
        ORDER BY Department, DoctorName;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS tmp_report;
    CREATE TEMPORARY TABLE tmp_report (DoctorName VARCHAR(50), Department VARCHAR(40), ConsultationFee DECIMAL(10,2));

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_name, v_dept, v_fee;
        IF done THEN LEAVE read_loop; END IF;
        INSERT INTO tmp_report VALUES (v_name, v_dept, v_fee);
    END LOOP;
    CLOSE cur;

    SELECT * FROM tmp_report;     -- rows come out in cursor order (insertion order)
END //

-- Cursor Q9  - count Active doctors
CREATE PROCEDURE cur_count_active(OUT p_count INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_status VARCHAR(20);
    DECLARE cur CURSOR FOR SELECT Status FROM Doctors;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET p_count = 0;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_status;
        IF done THEN LEAVE read_loop; END IF;
        IF v_status = 'Active' THEN
            SET p_count = p_count + 1;
        END IF;
    END LOOP;
    CLOSE cur;
END //

-- Cursor Q10 - 5% increase for fee >= 1200
CREATE PROCEDURE cur_raise_high_fee()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE cur CURSOR FOR SELECT DoctorID FROM Doctors WHERE ConsultationFee >= 1200;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done THEN LEAVE read_loop; END IF;
        UPDATE Doctors SET ConsultationFee = ConsultationFee * 1.05 WHERE DoctorID = v_id;
    END LOOP;
    CLOSE cur;
END //

DELIMITER ;

-- ---- Run / verify the cursor procedures --------------------------------
CALL cur_show_doctors();                         -- 6 doctors, DoctorsProcessed = 6
CALL cur_fee_above_1000();
CALL cur_total_fee(@total);   SELECT @total AS TotalFee;          -- 6750.00
CALL cur_count_cardiology(@c); SELECT @c AS CardiologyDoctors;    -- 2
CALL cur_avg_fee(@avg);       SELECT @avg AS AverageFee;          -- 1125.00
CALL cur_raise_pediatrics();  SELECT * FROM Doctors;              -- 202 -> 990, 206 -> 935
CALL cur_mark_review();       SELECT * FROM Doctors;              -- 202, 206 become 'Review'
CALL cur_doctor_report();
CALL cur_count_active(@a);    SELECT @a AS ActiveDoctors;         -- 4 after Q7 (6 on fresh data)
CALL cur_raise_high_fee();    SELECT * FROM Doctors;              -- 201 -> 1260, 203 -> 1575, 205 -> 1365

-- ============================ PART E : TRIGGERS ======================
-- To let Trigger Q9 store the old/new department, two nullable columns are
-- added to Doctor_Audit (the original table has no place for them).
ALTER TABLE Doctor_Audit
    ADD COLUMN OldDepartment VARCHAR(40) NULL,
    ADD COLUMN NewDepartment VARCHAR(40) NULL;

DELIMITER //

-- Trigger Q1 - AFTER INSERT audit
CREATE TRIGGER trg_doctor_after_insert
AFTER INSERT ON Doctors
FOR EACH ROW
BEGIN
    INSERT INTO Doctor_Audit (DoctorID, ActionType, OldFee, NewFee)
    VALUES (NEW.DoctorID, 'INSERT', NULL, NEW.ConsultationFee);
END //

-- Trigger Q2 - AFTER UPDATE: record OLD and NEW fee when the fee changes
CREATE TRIGGER trg_doctor_after_update_fee
AFTER UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF OLD.ConsultationFee <> NEW.ConsultationFee THEN
        INSERT INTO Doctor_Audit (DoctorID, ActionType, OldFee, NewFee)
        VALUES (OLD.DoctorID, 'FEE_UPDATE', OLD.ConsultationFee, NEW.ConsultationFee);
    END IF;
END //

-- Trigger Q3 - BEFORE INSERT: store DoctorName in uppercase
CREATE TRIGGER trg_doctor_name_upper
BEFORE INSERT ON Doctors
FOR EACH ROW
BEGIN
    SET NEW.DoctorName = UPPER(NEW.DoctorName);
END //

-- Trigger Q4 - BEFORE INSERT: reject a negative fee
CREATE TRIGGER trg_doctor_fee_not_negative_ins
BEFORE INSERT ON Doctors
FOR EACH ROW
BEGIN
    IF NEW.ConsultationFee < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ConsultationFee cannot be negative';
    END IF;
END //

-- Trigger Q5 - AFTER DELETE audit
CREATE TRIGGER trg_doctor_after_delete
AFTER DELETE ON Doctors
FOR EACH ROW
BEGIN
    INSERT INTO Doctor_Audit (DoctorID, ActionType, OldFee, NewFee)
    VALUES (OLD.DoctorID, 'DELETE', OLD.ConsultationFee, NULL);
END //

-- Trigger Q6 - AFTER UPDATE: keep every fee change in Fee_Log
CREATE TRIGGER trg_doctor_fee_log
AFTER UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF OLD.ConsultationFee <> NEW.ConsultationFee THEN
        INSERT INTO Fee_Log (DoctorID, DoctorName, OldFee, NewFee)
        VALUES (OLD.DoctorID, OLD.DoctorName, OLD.ConsultationFee, NEW.ConsultationFee);
    END IF;
END //

-- Trigger Q7 - BEFORE UPDATE: fee can never become negative
CREATE TRIGGER trg_doctor_fee_not_negative_upd
BEFORE UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF NEW.ConsultationFee < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ConsultationFee cannot be updated to a negative value';
    END IF;
END //

-- Trigger Q8 - BEFORE UPDATE: normalise 'active' to 'Active'
CREATE TRIGGER trg_doctor_status_normalize
BEFORE UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF LOWER(NEW.Status) = 'active' THEN
        SET NEW.Status = 'Active';
    END IF;
END //

-- Trigger Q9 - AFTER UPDATE: audit a department change
CREATE TRIGGER trg_doctor_dept_change
AFTER UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF OLD.Department <> NEW.Department THEN
        INSERT INTO Doctor_Audit (DoctorID, ActionType, OldFee, NewFee, OldDepartment, NewDepartment)
        VALUES (OLD.DoctorID, 'DEPARTMENT_CHANGE', OLD.ConsultationFee, NEW.ConsultationFee,
                OLD.Department, NEW.Department);
    END IF;
END //

-- Trigger Q10 - own choice (the sheet's last sentence is cut off, so the rule
-- is explained here): BEFORE UPDATE data-validation rule that blocks a fee
-- change of more than 50% in one step and flags it as a probable typing error.
CREATE TRIGGER trg_doctor_fee_jump_guard
BEFORE UPDATE ON Doctors
FOR EACH ROW
BEGIN
    IF OLD.ConsultationFee > 0
       AND ABS(NEW.ConsultationFee - OLD.ConsultationFee) > OLD.ConsultationFee * 0.5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fee change above 50% is not allowed; check the amount';
    END IF;
END //

DELIMITER ;

-- ---- Tests --------------------------------------------------------------
-- T1 insert + audit
INSERT INTO Doctors VALUES (207,'Dr. Gita','Orthopedics',1100,'Active');
SELECT * FROM Doctor_Audit;                       -- INSERT row, NewFee 1100

-- T2 fee update + audit  (fee 1100 -> 1200 is a change of under 50%)
UPDATE Doctors SET ConsultationFee = 1200 WHERE DoctorID = 207;
SELECT * FROM Doctor_Audit;                       -- FEE_UPDATE 1100 -> 1200

-- T3 uppercase name
INSERT INTO Doctors VALUES (208,'dr. hari','ENT',700,'Active');
SELECT DoctorName FROM Doctors WHERE DoctorID = 208;   -- DR. HARI

-- T4 negative fee on insert
INSERT INTO Doctors VALUES (209,'Dr. Ila','ENT',-100,'Active');
-- ERROR 1644 (45000): ConsultationFee cannot be negative

-- T5 delete + audit
DELETE FROM Doctors WHERE DoctorID = 207;
SELECT * FROM Doctor_Audit WHERE ActionType = 'DELETE';    -- OldFee 1200

-- T6 Fee_Log
UPDATE Doctors SET ConsultationFee = 800 WHERE DoctorID = 208;   -- 700 -> 800
SELECT * FROM Fee_Log;

-- T7 negative fee on update
UPDATE Doctors SET ConsultationFee = -50 WHERE DoctorID = 208;
-- ERROR 1644 (45000): ConsultationFee cannot be updated to a negative value

-- T8 status normalisation
UPDATE Doctors SET Status = 'active' WHERE DoctorID = 208;
SELECT DoctorID, Status FROM Doctors WHERE DoctorID = 208;       -- Active

-- T9 department change audit
UPDATE Doctors SET Department = 'Neurology' WHERE DoctorID = 201;
SELECT * FROM Doctor_Audit WHERE ActionType = 'DEPARTMENT_CHANGE';

-- T10 fee-jump guard
UPDATE Doctors SET ConsultationFee = 5000 WHERE DoctorID = 202;
-- ERROR 1644 (45000): Fee change above 50% is not allowed; check the amount

-- Check all trigger definitions
SHOW TRIGGERS;
