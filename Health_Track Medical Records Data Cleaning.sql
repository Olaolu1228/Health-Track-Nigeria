-- Carrying out Data Inspection and Cleaning on the Records Table

SELECT *
FROM Records_1

-- Check for duplicate record_id

SELECT record_id, COUNT(*) AS count
FROM Records_1
GROUP BY record_id
HAVING COUNT(*) > 1;

-- Check the full duplicate rows

SELECT *
FROM Records_1
WHERE record_id IN (
    SELECT record_id
    FROM Records_1
    GROUP BY record_id
    HAVING COUNT(*) > 1
)
ORDER BY record_id;

-- -- See duplicate record_ids where patient_id differs
SELECT 
    record_id,
    patient_id,
    admission_date,
    diagnosis,
    hospital,
    department
FROM Records_1
WHERE record_id IN (
    SELECT record_id
    FROM Records_1
    GROUP BY record_id
    HAVING COUNT(*) > 1
)
ORDER BY record_id, patient_id;

-- - same record_id different patient
SELECT 
    record_id,
    COUNT(DISTINCT patient_id) AS different_patients
FROM Records_1
GROUP BY record_id
HAVING COUNT(DISTINCT patient_id) > 1;

-- Find the highest record number currently in the table
SELECT TOP 1
    record_id,
    CAST(SUBSTRING(record_id, 4, LEN(record_id)) AS INT) AS record_num
FROM Records_1
ORDER BY CAST(SUBSTRING(record_id, 4, LEN(record_id)) AS INT) DESC;

-- i can now reassign the new record_ids to duplicate rows and keep original 
WITH CTE AS (
    SELECT 
        record_id,
        patient_id,
        ROW_NUMBER() OVER (
            PARTITION BY record_id 
            ORDER BY admission_date
        ) AS row_num,
        ROW_NUMBER() OVER (
            ORDER BY record_id
        ) AS new_num
    FROM Records_1
    WHERE record_id IN (
        SELECT record_id
        FROM Records_1
        GROUP BY record_id
        HAVING COUNT(DISTINCT patient_id) > 1
    )
)
UPDATE m
SET m.record_id = 'REC' + RIGHT('000000' + CAST(90000 + c.new_num AS VARCHAR(10)), 6)
FROM Records_1 m
INNER JOIN CTE c 
    ON m.record_id = c.record_id
    AND m.patient_id = c.patient_id
WHERE c.row_num > 1;

-- i am starting new IDs from 90000 which will ensure that they don't clash with existing IDs which run from
-- REC000001 to REC015000

-- Confirm no more duplicate record_ids
SELECT 
    record_id,
    COUNT(*) AS count
FROM Records_1
GROUP BY record_id
HAVING COUNT(*) > 1;

SElECT *
FROM Records_1

-- Check for null diagnosis

SELECT * 
FROM Records_1
WHERE diagnosis IS NULL;

-- Check if nulls are concentrated in specific departments or hospitals
SELECT 
    department,
    hospital,
    COUNT(*) AS total_records,
    SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END) AS null_diagnosis
FROM Records_1
GROUP BY department, hospital
HAVING SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END) > 0
ORDER BY null_diagnosis DESC;

-- Check if nulls are linked to specific admission types
SELECT 
    admission_type,
    COUNT(*) AS total,
    SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END) AS null_diagnosis
FROM Records_1
GROUP BY admission_type
ORDER BY null_diagnosis DESC;

-- Check if nulls are linked to a specific patient status
SELECT 
    patient_status,
    COUNT(*) AS total,
    SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END) AS null_diagnosis
FROM Records_1
GROUP BY patient_status
ORDER BY null_diagnosis DESC;

-- Try and match the Null diagnosis to the medications prescribed

SELECT 
    record_id,
    patient_id,
    department,
    medication_prescribed,
    diagnosis
FROM Records_1
WHERE diagnosis IS NULL
ORDER BY department, medication_prescribed;

--Try and match the nulls diagnosis to a specific medication prescribed

-- If medication is Metformin diagnosis is likely Diabetes
UPDATE Records_1
SET diagnosis = 'Diabetes'
WHERE diagnosis IS NULL
AND medication_prescribed = 'Metformin';

