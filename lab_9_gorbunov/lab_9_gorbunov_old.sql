-- Создание базы данных
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Lab_9_DB')
BEGIN
    DROP DATABASE Lab_9_DB;
END

CREATE DATABASE Lab_9_DB;
GO

-- Переключение на созданную базу данных
USE Lab_9_DB;
GO

-- Создание таблиц
CREATE TABLE Table1 (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);

CREATE TABLE Table2 (
    ID INT PRIMARY KEY,
    Description NVARCHAR(100),
    CONSTRAINT FK_Table2_Table1 FOREIGN KEY (ID) REFERENCES Table1(ID)
);
GO

-- Триггеры для Table1
CREATE TRIGGER trg_Insert_Table1
ON Table1
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Name IS NULL)
    BEGIN
        THROW 50000, 'Name cannot be NULL', 1;
    END
END;
GO

CREATE TRIGGER trg_Update_Table1
ON Table1
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 2 FROM inserted WHERE Name IS NULL)
    BEGIN
        THROW 50001, 'Name cannot be NULL', 1;
    END
END;
GO

CREATE TRIGGER trg_Delete_Table1
ON Table1
INSTEAD OF DELETE
AS
BEGIN
    THROW 50002, 'Deletion from Table1 is not allowed', 1;
END;
GO

-- Триггеры для Table2
CREATE TRIGGER trg_Insert_Table2
ON Table2
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Description IS NULL)
    BEGIN
        THROW 50003, 'Description cannot be NULL', 1;
    END
END;
GO

CREATE TRIGGER trg_Update_Table2
ON Table2
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Description IS NULL)
    BEGIN
        THROW 50004, 'Description cannot be NULL', 1;
    END
END;
GO

CREATE TRIGGER trg_Delete_Table2
ON Table2
INSTEAD OF DELETE
AS
BEGIN
    THROW 50005, 'Deletion from Table2 is not allowed', 1;
END;
GO

-- Создание представления
CREATE VIEW View1 AS
SELECT t1.ID, t1.Name, t2.Description
FROM Table1 t1
JOIN Table2 t2 ON t1.ID = t2.ID;
GO

-- Триггеры для представления
CREATE TRIGGER trg_Insert_View1
ON View1
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Table1 (ID, Name)
    SELECT ID, Name FROM inserted;

    INSERT INTO Table2 (ID, Description)
    SELECT ID, Description FROM inserted;
END;
GO

CREATE TRIGGER trg_Update_View1
ON View1
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Table1
    SET Name = i.Name
    FROM inserted i
    WHERE Table1.ID = i.ID;

    UPDATE Table2
    SET Description = i.Description
    FROM inserted i
    WHERE Table2.ID = i.ID;
END;
GO

CREATE TRIGGER trg_Delete_View1
ON View1
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Table1
    WHERE ID IN (SELECT ID FROM deleted);

    DELETE FROM Table2
    WHERE ID IN (SELECT ID FROM deleted);
END;
GO

-- Примеры использования триггеров

-- Пример 1: Вставка данных с NULL значением в Name в Table1
BEGIN TRY
    INSERT INTO Table1 (ID, Name)
    VALUES (2, NULL);
    PRINT 'Insert into Table1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Insert into Table1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 2: Вставка данных с NULL значением в Description в Table2
BEGIN TRY
    INSERT INTO Table2 (ID, Description)
    VALUES (2, NULL);
    PRINT 'Insert into Table2 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Insert into Table2 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

INSERT INTO Table1(ID, Name) 
VALUES (5, 'Ken');
GO

INSERT INTO Table2(ID, Description) 
VALUES (5, 'Descript');
GO

-- Пример 3: Обновление данных с NULL значением в Name в Table1 
BEGIN TRY
    UPDATE Table1
    SET Name = NULL
    WHERE ID = 5;
    PRINT 'Update Table1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Update Table1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 4: Обновление данных с NULL значением в Description в Table2 
BEGIN TRY
    UPDATE Table2
    SET Description = NULL
    WHERE ID = 5;
    PRINT 'Update Table2 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Update Table2 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 5: Удаление данных из Table1 
BEGIN TRY
    DELETE FROM Table1
    WHERE ID = 2;
    PRINT 'Delete from Table1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Delete from Table1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 6: Удаление данных из Table2 
BEGIN TRY
    DELETE FROM Table2
    WHERE ID = 2;
    PRINT 'Delete from Table2 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Delete from Table2 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT * FROM Table1;
SELECT * FROM Table2;
GO

-- Примеры использования триггеров для представления

-- Пример 7: Вставка данных через представление
BEGIN TRY
    INSERT INTO View1 (ID, Name, Description)
    VALUES (3, 'Alice Smith', 'Description for Alice Smith');
    PRINT 'Insert into View1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Insert into View1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 8: Вставка данных с NULL значением в Name через представление 
BEGIN TRY
    INSERT INTO View1 (ID, Name, Description)
    VALUES (4, NULL, 'Description for NULL Name');
    PRINT 'Insert into View1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Insert into View1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 8: Обновление данных через представление
BEGIN TRY
    UPDATE View1
    SET Name = 'Bob Johnson', Description = 'Description for Bob Johnson'
    WHERE ID = 3;
    PRINT 'Update View1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Update View1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 9: Обновление данных с NULL значением в Description через представление 
BEGIN TRY
    UPDATE View1
    SET Description = NULL
    WHERE ID = 3;
    PRINT 'Update View1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Update View1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Пример 10: Удаление данных через представление 
BEGIN TRY
    DELETE FROM View1
    WHERE ID = 3;
    PRINT 'Delete from View1 succeeded';
END TRY
BEGIN CATCH
    PRINT 'Delete from View1 failed: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Проверка данных в таблицах
SELECT * FROM Table1;
SELECT * FROM Table2;
SELECT * FROM View1;
GO


DROP VIEW View1;
GO
USE master;
GO
DROP DATABASE Lab_9_DB;
GO