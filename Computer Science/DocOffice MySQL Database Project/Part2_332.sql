-- FILE STRUCTURES AND DATABASES: DocOffice Database Project
-- JAMES SAMAWI, ALAN CAMPOS, NATHAN THAI 5/7/20
DROP DATABASE IF EXISTS DocOffice;
--
-- Create schema DocOffice
--

CREATE DATABASE IF NOT EXISTS DocOffice;
USE DocOffice;

--
-- Definition of table `person`
--

CREATE TABLE Person (
  personId varchar(10) NOT NULL,
  lastName varchar(50) default NULL,
  firstName varchar(50) default NULL,
  street varchar(50) default NULL,
  city varchar(50) default NULL,
  state varchar(2) default NULL,
  zipcode varchar(5) default NULL,
  pno varchar(10) default NULL,
  ssn varchar(9) default NULL,
  PRIMARY KEY  (personId),
  UNIQUE KEY (ssn,personId)
);

--
-- Dumping data for table `person`
--


INSERT INTO Person VALUES 
 ('0000000000', 'Stevens', 'Robert', '12345 Main Street', 'Brea', 'CA', '12345', '9498390293', '123456789' ),
 ('0000000001', 'Devin', 'Ben', '5923 1st Street', 'Fullerton', 'CA', '09876', '9495022942', '234567890' ),
 ('0000000002', 'Doe', 'John', '5392 2nd Street', 'Long Beach', 'CA', '23456', '9492039594', '345678901' ),
 ('0000000003', 'Campo', 'Alta', '2592 3rd Street', 'Ontario', 'CA', '34567', '9495252626', '456789012' ),
 ('0000000004', 'Price', 'Karen', '9930 4th Street', 'Riverside', 'CA', '45678', '6263959203', '567890123' ),
 ('0000000005', 'Shmurda', 'Bob', '4142 5th Street', 'Fullerton', 'CA', '56789', '9515629359', '678901234' ),
 ('0000000006', 'Gonzalez', 'Madison', '1239 6th Street', 'Fullerton', 'CA', '67890', '7146954233', '789012345' ),
 ('0000000007', 'White', 'Jessica', '2342 7th Street', 'Santa Ana', 'CA', '42325', '7140389232', '890123456' ),
 ('0000000008', 'Bonk', 'Khalid', '3993 8th Street', 'Yorba Linda', 'CA', '24242', '9495623123', '901234567' ),
 ('0000000009', 'Dog', 'Snoop', '2933 9th Street', 'Fullerton', 'CA', '42422', '9235231612', '012345678' ),
 ('0000000010', 'Pace', 'Vivian', '4923 10th Street', 'Huntington Beach', 'CA', '92813', '5621234567', '87623135');
 
--
-- Definition of table `patient`
--

CREATE TABLE Patient (
  PatientId varchar(10) NOT NULL UNIQUE,
  pno varchar(10) default NULL,
  DOB date default NULL,
  personId varchar(10),
  PRIMARY KEY  (patientId), FOREIGN KEY (personId) REFERENCES Person(personId)
);

--
-- Dumping data for table `patient`
--


INSERT INTO Patient VALUES 
 ('0000', '9498390293', '1958-02-04', '0000000000'),
 ('0001','9495022942', '1988-07-15', '0000000001'),
 ('0002', '9492039594','1994-05-15', '0000000002'),
 ('0003', '9495252626', '1990-08-20', '0000000003'),
 ('0004',  '6263959203', '1997-03-27', '0000000004'),
 ('0005', '9515629359', '1999-03-03', '0000000005'),
 ('0006', '7146954233', '1995-04-14', '0000000006'),
 ('0007', '7140389232', '1985-12-25', '0000000007'),
 ('0008', '9495623123', '1986-11-27', '0000000008'),
 ('0009', '9235231612', '1960-11-11', '0000000009'),
 ('0010', '5621234567', '1997-06-03', '0000000010');


--
-- Definition of table `doctor`
--

CREATE TABLE Doctor (
  doctorId varchar(10) NOT NULL UNIQUE,
  medicalDegrees varchar(256) default NULL,
  personId int(10) NOT NUll ,
  PRIMARY KEY  (doctorId)
);

--
-- Dumping data for table `doctor`
--

INSERT INTO doctor VALUES 
 ('rs99999999', 'PHD', '0000000000'),
 ('bd88888888', 'M.D', '0000000001'),
 ('jd77777777', 'Ph.D', '0000000002'),
 ('mk66666666', 'Ph.D', '0000000008'),
 ('sd55555555', 'M.D.', '0000000009'),
 ('ne44444444', 'M.D', '0000000010');
--
-- Definition of table `Speciality`
--
CREATE TABLE Speciality
( specialityId int(10) NOT NULL,
specialityName char(15) NOT NULL,
PRIMARY KEY (specialityID)
);

