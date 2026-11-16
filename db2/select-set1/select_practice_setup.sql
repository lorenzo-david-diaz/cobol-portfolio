-- =====================================================================
-- SELECT PRACTICE - SETUP SCRIPT FOR DB2 COMMUNITY EDITION (LUW)
-- Creates schema PRACTICE with two tables: DEPT and EMP.
-- Kept separate from the banking capstone tables.
--
-- How to run (Db2 Command Window / CLP):
--   db2 connect to <your_database>
--   db2 -tvf select_practice_setup.sql
-- Or open this file in VS Code with the Db2 extension and run it all.
-- =====================================================================

CREATE SCHEMA PRACTICE;

SET SCHEMA PRACTICE;

-- ---------------------------------------------------------------------
-- DEPARTMENTS
-- ---------------------------------------------------------------------
CREATE TABLE PRACTICE.DEPT (
    DEPT_ID     CHAR(3)       NOT NULL,
    DEPT_NAME   VARCHAR(30)   NOT NULL,
    LOCATION    VARCHAR(20)   NOT NULL,
    CONSTRAINT PK_DEPT PRIMARY KEY (DEPT_ID)
);

-- ---------------------------------------------------------------------
-- EMPLOYEES
--   DEPT_ID, COMMISSION and MANAGER_ID allow NULL on purpose,
--   so we can practice IS NULL, COALESCE and outer joins.
-- ---------------------------------------------------------------------
CREATE TABLE PRACTICE.EMP (
    EMP_ID      INTEGER       NOT NULL,
    FIRST_NAME  VARCHAR(20)   NOT NULL,
    LAST_NAME   VARCHAR(20)   NOT NULL,
    DEPT_ID     CHAR(3),
    JOB         VARCHAR(20)   NOT NULL,
    HIRE_DATE   DATE          NOT NULL,
    SALARY      DECIMAL(9,2)  NOT NULL,
    COMMISSION  DECIMAL(9,2),
    MANAGER_ID  INTEGER,
    CONSTRAINT PK_EMP PRIMARY KEY (EMP_ID),
    CONSTRAINT FK_EMP_DEPT FOREIGN KEY (DEPT_ID)
        REFERENCES PRACTICE.DEPT (DEPT_ID)
);

-- ---------------------------------------------------------------------
-- DATA
-- ---------------------------------------------------------------------
INSERT INTO PRACTICE.DEPT (DEPT_ID, DEPT_NAME, LOCATION) VALUES
    ('A00', 'Administration',         'Caracas'),
    ('B01', 'Information Technology', 'Caracas'),
    ('C01', 'Finance',                'Maracaibo'),
    ('D01', 'Operations',             'Valencia'),
    ('E01', 'Marketing',              'Maracaibo');

INSERT INTO PRACTICE.EMP
    (EMP_ID, FIRST_NAME, LAST_NAME, DEPT_ID, JOB, HIRE_DATE, SALARY, COMMISSION, MANAGER_ID)
VALUES
    (1001, 'Lorena',   'Mendez',   'A00', 'PRESIDENT',  '1998-03-15', 180000.00, NULL,    NULL),
    (1002, 'Carlos',   'Rivas',    'B01', 'MANAGER',    '2005-06-01', 120000.00, NULL,    1001),
    (1003, 'Ana',      'Torres',   'C01', 'MANAGER',    '2008-09-10', 115000.00, NULL,    1001),
    (1004, 'Jose',     'Pereira',  'D01', 'MANAGER',    '2010-01-20', 110000.00, NULL,    1001),
    (1005, 'Maria',    'Gonzalez', 'B01', 'ANALYST',    '2012-04-02',  85000.00, NULL,    1002),
    (1006, 'Pedro',    'Salazar',  'B01', 'PROGRAMMER', '2015-07-15',  72000.00, NULL,    1002),
    (1007, 'Luisa',    'Ramirez',  'B01', 'PROGRAMMER', '2019-11-04',  68000.00, NULL,    1002),
    (1008, 'Jorge',    'Castillo', 'C01', 'ACCOUNTANT', '2011-02-28',  78000.00, NULL,    1003),
    (1009, 'Elena',    'Rojas',    'C01', 'CLERK',      '2020-08-17',  42000.00, NULL,    1003),
    (1010, 'Ricardo',  'Blanco',   'D01', 'SALESREP',   '2016-05-09',  55000.00, 9500.00, 1004),
    (1011, 'Sofia',    'Herrera',  'D01', 'SALESREP',   '2021-03-22',  52000.00, 7200.00, 1004),
    (1012, 'Miguel',   'Ortega',   'D01', 'SALESREP',   '2023-10-02',  48000.00,    0.00, 1004),
    (1013, 'Carmen',   'Vargas',   'D01', 'CLERK',      '2018-12-03',  40000.00, NULL,    1004),
    (1014, 'Andres',   'Molina',   NULL,  'CONSULTANT', '2024-01-15',  95000.00, NULL,    NULL),
    (1015, 'Patricia', 'Luna',     'B01', 'ANALYST',    '2009-05-11',  88000.00, NULL,    1002);

COMMIT;

-- ---------------------------------------------------------------------
-- QUICK CHECK: expect 5 and 15
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS DEPT_ROWS FROM PRACTICE.DEPT;
SELECT COUNT(*) AS EMP_ROWS  FROM PRACTICE.EMP;
