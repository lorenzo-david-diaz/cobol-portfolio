# Db2 SELECT Exercises — Set 2

Seventeen SQL exercises on **aggregate functions, GROUP BY, HAVING, joins and subqueries**,
run on **IBM Db2 LUW 12.1** (Community Edition, Windows).

This set builds on [Set 1](../select-set1/) (single-table SELECT) and moves to
multi-table and summary queries, the kind used in COBOL batch reports.

## Files

| File | Description |
|------|-------------|
| `set2_answers.sql` | The 17 answers, as one Db2 CLP script |
| `set2_output.txt`  | Full output of the script, as produced by Db2 |

## Test data

Database `PRACTDB`, schema `PRACTICE`:

- **DEPT**: 5 departments in 3 locations (Caracas, Valencia, Maracaibo)
- **EMP**: 15 employees, with a self-reference `MANAGER_ID → EMP_ID`

The data includes some deliberate traps:

- one employee with **no department** (`DEPT_ID` is NULL)
- one department with **no employees** (Marketing)
- commissions that are NULL for most employees

## How to run

From a Db2 Command Window, in this folder:

```
db2 -tvf set2_answers.sql > set2_output.txt
```

## Exercises

| # | Task | Main technique | Rows |
|---|------|----------------|------|
| 1 | Total employees and how many have a commission | `COUNT(*)` vs `COUNT(column)` | 1 |
| 2 | Company total, average, lowest and highest salary | `SUM`, `AVG`, `MIN`, `MAX` | 1 |
| 3 | Employees per department | `GROUP BY` (NULL forms its own group) | 5 |
| 4 | Average salary per job, highest first | `GROUP BY` + `ORDER BY` alias | 8 |
| 5 | Departments with more than 3 employees | `HAVING` | 2 |
| 6 | Jobs with average salary above 70,000 | `HAVING AVG(...)` | 5 |
| 7 | Hired before 2020, departments above 200,000 | `WHERE` + `HAVING` together | 2 |
| 8 | Employees per job within each department | `GROUP BY` two columns | 10 |
| 9 | Last name with department name | `INNER JOIN` | 14 |
| 10 | Same, including the employee with no department | `LEFT OUTER JOIN`, `COALESCE` | 15 |
| 11 | Departments with no employees | `LEFT JOIN ... WHERE ... IS NULL` | 1 |
| 12 | Every department with its headcount, zero included | `LEFT JOIN` + `COUNT(column)` | 5 |
| 13 | Employee with manager name | Self-join | 13 |
| 14 | Employees earning above the company average | Scalar subquery | 7 |
| 15 | Employees in Caracas, two ways | `JOIN` vs `IN (subquery)` | 6 |
| 16 | Headcount and average salary per location | `JOIN` + `GROUP BY` | 3 |
| 17 | Highest-paid employee of each department | Correlated subquery | 4 |

Every query returned the expected number of rows.

## Notes

- **Averages** are shown with two decimals using `DECIMAL(ROUND(AVG(SALARY), 2), 9, 2)`.
- **Decimal comma**: the output shows `83200,00` instead of `83200.00` because
  Db2 formats numbers with the Windows regional settings (Venezuela).
- **NULL handling** is the main lesson of this set: `COUNT(*)` counts rows,
  `COUNT(column)` skips NULLs, and an inner join silently drops the employee
  with no department.

## Acknowledgment

Exercises designed and reviewed with the help of Claude (Anthropic), as part of
my mainframe skills refresh. All queries were written and run by me.

— Lorenzo David Diaz
