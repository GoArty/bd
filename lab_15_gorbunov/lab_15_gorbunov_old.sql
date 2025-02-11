-- Шаг 1: Создание двух баз данных
CREATE DATABASE Database1;
GO
CREATE DATABASE Database2;
GO

-- Шаг 2: Создание связанных таблиц
USE Database1;
GO

CREATE TABLE Table1 (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100)
);
GO

USE Database2;
GO

CREATE TABLE Table2 (
    ID INT PRIMARY KEY,
    Description NVARCHAR(100)
);
GO

-- Шаг 3: Создание представлений для объединения связанных таблиц
USE Database1;
GO

CREATE VIEW LinkedView AS
SELECT t1.ID, t1.Name, t2.Description
FROM Database1.dbo.Table1 t1
JOIN Database2.dbo.Table2 t2 ON t1.ID = t2.ID;
GO

-- Шаг 4: Создание триггеров для вставки, обновления и удаления данных
USE Database1;
GO

-- Триггер для вставки данных
CREATE TRIGGER trg_InsertLinkedData
ON LinkedView
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Database1.dbo.Table1 (ID, Name)
    SELECT i.ID, i.Name FROM inserted AS i;

    INSERT INTO Database2.dbo.Table2 (ID, Description)
    SELECT i.ID, i.Description FROM inserted AS i;
END;
GO

-- Триггер для обновления данных
CREATE TRIGGER trg_UpdateLinkedData
ON LinkedView
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Database1.dbo.Table1
    SET Name = i.Name
    FROM inserted AS i
    INNER JOIN Database1.dbo.Table1 AS t1 ON t1.ID = i.ID;

    UPDATE Database2.dbo.Table2
    SET Description = i.Description
    FROM inserted AS i
    INNER JOIN Database2.dbo.Table2 AS t2 ON t2.ID = i.ID;
END;
GO

-- Триггер для удаления данных
CREATE TRIGGER trg_DeleteLinkedData
ON LinkedView
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Database1.dbo.Table1
    WHERE ID IN (SELECT d.ID FROM deleted AS d);

    DELETE FROM Database2.dbo.Table2
    WHERE ID IN (SELECT d.ID FROM deleted AS d);
END;
GO

-- Пример использования представлений и триггеров
-- Вставка данных
INSERT INTO LinkedView (ID, Name, Description) VALUES
(1, 'Name1', 'Description1'),
(2, 'Name2', 'Description2'),
(3, 'Name3', 'Description3'),
(4, 'Name4', 'Description4'),
(5, 'Name5', 'Description5');
GO

-- Выборка данных
SELECT * FROM LinkedView;
GO

-- Обновление данных
UPDATE LinkedView
SET Name = 'UpdatedName2', Description = 'UpdatedDescription2'
WHERE ID = 2;
GO

SELECT * FROM LinkedView;
GO

-- Удаление данных
DELETE FROM LinkedView
WHERE ID = 1;
GO

SELECT * FROM LinkedView;
GO

-- Шаг 5: Удаление баз данных
USE master;
GO

DROP DATABASE Database1;
GO
DROP DATABASE Database2;
GO
