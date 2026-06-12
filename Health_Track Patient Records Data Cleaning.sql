USE health_1

SELECT COUNT (*) AS count_rows
FROM Records_1

SELECT COUNT (*) AS count_rows
FROM Patient_1
-- Carrying out Data Inspection and Cleaning on the Patients Table

SELECT *
FROM Patient_1

-- Check for duplicates

SELECT
patient_id,  
COUNT (*) AS count
FROM Patient_1
GROUP BY patient_id
HAVING COUNT (*) > 1

-- Check the full duplicate rows

SELECT *
FROM Patient_1
WHERE patient_id IN (
    SELECT patient_id
    FROM Patient_1
    GROUP BY patient_id
    HAVING COUNT(*) > 1
)
ORDER BY patient_id;

-- Check if all columns are identical
/*SELECT 
    patient_id,
    full_name,
    age,
    phone,
    COUNT(*) AS count
FROM Patient_1
GROUP BY patient_id, full_name, age, phone
HAVING COUNT(*) > 1; */

-- Since the duplicates are of just similar patient_id but the rest of the columns are different 
-- So what we can do is assign new patient_id to one of the duplicated rows

--  Find the duplicate patient_ids
WITH duplicates AS (
    SELECT 
        patient_id,
        full_name,
        registration_date,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id 
            ORDER BY registration_date
        ) AS row_num
    FROM Patient_1
),
-- Tag only the duplicate rows (row_num > 1)
to_update AS (
    SELECT 
        patient_id,
        full_name,
        row_num,
        ROW_NUMBER() OVER (ORDER BY patient_id) AS new_num
    FROM duplicates
    WHERE row_num > 1
)
-- Update those rows with a new unique ID
UPDATE p
SET p.patient_id = 'PAT_NEW_' + CAST(u.new_num AS VARCHAR(10))
FROM Patient_1 p
INNER JOIN to_update u 
    ON p.patient_id = u.patient_id
    AND p.full_name = u.full_name;


-- To verify it worked 

SELECT 
    patient_id,
    COUNT(*) AS count
FROM Patient_1
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Check if the newly assigned IDs look correct
SELECT * 
FROM Patient_1
WHERE patient_id LIKE 'PAT_NEW_%';

-- Check for NULL values in Phone number

SELECT * 
FROM Patient_1
WHERE phone IS NULL

-- Using a fix of replacing null phone numbers with their emergency contact

UPDATE Patient_1
SET phone = emergency_contact
WHERE phone IS NULL
AND emergency_contact IS NOT NULL;

-- Flagging records with no phone number provided and no emergency contact provided

UPDATE Patient_1
SET phone = 'NO CONTACT ON FILE'
WHERE phone IS NULL;


-- Fixing wrong date formats (Not using YYYY/MM/DD)

SELECT * FROM Patient_1
WHERE registration_date NOT LIKE '____-__-__%';

SELECT * FROM Patient_1
WHERE date_of_birth NOT LIKE '____-__-__%';

--- Check for outlier ages (Abnormal recorded age)

SELECT * 
FROM Patient_1
WHERE age <= 0 OR age > 100;

--10 rows have abnormal age record, we can fix this since we have information on their birth_date

UPDATE Patient_1
SET age = DATEDIFF(YEAR, TRY_CAST(date_of_birth AS DATE), GETDATE())
WHERE (age <= 0 OR age > 100)
AND TRY_CAST(date_of_birth AS DATE) IS NOT NULL
AND DATEDIFF(YEAR, TRY_CAST(date_of_birth AS DATE), GETDATE()) BETWEEN 1 AND 100;

-- Check for columns you know should have a particular type of entry
-- e.g Gender should either be male or female

SELECT DISTINCT gender 
FROM Patient_1;
-- Gender has 4 different enteries (Male, Female, M and F). Set all M = Male and F = Female
UPDATE Patient_1
SET gender = CASE
    WHEN UPPER(gender) IN ('M','MALE') THEN 'Male'
    WHEN UPPER(gender) IN ('F','FEMALE') THEN 'Female'
    ELSE gender
