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

-- Удаление таблиц, если они существуют
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Students;
GO

-- Создание таблицы Students
CREATE TABLE Students (
    StudentsID INT PRIMARY KEY IDENTITY(1,1),
    report_card INT NOT NULL UNIQUE,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    enrollment_date DATE NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT CHK_email_Students CHECK (email LIKE '%@%')
);
GO

-- Создание таблицы Teachers
CREATE TABLE Teachers (
    TeachersID INT PRIMARY KEY IDENTITY(1,1),
    SPIN_code INT NOT NULL UNIQUE,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    department NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone_number NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_email_Teachers CHECK (email LIKE '%@%')
);
GO

-- Создание таблицы Courses
CREATE TABLE Courses (
    CoursesID INT PRIMARY KEY IDENTITY(1,1),
    title_of_course NVARCHAR(100) NOT NULL,
    date_of_course DATE NOT NULL,
    description NVARCHAR(255),
    department NVARCHAR(50) NOT NULL,
    schedule NVARCHAR(100) NOT NULL
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
    ExamsID INT PRIMARY KEY IDENTITY(1,1),
    CoursesID INT,
    StudentID INT,
    time_stamp DATETIME NOT NULL DEFAULT GETDATE(),
    TeachersID INT,
    grade INT NOT NULL CHECK (grade BETWEEN 0 AND 100),
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID)
);
GO

-- Включение IDENTITY_INSERT для вставки значений в столбцы идентификаторов
SET IDENTITY_INSERT Students ON;
GO

