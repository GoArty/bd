-- Создание базы данных
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'StudentsDB')
BEGIN
DROP DATABASE StudentsDB;
END

CREATE DATABASE StudentsDB;
GO

-- Переключение на созданную базу данных
USE StudentsDB;
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

-- Добавление данных в таблицу Students
INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES
(1, 101, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(2, 102, 'Jane', 'Smith', '1999-05-15', '2019-09-01', 'jane.smith@example.com'),
(3, 103, 'Alice', 'Johnson', '2001-11-30', '2021-09-01', 'alice.johnson@example.com');
GO

SELECT * FROM Students