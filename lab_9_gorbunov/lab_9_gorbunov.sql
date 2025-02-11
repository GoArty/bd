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

-- Создание таблицы StudentsMain
CREATE TABLE StudentsMain (
    StudentsID INT PRIMARY KEY,
    report_card INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50)
);
GO

-- Создание таблицы StudentsDetails
CREATE TABLE StudentsDetails (
    StudentsID INT PRIMARY KEY,
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100),
    FOREIGN KEY (StudentsID) REFERENCES StudentsMain(StudentsID)
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
    FOREIGN KEY (StudentID) REFERENCES StudentsMain(StudentsID),
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
    FOREIGN KEY (StudentID) REFERENCES StudentsMain(StudentsID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID)
);
GO

-- Добавление данных в таблицу StudentsMain
INSERT INTO StudentsMain (StudentsID, report_card, first_name, last_name)
VALUES
(1, 101, 'John', 'Doe'),
(2, 102, 'Jane', 'Smith'),
(3, 103, 'Alice', 'Johnson');
GO

-- Добавление данных в таблицу StudentsDetails
INSERT INTO StudentsDetails (StudentsID, date_of_birth, enrollment_date, email)
VALUES
(1, '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(2, '1999-05-15', '2019-09-01', 'jane.smith@example.com'),
(3, '2001-11-30', '2021-09-01', 'alice.johnson@example.com');
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

CREATE TRIGGER trg_BeforeInsert_Teachers ON Teachers
INSTEAD OF INSERT AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE email IN (SELECT email FROM Teachers))
    BEGIN
        THROW 50000, 'Email преподавателя должен быть уникальным.', 1;
        ROLLBACK;
        RETURN;
    END

    INSERT INTO Teachers (TeachersID, SPIN_code, first_name, last_name, department, email, phone_number)
    SELECT TeachersID, SPIN_code, first_name, last_name, department, email, phone_number
    FROM inserted;
END;
GO

CREATE TRIGGER trg_BeforeUpdate_Courses ON Courses
INSTEAD OF UPDATE AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE CoursesID NOT IN (SELECT CoursesID FROM Courses))
    BEGIN
        RAISERROR ('Курс с указанным ID не существует.', 16, 1);
        ROLLBACK;
        RETURN;
    END

    UPDATE Courses
    SET title_of_course = inserted.title_of_course, date_of_course = inserted.date_of_course, description = inserted.description, department = inserted.department, schedule = inserted.schedule
    FROM inserted WHERE Courses.CoursesID = inserted.CoursesID;
END;
GO

CREATE TRIGGER trg_AfterDelete_StudentsMain ON StudentsMain
INSTEAD OF DELETE AS
BEGIN
    DELETE FROM StudentsDetails WHERE StudentsID IN (SELECT StudentsID FROM deleted);

    DELETE FROM Exams WHERE StudentID IN (SELECT StudentsID FROM deleted);

	DELETE FROM Students_Courses_INT WHERE StudentID IN (SELECT StudentsID FROM deleted);

	DELETE FROM StudentsMain WHERE StudentsID IN (SELECT StudentsID FROM deleted);
END;
GO

CREATE TRIGGER StudentsMainUpdate ON StudentsMain
INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in StudentsMain.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		UPDATE sm SET sm.report_card = i.report_card, sm.first_name = i.first_name, sm.last_name = i.last_name FROM inserted AS i
		JOIN UniversityDB.dbo.StudentsMain AS sm ON sm.StudentsID = i.StudentsID;
	END;
END;
GO

CREATE TRIGGER StudentsDetailsUpdate ON StudentsDetails
INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in StudentsDetails.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		UPDATE sd SET sd.date_of_birth = i.date_of_birth, sd.enrollment_date = i.enrollment_date, sd.email = i.email FROM inserted AS i
		JOIN UniversityDB.dbo.StudentsDetails AS sd ON sd.StudentsID = i.StudentsID;
	END