-- If medication is Artemether diagnosis is likely Malaria
UPDATE Records_1
SET diagnosis = 'Malaria'
WHERE diagnosis IS NULL
AND medication_prescribed = 'Artemether';

-- If medication is Amlodipine diagnosis is likely Hypertension
UPDATE Records_1
SET diagnosis = 'Hypertension'
WHERE diagnosis IS NULL
AND medication_prescribed = 'Amlodipine';

-- If medication is Sertraline diagnosis is likely Depression
UPDATE Records_1
SET diagnosis = 'Depression'
WHERE diagnosis IS NULL
AND medication_prescribed = 'Sertraline';

-- If medication is Carbamazepine diagnosis is likely Epilepsy
UPDATE Records_1
SET diagnosis = 'Epilepsy'
WHERE diagnosis IS NULL
AND medication_prescribed = 'Carbamazepine';

--- Check how many rows are still left with null diagnosis
SELECT 
    SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END) AS still_null,
    SUM(CASE WHEN diagnosis IS NOT NULL THEN 1 ELSE 0 END) AS recovered
FROM Records_1;

-- Suggestion : Using the department as a general placeholder

-- Set diagnosis to department general condition
UPDATE Records_1
SET diagnosis = 
    CASE department
        WHEN 'Cardiology'       THEN 'Unspecified Cardiac Condition'
        WHEN 'Oncology'         THEN 'Unspecified Oncological Condition'
        WHEN 'Neurology'        THEN 'Unspecified Neurological Condition'
        WHEN 'Pediatrics'       THEN 'Unspecified Pediatric Condition'
        WHEN 'Orthopedics'      THEN 'Unspecified Orthopedic Condition'
        WHEN 'Gynecology'       THEN 'Unspecified Gynecological Condition'
        WHEN 'Dermatology'      THEN 'Unspecified Dermatological Condition'
        WHEN 'Psychiatry'       THEN 'Unspecified Psychiatric Condition'
        WHEN 'Emergency'        THEN 'Unspecified Emergency Condition'
        WHEN 'General Practice' THEN 'Unspecified General Condition'
        ELSE 'Unspecified Condition'
    END
WHERE diagnosis IS NULL;


-- Records with unusual discharge and admission date
-- Records with earlier discharge than admission date 
SELECT record_id, admission_date, discharge_date
FROM Records_1
WHERE discharge_date < admission_date;

-- Case 1:  Cases where the discharge date recorded and admission date recorded was swapped

SELECT 
    record_id,
    admission_date,
    discharge_date,
    length_of_stay,
    ABS(DATEDIFF(DAY,
        CAST(admission_date AS DATE),
        CAST(discharge_date AS DATE)
    )) AS actual_difference
FROM Records_1
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE)
AND length_of_stay = ABS(DATEDIFF(DAY,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE)
));

--- Fix for Case 1

UPDATE Records_1
SET 
    admission_date  = discharge_date,
    discharge_date  = admission_date
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE)
AND length_of_stay = ABS(DATEDIFF(DAY,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE)
));

-- Case 2:Cases where admission date is correct and discharge date is a typo

SELECT 
    record_id,
    admission_date,
    discharge_date,
    length_of_stay
FROM Records_1
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE)
AND ABS(DATEDIFF(DAY,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE)
)) <= 3;

--- Fix for Case 2: Use the length of stay to get the correct discharge date
--- discharge date = admission date + length of stay

UPDATE Records_1
SET discharge_date = CONVERT(VARCHAR(20),
    DATEADD(DAY, length_of_stay, CAST(admission_date AS DATE)),
23)
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE)
AND length_of_stay > 0;

-- Case 3: Cases where theres a large difference between the admission date and discharge date
-- Where maybe a wrong year was entered into the records

SELECT 
    record_id,
    admission_date,
    discharge_date,
    length_of_stay
FROM Records_1
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE)
AND ABS(DATEDIFF(DAY,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE)
)) > 365;

-- Fix: Lets just make the discharge date as NULL or Under review

