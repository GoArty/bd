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

-- Добавление данных в таблицу Students_Courses_INT
INSERT INTO Students_Courses_INT (StudentID, CoursesID)
VALUES
(1, 1),
(2, 2),
(3, 3);

-- Объявление переменных для хранения TeachersID
DECLARE @TeacherID1 UNIQUEIDENTIFIER, @TeacherID2 UNIQUEIDENTIFIER, @TeacherID3 UNIQUEIDENTIFIER;

-- Получение существующих TeachersID для вставки в другие таблицы
BEGIN
    SELECT @TeacherID1 = TeachersID FROM Teachers WHERE first_name = 'Dr.' AND last_name = 'Brown';
    SELECT @TeacherID2 = TeachersID FROM Teachers WHERE first_name = 'Prof.' AND last_name = 'Green';
    SELECT @TeacherID3 = TeachersID FROM Teachers WHERE first_name = 'Ms.' AND last_name = 'White';

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

SELECT * FROM Students
SELECT * FROM Teachers
SELECT * FROM Courses
SELECT * FROM Exams
SELECT * FROM Teachers_Courses_INT
SELECT * FROM Students_Courses_INT

-- Удаление данных из таблиц
DELETE FROM Exams;
DELETE FROM Teachers_Courses_INT;
DELETE FROM Students_Courses_INT;
DELETE FROM Courses;
DELETE FROM Teachers;
DELETE FROM Students;
GO

---- Удаление таблиц
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Students;
GO

---- Удаление последовательности
DROP SEQUENCE IF EXISTS CoursesSeq;
GO

---- Переключение на мастер базу данных для удаления UniversityDB
USE master;
GO

---- Удаление базы данных
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    DROP DATABASE UniversityDB;
END
GO
