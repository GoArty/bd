-- Создание базы данных
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
DROP DATABASE UniversityDB;
END

CREATE DATABASE UniversityDB;
GO

-- Переключение на созданную базу данных
USE UniversityDB;
GO

-- Создание таблицы Students
CREATE TABLE Students (
StudentsID INT PRIMARY KEY,
report_card INT,
first_name NVARCHAR(50),
last_name NVARCHAR(50),
date_of_birth DATE,
enrollment_date DATE,
email NVARCHAR(100)
);
GO

-- Создание таблицы Teachers
CREATE TABLE Teachers (
TeachersID INT PRIMARY KEY,
SPIN_code INT,
first_name NVARCHAR(50),
last_name NVARCHAR(50),
department NVARCHAR(50),
email NVARCHAR(100),
phone_number NVARCHAR(20)
);
GO

-- Создание таблицы Courses
CREATE TABLE Courses (
CoursesID INT PRIMARY KEY,
title_of_course NVARCHAR(100),
date_of_course DATE,
description NVARCHAR(255),
department NVARCHAR(50),
schedule NVARCHAR(100)
);
GO

-- Создание таблицы Students_Courses_INT
CREATE TABLE Students_Courses_INT (
StudentID INT,
CoursesID INT,
PRIMARY KEY (StudentID, CoursesID),
FOREIGN KEY (StudentID) REFERENCES Students(StudentsID),
FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- Создание таблицы Teachers_Courses_INT
CREATE TABLE Teachers_Courses_INT (
TeachersID INT,
CoursesID INT,
PRIMARY KEY (TeachersID, CoursesID),
FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID),
FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- Создание таблицы Exams
CREATE TABLE Exams (
ExamsID INT PRIMARY KEY,
CoursesID INT,
StudentID INT,
time_stamp DATETIME,
TeachersID INT,
grade INT,
FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID),
FOREIGN KEY (StudentID) REFERENCES Students(StudentsID),
FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID)
);
GO

-- Добавление данных в таблицу Students
INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES
(1, 101, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(2, 102, 'Jane', 'Smith', '1999-05-15', '2019-09-01', 'jane.smith@example.com'),
(3, 103, 'Alice', 'Johnson', '2001-11-30', '2021-09-01', 'alice.johnson@example.com');
GO

-- Добавление данных в таблицу Teachers
INSERT INTO Teachers (TeachersID, SPIN_code, first_name, last_name, department, email, phone_number)
VALUES
(1, 12345, 'Dr.', 'Brown', 'Mathematics', 'dr.brown@example.com', '555-1234'),
(2, 67890, 'Prof.', 'Green', 'Physics', 'prof.green@example.com', '555-5678'),
(3, 24680, 'Ms.', 'White', 'Chemistry', 'ms.white@example.com', '555-9101');
GO

-- Добавление данных в таблицу Courses
INSERT INTO Courses (CoursesID, title_of_course, date_of_course, description, department, schedule)
VALUES
(1, 'Calculus I', '2023-09-01', 'Introduction to calculus', 'Mathematics', 'MWF 9:00-10:00'),
(2, 'Physics I', '2023-09-01', 'Introduction to physics', 'Physics', 'TTh 11:00-12:30'),
(3, 'Chemistry I', '2023-09-01', 'Introduction to chemistry', 'Chemistry', 'MWF 13:00-14:30');
GO

-- Добавление данных в таблицу Students_Courses_INT
INSERT INTO Students_Courses_INT (StudentID, CoursesID)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

-- Добавление данных в таблицу Teachers_Courses_INT
INSERT INTO Teachers_Courses_INT (TeachersID, CoursesID)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

-- Добавление данных в таблицу Exams
INSERT INTO Exams (ExamsID, CoursesID, StudentID, time_stamp, TeachersID, grade)
VALUES
(1, 1, 1, '2023-12-01 10:00:00', 1, 90),
(2, 2, 2, '2023-12-02 14:00:00', 2, 85),
(3, 3, 3, '2023-12-03 09:00:00', 3, 95);
GO


SELECT * FROM Students
SELECT * FROM Teachers
SELECT * FROM Courses
SELECT * FROM Exams
SELECT * FROM Teachers_Courses_INT
SELECT * FROM Students_Courses_INT

-- Удаление данных из таблиц
DELETE FROM Exams;
DELETE FROM Teachers_Courses_INT;
DELETE FROM Students_Courses_INT;
DELETE FROM Courses;
DELETE FROM Teachers;
DELETE FROM Students;
GO

-- Удаление таблиц
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Students;
GO

-- Переключение на мастер базу данных для удаления UniversityDB
USE master;
GO

-- Удаление базы данных
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
DROP DATABASE UniversityDB;
END
GO