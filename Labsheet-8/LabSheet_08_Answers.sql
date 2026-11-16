-- =====================================================================
-- Database Technologies Lab Sheet 8 (MCA105P-AS15)
-- Functions and Stored Procedures (Hospital_Functions_Lab)  -- Q1 - Q10
-- MySQL / MariaDB
-- =====================================================================
-- Run the database/table/data script from the lab sheet first.
-- ASSUMPTION: Q1 and Q9 need a height for the BMI, but the Patients table
-- has no height column. The block below adds one with sample heights (metres).
-- Replace the numbers with your own if your teacher gave different ones.
-- =====================================================================
USE Hospital_Functions_Lab;

ALTER TABLE Patients ADD COLUMN HeightM DECIMAL(4,2);
UPDATE Patients SET HeightM = 1.60 WHERE PatientID = 201;
UPDATE Patients SET HeightM = 1.75 WHERE PatientID = 202;
UPDATE Patients SET HeightM = 1.62 WHERE PatientID = 203;
UPDATE Patients SET HeightM = 1.70 WHERE PatientID = 204;
UPDATE Patients SET HeightM = 1.68 WHERE PatientID = 205;
UPDATE Patients SET HeightM = 1.58 WHERE PatientID = 206;

-- ============================ FUNCTIONS ==============================
DELIMITER //

-- Q1  BMI = weight (kg) / height (m)^2
CREATE FUNCTION calculate_bmi(weight_kg DECIMAL(5,2), height_m DECIMAL(4,2))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    IF height_m IS NULL OR height_m <= 0 THEN
        RETURN NULL;
    END IF;
    RETURN ROUND(weight_kg / (height_m * height_m), 2);
END //

-- Q2  rules chosen: Child below 18, Adult 18-59, Senior 60 and above
CREATE FUNCTION age_category(p_age INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF p_age < 18 THEN
        RETURN 'Child';
    ELSEIF p_age < 60 THEN
        RETURN 'Adult';
    END IF;
    RETURN 'Senior';
END //

-- Q3  fee after adding tax %
CREATE FUNCTION consultation_with_tax(fee DECIMAL(10,2), tax_percent DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(fee + (fee * tax_percent / 100), 2);
END //

-- Q4  stock value = UnitPrice x Stock
CREATE FUNCTION medicine_stock_value(unit_price DECIMAL(10,2), stock INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN unit_price * stock;
END //

DELIMITER ;

-- Tests
SELECT calculate_bmi(70, 1.75) AS BMI;                     -- 22.86
-- Q2 applied to every patient
SELECT PatientID, PatientName, Age, age_category(Age) AS Category FROM Patients;
--   Asha 24 Adult | Rohan 35 Adult | Meera 29 Adult | Vivek 46 Adult
--   Nitin 17 Child | Kavya 52 Adult   (no patient is 60+, so no 'Senior' appears)
-- Q3 original and calculated fee (18% tax)
SELECT PatientID, PatientName, ConsultationFee AS OriginalFee,
       consultation_with_tax(ConsultationFee, 18) AS FeeWithTax
FROM Patients;
--   600 -> 708.00 | 800 -> 944.00 | 700 -> 826.00 | 1000 -> 1180.00 | 500 -> 590.00 | 900 -> 1062.00
-- Q4 stock value for every medicine
SELECT MedicineID, MedicineName, UnitPrice, Stock,
       medicine_stock_value(UnitPrice, Stock) AS StockValue
FROM Medicines;
--   Paracetamol 2500.00 | Amoxicillin 4000.00 | Cetirizine 2625.00
--   Omeprazole 2400.00  | Azithromycin 3000.00

-- ========================= STORED PROCEDURES ==========================
DELIMITER //

-- Q5
CREATE PROCEDURE patient_by_gender(IN p_gender VARCHAR(10))
BEGIN
    SELECT * FROM Patients WHERE Gender = p_gender;
END //

-- Q6
CREATE PROCEDURE patients_above_age(IN p_age INT)
BEGIN
    SELECT * FROM Patients WHERE Age > p_age;
END //

-- Q7
CREATE PROCEDURE update_medicine_stock(IN p_id INT, IN p_quantity INT)
BEGIN
    UPDATE Medicines SET Stock = Stock + p_quantity WHERE MedicineID = p_id;
    SELECT * FROM Medicines WHERE MedicineID = p_id;      -- shows the changed row
END //

-- Q8
CREATE PROCEDURE medicine_count(OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count FROM Medicines;
END //

-- Q9  uses calculate_bmi() and age_category()
CREATE PROCEDURE patient_report()
BEGIN
    SELECT PatientID,
           PatientName,
           Age,
           calculate_bmi(WeightKg, HeightM) AS BMI,
           age_category(Age)                AS AgeCategory
    FROM Patients;
END //

-- Q10  uses medicine_stock_value()
CREATE PROCEDURE medicine_report()
BEGIN
    SELECT MedicineID,
           MedicineName,
           UnitPrice,
           Stock,
           medicine_stock_value(UnitPrice, Stock) AS StockValue,
           CASE
               WHEN Stock < 30  THEN 'Low Stock'
               WHEN Stock < 60  THEN 'Moderate Stock'
               ELSE 'Well Stocked'
           END AS StockStatus
    FROM Medicines;
END //

DELIMITER ;

-- Run them
CALL patient_by_gender('F');            -- Asha, Meera, Kavya
CALL patient_by_gender('M');            -- Rohan, Vivek, Nitin
CALL patients_above_age(30);            -- Rohan 35, Vivek 46, Kavya 52
CALL patients_above_age(45);            -- Vivek 46, Kavya 52
CALL update_medicine_stock(301, 20);    -- Paracetamol stock 100 -> 120
CALL medicine_count(@total_medicines);
SELECT @total_medicines AS TotalMedicines;              -- 5
CALL patient_report();
--   Asha 24 BMI 21.68 Adult | Rohan 35 23.51 Adult | Meera 29 23.43 Adult
--   Vivek 46 29.41 Adult    | Nitin 17 20.55 Child | Kavya 52 27.24 Adult
CALL medicine_report();
--   (after Q7, Paracetamol has stock 120)
--   Paracetamol 25 x 120 = 3000.00 Well Stocked | Amoxicillin 80 x 50 = 4000.00 Moderate Stock
--   Cetirizine 35 x 75 = 2625.00 Well Stocked   | Omeprazole 60 x 40 = 2400.00 Moderate Stock
--   Azithromycin 120 x 25 = 3000.00 Low Stock

-- Verify the stored definitions
SHOW CREATE FUNCTION calculate_bmi;
SHOW CREATE PROCEDURE patient_report;