INSERT INTO Speciality VALUES
('1', 'Gynecology'),
('2', 'Psychology'),
('3', 'Oncology'),
('4', 'Psychiatry'),
('5', 'Neurology');

CREATE TABLE doctorSpeciality (
  doctorId varchar(10) NOT NULL, 
  specialityId int(10) NOT NULL,
  FOREIGN KEY (doctorID) REFERENCES  doctor(doctorId), FOREIGN KEY (specialityId) REFERENCES Speciality(specialityId)
);

--
-- Dumping data for table `doctorSpeciality`
--


INSERT INTO doctorSpeciality VALUES
('rs99999999', '1'),
('bd88888888', '2'),
('jd77777777', '3'),
('mk66666666', '4'),
('sd55555555', '5');	


--
-- Definition of table `patientVisit`
--

CREATE TABLE patientVisit (
  visitId varchar(10) NOT NULL,
  patientId varchar(10),
  doctorid varchar(10),
  visitDate date,
  docNote char(10),
  PRIMARY KEY  (visitId), 
  FOREIGN KEY(patientId) REFERENCES Patient(patientId)
);

--
-- Dumping data for table `patientVisit`
--


INSERT INTO patientVisit VALUES 
 ('01', '0004', 'rs99999999', '2020-02-20', 'yes'),
 ('02', '0010', 'rs99999999', '2020-01-15', 'yes'),
 ('03', '0005', 'rs99999999', '2020-01-01', 'yes');



--
-- Definition of table `pVisitPrescription`
--

CREATE TABLE Prescription ( prescriptionId varchar(10) NOT NULL UNIQUE, 
prescriptionName varchar(50) DEFAULT NULL,
PRIMARY KEY (prescriptionId)
);

INSERT INTO Prescription VALUES 
('1', 'Adderall'),
('2', 'Vicodin'),
('3', 'Tylenol');


-- trigger if doctorSpeciality is updated 
CREATE TABLE pVisitPrescription (
  visitId varchar(10) NOT NULL, 
  prescriptionId varchar(10) NOT NULL, 
   FOREIGN KEY (prescriptionId) REFERENCES Prescription (prescriptionId),
   FOREIGN KEY (visitId) REFERENCES patientVisit(visitId)
);

--
-- Dumping data for table `pVisitPrescription`
--


INSERT INTO pVisitPrescription VALUES 
 ('01', '2'),
 ('02', '1'),
 ('03', '3');


--
-- Definition of table `Test`
--
CREATE TABLE Test (
testId int(10) NOT NULL UNIQUE, 
testName char(50) default NULL, 
PRIMARY KEY (testId)
);

INSERT INTO Test VALUES ('001', 'Physical Test');


CREATE TABLE pVisitTest (
  visitId varchar(10) NOT NULL,
  testId int(10) NOT NULL UNIQUE,
  FOREIGN KEY (testId) REFERENCES Test(testId), FOREIGN KEY (visitId) REFERENCES patientVisit(visitId)
);

--
-- Dumping data for table `pVisitTest`
--

INSERT INTO pVisitTest VALUES 
 ('01', '001');

-- defintion of trigger table Audit 
CREATE TABLE Audit (firstName varchar(50), 
doctorSpeciality int(10)
);

-- trigger if doctorSpeciality is updated 
delimiter $$;
CREATE TRIGGER Update_audit
AFTER INSERT
ON doctorSpecialty
FOR EACH ROW
begin 
INSERT INTO audit(firstname,action,specialtyName,DOM)
SELECT P.firstName,
'UPDATED' AS action, S.specialtyName, getdate() as DOM
FROM doctor D JOIN person P
ON P.personId = D.personId JOIN doctorSpecialty SP
ON D.doctorId = SP.doctorId JOIN speciality S on
S.specialtyId = SP.specialtyId JOIN Inserted INS
on INS.personid = P.personId
WHERE EXISTS(SELECT 1 FROM Inserted WHERE personId = P.personId) AND EXISTS(SELECT 1 FROM Deleted WHERE personId = p.personId)
UNION
SELECT P.firstName,
'INSERTED' AS action, S.specialtyName, getdate() AS DOM
FROM Doctor D JOIN Person P
ON P.personId = D.personId
JOIN doctorSpecialty SP
ON D.doctorId = SP.doctorId
JOIN specialty S on
S.specialtyId = SP.specialtyId
JOIN Inserted INS
ON INS.personId = P.personId
WHERE EXISTS(SELECT 1 FROM Inserted WHERE personId = P.personId)
AND NOT EXISTS(SELECT 1 FROM Deleted WHERE personId = P.personId)

end; $$ delimiter ;
