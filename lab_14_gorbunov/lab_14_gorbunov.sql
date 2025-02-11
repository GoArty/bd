-- Шаг 1: Создание двух баз данных
CREATE DATABASE Database1;
GO
CREATE DATABASE Database2;
GO

-- Шаг 2: Создание вертикально фрагментированных таблиц
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
    StudentsID INT PRIMARY KEY,
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100)
);
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
		JOIN Database2.dbo.StudentsDetails AS sd ON sd.StudentsID = i.StudentsID;
	END;
END;
GO

-- Шаг 3: Создание представлений для объединения вертикально фрагментированных таблиц
USE Database1;
GO

CREATE VIEW StudentsVerticalPartitionedView AS
SELECT sm.StudentsID, sm.report_card, sm.first_name, sm.last_name, sd.date_of_birth, sd.enrollment_date, sd.email
FROM Database1.dbo.StudentsMain sm
JOIN Database2.dbo.StudentsDetails sd ON sm.StudentsID = sd.StudentsID;
GO

-- Шаг 4: Создание триггеров для вставки, обновления и удаления данных
USE Database1;
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
		JOIN Database1.dbo.StudentsMain AS sm ON sm.StudentsID = i.StudentsID;
	END;
END;
GO

CREATE TRIGGER trg_InsertStudentsData ON StudentsVerticalPartitionedView
INSTEAD OF INSERT AS
BEGIN
    INSERT INTO Database1.dbo.StudentsMain (StudentsID, report_card, first_name, last_name)
    SELECT i.StudentsID, i.report_card, i.first_name, i.last_name FROM inserted AS i;

    INSERT INTO Database2.dbo.StudentsDetails (StudentsID, date_of_birth, enrollment_date, email)
    SELECT i.StudentsID, i.date_of_birth, i.enrollment_date, i.email FROM inserted AS i;
END;
GO

CREATE TRIGGER trg_UpdateStudentsData ON StudentsVerticalPartitionedView
INSTEAD OF UPDATE AS
BEGIN
	IF UPDATE(StudentsID)
    BEGIN
        RAISERROR('Updating StudentsID in StudentsVerticalPartitionedView.', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
	BEGIN
		UPDATE sd SET sd.date_of_birth = i.date_of_birth, sd.enrollment_date = i.enrollment_date, sd.email = i.email FROM inserted AS i
		JOIN Database2.dbo.StudentsDetails AS sd ON sd.StudentsID = i.StudentsID;

		UPDATE sm SET sm.report_card = i.report_card, sm.first_name = i.first_name, sm.last_name = i.last_name FROM inserted AS i
		JOIN Database1.dbo.StudentsMain AS sm ON sm.StudentsID = i.StudentsID;
	END;
END;
GO

CREATE TRIGGER trg_DeleteStudentsData ON StudentsVerticalPartitionedView
INSTEAD OF DELETE AS
BEGIN
    DELETE FROM Database1.dbo.StudentsMain WHERE StudentsID IN (SELECT d.StudentsID FROM deleted AS d);
    DELETE FROM Database2.dbo.StudentsDetails WHERE StudentsID IN (SELECT d.StudentsID FROM deleted AS d);
END;
GO

-- Пример использования вертикально фрагментированных представлений и триггеров
-- Вставка данных
INSERT INTO StudentsVerticalPartitionedView (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email) VALUES
(1, 90, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(2, 85, 'Jane', 'Smith', '2001-02-02', '2021-09-01', 'jane.smith@example.com'),
(3, 95, 'Alice', 'Johnson', '2002-03-03', '2022-09-01', 'alice.johnson@example.com');
GO

-- Выборка данных
SELECT * FROM StudentsVerticalPartitionedView;

-- Обновление данных
UPDATE StudentsVerticalPartitionedView
SET first_name = 'Jane', last_name = 'Doe', email = 'jane.doe@example.com'
WHERE StudentsID = 2;
GO
SELECT * FROM StudentsVerticalPartitionedView;

-- Удаление данных
DELETE FROM StudentsVerticalPartitionedView
WHERE StudentsID = 1;
GO

SELECT * FROM StudentsVerticalPartitionedView;
SELECT * FROM Database1.dbo.StudentsMain; 
SELECT * FROM Database2.dbo.StudentsDetails; 
SELECT * FROM StudentsVerticalPartitionedView

--UPDATE StudentsVerticalPartitionedView
--set StudentsID = StudentsID+1
--SELECT * FROM StudentsVerticalPartitionedView

-- Шаг 5: Удаление баз данных
USE master;
GO

DROP DATABASE Database1;
GO
DROP DATABASE Database2;
GO
