--This project analyzes patientís visits datasets from healthcare facilities in Nairobi county to get insights on;
--1.	No of the visits the facilities book in on a daily basis.
--2.	Revenue generated by each facility.
--3.	Types of diagnosis done by each facility.
--4.	Cost of each diagnosis.
--5.	Payment mode by each patient.
--6.	Revenue collected from each visit category, tele visits or in patient.
--7.	Rating and reviews by patients.
--8.	Intensity of each diagnosis across all the facilities.


--The objectives of this project is to;
--1. Identify risk factors, disease transmission, and effective treatments for various conditions.
--2. Support clinical decision making and improve the quality and safety of care.
--3. Predict disease outbreaks and preventable illnesses and enhance public health strategy.
--4. Reduce the cost of treatment and improve the quality of life of patients.



USE ProjectPortfolio;

--Backing up database--

Backup database ProjectPortfolio
To Disk = 'C:\ProjectPortfolio.bak'

--The database has 3 related tables 
--1.Visits
--2.Invoice
--3.Diagnosis
----------DATA EXPLORATION BY TSQL-----------------------

--VISITS TABLE--

--HOW MANY VISITS WAS PAID TO EACH MEDICAL CENTER..?

SELECT MedicalCenter, COUNT(VisitCode) as TotalVisit,COUNT(PatientCode) as TotalPatient
FROM Visits
GROUP BY MedicalCenter
ORDER BY TotalVisit DESC


--WHICH WAS THE MOST PREFERED VISIT CATEGORY..?

SELECT VisitCategory, COUNT(PatientCode) as TotalPatient
FROM Visits
GROUP BY VisitCategory
ORDER BY TotalPatient DESC



--WHICH WAS THE MOST PREFERED PAYOR..?


SELECT Payor, COUNT(PatientCode) as TotalPatient
FROM Visits
GROUP BY Payor
ORDER BY TotalPatient DESC



--WHICH WAS THE HIGHLY RATED MEDICAL CENTER..?


SELECT MedicalCenter, sum(NPS_Score) as Rating
FROM Visits
GROUP BY MedicalCenter
ORDER BY Rating DESC


--WHAT WAS THE VISITS TREND IN EACH QUATER QUATERLY..?

SELECT DISTINCT(VisitCode),VisitDateTime,MedicalCenter
FROM Visits
WHERE VisitDateTime >='2022-09-01' AND VisitDateTime <= '2022-09-30'
GROUP BY VisitCode,VisitDateTime,MedicalCenter

		



--HOW MANY  VISITS FROM JUNE TO SEPT BY EACH PATIENT..?

SELECT VisitDateTime, COUNT(PatientCode) as TotalPatient
FROM Visits
WHERE VisitDateTime >='2022-06-01' AND VisitDateTime <= '2022-09-30'
GROUP BY VisitDateTime
ORDER BY  TotalPatient DESC


--HOW MANY VISITS FROM MAY-SEPT TO KIMATHI STREET & PIPELINE OUTLETS..?

SELECT COUNT(VisitCode) as TotalVisit
FROM Visits
WHERE MedicalCenter ='Kimathi Street' OR MedicalCenter='Pipeline' 
	AND VisitDateTime BETWEEN '2022-05-01' AND '2022-09-30'

-------------------DATA EXPLORATION PART 2-------------------------
--INVOICE TABLE--
--DROPPING TABLE COLUMN PAYOR--

SELECT *
FROM Invoice
ALTER TABLE Invoice
DROP COLUMN PAYOR


--WHAT WAS THE HIGHEST AMOUNT PAID IN EACH VISIT..?

SELECT  VisitCode, MAX(Amount) as HighestAmount
FROM Invoice
GROUP BY VisitCode
ORDER BY HighestAmount DESC


--JOINING VISITS & INVOICE TABLES--
--WHICH WAS THE MOST PREFERED MODE OF PAYMENT..?
--HOW MANY CONTRIBUTORS PER PAYOR/PAYMENT MODE..?


SELECT Visits.Payor, COUNT(Invoice.VisitCode) as NumberofContributors
FROM Invoice
INNER JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY Payor
ORDER BY NumberofContributors DESC


--HOW MUCH INCOME WAS GENERATED BY EACH PAYOR..?

SELECT Visits.Payor, COUNT(Invoice.VisitCode) as NumberofContributors, SUM(AMOUNT) as PayorAmount
FROM Invoice
INNER JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY Payor
ORDER BY NumberofContributors DESC


--WHAT AMOUNT OF INCOME WAS GENERATED BY EACH MEDICAL CENTER REVENUE..?
--INNER JOIN--

SELECT Visits.MedicalCenter, SUM(Invoice.Amount) as RevenuePMC
FROM Invoice
INNER JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY MedicalCenter
ORDER BY RevenuePMC DESC

--WHAT WAS THE TOTAL INCOME  PAID BY EACH VISIT CODE..?