END;

-- Also check for State of origin to make sure all enteries are actually a State
SELECT DISTINCT state_of_origin
FROM Patient_1;

-- Taking care of NULL values in Insurance_id

SELECT *
FROM Patient_1
WHERE insurance_id IS NULL;

-- Check insurance_type with the most Nulls

SELECT
    insurance_type,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN insurance_id IS NULL THEN 1 ELSE 0 END) AS null_insurance_ids
FROM Patient_1
GROUP BY insurance_type
ORDER BY null_insurance_ids DESC;

-- Self Pay insurance_type are not expected to have insurance_id 
-- Set Self Pay customers to N/A - Self Pay

UPDATE Patient_1
SET insurance_id = 'N/A - SELF PAY'
WHERE insurance_id IS NULL
AND insurance_type = 'Self Pay';

-- Set Others to Missing - Follow Up
UPDATE Patient_1
SET insurance_id = 'MISSING - FOLLOW UP'
WHERE insurance_id IS NULL
AND insurance_type != 'Self Pay';

-- Fix Null registration dates

SELECT COUNT (*)
FROM Patient_1
WHERE registration_date IS NULL;

-- See if nulls are concentrated in specific groups
SELECT
    state_of_origin,
    insurance_type,
    COUNT(*) AS total,
    SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS null_reg_dates
FROM Patient_1
GROUP BY state_of_origin, insurance_type
HAVING SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) > 0
ORDER BY null_reg_dates DESC;

-- USE the admission date from the Records table as the registration date, We use the INNER JOIN

-- Use earliest admission date as registration date where missing
UPDATE p
SET p.registration_date = CONVERT(VARCHAR(20),MIN_DATE.earliest_admission, 23)
FROM Patient_1 p
INNER JOIN (
    SELECT 
        patient_id,
        MIN(CAST(admission_date AS DATE)) AS earliest_admission
    FROM Records_1
    WHERE admission_date IS NOT NULL
    GROUP BY patient_id
) AS MIN_DATE ON p.patient_id = MIN_DATE.patient_id
WHERE p.registration_date IS NULL;

-- Verify how many reords were used from the Records Table
SELECT
    SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS still_null,
    SUM(CASE WHEN registration_date IS NOT NULL THEN 1 ELSE 0 END) AS recovered
FROM Patient_1

-- We can Flag the rest as Unknown
SELECT *
FROM Patient_1
WHERE registration_date IS NULL;

-- Ran into an date format error when trying to flag nulls,   Fix date conversion issue

-- Check which rows have the wrong date format
SELECT 
    patient_id,
    registration_date
FROM Patient_1
WHERE registration_date IS NOT NULL
AND TRY_CAST(registration_date AS DATE) IS NULL;

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Patients'
AND COLUMN_NAME = 'registration_date';
-- Dtes gotten from my records table are still in VARCHAR which is why im having the error

-- Created a new VARCHAR Column
ALTER TABLE Patient_1
ADD registration_date_clean VARCHAR(20);

-- Copy all existing dates into it as text and then use the CONVERT(23) style to convert it to date
UPDATE Patient_1
SET registration_date_clean = CONVERT(VARCHAR(20), registration_date, 23);

-- Verify it copied correctly into my new column
SELECT TOP 10
    registration_date,
    registration_date_clean
FROM Patient_1;

-- Now i can do mu NULL fix,  Flag nulls in the new column
UPDATE Patient_1
SET registration_date_clean = 'UNKNOWN'
WHERE registration_date_clean IS NULL;

-- Delete my previous table which was registration date
ALTER TABLE Patient_1
DROP COLUMN registration_date;

-- Rename the new table from registration date clean back to registration date to keep consistency
EXEC sp_rename 'Patient_1.registration_date_clean', 'registration_date', 'COLUMN';

SELECT *
FROM Patient_1
WHERE gender != 'Male' 
AND gender != 'Female'

SELECT DISTINCT state_of_origin
FROM Patient_1