-- =====================================================================
-- DB2 SELECT EXERCISES - SET 2 - ANSWERS
-- Author : Lorenzo David Diaz
-- Tables : PRACTICE.DEPT, PRACTICE.EMP   (database PRACTDB)
-- Run    : db2 -tvf set2_answers.sql
-- Topics : aggregates, GROUP BY, HAVING, joins, subqueries
-- =====================================================================

CONNECT TO PRACTDB;
SET SCHEMA PRACTICE;

-- ---------------------------------------------------------------------
-- 1. Total employees and how many have a commission.      (1 row)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS TOTAL_EMPLOYEES, COUNT(COMMISSION) AS EMPLOYEES_WITH_COMMISSION
FROM PRACTICE.EMP;

-- ---------------------------------------------------------------------
-- 2. Company total, average, lowest and highest salary.   (1 row)
-- ---------------------------------------------------------------------
SELECT SUM(SALARY) AS TOTAL,
       DECIMAL(ROUND(AVG(SALARY), 2), 9, 2) AS AVG_SALARY,
       MAX(SALARY) AS HIGHEST,
       MIN(SALARY) AS LOWEST
FROM PRACTICE.EMP;

-- ---------------------------------------------------------------------
-- 3. Number of employees per department.                  (5 rows)
-- ---------------------------------------------------------------------
SELECT DEPT_ID, COUNT(EMP_ID) AS EMPLOYEES
FROM PRACTICE.EMP
GROUP BY DEPT_ID
ORDER BY DEPT_ID;

-- ---------------------------------------------------------------------
-- 4. Average salary per job, highest first.               (8 rows)
-- ---------------------------------------------------------------------
SELECT JOB, DECIMAL(ROUND(AVG(SALARY), 2), 9, 2) AS AVERAGE
FROM PRACTICE.EMP
GROUP BY JOB
ORDER BY AVERAGE DESC;

-- ---------------------------------------------------------------------
-- 5. Departments with more than 3 employees.              (2 rows)
-- ---------------------------------------------------------------------
SELECT DEPT_ID, COUNT(*) AS HEADCOUNT
FROM PRACTICE.EMP
GROUP BY DEPT_ID
HAVING COUNT(*) > 3;

-- ---------------------------------------------------------------------
-- 6. Jobs whose average salary is above 70,000.           (5 rows)
-- ---------------------------------------------------------------------
SELECT JOB, DECIMAL(ROUND(AVG(SALARY), 2), 9, 2) AS AVERAGE
FROM PRACTICE.EMP
GROUP BY JOB
HAVING AVG(SALARY) > 70000
ORDER BY AVERAGE DESC;

-- ---------------------------------------------------------------------
-- 7. Hired before 2020: headcount and total salary per
--    department, only departments above 200,000.          (2 rows)
-- ---------------------------------------------------------------------
SELECT DEPT_ID, COUNT(*) AS HEADCOUNT, SUM(SALARY) AS TOTAL
FROM PRACTICE.EMP
WHERE HIRE_DATE < '2020-01-01'
GROUP BY DEPT_ID
HAVING SUM(SALARY) > 200000;

-- ---------------------------------------------------------------------
-- 8. Employees per job within each department
--    (no NULL department).                                (10 rows)
-- ---------------------------------------------------------------------
SELECT DEPT_ID, JOB, COUNT(*) AS EMPLOYEES
FROM PRACTICE.EMP
WHERE DEPT_ID IS NOT NULL
GROUP BY DEPT_ID, JOB
ORDER BY DEPT_ID, JOB;

-- ---------------------------------------------------------------------
-- 9. Last name with department name.                      (14 rows)
-- ---------------------------------------------------------------------
SELECT E.LAST_NAME, D.DEPT_NAME
FROM PRACTICE.EMP E
INNER JOIN PRACTICE.DEPT D ON E.DEPT_ID = D.DEPT_ID
ORDER BY E.LAST_NAME;

-- ---------------------------------------------------------------------
-- 10. Same as 9, including the employee with no department. (15 rows)
-- ---------------------------------------------------------------------
-- 10a. Plain LEFT OUTER JOIN: the missing department shows as NULL (-).
SELECT E.LAST_NAME, D.DEPT_NAME
FROM PRACTICE.EMP E
LEFT OUTER JOIN PRACTICE.DEPT D ON E.DEPT_ID = D.DEPT_ID
ORDER BY E.LAST_NAME;

