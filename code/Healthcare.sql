
create database hospital;

-- import dataset 

-- Total Patients

select distinct count(*)  as total_patients 
from patient;

-- Monthly Appointment Count

select month(date) as Monthly ,count(*) as appointment_count
from appointment 
group by Monthly
order by Monthly asc;


-- Top Performing Doctors by Appointments (Monthly)

SELECT 
    d.doctorname,
    MONTH(a.date) AS appointment_month,
    COUNT(p.patientid) AS total_patients
FROM
    appointment a
        JOIN
    doctor d ON a.doctorid = d.doctorid
        JOIN
    patient p ON p.patientid = a.patientid
GROUP BY d.doctorname , MONTH(a.date)
ORDER BY appointment_month;



-- Revenue by Doctor & Procedure

SELECT 
    d.doctorname, SUM(b.amount) AS revenue, m.procedurename
FROM
    appointment a
        JOIN
    doctor d ON a.doctorid = d.doctorid
        JOIN
    billing b ON b.patientid = a.patientid
        JOIN
    `medical procedure` m ON m.appointmentid = a.appointmentid
GROUP BY d.doctorname , m.procedurename;
-- having d.doctorname= 'Flory';


-- Repeat Visits Analysis

SELECT 
	CONCAT(p.firstname, ' ', p.lastname) AS Full_Name,
    COUNT(*) AS no_of_visits
FROM
    patient p
        JOIN
    appointment a ON a.PatientID = p.PatientID
WHERE
    a.Date <= DATE_SUB(STR_TO_DATE('12-31-2023', '%m-%d-%y'),
        INTERVAL 30 DAY)
GROUP BY Full_Name
HAVING no_of_visits > 1
ORDER BY no_of_visits DESC;


-- Revenue Breakdown by Department

SELECT 
    d.specialization AS Department, SUM(b.amount) Revenue
FROM
    appointment a
        JOIN
    billing b ON a.PatientID = b.PatientID
        JOIN
    doctor d ON d.DoctorID = a.DoctorID
GROUP BY d.specialization
ORDER BY revenue DESC;


-- Top 5 Highest-Earning Medical Procedures

SELECT 
    m.procedurename AS MedicalProcedure,
    SUM(b.amount) AS revenue
FROM
    appointment a
        JOIN
    billing b ON b.PatientID = a.PatientID
        JOIN
    `medical procedure` m ON m.AppointmentID = a.AppointmentID
GROUP BY m.ProcedureName
ORDER BY revenue DESC
LIMIT 5;


-- Doctor-wise Unique Patient Count (Last 3 Months)

SELECT 
    d.doctorname AS D_name,
    COUNT(DISTINCT (p.patientid)) AS no_of_patients
FROM
    appointment a
        JOIN
    patient p ON p.PatientID = a.PatientID
        JOIN
    doctor d ON d.DoctorID = a.DoctorID
WHERE
    a.Date <= DATE_SUB(STR_TO_DATE('12-31-2023', '%m-%d-%Y'),
        INTERVAL 90 DAY)
GROUP BY D_name
ORDER BY no_of_patients DESC;


-- Patient Lifetime Value (PLTV)

SELECT 
    p.patientid AS ID,
    CONCAT(p.firstname, ' ', p.lastname) AS Full_Name,
    SUM(b.amount) AS revenue
FROM
    billing b
        JOIN
    patient p ON p.PatientID = b.PatientID
GROUP BY ID , Full_Name
ORDER BY revenue DESC;


-- Inactive Patients in Last 6 Months

SELECT 
    PatientID AS ID,
    CONCAT(firstname, ' ', lastname) AS Full_Name
FROM
    patient
WHERE
    PatientID NOT IN (SELECT 
            p.PatientID
        FROM
            patient p
                JOIN
            appointment a ON a.PatientID = p.PatientID
        WHERE
            a.date <= DATE_SUB(STR_TO_DATE('12-31-2023', '%m-%d-%Y'),
                INTERVAL 6 MONTH))
                ;

-- Procedure Cost Outlier Detection

SELECT 
    m.procedurename AS P_Name, b.amount AS cost
FROM
    appointment a
        JOIN
    billing b ON a.PatientID = b.PatientID
        JOIN
    `medical procedure` m ON m.AppointmentID = a.AppointmentID
WHERE
    b.amount > (SELECT 
            AVG(amount) + 2 * STDDEV(amount) AS revenue
        FROM
            billing);
            

