-- �������� ���� ������
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    DROP DATABASE UniversityDB;
END

CREATE DATABASE UniversityDB;
GO

-- ������������ �� ��������� ���� ������
USE UniversityDB;
GO

-- �������� ������� Students � ���������������� ��������� ������
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

-- �������� ������� Teachers � ��������� ������ �� ������ ����������� ����������� ��������������
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

-- �������� ������� Courses � ��������� ������ �� ������ ������������������
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

-- �������� ������� Students_Courses_INT � �������� ������� � ������������� ��������� �����������
CREATE TABLE Students_Courses_INT (
    StudentID INT,
    CoursesID INT,
    PRIMARY KEY (StudentID, CoursesID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentsID) ON DELETE CASCADE,
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- �������� ������� Teachers_Courses_INT � �������� ������� � ������������� ��������� �����������
CREATE TABLE Teachers_Courses_INT (
    TeachersID UNIQUEIDENTIFIER,
    CoursesID INT,
    PRIMARY KEY (TeachersID, CoursesID),
    FOREIGN KEY (TeachersID) REFERENCES Teachers(TeachersID) ON DELETE NO ACTION,
    FOREIGN KEY (CoursesID) REFERENCES Courses(CoursesID)
);
GO

-- �������� ������� Exams � �������� ������� � ������������� ��������� �����������
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

-- ���������� ������ � ������� Students
INSERT INTO Students (report_card, first_name, last_name, email)
VALUES
(101, 'John', 'Doe', 'john.doe@example.com'),
(102, 'Jane', 'Smith', 'jane.smith@example.com'),
(103, 'Alice', 'Johnson', 'alice.johnson@example.com');
GO

-- ���������� ������ � ������� Teachers
INSERT INTO Teachers (SPIN_code, first_name, last_name, department, email, phone_number)
VALUES
(12345, 'Dr.', 'Brown', 'Mathematics', 'dr.brown@example.com', '555-1234'),
(67890, 'Prof.', 'Green', 'Physics', 'prof.green@example.com', '555-5678'),
(24680, 'Ms.', 'White', 'Chemistry', 'ms.white@example.com', '555-9101');
GO

-- ���������� ������ � ������� Courses
INSERT INTO Courses (title_of_course, description, department, schedule)
VALUES
('Calculus I', 'Introduction to calculus', 'Mathematics', 'MWF 9:00-10:00'),
('Physics I', 'Introduction to physics', 'Physics', 'TTh 11:00-12:30'),
('Chemistry I', 'Introduction to chemistry', 'Chemistry', 'MWF 13:00-14:30');
GO

-- ���������� ���������� ��� �������� TeachersID
DECLARE @TeacherID1 UNIQUEIDENTIFIER, @TeacherID2 UNIQUEIDENTIFIER, @TeacherID3 UNIQUEIDENTIFIER;

-- ��������� ������������ TeachersID ��� ������� � ������ �������
BEGIN
    SELECT @TeacherID1 = TeachersID FROM Teachers WHERE first_name = 'Dr.' AND last_name = 'Brown';
    SELECT @TeacherID2 = TeachersID FROM Teachers WHERE first_name = 'Prof.' AND last_name = 'Green';
    SELECT @TeacherID3 = TeachersID FROM Teachers WHERE first_name = 'Ms.' AND last_name = 'White';

    -- ���������� ������ � ������� Students_Courses_INT
    INSERT INTO Students_Courses_INT (StudentID, CoursesID)
    VALUES
    (1, 1),
    (2, 2),
    (3, 3);

    -- ���������� ������ � ������� Teachers_Courses_INT
    INSERT INTO Teachers_Courses_INT (TeachersID, CoursesID)
    VALUES
    (@TeacherID1, 1),
    (@TeacherID2, 2),
    (@TeacherID3, 3);

    -- ���������� ������ � ������� Exams
    INSERT INTO Exams (CoursesID, StudentID, TeachersID, grade)
    VALUES
    (1, 1, @TeacherID1, 90),
    (2, 2, @TeacherID2, 85),
    (3, 3, @TeacherID3, 95);
END
GO

-- �������� ������������� �� ������ ����� �� ������
CREATE VIEW StudentView AS
SELECT StudentsID, first_name, last_name, email
FROM Students;
GO

-- �������� ������������� �� ������ ����� ����� ��������� ������
CREATE VIEW StudentCourseView AS
SELECT S.StudentsID, S.first_name, S.last_name, C.title_of_course, C.department
FROM Students S
JOIN Students_Courses_INT SC ON S.StudentsID = SC.StudentID
JOIN Courses C ON SC.CoursesID = C.CoursesID;
GO

-- �������� ������� ��� ����� �� ������, ������� � ���� �������������� ���������� ����
CREATE INDEX IDX_Students_LastName ON Students (last_name) INCLUDE (first_name, email);
GO

SELECT last_name, first_name, email
FROM Students
WHERE last_name = 'Smith' OR last_name = 'Doe' ORDER BY email;
GO

-- �������� ���������������� �������������
CREATE VIEW StudentCourseIndexedView WITH SCHEMABINDING AS
SELECT S.StudentsID, S.first_name, S.last_name, C.title_of_course, C.department
FROM dbo.Students S
JOIN dbo.Students_Courses_INT SC ON S.StudentsID = SC.StudentID
JOIN dbo.Courses C ON SC.CoursesID = C.CoursesID;
GO

SELECT * FROM StudentCourseIndexedView	--

INSERT INTO Students (report_card, first_name, last_name, email) --
VALUES
(104, 'Red', 'Doue', 'john.doe@example.com')
GO

--ALTER TABLE Students DROP COLUMN last_name
--GO

SELECT * FROM StudentCourseIndexedView

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