END;
GO

-- Создание представления Students
CREATE VIEW Students AS
SELECT
    SM.StudentsID,
    SM.report_card,
    SM.first_name,
    SM.last_name,
    SD.date_of_birth,
    SD.enrollment_date,
    SD.email
FROM
    StudentsMain SM
JOIN
    StudentsDetails SD ON SM.StudentsID = SD.StudentsID;
GO

-- Триггер для вставки данных в представление Students
CREATE TRIGGER trg_BeforeInsert_Students ON Students
INSTEAD OF INSERT AS
BEGIN
    INSERT INTO StudentsMain (StudentsID, report_card, first_name, last_name) SELECT StudentsID, report_card, first_name, last_name FROM inserted;

    INSERT INTO StudentsDetails (StudentsID, date_of_birth, enrollment_date, email) SELECT StudentsID, date_of_birth, enrollment_date, email FROM inserted;
END;
GO

CREATE TRIGGER trg_BeforeUpdate_Students ON Students
INSTEAD OF UPDATE AS
BEGIN

	IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in Students.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		UPDATE sd SET sd.date_of_birth = i.date_of_birth, sd.enrollment_date = i.enrollment_date, sd.email = i.email FROM inserted AS i
		JOIN UniversityDB.dbo.StudentsDetails AS sd ON sd.StudentsID = i.StudentsID;

		UPDATE sm SET sm.report_card = i.report_card, sm.first_name = i.first_name, sm.last_name = i.last_name FROM inserted AS i
		JOIN UniversityDB.dbo.StudentsMain AS sm ON sm.StudentsID = i.StudentsID;
	END;
END;
GO

-- Триггер для удаления данных из представления Students
CREATE TRIGGER trg_AfterDelete_Students ON Students
INSTEAD OF DELETE AS
BEGIN
    DELETE FROM StudentsMain WHERE StudentsID IN (SELECT StudentsID FROM deleted);
END;
GO

SELECT * FROM Exams;
SELECT * FROM Teachers_Courses_INT;
SELECT * FROM Students_Courses_INT;
SELECT * FROM Courses;
SELECT * FROM Teachers;
SELECT * FROM StudentsDetails;
SELECT * FROM StudentsMain;
GO

--INSERT INTO Teachers (TeachersID, SPIN_code, first_name, last_name, department, email, phone_number)
--VALUES	(4, 54321, 'Dr.', 'Smith', 'Biology', 'dr.brown@newexample.com', '555-1111'),
--		(5, 54321, 'Dr.', 'Smith', 'Biology', 'dr.brown@example.com', '555-1111');

--SELECT * FROM Teachers;

--UPDATE Courses
--SET CoursesID = 2, title_of_course = 'Advanced Calculus', description = 'Advanced topics in calculus'
--WHERE CoursesID = 1;

--SELECT * FROM Courses;

DELETE FROM StudentsMain
WHERE StudentsID = 1;

SELECT * FROM StudentsMain;
SELECT * FROM StudentsDetails;

INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES (4, 104, 'Bob', 'Brown', '2002-03-15', '2022-09-01', 'bob.brown@example.com');

SELECT * FROM Students

UPDATE Students
SET first_name = 'Robert', email = 'robert.brown@example.com'
WHERE StudentsID = 4;

SELECT * FROM Students

DELETE FROM Students
WHERE StudentsID = 4;

--SELECT * FROM Students
--UPDATE Students
--set StudentsID = StudentsID+1
--SELECT * FROM Students

-- Удаление данных из таблиц
DELETE FROM Exams;
DELETE FROM Teachers_Courses_INT;
DELETE FROM Students_Courses_INT;
DELETE FROM Courses;
DELETE FROM Teachers;
DELETE FROM StudentsDetails;
DELETE FROM StudentsMain;
GO

-- Удаление таблиц
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS StudentsDetails;
DROP TABLE IF EXISTS StudentsMain;
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
