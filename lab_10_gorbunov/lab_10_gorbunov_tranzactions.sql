USE UniversityDB_lab_10;
GO

--Грязное чтение на уровне изоляции READ UNCOMMITTED
BEGIN TRANSACTION T1;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Начало транзакции 2
BEGIN TRANSACTION T2;

-- Устанавливаем уровень изоляции READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Чтение данных из таблицы Students
SELECT * FROM Students;

-- Завершение транзакции 2
COMMIT TRANSACTION T2;

-- Вставка новой записи в таблицу Students
INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES (4, 12345, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com');

SELECT resource_type, resource_subtype, request_mode FROM sys.dm_tran_locks WHERE request_session_id = @@SPID;

-- Завершение транзакции 1
COMMIT TRANSACTION T1;

---------------------------------------------------------------------------------------

-- Грязное чтение на уровне изоляции SERIALIZABLE

-- Начало транзакции 1
BEGIN TRANSACTION T1;

-- Устанавливаем уровень изоляции SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Грязное чтение на уровне изоляции SERIALIZABLE

-- Начало транзакции 2
BEGIN TRANSACTION T2;

-- Устанавливаем уровень изоляции SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Чтение данных из таблицы Students
SELECT * FROM Students;

-- Завершение транзакции 2
COMMIT TRANSACTION T2;

-- Вставка новой записи в таблицу Students
INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES (5, 44556, 'Bob', 'Brown', '2003-04-04', '2023-09-01', 'bob.brown@example.com');

SELECT resource_type, resource_subtype, request_mode FROM sys.dm_tran_locks WHERE request_session_id = @@SPID;

-- Завершение транзакции 1
COMMIT TRANSACTION T1;

---------------------------------------------------------------------------------------

-- Несогласованное чтение на уровне изоляции READ COMMITTED

-- Начало транзакции 1
BEGIN TRANSACTION T1;

-- Устанавливаем уровень изоляции READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Чтение данных из таблицы Students
SELECT * FROM Students;

-- Программа 2: Изменение данных в таблице Students

-- Начало транзакции 2
BEGIN TRANSACTION T2;

-- Устанавливаем уровень изоляции READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Обновление данных в таблице Students
UPDATE Students
SET first_name = 'Deck'
WHERE StudentsID = 1;

-- Завершение транзакции 2
COMMIT TRANSACTION T2;

-- Чтение данных из таблицы Students снова
SELECT * FROM Students;

SELECT resource_type, resource_subtype, request_mode FROM sys.dm_tran_locks WHERE request_session_id = @@SPID;

-- Завершение транзакции 1
COMMIT TRANSACTION T1;

---------------------------------------------------------------------------------------

-- Несогласованное чтение на уровне изоляции REPEATABLE READ
-- Начало транзакции 1
BEGIN TRANSACTION T1;

-- Устанавливаем уровень изоляции REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Чтение данных из таблицы Students
SELECT * FROM Students;

-- Попытка изменения данных в таблице Students

-- Начало транзакции 2
BEGIN TRANSACTION T2;

-- Устанавливаем уровень изоляции REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Попытка обновления данных в таблице Students
UPDATE Students
SET first_name = 'Johnny'
WHERE StudentsID = 1;

-- Завершение транзакции 2
COMMIT TRANSACTION T2;

-- Чтение данных из таблицы Students снова
SELECT * FROM Students;

SELECT resource_type, resource_subtype, request_mode FROM sys.dm_tran_locks WHERE request_session_id = @@SPID;

-- Завершение транзакции 1
COMMIT TRANSACTION T1;