UPDATE Records_1
SET 
    discharge_date = NULL,
    patient_status = 'Discharge Date - Under Review'
WHERE CAST(discharge_date AS DATE) < CAST(admission_date AS DATE);

-- To verify all invalid dates are fixed
SELECT 
    record_id,
    admission_date,
    discharge_date
FROM Records_1
WHERE discharge_date IS NOT NULL
AND CAST(discharge_date AS DATE) < CAST(admission_date AS DATE);


-- Lets Perform EDA Analysis
-- From analysis, Patient paid = bill amount - insurance covered
-- Lets check for rows where patient paid != bill amount - insurance covered

SELECT record_id, bill_amount, insurance_covered, patient_paid,
       ROUND(bill_amount - insurance_covered, 2) AS expected_paid,
       ABS(patient_paid - ROUND(bill_amount - insurance_covered, 2)) AS difference
FROM Records_1
WHERE ABS(patient_paid - ROUND(bill_amount - insurance_covered, 2)) > 100
ORDER BY difference DESC;

-- From the Analysis, we can see that some patients were overcharged and some were undercharged

-- For the number patients that were overcharged

SELECT 
    COUNT(*) AS overcharged_patients,
    SUM(ROUND(patient_paid - 
        ROUND(bill_amount - insurance_covered, 2), 2)) AS total_overcharged
FROM Records_1
WHERE ROUND(patient_paid - 
    ROUND(bill_amount - insurance_covered, 2), 2) > 100;


-- For the number of patients that were u dercharged

SELECT 
    COUNT(*) AS undercharged_patients,
    SUM(ROUND(ROUND(bill_amount - insurance_covered, 2) 
        - patient_paid, 2)) AS total_undercharged
FROM Records_1
WHERE ROUND(ROUND(bill_amount - insurance_covered, 2) 
    - patient_paid, 2) > 100;

-- Also in a case where the Insurance covers more than the amount the total_paid

SELECT 
    record_id,
    patient_id,
    bill_amount,
    insurance_covered,
    patient_paid
FROM Records_1
WHERE insurance_covered > bill_amount
ORDER BY insurance_covered DESC;

-- There was no case where the insurance covered more than the Patient paid..Confirmation test

-- The best fix for billing errors is to Fix the error and keep a record of what was changed
-- For this we create a new Table to keep as an audit

-- Create the Audit table

CREATE TABLE Billing_Audit (
    record_id               VARCHAR(20),
    patient_id              VARCHAR(20),
    original_patient_paid   FLOAT,
    corrected_patient_paid  FLOAT,
    billing_difference      FLOAT,
    error_type              VARCHAR(20),
    corrected_date          DATETIME DEFAULT GETDATE()
);


-- Log all the errors before applying the fix

INSERT INTO Billing_Audit (
    record_id,
    patient_id,
    original_patient_paid,
    corrected_patient_paid,
    billing_difference,
    error_type
)
SELECT 
    record_id,
    patient_id,
    patient_paid AS original_patient_paid,
    ROUND(bill_amount - insurance_covered, 2) AS corrected_patient_paid,
    ROUND(ABS(patient_paid - 
        ROUND(bill_amount - insurance_covered, 2)), 2) AS billing_difference,
    CASE 
        WHEN patient_paid > ROUND(bill_amount - insurance_covered, 2) 
            THEN 'Overcharged'
        ELSE 'Undercharged'
    END AS error_type
FROM Records_1
WHERE ROUND(ABS(patient_paid - 
    ROUND(bill_amount - insurance_covered, 2)), 2) > 100;

-- Verify the Audit table was recorded well

SELECT *
FROM Billing_Audit

SELECT 
    error_type,
    COUNT(*) AS records_fixed,
    SUM(billing_difference) AS total_discrepancy
FROM Billing_Audit
GROUP BY error_type;

-- Apply Fix to the record table

UPDATE Records_1
SET patient_paid = ROUND(bill_amount - insurance_covered, 2)
WHERE ROUND(ABS(patient_paid - 
    ROUND(bill_amount - insurance_covered, 2)), 2) > 100;

