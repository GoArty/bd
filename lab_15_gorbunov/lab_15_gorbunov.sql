-- Шаг 1: Создание двух баз данных
CREATE DATABASE Database1;
GO
CREATE DATABASE Database2;
GO

-- Шаг 2: Создание связанных таблиц
USE Database1;
GO

CREATE TABLE StudentsMain (
    StudentsID INT PRIMARY KEY,
    report_card INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50)
);
GO

USE Database2;
GO

CREATE TABLE StudentsDetails (
    DetailsID INT IDENTITY(1,1) PRIMARY KEY,
    StudentsID INT NOT NULL,
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100)
);
GO

-- Шаг 3: Создание представлений для объединения связанных таблиц
CREATE VIEW LinkedStudentsView AS
SELECT sm.StudentsID, sm.report_card, sm.first_name, sm.last_name, sd.DetailsID, sd.date_of_birth, sd.enrollment_date, sd.email
FROM Database1.dbo.StudentsMain AS sm
LEFT JOIN Database2.dbo.StudentsDetails AS sd
ON sm.StudentsID = sd.StudentsID;
GO

-- Шаг 4: Создание триггеров для вставки, обновления и удаления данных
USE Database2;
GO


-- Триггер для вставки данных в StudentsDetails
CREATE TRIGGER StudentsDetailsInsert ON StudentsDetails
AFTER INSERT AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted AS i LEFT JOIN Database1.dbo.StudentsMain AS sm ON i.StudentsID = sm.StudentsID WHERE sm.StudentsID IS NULL)
    BEGIN
        RAISERROR('Inserted StudentsID does not exist in StudentsMain.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- Триггер для обновления данных в StudentsDetails
CREATE TRIGGER StudentsDetailsUpdate ON StudentsDetails
AFTER UPDATE AS
BEGIN
    IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in StudentsDetails.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

USE Database1;
GO

-- Триггер для обновления данных в StudentsMain
CREATE TRIGGER StudentsMainUpdate ON StudentsMain
AFTER UPDATE AS
BEGIN
    IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in StudentsMain.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO

-- Триггер для удаления данных в StudentsMain
CREATE TRIGGER StudentsMainDelete ON StudentsMain
AFTER DELETE
AS
BEGIN
    DELETE sd FROM Database2.dbo.StudentsDetails AS sd INNER JOIN deleted AS d ON sd.StudentsID = d.StudentsID;
END;
GO

-- Пример использования триггеров
-- Вставка данных
INSERT INTO StudentsMain (StudentsID, report_card, first_name, last_name) VALUES
	(1, 90, 'John', 'Doe'),
	(2, 85, 'Jane', 'Smith'),
	(3, 95, 'Alice', 'Johnson'),
	(4, 88, 'Bob', 'Brown');
GO

SELECT * FROM StudentsMain;
GO

USE Database2;
GO

INSERT INTO StudentsDetails (StudentsID, date_of_birth, enrollment_date, email)
VALUES
	(1, '2000-01-01', '2020-09-01', 'john.doe@example.com'),
	(1, '2000-01-01', '2021-09-01', 'john.doe@newdomain.com'),
	(2, '2001-02-02', '2021-09-01', 'jane.smith@example.com'),
	(2, '2001-02-02', '2022-09-01', 'jane.smith@newdomain.com'),
	(3, '2002-03-03', '2022-09-01', 'alice.johnson@example.com'),
	(4, '2003-04-04', '2023-09-01', 'bob.brown@example.com');
GO

SELECT * FROM StudentsDetails;
GO

SELECT * FROM LinkedStudentsView;
GO

-- Обновление данных
USE Database2;
GO

UPDATE StudentsDetails
SET email = 'frisk.noe@example.com'
WHERE DetailsID = 1;
GO

-- UPDATE StudentsDetails
-- SET StudentsID = 5
-- WHERE DetailsID = 1;
-- GO

SELECT * FROM LinkedStudentsView;
GO

-- Удаление данных
USE Database1;
GO

 --UPDATE StudentsMain
 --SET StudentsID = 5
 --WHERE StudentsID = 2;
 --GO

DELETE FROM StudentsMain
WHERE StudentsID = 2;
GO

USE Database2;
GO

SELECT * FROM LinkedStudentsView;
GO

SELECT * FROM StudentsDetails;
GO

-- Шаг 5: Удаление баз данных
USE master;
GO

DROP DATABASE Database1;
GO
DROP DATABASE Database2;
GO
