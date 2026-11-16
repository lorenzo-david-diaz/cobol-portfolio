-- =====================================================================
-- DB2 SELECT EXERCISES - SET 1 - ANSWERS
-- Author : Lorenzo David Diaz
-- Tables : PRACTICE.DEPT, PRACTICE.EMP   (database PRACTDB)
-- Run    : db2 -tvf set1_answers.sql
-- Note   : Write each query below its comment and end it with ;
--          Lines starting with -- are comments and are ignored.
-- =====================================================================

CONNECT TO PRACTDB;
SET SCHEMA PRACTICE;

-- ---------------------------------------------------------------------
-- 1. List every column of every employee.                 (15 rows)
-- ---------------------------------------------------------------------

SELECT * FROM PRACTICE.EMP;
-- ---------------------------------------------------------------------
-- 2. First name, last name and salary of all employees,
--    highest salary first.                                (15 rows)
-- ---------------------------------------------------------------------
SELECT FIRST_NAME, LAST_NAME, SALARY FROM PRACTICE.EMP ORDER BY SALARY DESC;

-- ---------------------------------------------------------------------
-- 3. Each job title once, in alphabetical order.           (8 rows)
-- ---------------------------------------------------------------------
SELECT DISTINCT JOB FROM PRACTICE.EMP ORDER BY JOB ASC;

-- ---------------------------------------------------------------------
-- 4. Employees who work in department B01.                 (5 rows)
-- ---------------------------------------------------------------------

SELECT EMP_ID, FIRST_NAME, LAST_NAME FROM PRACTICE.EMP WHERE DEPT_ID = 'B01';
-- ---------------------------------------------------------------------
-- 5. Employees earning from 50,000 to 90,000,
--    both limits included.                                 (7 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID FROM PRACTICE.EMP WHERE SALARY BETWEEN 50000 AND 90000;

-- ---------------------------------------------------------------------
-- 6. Employees whose last name starts with R.              (3 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, LAST_NAME FROM PRACTICE.EMP WHERE LAST_NAME LIKE 'R%';

-- ---------------------------------------------------------------------
-- 7. Employees in departments C01 or D01,
--    using a single condition.                             (8 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, LAST_NAME, DEPT_ID FROM PRACTICE.EMP WHERE DEPT_ID IN ('C01', 'D01');

-- ---------------------------------------------------------------------
-- 8. Employees who have no commission recorded.           (12 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, COMMISSION FROM PRACTICE.EMP WHERE COMMISSION IS NULL;

-- ---------------------------------------------------------------------
-- 9. The employee not assigned to any department.          (1 row)
-- ---------------------------------------------------------------------
SELECT EMP_ID FROM PRACTICE.EMP WHERE DEPT_ID IS NULL;

-- ---------------------------------------------------------------------
-- 10. Employees hired on or after January 1, 2015,
--     oldest hire first.                                   (8 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, HIRE_DATE FROM PRACTICE.EMP WHERE HIRE_DATE >= '2015-01-01' ORDER BY HIRE_DATE ASC;

-- ---------------------------------------------------------------------
-- 11. Department D01: name, salary, commission and
--     TOTAL_PAY = salary + commission (missing commission = 0).
--     Then try it without the fix and compare.             (5 rows)
--     Without COALESCE, TOTAL_PAY is NULL when COMMISSION is NULL.
-- ---------------------------------------------------------------------
SELECT EMP_ID, DEPT_ID, SALARY, COMMISSION, SALARY + COALESCE(COMMISSION, 0) AS TOTAL_PAY FROM PRACTICE.EMP WHERE DEPT_ID = 'D01';

-- ---------------------------------------------------------------------
-- 12. The 3 highest-paid employees.                        (3 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, SALARY FROM PRACTICE.EMP ORDER BY SALARY DESC FETCH FIRST 3 ROWS ONLY;
-- ---------------------------------------------------------------------
-- 13. Every employee with SALARY_BAND:
--     HIGH (>= 100,000), MEDIUM (60,000 to 99,999.99),
--     LOW (< 60,000).                  (15 rows: 4 HIGH, 6 MEDIUM, 5 LOW)
-- ---------------------------------------------------------------------
SELECT EMP_ID, SALARY, CASE WHEN SALARY >= 100000 THEN 'HIGH' WHEN SALARY >= 60000 THEN 'MEDIUM' ELSE 'LOW' END AS SALARY_BAND FROM PRACTICE.EMP ORDER BY SALARY DESC;

-- ---------------------------------------------------------------------
-- 14. B01 analysts and programmers hired before 2016,
--     ordered by hire date.                                (3 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, DEPT_ID, HIRE_DATE, JOB FROM PRACTICE.EMP WHERE DEPT_ID = 'B01' AND JOB IN ('PROGRAMMER', 'ANALYST') AND HIRE_DATE < '2016-01-01' ORDER BY HIRE_DATE;

-- ---------------------------------------------------------------------
-- 15. One column FULL_NAME as "Last, First",
--     sorted alphabetically.                               (15 rows)
-- ---------------------------------------------------------------------

SELECT EMP_ID, LAST_NAME || ', ' || FIRST_NAME AS FULL_NAME FROM PRACTICE.EMP ORDER BY FULL_NAME;

CONNECT RESET;