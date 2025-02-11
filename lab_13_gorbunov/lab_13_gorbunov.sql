-- Шаг 1: Создание двух баз данных
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB1')
BEGIN
    DROP DATABASE UniversityDB1;
END

CREATE DATABASE UniversityDB1;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB2')
BEGIN
    DROP DATABASE UniversityDB2;
END

CREATE DATABASE UniversityDB2;
GO

-- Шаг 2: Создание горизонтально фрагментированных таблиц
USE UniversityDB1;
GO

CREATE TABLE Students (
    StudentsID INT PRIMARY KEY CHECK (StudentsID < 4),
    report_card INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100)
);
GO

USE UniversityDB2;
GO

CREATE TABLE Students (
    StudentsID INT PRIMARY KEY CHECK (StudentsID >= 4),
    report_card INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100)
);
GO

-- Шаг 3: Создание секционированных представлений
USE UniversityDB1;
GO

CREATE VIEW PartitionedView AS
SELECT StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email
FROM UniversityDB1.dbo.Students
UNION ALL
SELECT StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email
FROM UniversityDB2.dbo.Students;
GO

-- Пример использования секционированного представления
-- Вставка данных
INSERT INTO UniversityDB1.dbo.Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES	(1, 101, 'John1', 'Doe1', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
		(2, 102, 'John2', 'Doe2', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
		(3, 103, 'John3', 'Doe3', '2000-01-01', '2020-09-01', 'john.doe@example.com');

INSERT INTO UniversityDB2.dbo.Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES	(4, 104, 'John4', 'Doe4', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
		(5, 105, 'John5', 'Doe5', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
		(6, 106, 'John6', 'Doe6', '2000-01-01', '2020-09-01', 'john.doe@example.com');

-- Выборка данных
SELECT * FROM PartitionedView;

-- Обновление данных
UPDATE UniversityDB1.dbo.Students
SET report_card = 107, first_name = 'John1_updated', last_name = 'Doe1', date_of_birth = '2000-01-01', enrollment_date = '2020-09-01', email = 'john.doe@example.com'
WHERE StudentsID = 2;

SELECT * FROM PartitionedView;

-- Удаление данных
DELETE FROM UniversityDB1.dbo.Students
WHERE StudentsID = 2;

SELECT * FROM PartitionedView;

USE UniversityDB1;
GO
SELECT * FROM Students;

USE UniversityDB2;
GO
SELECT * FROM Students;
