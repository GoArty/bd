-- �������� ���� ������
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    DROP DATABASE UniversityDB;
END

CREATE DATABASE UniversityDB
ON PRIMARY
(
    NAME = 'UniversityDB_Data',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\UniversityDB.mdf',
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 20%
)
LOG ON
(
    NAME = 'UniversityDB_Log',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\LOG\UniversityDB.ldf',
    SIZE = 5MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 10%
);
GO

-- ������������ �� ��������� ���� ������
USE UniversityDB;
GO

-- �������� ������� Students
CREATE TABLE Students (
    StudentsID INT IDENTITY(1,1) PRIMARY KEY,
    report_card INT UNIQUE NOT NULL,
    first_name NVARCHAR(50) NULL,
    last_name NVARCHAR(50) NULL,
    date_of_birth DATE NULL,
    enrollment_date DATE NULL,
    email NVARCHAR(100) UNIQUE NOT NULL
);
GO

-- �������� ������� Teachers
CREATE TABLE Teachers (
    TeachersID INT IDENTITY(1,1) PRIMARY KEY,
    SPIN_code INT UNIQUE NOT NULL,
    first_name NVARCHAR(50) NULL,
    last_name NVARCHAR(50) NULL,
    department NVARCHAR(50) NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    phone_number NVARCHAR(20) NOT NULL
);
GO

-- �������� ������� Courses
CREATE TABLE Courses (
    CoursesID INT IDENTITY(1,1) PRIMARY KEY,
    title_of_course NVARCHAR(100) NOT NULL,
    date_of_course DATE NOT NULL,
    description NVARCHAR(255) NULL,
    department NVARCHAR(50) NULL,
    schedule NVARCHAR(100) NULL
);
GO

-- �������� ������� Students_Courses_INT
CREATE TABLE Students_Courses_INT (
    StudentID INT NOT NULL,
    CoursesID INT NOT NULL,
    PRIMARY KEY (StudentID, CoursesID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID),
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- �������� ������� Teachers_Courses_INT
CREATE TABLE Teachers_Courses_INT (
    TeachersID INT NOT NULL,
    CoursesID INT NOT NULL,
    PRIMARY KEY (TeachersID, CoursesID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID),
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- �������� ����� �������� ������ � ����� ������
ALTER DATABASE UniversityDB ADD FILEGROUP fg;
GO

ALTER DATABASE UniversityDB ADD FILE
(
    NAME = 'fg_File',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\fg.ndf',
    SIZE = 5MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10%
) TO FILEGROUP fg;
GO

-- ��������� ����� �������� ������ ��� �������� ������ �� ���������
ALTER DATABASE UniversityDB MODIFY FILEGROUP fg DEFAULT;
GO

-- �������� ������� Exams
CREATE TABLE Exams (
    ExamsID INT IDENTITY(1,1) PRIMARY KEY,
    CoursesID INT NOT NULL,
    StudentID INT NOT NULL,
    time_stamp DATETIME NOT NULL,
    TeachersID INT NOT NULL,
    grade INT NULL,
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID)
);
GO

-- ���������� ������ � ������� Students
INSERT INTO Students (report_card, first_name, last_name, date_of_birth, enrollment_date, email)
VALUES
(101, 'John', 'Doe', '2000-01-01', '2020-09-01', 'john.doe@example.com'),
(102, 'Jane', 'Smith', '1999-05-15', '2019-09-01', 'jane.smith@example.com'),
(103, 'Alice', 'Johnson', '2001-11-30', '2021-09-01', 'alice.johnson@example.com');
GO

-- ���������� ������ � ������� Teachers
INSERT INTO Teachers (SPIN_code, first_name, last_name, department, email, phone_number)
VALUES
(12345, 'Dr.', 'Brown', 'Mathematics', 'dr.brown@example.com', '555-1234'),
(67890, 'Prof.', 'Green', 'Physics', 'prof.green@example.com', '555-5678'),
(24680, 'Ms.', 'White', 'Chemistry', 'ms.white@example.com', '555-9101');
GO

-- ���������� ������ � ������� Courses
INSERT INTO Courses (title_of_course, date_of_course, description, department, schedule)
VALUES
('Calculus I', '2023-09-01', 'Introduction to calculus', 'Mathematics', 'MWF 9:00-10:00'),
('Physics I', '2023-09-01', 'Introduction to physics', 'Physics', 'TTh 11:00-12:30'),
('Chemistry I', '2023-09-01', 'Introduction to chemistry', 'Chemistry', 'MWF 13:00-14:30');
GO

-- ���������� ������ � ������� Students_Courses_INT
INSERT INTO Students_Courses_INT (StudentID, CoursesID)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

-- ���������� ������ � ������� Teachers_Courses_INT
INSERT INTO Teachers_Courses_INT (TeachersID, CoursesID)
VALUES
(1, 1),
(2, 2),
(3, 3);
GO

-- ���������� ������ � ������� Exams
INSERT INTO Exams (CoursesID, StudentID, time_stamp, TeachersID, grade)
VALUES
(1, 1, '2023-12-01 10:00:00', 1, 90),
(2, 2, '2023-12-02 14:00:00', 2, 85),
(3, 3, '2023-12-03 09:00:00', 3, 95);
GO

-- �������� ����� � ����������� ������� Students � ����� �����
CREATE SCHEMA MySchema AUTHORIZATION dbo;
GO

ALTER SCHEMA MySchema TRANSFER dbo.Students;
GO

SELECT * FROM MySchema.Students
SELECT * FROM Teachers
SELECT * FROM Courses
SELECT * FROM Exams
SELECT * FROM Teachers_Courses_INT
SELECT * FROM Students_Courses_INT

-- �������� ������ �� ������
DELETE FROM Exams;
DELETE FROM Teachers_Courses_INT;
DELETE FROM Students_Courses_INT;
DELETE FROM Courses;
DELETE FROM Teachers;
DELETE FROM MySchema.Students;
GO

-- �������� ������
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Teachers_Courses_INT;
DROP TABLE IF EXISTS Students_Courses_INT;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS MySchema.Students;
GO

-- ������� �������� ������ �� ��������� ������� �� PRIMARY
ALTER DATABASE UniversityDB MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

-- �������� �������� ������ fg
IF EXISTS (SELECT * FROM sys.filegroups WHERE name = 'fg')
BEGIN
    IF EXISTS (SELECT * FROM sys.master_files WHERE name = 'fg_File' AND database_id = DB_ID('UniversityDB'))
    BEGIN
        ALTER DATABASE UniversityDB REMOVE FILE fg_File;
    END

    ALTER DATABASE UniversityDB REMOVE FILEGROUP fg;
END
GO

-- �������� �����
DROP SCHEMA MySchema;
GO

-- ������������ �� ������ ���� ������ ��� �������� UniversityDB
USE master;
GO

-- �������� ���� ������
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    DROP DATABASE UniversityDB;
END
GO