SELECT Invoice.Amount, Visits.VisitCode
FROM Invoice
LEFT JOIN Visits ON Visits.VisitCode=Invoice.VisitCode



--WHAT WAS THE TOTAL INCOME/REVENUE BY EACH VISITCATEGORY..? ( EXPLORING ALL OTHERS JOINS)
--INNER JOIN--

SELECT Visits.VisitCategory, SUM(Invoice.AMOUNT) as RevenuePVC
FROM Invoice
INNER JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY VisitCategory

--LEFT JOIN--


SELECT Visits.VisitCategory, SUM(Invoice.AMOUNT) as RevenuePVC
FROM Invoice
LEFT JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY VisitCategory


--RIGHT JOIN--

SELECT Visits.VisitCategory, SUM(Invoice.AMOUNT) as RevenuePVC
FROM Visits
RIGHT JOIN Invoice ON Invoice.VisitCode=Visits.VisitCode
GROUP BY VisitCategory


--FULL OUTER JOIN OR FULL JOIN--

SELECT Visits.VisitCode, SUM(Invoice.AMOUNT) as RevenuePVC
FROM Invoice
FULL OUTER JOIN Visits ON Invoice.VisitCode=Visits.VisitCode
GROUP BY Visits.VisitCode


--DATA EXPLORATION  TABLE 3-DIAGNOSIS--

SELECT *
FROM Diagnosis

--How many times a diagnosis was done in the entire period..?


SELECT  DISTINCT(Diag), COUNT(VisitCode) as NumberofDiagnosis
FROM Diagnosis
GROUP BY Diag
ORDER BY NumberofDiagnosis DESC


---WHAT ARE SOME OF THE DIAGNOSIS DONE BY EACH MEDICAL CENTER..?

SELECT Visits.MedicalCenter, Diagnosis.Diag
FROM Diagnosis
INNER JOIN Visits ON Visits.VisitCode=Diagnosis.VisitCode

--HOW MUCH DID EACH DIAGNOSIS COST..? 


SELECT SUM(Invoice.Amount) as CostofDiagnosis, Diagnosis.Diag
FROM Invoice
INNER JOIN Diagnosis ON Invoice.VisitCode=Diagnosis.VisitCode
GROUP BY Diag
ORDER BY CostofDiagnosis


--HOW MANY TIMES WAS A DIAGNOSIS DONE BY EACH MEDICALCENTER..?


SELECT Visits.MedicalCenter,COUNT(Diagnosis.Diag) NumberofDiagnosis
FROM Diagnosis
INNER JOIN Visits ON Visits.VisitCode = Diagnosis.VisitCode
GROUP BY MedicalCenter
ORDER BY NumberofDiagnosis DESC


--WHAT IS THE NUMBER OF ACUTE GASTRITIS FROM EACH MEDICAL CENTER..?

SELECT Visits.MedicalCenter, COUNT(Diagnosis.Diag) AS NumberofDiagnosis
FROM Diagnosis
INNER JOIN Visits ON Visits.VisitCode = Diagnosis.VisitCode
WHERE Diag = 'acute gastritis'
GROUP BY MedicalCenter
ORDER BY NumberofDiagnosis DESC


--PIVOT TABLE FOR ANALYSIS--
--COUNTING NUMBER OF TIMES A DIAGNOSIS WAS DONE BY EACH MEDICALCENTER--

SP_RENAME 'Diagnosis.Diagnosis','Diag'


DECLARE @columns AS NVARCHAR(MAX),
        @query  AS NVARCHAR(MAX);
SELECT @columns = STUFF((SELECT distinct ',' + QUOTENAME(MedicalCenter) 
                         FROM Diagnosis
                         FOR XML PATH(''), TYPE
                        ).value('.', 'NVARCHAR(MAX)') 
                       ,1,1,'')
SET @query = 'SELECT Diagnosis, ' + @columns + ' 
              FROM
              (
                SELECT d.MedicalCenter, d.Diagnosis, COUNT(*) as Count
                FROM Diagnosis AS d
                JOIN Visits AS v
                ON d.VisitCode = v.VisitCode
                GROUP BY d.MedicalCenter, d.Diagnosis
              ) x
			PIVOT 
              (
                 SUM(Count)
                 FOR MedicalCenter IN (' + @columns + ')
              ) p'
EXECUTE(@query);


--PIVOT TABLE FOR ANALYSIS--
--HOW MANY TIMES WAS EACH DIAGNOSIS DONE IN DISCTINCT MEDICAL CENTER..?

SELECT Visits.MedicalCenter, Diagnosis.Diag, COUNT(Diag) as XCount
FROM Diagnosis
INNER JOIN Visits
ON Visits.VisitCode = Diagnosis.VisitCode
GROUP BY Visits.MedicalCenter, Diagnosis.Diag
ORDER BY XCount DESC