-- Lets verify all the billing errors are fixed in our records table

SELECT COUNT(*) AS remaining_errors
FROM Records_1
WHERE ROUND(ABS(patient_paid - 
    ROUND(bill_amount - insurance_covered, 2)), 2) > 100;


-- Lets check for records with abnormal vitals values (abnormal blood pressure, temperature, weight, etc values)

SELECT * 
FROM Records_1
WHERE systolic_bp > 250 OR systolic_bp <= 0
   OR temperature_c > 45 OR temperature_c < 30
   OR weight_kg <= 0 OR weight_kg > 300
   OR bmi <= 0 OR bmi > 100;

-- From Google serach 
-- For systolic bp - Min value = 60, Max value = 250
-- For diastolic bp - Min value = 40, Max value = 150
-- For temperature, Celcius - Min value = 34.0, Max Value = 42.0
-- For weight, Kg - Min value = 2.0, Max value = 300
-- For bmi - Min value = 10.0, Max value = 80.0 

-- Lets check from the records for vitals that are Outliers

SELECT
    SUM(CASE WHEN systolic_bp <= 0 OR systolic_bp > 250       THEN 1 ELSE 0 END) AS systolic_outliers,
    SUM(CASE WHEN diastolic_bp <= 0 OR diastolic_bp > 150     THEN 1 ELSE 0 END) AS diastolic_outliers,
    SUM(CASE WHEN temperature_c < 34 OR temperature_c > 42    THEN 1 ELSE 0 END) AS temperature_outliers,
    SUM(CASE WHEN weight_kg <= 0 OR weight_kg > 300           THEN 1 ELSE 0 END) AS weight_outliers,
    SUM(CASE WHEN bmi <= 0 OR bmi > 80                        THEN 1 ELSE 0 END) AS bmi_outliers
FROM Records_1;

-- Lets flag all the Outliers and add them to our table

ALTER TABLE Records_1
ADD vitals_flag VARCHAR(50) DEFAULT 'Valid';

-- Fix systolic bp

UPDATE m
SET m.systolic_bp = dept_avg.avg_systolic,
    m.vitals_flag = 'Systolic BP - Replaced'
FROM Records_1 m
INNER JOIN (
    SELECT department,
        AVG(CAST(systolic_bp AS FLOAT)) AS avg_systolic
    FROM Records_1
    WHERE systolic_bp BETWEEN 60 AND 250
    GROUP BY department
) dept_avg ON m.department = dept_avg.department
WHERE m.systolic_bp <= 0 OR m.systolic_bp > 250;

-- Fix diastolic bp

UPDATE m
SET m.diastolic_bp = dept_avg.avg_diastolic,
    m.vitals_flag = 'Diastolic BP - Replaced'
FROM Records_1 m
INNER JOIN (
    SELECT department,
        AVG(CAST(diastolic_bp AS FLOAT)) AS avg_diastolic
    FROM Records_1
    WHERE diastolic_bp BETWEEN 40 AND 150
    GROUP BY department
) dept_avg ON m.department = dept_avg.department
WHERE m.diastolic_bp <= 0 OR m.diastolic_bp > 150;

-- Fix for temperature

UPDATE m
SET m.temperature_c = ROUND(dept_avg.avg_temp, 1),
    m.vitals_flag = 'Temperature - Replaced'
FROM Records_1 m
INNER JOIN (
    SELECT department,
        AVG(CAST(temperature_c AS FLOAT)) AS avg_temp
    FROM Records_1
    WHERE temperature_c BETWEEN 34 AND 42
    GROUP BY department
) dept_avg ON m.department = dept_avg.department
WHERE m.temperature_c < 34 OR m.temperature_c > 42;

-- Fix for Weight

UPDATE Records_1
SET weight_kg = NULL,
    vitals_flag = 'Weight - Set to NULL'
WHERE weight_kg <= 0 OR weight_kg > 300;

-- Fix Bmi

UPDATE Records_1
SET bmi = ROUND(weight_kg / (1.70 * 1.70), 1)
WHERE (bmi <= 0 OR bmi > 80)
AND weight_kg IS NOT NULL
AND weight_kg BETWEEN 2 AND 300;

