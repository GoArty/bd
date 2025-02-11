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

-- Создание пользовательской функции для формирования столбца
CREATE FUNCTION dbo.GetFullName(@first_name NVARCHAR(50), @last_name NVARCHAR(50))
RETURNS NVARCHAR(101)
AS
BEGIN
    RETURN @first_name + ' ' + @last_name;
END;
GO

-- Модификация хранимой процедуры для использования пользовательской функции
CREATE PROCEDURE GetStudentsCursor
	@StudentCursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @StudentCursor = CURSOR FOR
    SELECT StudentsID, report_card, dbo.GetFullName(first_name, last_name) AS full_name, date_of_birth, enrollment_date, email
    FROM Students;

    OPEN @StudentCursor;
	--fetch next
    RETURN;
END;
GO

-- Создание хранимой процедуры
CREATE PROCEDURE StudentsCursor
AS
BEGIN
    DECLARE @MyCursor CURSOR;
    EXEC GetStudentsCursor @StudentCursor = @MyCursor OUTPUT;

    -- Возвращаем курсор через выходной параметр
    DECLARE @StudentsID INT, @report_card INT, @full_name NVARCHAR(101), @date_of_birth DATE, @enrollment_date DATE, @email NVARCHAR(100);
	FETCH NEXT FROM @MyCursor INTO @StudentsID, @report_card, @full_name, @date_of_birth, @enrollment_date, @email;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Student ID: ' + CAST(@StudentsID AS NVARCHAR(10)) + ', Full Name: ' + @full_name + ', Report Card: ' + CAST(@report_card AS NVARCHAR(10)); 
		FETCH NEXT FROM @MyCursor INTO @StudentsID, @report_card, @full_name, @date_of_birth, @enrollment_date, @email;
    END

    CLOSE @MyCursor;
    DEALLOCATE @MyCursor;
END;
GO

-- Создание пользовательской функции для проверки условия
CREATE FUNCTION dbo.CheckCondition(@report_card INT)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @report_card > 100 THEN 1 ELSE 0 END;
END;
GO

-- Создание хранимой процедуры для вызова курсора и прокрутки
CREATE PROCEDURE ProcessStudentsCursor
AS
BEGIN
	DECLARE @MyCursor CURSOR;
    EXEC GetStudentsCursor @StudentCursor = @MyCursor OUTPUT;

	 DECLARE @StudentsID INT, @report_card INT, @full_name NVARCHAR(101), @date_of_birth DATE, @enrollment_date DATE, @email NVARCHAR(100);
    FETCH NEXT FROM @MyCursor INTO @StudentsID, @report_card, @full_name, @date_of_birth, @enrollment_date, @email;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.CheckCondition(@report_card) = 1
        BEGIN
            PRINT 'Student ID: ' + CAST(@StudentsID AS NVARCHAR(10)) + ', Full Name: ' + @full_name + ', Report Card: ' + CAST(@report_card AS NVARCHAR(10));
        END
        FETCH NEXT FROM @MyCursor INTO @StudentsID, @report_card, @full_name, @date_of_birth, @enrollment_date, @email;
    END

    CLOSE @MyCursor;
    DEALLOCATE @MyCursor;
END;
GO

-- Создание табличной функции для выборки данных
CREATE FUNCTION dbo.GetStudentsTable()
RETURNS @StudentsTable TABLE
(
    StudentsID INT,
    report_card INT,
    full_name NVARCHAR(101),
    date_of_birth DATE,
    enrollment_date DATE,
    email NVARCHAR(100)
)
AS
BEGIN
    INSERT INTO @StudentsTable
    SELECT StudentsID, report_card, dbo.GetFullName(first_name, last_name), date_of_birth, enrollment_date, email
    FROM Students;

    RETURN;
END;
GO

CREATE FUNCTION dbo.GetStudentsTable2()
RETURNS TABLE
AS
RETURN
(
    SELECT StudentsID, report_card, dbo.GetFullName(first_name, last_name) AS full_name, date_of_birth, enrollment_date, email
    FROM Students
);
GO

SELECT * FROM Students
SELECT * FROM Teachers
SELECT * FROM Courses
SELECT * FROM Exams
SELECT * FROM Teachers_Courses_INT
SELECT * FROM Students_Courses_INT

-- Вызов хранимой процедуры для обработки курсора и вывода сообщений
EXEC ProcessStudentsCursor;
EXEC StudentsCursor;
-- Вызов табличной функции для получения данных
SELECT * FROM dbo.GetStudentsTable();
SELECT * FROM dbo.GetStudentsTable2();
-- Вызов пользовательской функции для формирования полного имени
DECLARE @first_name NVARCHAR(50) = 'John';
DECLARE @last_name NVARCHAR(50) = 'Doe';
SELECT dbo.GetFullName(@first_name, @last_name) AS full_name;
-- Вызов пользовательской функции для проверки условия
DECLARE @report_card INT = 102;
SELECT dbo.CheckCondition(@report_card) AS condition_met;


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
