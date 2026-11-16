# Db2 SELECT Exercises - Set 1

Fifteen single-table SELECT queries, run on **Db2 Community Edition 12.1**
(Db2 for Linux, UNIX and Windows) against a small practice database.

## Files

| File | Purpose |
|---|---|
| `select_practice_setup.sql` | Creates schema PRACTICE with tables DEPT (5 rows) and EMP (15 rows) |
| `set1_answers.sql` | My answers to the 15 exercises |
| `set1_output.txt` | The complete output of running the answers with the Db2 command line |

## The practice data

**PRACTICE.DEPT** - DEPT_ID (primary key), DEPT_NAME, LOCATION

**PRACTICE.EMP** - EMP_ID (primary key), FIRST_NAME, LAST_NAME, DEPT_ID
(foreign key to DEPT), JOB, HIRE_DATE, SALARY, COMMISSION, MANAGER_ID

DEPT_ID, COMMISSION and MANAGER_ID allow NULL on purpose. The data includes
a few traps to practice with:

- One employee (1014) has no department.
- One employee (1012) has a commission of **0.00**, which is not the same as NULL.
- One department (E01) has no employees, for the joins in Set 2.

## Exercises and results

| # | Task | Concepts | Expected | Result |
|---|---|---|---|---|
| 1 | Every column of every employee | `SELECT *` | 15 rows | Pass |
| 2 | Name and salary, highest salary first | `ORDER BY ... DESC` | 15 rows | Pass |
| 3 | Each job title once, alphabetically | `DISTINCT` | 8 rows | Pass |
| 4 | Employees in department B01 | `WHERE =` | 5 rows | Pass |
| 5 | Salaries from 50,000 to 90,000, both included | `BETWEEN` | 7 rows | Pass |
| 6 | Last name starts with R | `LIKE 'R%'` | 3 rows | Pass |
| 7 | Departments C01 or D01, in one condition | `IN` | 8 rows | Pass |
| 8 | No commission recorded | `IS NULL` | 12 rows | Pass |
| 9 | Employee with no department | `IS NULL` | 1 row | Pass |
| 10 | Hired on or after 2015-01-01, oldest first | Date comparison | 8 rows | Pass |
| 11 | D01 total pay = salary + commission | `COALESCE`, expressions | 5 rows | Pass |
| 12 | The 3 highest-paid employees | `FETCH FIRST n ROWS ONLY` | 3 rows | Pass |
| 13 | Salary band HIGH / MEDIUM / LOW | `CASE` | 15 rows (4 / 6 / 5) | Pass |
| 14 | B01 analysts and programmers hired before 2016 | `AND`, `IN`, dates | 3 rows | Pass |
| 15 | Full name as "Last, First", sorted | Concatenation `\|\|` | 15 rows | Pass |

Exercise 11 shows why `COALESCE` matters: without it, `SALARY + COMMISSION`
is NULL whenever the commission is NULL.

## How to run

In a Db2 Command Window, from this folder:

```
db2 CREATE DATABASE PRACTDB
db2 connect to PRACTDB
db2 -tvf select_practice_setup.sql
db2 -tvf set1_answers.sql
```

`-t` ends statements at `;`, `-v` echoes each statement, and `-f` reads
them from the file. The setup script ends with a check that should show
5 departments and 15 employees.

**Note on the output file:** the Db2 command line follows the Windows
regional settings, so `set1_output.txt` shows dates as DD/MM/YYYY and
decimal commas (180000,00). The data and the SQL use the standard formats.

## Related work

- [`../ddl`](../ddl) - ACCOUNT table DDL for PostgreSQL, Db2 LUW and Db2 for z/OS
- [`../acctins`](../acctins) - COBOL program with embedded SQL (INSERT tests)

---

*Claude (Anthropic's AI assistant) designed the exercise set and the
practice data with me. I wrote and ran the answers myself; Claude reviewed
them and helped prepare this documentation.*