UPDATE Records_1
SET bmi = NULL,
    vitals_flag = 'BMI - Set to NULL'
WHERE bmi <= 0 OR bmi > 80;

-- Verify if we do not have any Outlier Vitals

SELECT
    SUM(CASE WHEN systolic_bp <= 0 OR systolic_bp > 250    THEN 1 ELSE 0 END) AS systolic_outliers,
    SUM(CASE WHEN diastolic_bp <= 0 OR diastolic_bp > 150  THEN 1 ELSE 0 END) AS diastolic_outliers,
    SUM(CASE WHEN temperature_c < 34 OR temperature_c > 42 THEN 1 ELSE 0 END) AS temperature_outliers,
    SUM(CASE WHEN weight_kg <= 0 OR weight_kg > 300        THEN 1 ELSE 0 END) AS weight_outliers,
    SUM(CASE WHEN bmi <= 0 OR bmi > 80                     THEN 1 ELSE 0 END) AS bmi_outliers
FROM Records_1;

SELECT *
FROM Records_1

-- Lets check for abnormal length of stay (negative stays)

SELECT * 
FROM Records_1
WHERE length_of_stay < 0;

-- length of stay can be recalculated from admission date and discharge date

UPDATE Records_1
SET length_of_stay = DATEDIFF(DAY,
    CAST(admission_date AS DATE),
    CAST(discharge_date AS DATE)
)
WHERE length_of_stay < 0
AND discharge_date IS NOT NULL
AND CAST(discharge_date AS DATE) > CAST(admission_date AS DATE);

-- Some records are still affected due to Null discharge dates
-- Personally i will use the department average length of stay

UPDATE m
SET m.length_of_stay = dept_avg.avg_los
FROM Records_1 m
INNER JOIN (
    SELECT 
        department,
        AVG(CAST(length_of_stay AS FLOAT)) AS avg_los
    FROM Records_1
    WHERE length_of_stay > 0
    GROUP BY department
) AS dept_avg ON m.department = dept_avg.department
WHERE m.length_of_stay < 0
AND (m.discharge_date IS NULL
    OR CAST(m.discharge_date AS DATE) <= CAST(m.admission_date AS DATE));


-- Lets use the JOIN statement to get patients that have recors in the records table but not in the Patients table

SELECT r.*
FROM Records_1 r
LEFT JOIN Patient_1 p ON r.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- Best fix for this sceneario is to create placeholders patients for orpahend records

--- Find all unique orphaned patient_ids
SELECT DISTINCT r.patient_id
FROM Records_1 r
LEFT JOIN Patient_1 p ON r.patient_id = p.patient_id
WHERE p.patient_id IS NULL
AND r.patient_id IS NOT NULL;

-- Insert placeholder patients for each orphaned ID
-- Insert placeholder patients with correct data types
INSERT INTO Patient_1(
    patient_id,
    full_name,
    gender,
    age,
    state_of_origin,
    insurance_type,
    registration_date,
    chronic_condition,
    allergies
)
SELECT DISTINCT
    r.patient_id,
    'Unknown Patient'   AS full_name,
    'Unknown'           AS gender,
    0                   AS age,
    'Unknown'           AS state_of_origin,
    'Unknown'           AS insurance_type,
    CONVERT(VARCHAR(20), GETDATE(), 23) AS registration_date,
    0                   AS chronic_condition,
    'None'              AS allergies
FROM Records_1 r
LEFT JOIN Patient_1 p ON r.patient_id = p.patient_id
WHERE p.patient_id IS NULL
AND r.patient_id IS NOT NULL;

-- Add a flag to identify placeholder patients
ALTER TABLE Patient_1
ADD patient_flag VARCHAR(30) DEFAULT 'Valid';

UPDATE Patient_1
SET patient_flag = 'Placeholder - Orphaned Record'
WHERE full_name = 'Unknown Patient';

-- Verify placeholders were created
SELECT COUNT(*) AS placeholder_patients
FROM Patient_1
WHERE patient_flag = 'Placeholder - Orphaned Record';