-- 10b. Same query, with COALESCE to replace NULL by a readable text.
SELECT E.LAST_NAME, COALESCE(D.DEPT_NAME, 'No department') AS DEPT_NAME
FROM PRACTICE.EMP E
LEFT OUTER JOIN PRACTICE.DEPT D ON E.DEPT_ID = D.DEPT_ID
ORDER BY E.LAST_NAME;

-- ---------------------------------------------------------------------
-- 11. Departments with no employees.                      (1 row)
-- ---------------------------------------------------------------------
SELECT D.DEPT_ID, D.DEPT_NAME
FROM PRACTICE.DEPT D
LEFT OUTER JOIN PRACTICE.EMP E ON E.DEPT_ID = D.DEPT_ID
WHERE E.EMP_ID IS NULL;

-- ---------------------------------------------------------------------
-- 12. Every department name with its headcount
--     (zero included).                                    (5 rows)
-- ---------------------------------------------------------------------
SELECT D.DEPT_NAME, COUNT(E.EMP_ID) AS HEADCOUNT
FROM PRACTICE.DEPT D
LEFT OUTER JOIN PRACTICE.EMP E ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_NAME
ORDER BY D.DEPT_NAME;

-- ---------------------------------------------------------------------
-- 13. Employee last name with manager last name.          (13 rows)
-- ---------------------------------------------------------------------
SELECT E.LAST_NAME AS EMPLOYEE, M.LAST_NAME AS MANAGER
FROM PRACTICE.EMP E
INNER JOIN PRACTICE.EMP M ON E.MANAGER_ID = M.EMP_ID
ORDER BY M.LAST_NAME, E.LAST_NAME;

-- ---------------------------------------------------------------------
-- 14. Employees earning more than the company average.    (7 rows)
-- ---------------------------------------------------------------------
SELECT EMP_ID, LAST_NAME, SALARY
FROM PRACTICE.EMP
WHERE SALARY > (SELECT AVG(SALARY) FROM PRACTICE.EMP)
ORDER BY SALARY DESC;

-- ---------------------------------------------------------------------
-- 15. Employees in Caracas: once with JOIN,
--     once with IN (subquery).                            (6 rows)
-- ---------------------------------------------------------------------
-- 15a. With JOIN.
SELECT E.LAST_NAME, D.LOCATION
FROM PRACTICE.EMP E
INNER JOIN PRACTICE.DEPT D ON E.DEPT_ID = D.DEPT_ID
WHERE D.LOCATION = 'Caracas'
ORDER BY E.LAST_NAME;

-- 15b. With IN (subquery).
SELECT E.LAST_NAME, E.DEPT_ID
FROM PRACTICE.EMP E
WHERE E.DEPT_ID IN (SELECT DEPT_ID
                    FROM PRACTICE.DEPT
                    WHERE LOCATION = 'Caracas')
ORDER BY E.LAST_NAME;

-- ---------------------------------------------------------------------
-- 16. Per location: headcount and average salary,
--     largest headcount first.                            (3 rows)
-- ---------------------------------------------------------------------
SELECT D.LOCATION,
       COUNT(*) AS EMP_COUNT,
       DECIMAL(ROUND(AVG(E.SALARY), 2), 11, 2) AS AVG_SALARY
FROM PRACTICE.EMP E
INNER JOIN PRACTICE.DEPT D ON E.DEPT_ID = D.DEPT_ID
GROUP BY D.LOCATION
ORDER BY EMP_COUNT DESC;

-- ---------------------------------------------------------------------
-- 17. Highest-paid employee of each department.           (4 rows)
--     Correlated subquery: the inner MAX is recalculated for the
--     department of each outer row.
-- ---------------------------------------------------------------------
SELECT E.DEPT_ID, E.LAST_NAME, E.SALARY
FROM PRACTICE.EMP E
WHERE E.SALARY = (SELECT MAX(X.SALARY)
                  FROM PRACTICE.EMP X
                  WHERE X.DEPT_ID = E.DEPT_ID)
ORDER BY E.DEPT_ID;

CONNECT RESET;
