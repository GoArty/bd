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

-- Создание таблицы Students с автоинкрементным первичным ключом
CREATE TABLE Students (
    StudentsID INT IDENTITY(1,1) PRIMARY KEY,
    report_card INT CHECK (report_card > 0),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    date_of_birth DATE,
    enrollment_date DATE DEFAULT GETDATE(),
    email NVARCHAR(100) DEFAULT 'default@example.com'
);
GO

-- Создание таблицы Teachers с первичным ключом на основе глобального уникального идентификатора
CREATE TABLE Teachers (
    TeachersID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SPIN_code INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    department NVARCHAR(50),
    email NVARCHAR(100),
    phone_number NVARCHAR(20)
);
GO

-- Создание таблицы Courses с первичным ключом на основе последовательности
CREATE SEQUENCE CoursesSeq START WITH 1 INCREMENT BY 1;
GO

CREATE TABLE Courses (
    CoursesID INT PRIMARY KEY DEFAULT NEXT VALUE FOR CoursesSeq,
    title_of_course NVARCHAR(100),
    date_of_course DATE DEFAULT GETDATE(),
    description NVARCHAR(255),
    department NVARCHAR(50),
    schedule NVARCHAR(100)
);
GO

-- Создание таблицы Students_Courses_INT с внешними ключами и ограничениями ссылочной целостности
CREATE TABLE Students_Courses_INT (
    StudentID INT,
    CoursesID INT,
    PRIMARY KEY (StudentID, CoursesID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID) ON DELETE CASCADE,
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- Создание триггеров на таблицу Students_Courses_INT
CREATE TRIGGER trg_Students_Courses_INT_Insert
ON Students_Courses_INT
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE StudentID NOT IN (SELECT StudentsID FROM Students))
    BEGIN
        THROW 50000, 'StudentID does not exist in Students table.', 1;
    END
END;
GO

CREATE TRIGGER trg_Students_Courses_INT_Update
ON Students_Courses_INT
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE StudentID NOT IN (SELECT StudentsID FROM Students))
    BEGIN
        THROW 50001, 'StudentID does not exist in Students table.', 1;
    END
END;
GO

CREATE TRIGGER trg_Students_Courses_INT_Delete
ON Students_Courses_INT
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE StudentID NOT IN (SELECT StudentsID FROM Students))
    BEGIN
        THROW 50002, 'StudentID does not exist in Students table.', 1;
    END
END;
GO

-- Создание таблицы Teachers_Courses_INT с внешними ключами и ограничениями ссылочной целостности
CREATE TABLE Teachers_Courses_INT (
    TeachersID UNIQUEIDENTIFIER,
    CoursesID INT,
    PRIMARY KEY (TeachersID, CoursesID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID) ON DELETE NO ACTION,
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- Создание таблицы Exams с внешними ключами и ограничениями ссылочной целостности
CREATE TABLE Exams (
    ExamsID INT IDENTITY(1,1) PRIMARY KEY,
    CoursesID INT,
    StudentID INT,
    time_stamp DATETIME DEFAULT GETDATE(),
    TeachersID UNIQUEIDENTIFIER,
    grade INT CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID) ON DELETE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID) ON DELETE SET NULL,
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID) ON DELETE SET DEFAULT
);
GO

-- Добавление данных в таблицу Students
INSERT INTO Students (report_card, first_name, last_name, email)
VALUES
(101, 'John', 'Doe', 'john.doe@example.com'),
(102, 'Jane', 'Smith', 'jane.smith@example.com'),
(103, 'Alice', 'Johnson', 'alice.johnson@example.com');
GO

-- Добавление данных в таблицу Teachers
INSERT INTO Teachers (SPIN_code, first_name, last_name, department, email, phone_number)
VALUES
(12345, 'Dr.', 'Brown', 'Mathematics', 'dr.brown@example.com', '555-1234'),
(67890, 'Prof.', 'Green', 'Physics', 'prof.green@example.com', '555-5678'),
(24680, 'Ms.', 'White', 'Chemistry', 'ms.white@example.com', '555-9101');
GO

-- Добавление данных в таблицу Courses
INSERT INTO Courses (title_of_course, description, department, schedule)
VALUES
('Calculus I', 'Introduction to calculus', 'Mathematics', 'MWF 9:00-10:00'),
('Physics I', 'Introduction to physics', 'Physics', 'TTh 11:00-12:30'),
('Chemistry I', 'Introduction to chemistry', 'Chemistry', 'MWF 13:00-14:30');
GO