-- Добавление данных в таблицу Students
INSERT INTO Students (StudentsID, report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES
(1, 101, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(2, 102, 'Jane', 'Smith', '1999-05-15', '2019-09-01', 'jane.smith@example.com'),
(3, 103, 'Alice', 'Johnson', '2001-11-30', '2021-09-01', 'alice.johnson@example.com');
GO

SET IDENTITY_INSERT Students OFF;
GO

-- Включение IDENTITY_INSERT для вставки значений в столбцы идентификаторов
SET IDENTITY_INSERT Teachers ON;
GO

-- Добавление данных в таблицу Teachers
INSERT INTO Teachers (TeachersID, SPIN_code, first_name, last_name, department, email, phone_number)
VALUES
(1, 12345, 'Dr.', 'Brown', 'Mathematics', 'dr.brown@example.com', '555-1234'),
(2, 67890, 'Prof.', 'Green', 'Physics', 'prof.green@example.com', '555-5678'),
(3, 24680, 'Ms.', 'White', 'Chemistry', 'ms.white@example.com', '555-9101');
GO

SET IDENTITY_INSERT Teachers OFF;
GO

-- Включение IDENTITY_INSERT для вставки значений в столбцы идентификаторов
SET IDENTITY_INSERT Courses ON;
GO

-- Добавление данных в таблицу Courses
INSERT INTO Courses (CoursesID, title_of_course, date_of_course, description, department, schedule)
VALUES
(1, 'Calculus I', '2023-09-01', 'Introduction to calculus', 'Mathematics', 'MWF 9:00-10:00'),
(2, 'Physics I', '2023-09-01', 'Introduction to physics', 'Physics', 'TTh 11:00-12:30'),
(3, 'Chemistry I', '2023-09-01', 'Introduction to chemistry', 'Chemistry', 'MWF 13:00-14:30');
GO

SET IDENTITY_INSERT Courses OFF;
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
INSERT INTO Exams (CoursesID, StudentID, time_stamp, TeachersID, grade)
VALUES
(1, 1, '2023-12-01 10:00:00', 1, 90),
(2, 2, '2023-12-02 14:00:00', 2, 85),
(3, 3, '2023-12-03 09:00:00', 3, 95);
GO

-- Создание представления
CREATE VIEW StudentCourseGrades AS
SELECT s.StudentsID, s.first_name AS StudentFirstName, s.last_name AS StudentLastName, c.title_of_course AS CourseTitle, e.grade AS ExamGrade
FROM Students s
JOIN Students_Courses_INT sc ON s.StudentsID = sc.StudentID
JOIN Courses c ON sc.CoursesID = c.CoursesID
JOIN Exams e ON s.StudentsID = e.StudentID AND c.CoursesID = e.CoursesID;
GO

-- Создание индекса
CREATE INDEX IDX_Students_LastName ON Students (last_name);
GO

-- Создание хранимой процедуры
CREATE PROCEDURE AddStudent
    @report_card INT,
    @first_name NVARCHAR(50),
    @last_name NVARCHAR(50),
    @date_of_birth DATE,
    @enrollment_date DATE,
    @email NVARCHAR(100)
AS
BEGIN
    INSERT INTO Students (report_card, first_name, last_name, date_of_birth, enrollment_date, email)
    VALUES (@report_card, @first_name, @last_name, @date_of_birth, @enrollment_date, @email);
END;
GO

-- Создание функции
CREATE FUNCTION GetStudentAverageGrade (@StudentID INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AverageGrade FLOAT;
    SELECT @AverageGrade = AVG(grade)
    FROM Exams
    WHERE StudentID = @StudentID;
    RETURN @AverageGrade;
END;
GO

-- Создание триггера
CREATE TRIGGER trg_UpdateGrade
ON Exams
AFTER INSERT
AS
BEGIN
    DECLARE @StudentID INT;
    DECLARE @Grade INT;
    SELECT @StudentID = StudentID, @Grade = grade FROM inserted;
    IF @Grade < 50
    BEGIN
        PRINT 'Student ' + CAST(@StudentID AS NVARCHAR(10)) + ' has a grade below 50.';
    END
END;
GO

-- Выборка записей (команда SELECT)
SELECT * FROM Students;
SELECT * FROM Teachers;
SELECT * FROM Courses;
SELECT * FROM Exams;
SELECT * FROM Teachers_Courses_INT;
SELECT * FROM Students_Courses_INT;
SELECT * FROM StudentCourseGrades;
GO

-- Добавление новых записей (команда INSERT)
INSERT INTO Students (report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES (104, 'Bob', 'Brown', '2002-07-20', '2022-09-01', 'bob.brown@example.com');
GO

INSERT INTO Teachers (SPIN_code, first_name, last_name, department, email, phone_number)
SELECT 54321, 'Dr.', 'Black', 'Biology', 'dr.black@example.com', '555-4321'
WHERE NOT EXISTS (SELECT 1 FROM Teachers WHERE SPIN_code = 54321);
GO

-- Модификация записей (команда UPDATE)
UPDATE Students
SET email = 'john.doe@newexample.com'
WHERE StudentsID = 1;
GO

-- Удаление записей (команда DELETE)
DELETE FROM Students WHERE StudentsID = 4;
GO

-- Удаление повторяющихся записей (DISTINCT)
SELECT DISTINCT department FROM Courses;
GO

-- Выбор, упорядочивание и именование полей
SELECT s.StudentsID AS StudentID, s.first_name AS FirstName, s.last_name AS LastName, c.title_of_course AS CourseTitle FROM Students s
JOIN Students_Courses_INT sc ON s.StudentsID = sc.StudentID JOIN Courses c ON sc.CoursesID = c.CoursesID
ORDER BY s.last_name ASC, s.first_name DESC;
GO

-- Соединение таблиц (INNER JOIN / LEFT JOIN / RIGHT JOIN / FULL OUTER JOIN)
SELECT s.StudentsID, s.first_name, s.last_name, c.title_of_course, e.grade
FROM Students s
LEFT JOIN Students_Courses_INT sc ON s.StudentsID = sc.StudentID
LEFT JOIN Courses c ON sc.CoursesID = c.CoursesID
LEFT JOIN Exams e ON s.StudentsID = e.StudentID AND c.CoursesID = e.CoursesID;
GO

-- Условия выбора записей (NULL / LIKE / BETWEEN / IN / EXISTS)
SELECT * FROM Students WHERE email LIKE '%@example.com' AND enrollment_date BETWEEN '2020-01-01' AND '2022-12-31' AND StudentsID IN (1, 2, 3);
GO

-- Сортировка записей (ORDER BY - ASC, DESC)
SELECT * FROM Teachers ORDER BY last_name ASC, first_name DESC;
GO

-- Группировка записей (GROUP BY + HAVING, использование функций агрегирования – COUNT / AVG / SUM / MIN / MAX)
SELECT department, COUNT(*) AS NumberOfCourses, AVG(grade) AS AverageGrade
FROM Courses c JOIN Exams e ON c.CoursesID = e.CoursesID
GROUP BY department HAVING COUNT(*) > 1;
GO

-- Объединение результатов нескольких запросов (UNION / UNION ALL / EXCEPT / INTERSECT)
SELECT first_name, last_name FROM Students
UNION SELECT first_name, last_name FROM Teachers;
GO

-- Вложенные запросы
SELECT s.StudentsID, s.first_name, s.last_name, (SELECT AVG(grade) FROM Exams e WHERE e.StudentID = s.StudentsID) AS AverageGrade
FROM Students s;
GO

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
