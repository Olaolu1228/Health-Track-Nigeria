# Health-Track-Nigeria
This end-to-end healthcare analytics project focused on auditing, cleaning, and analyzing 30,000 hospital records across 10 teaching hospitals in Nigeria. I investigated patient outcomes, readmission rates, mortality trends, operational efficiency, revenue performance, billing accuracy, and patient demographics.
Health Track Nigeria – Healthcare Operations, Clinical & Financial Analytics
Project Overview
Health Track Nigeria is a hospital management company overseeing 10 major teaching hospitals across Nigeria. The organization is facing mounting pressure from the Ministry of Health over rising patient readmission rates, unresolved billing discrepancies, and inconsistent clinical outcomes across departments and hospitals. The data team has been tasked with performing a full data audit, cleaning the records in SQL, and building a Power BI dashboard to give hospital administrators and clinical directors a clear view of operational performance, financial health and patient outcomes.
________________________________________
Business Problems
1. Patient & Clinical Performance
•	Readmission Rates: Identified departments with the highest patient readmission rates to evaluate quality of care and discharge effectiveness. 
•	Diagnosis & Mortality Analysis: Analyzed the most common diagnoses and those associated with the highest mortality rates. 
•	Chronic Condition Impact: Assessed whether chronic illnesses resulted in longer hospital stays and increased treatment costs. 
•	Emergency Admissions: Evaluated hospital-level emergency admission volumes to identify capacity and demand patterns. 
2. Financial & Billing Analysis
•	Revenue Performance: Compared total revenue billed against actual collections to measure financial efficiency. 
•	Insurance Coverage Analysis: Determined which insurance plans provided the greatest coverage and lowest patient out-of-pocket expenses. 
•	Billing Accuracy: Investigated discrepancies between billed amounts, insurance coverage, and patient payments. 
•	Department Revenue Analysis: Identified the highest and lowest revenue-generating departments across the hospital network. 
3. Operational Efficiency
•	Length of Stay Analysis: Measured average patient length of stay across hospitals and departments. 
•	Readmission vs Stay Duration: Examined the relationship between longer hospital stays and readmission rates. 
•	Doctor Workload Assessment: Analyzed patient distribution among doctors to identify workload imbalances and burnout risks. 
•	Admission Type Evaluation: Determined which admission categories were associated with the longest hospital stays. 
4. Patient Demographics
•	Age Group Analysis: Identified the age groups with the highest admission frequencies and healthcare utilization. 
•	Gender-Based Insights: Explored differences in diagnoses and readmission rates between male and female patients. 
•	Geographic Patient Analysis: Assessed which states generated the highest patient volumes and healthcare costs. 
•	Blood Group Distribution: Investigated the most common blood groups among critically ill patients.
________________________________________
Data Cleaning & Preparation
Using SQL, I carried out extensive data cleaning and validation processes, including:
•	Checking for duplicate records, duplicate patient id and medical record id
•	Standardizing date formats and categorical fields
•	Engineering admission rate and re-admission rate metrics
•	Handling inconsistent records and validating data integrity
•	Handled missing data’s in registration date, discharge date, diagnoses, etc.
•	Discovering outlier medical values and flagging for investigation
•	Restoring relationships between tables.
•	Preparing a clean analytical table for Power BI reporting
The cleaned dataset was then modeled and visualized in Power BI.
________________________________________
Key Insights
Overall Executive Summary of Your Dashboard
If you were presenting this dashboard to a hospital board here is what you would say:
The Health Track Nigeria hospital network served 9,472 unique patients across 15,000 admissions between 2022 and 2024 generating $3.77 billion in billed revenue. However only 60.2% of that revenue was collected leaving $1.5 billion unrecovered. Patient load is well distributed across all 10 hospitals with no single facility overwhelmed. However three critical issues demand immediate attention. First the readmission rate has remained persistently above 15% for three consecutive years with no signs of improvement suggesting clinical protocols need urgent review. Second the mortality rate of 9.86% means nearly one in ten patients admitted to this network does not survive — an unacceptably high figure that requires department level investigation. Third the revenue collection gap is uniform across all hospitals confirming this is a system wide financial policy problem that cannot be solved by targeting individual hospitals.
Patient and Clinical Performances
During the clinical performance analysis, I discovered significant variations in patient outcomes across departments. Dermatology recorded the highest readmission rate at 18.12%, an unexpected result for a non-critical specialty, suggesting potential gaps in treatment effectiveness or post-discharge care. In contrast, Psychiatry achieved the lowest readmission rate at 13.92%, indicating stronger patient recovery outcomes. Mortality analysis revealed that Malnutrition and Lung Cancer had the highest mortality rates at 6.92%. Interestingly, conditions such as Psoriasis and Ringworm also appeared among the top diagnoses associated with mortality, highlighting potential data quality concerns that would warrant further investigation in a real healthcare environment.
Further analysis of patient stay duration and treatment costs showed that longer hospital stays did not always translate into higher medical expenses. While Endometriosis patients recorded both some of the longest stays and the highest treatment costs, the relationship between length of stay and billing was not consistent across all diagnoses. Additionally, emergency admission volumes were found to be remarkably balanced across all ten hospitals, with each facility handling between 276 and 313 emergency cases. This suggests that emergency patient demand is evenly distributed throughout the hospital network, reflecting effective operational capacity management rather than overreliance on a single facility.
Financial and Billing Analysis
The financial analysis revealed significant opportunities to improve revenue collection and billing efficiency across the hospital network. Cardiology emerged as the highest revenue-generating department, billing approximately $579 million and collecting $353 million, nearly twice the revenue generated by Dermatology. Across all departments, insurance consistently covered only about one-third of patient bills, leaving the majority of healthcare costs to be paid directly by patients. When revenue performance was examined at the hospital level, every facility recorded a collection rate of approximately 60%, indicating that the gap between billed and collected revenue is a system-wide issue rather than a problem isolated to specific hospitals. Although National Hospital Abuja performed slightly better with a 62% collection rate, the findings suggest that meaningful improvement will require organization-wide policy and process changes rather than targeted interventions at individual facilities.
Further analysis of insurance coverage highlighted a substantial financial burden on patients. Regardless of insurance provider, plans covered only 39–40% of treatment costs on average, leaving patients responsible for approximately 60–61% of their medical expenses. While HMO plans provided the highest average coverage per visit, patients still incurred significant out-of-pocket costs, demonstrating that existing insurance arrangements offer limited financial protection. Billing accuracy analysis also uncovered notable discrepancies across departments. General Practice recorded the highest number of billing errors, while Neurology exhibited the highest error rate relative to its volume of transactions. The investigation further revealed patterns of both overcharging and undercharging, with General Practice tending toward overbilling and Oncology toward under-billing. In contrast, Psychiatry maintained the lowest error rate, reflecting stronger billing controls and higher data quality standards. These findings emphasize the need for improved revenue cycle management, billing oversight, and insurance policy evaluation to enhance financial performance and patient affordability.
Operational Efficiency
Across the hospital network, admissions are evenly distributed, with all hospitals showing a similar mix of about 36% elective, 30% outpatient, 20% emergency, and 14% referral cases. This indicates a balanced system with no single hospital carrying a heavier emergency burden.
At the doctor level, workload is uneven. DOC014 handles the highest number of patients (332 records), while DOC003 has fewer patients but the longest average length of stay (15.84 days), suggesting more complex cases and a different kind of pressure on clinicians.
At the department level, readmission patterns reveal key inefficiencies. Dermatology has the highest readmission rate (18.12%) despite average stays, suggesting treatment or follow-up issues. General Practice records the longest stays (15.41 days) but only moderate readmissions, while Psychiatry stands out as the most efficient, with short stays and the lowest readmission rates.
Overall, the system is balanced in intake but uneven in workload intensity and clinical outcomes across doctors and departments.
Patient Demographics
Patient demographics reveal a clear concentration of risk in the 36–55 age group, which records the highest number of admissions (3,443) and the highest readmission rate (16.41%). This suggests middle-aged patients are the most clinically vulnerable group, possibly due to early discharge or insufficient follow-up care.
Gender distribution is almost perfectly balanced, with 49.04% female and 48.96% male across 15,000 patients. The small remaining 2% reflects unclean or mixed-case entries, highlighting an ongoing data quality issue. This imbalance is consistent across all departments, indicating no gender bias in service utilization.
At the state level, Lagos has the highest number of registered patients (1,535), while Abuja records the most total admissions (1,585), showing higher repeat visit patterns in Abuja. Meanwhile, Oyo stands out financially, with the highest average bill at $259,316 despite lower patient volume, suggesting more severe or complex cases.
Overall, the data shows a middle-aged risk concentration, strong demographic balance, and important regional differences in healthcare usage and cost intensity.
Dashboard Solution
To support executive decision-making, I developed a multi-page Power BI dashboard that included:
•	Executive Overview Dashboard
•	Patient and Clinical Performance
•	Financial and Billing Analysis
•	Operational Efficiency Dashboard
•	Patients Demographics Dashboard
The dashboard enabled stakeholders to monitor revenue trends, identify operational bottlenecks, track customer behavior, and uncover profit leakage areas in real time.
________________________________________
Tools & Technologies
•	SQL Server
•	Power BI
•	DAX
•	Data Cleaning & Transformation
•	Exploratory Data Analysis (EDA)
•	Business Intelligence & Dashboard Design
________________________________________
Final Outcome
This project demonstrates my ability to:
•	Clean and validate messy transactional datasets
•	Translate business problems into analytical solutions
•	Perform end-to-end exploratory data analysis
•	Build executive-level dashboards
•	Generate actionable business insights from data
The final solution provided leadership with a clear understanding of operational inefficiencies, customer behavior, and revenue leakage, enabling more informed strategic decisions.