-- Объявление переменных для хранения TeachersID
DECLARE @TeacherID1 UNIQUEIDENTIFIER, @TeacherID2 UNIQUEIDENTIFIER, @TeacherID3 UNIQUEIDENTIFIER;

-- Получение существующих TeachersID для вставки в другие таблицы
BEGIN
    SELECT @TeacherID1 = TeachersID FROM Teachers WHERE first_name = 'Dr.' AND last_name = 'Brown';
    SELECT @TeacherID2 = TeachersID FROM Teachers WHERE first_name = 'Prof.' AND last_name = 'Green';
    SELECT @TeacherID3 = TeachersID FROM Teachers WHERE first_name = 'Ms.' AND last_name = 'White';

    -- Добавление данных в таблицу Students_Courses_INT
    INSERT INTO Students_Courses_INT (StudentID, CoursesID)
    VALUES
    (1, 1),
    (2, 2),
    (3, 3);

    -- Добавление данных в таблицу Teachers_Courses_INT
    INSERT INTO Teachers_Courses_INT (TeachersID, CoursesID)
    VALUES
    (@TeacherID1, 1),
    (@TeacherID2, 2),
    (@TeacherID3, 3);

    -- Добавление данных в таблицу Exams
    INSERT INTO Exams (CoursesID, StudentID, TeachersID, grade)
    VALUES
    (1, 1, @TeacherID1, 90),
    (2, 2, @TeacherID2, 85),
    (3, 3, @TeacherID3, 95);
END
GO

-- Создание представления на основе одной из таблиц
CREATE VIEW StudentView AS
SELECT StudentsID, first_name, last_name, email
FROM Students;
GO

-- Создание представления на основе полей обеих связанных таблиц
CREATE VIEW StudentCourseView AS
SELECT S.StudentsID, S.first_name, S.last_name, C.title_of_course, C.department
FROM Students S
JOIN Students_Courses_INT SC ON S.StudentsID = SC.StudentID
JOIN Courses C ON SC.CoursesID = C.CoursesID;
GO

-- Создание триггеров на представление StudentCourseView
CREATE TRIGGER trg_StudentCourseView_Insert
ON StudentCourseView
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Students_Courses_INT (StudentID, CoursesID)
    SELECT i.StudentsID, C.CoursesID
    FROM inserted i
    JOIN Courses C ON i.title_of_course = C.title_of_course;
END;
GO

CREATE TRIGGER trg_StudentCourseView_Update
ON StudentCourseView
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Students_Courses_INT
    SET CoursesID = C.CoursesID
    FROM inserted i
    JOIN Courses C ON i.title_of_course = C.title_of_course
    WHERE Students_Courses_INT.StudentID = i.StudentsID;
END;
GO

CREATE TRIGGER trg_StudentCourseView_Delete
ON StudentCourseView
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Students_Courses_INT
    WHERE StudentID IN (SELECT StudentsID FROM deleted)
    AND CoursesID IN (SELECT CoursesID FROM Courses WHERE title_of_course IN (SELECT title_of_course FROM deleted));
END;
GO

-- Создание индекса для одной из таблиц, включив в него дополнительные неключевые поля
CREATE INDEX IDX_Students_LastName ON Students (last_name) INCLUDE (first_name, email);
GO

-- Создание индексированного представления
CREATE VIEW StudentCourseIndexedView WITH SCHEMABINDING AS
SELECT S.StudentsID, S.first_name, S.last_name, C.title_of_course, C.department
FROM dbo.Students S
JOIN dbo.Students_Courses_INT SC ON S.StudentsID = SC.StudentID
JOIN dbo.Courses C ON SC.CoursesID = C.CoursesID;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_StudentCourseIndexedView ON StudentCourseIndexedView (StudentsID, title_of_course);
GO

SELECT * FROM Students
SELECT * FROM Teachers
SELECT * FROM Courses
SELECT * FROM Exams
SELECT * FROM Teachers_Courses_INT
SELECT * FROM Students_Courses_INT
SELECT * FROM StudentView
SELECT * FROM StudentCourseView
SELECT * FROM StudentCourseIndexedView

-- Удаление данных из таблиц
DELETE FROM Exams;
DELETE FROM Teachers_Courses_INT;
DELETE FROM Students_Courses_INT;
DELETE FROM Courses;
DELETE FROM Teachers;
DELETE FROM Students;
GO

-- Удаление представлений
DROP VIEW IF EXISTS StudentCourseIndexedView;
DROP VIEW IF EXISTS StudentCourseView;
DROP VIEW IF EXISTS StudentView;
GO

-- Удаление таблиц
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Students;
GO

-- Удаление последовательности
DROP SEQUENCE IF EXISTS CoursesSeq;
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
