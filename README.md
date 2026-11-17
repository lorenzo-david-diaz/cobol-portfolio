# COBOL Portfolio

COBOL, JCL, VSAM and Db2 work by **Lorenzo David Díaz**, run on a real **IBM z/OS** system (IBM Z Xplore, Enterprise COBOL) and on a PC with **Rocket (Micro Focus) Visual COBOL for Eclipse**, **GnuCOBOL 3.2** and **IBM Db2 Community Edition**.

About 25 years of mainframe experience with COBOL, PL/I, FORTRAN and Assembler, including IBM MVS systems programming, now applied with modern tools: z/OS through VS Code and Zowe, Visual COBOL, Db2, Git and GitHub. Every exercise here was run and its results checked; most folders include the real output of the run.

## Contents

| Item | Topic | Platform | Location |
|------|-------|----------|----------|
| PROG0010 | Sequential report with page break and totals | Visual COBOL, GnuCOBOL | [`PROG0010/`](PROG0010/) |
| PROG0020 | Load an indexed (keyed) file from a sequential one | Visual COBOL, GnuCOBOL | [`PROG0020/`](PROG0020/) |
| PROG0021 | Read an indexed file sequentially and by key | Visual COBOL, GnuCOBOL | [`PROG0020/`](PROG0020/) |
| VSAM Exercise 3 | Define and load a KSDS (IDCAMS, SORT) | z/OS | [`vsam/ex03-ksds-load/`](vsam/ex03-ksds-load/) |
| VSAM Exercise 5 | Account maintenance: add, deposit, withdraw, change status, delete | z/OS | [`vsam/ex05-account-maintenance/`](vsam/ex05-account-maintenance/) |
| VSAM Exercise 8 | Alternate index and inquiry by holder name | z/OS | [`vsam/ex08-alternate-index/`](vsam/ex08-alternate-index/) |
| ACCOUNT DDL | The ACCOUNT table for PostgreSQL, Db2 LUW and Db2 for z/OS | Db2, PostgreSQL | [`db2/ddl/`](db2/ddl/) |
| ACCTINS | Db2 INSERT tests with embedded SQL (7 test cases) | Visual COBOL + Db2 LUW | [`db2/acctins/`](db2/acctins/) |
| SELECT Set 1 | 15 single-table SELECT exercises | Db2 LUW | [`db2/select-set1/`](db2/select-set1/) |
| Db2 cheat sheet | My cumulative Db2 notes (PDF) | - | [`docs/Db2_Cheat_Sheet.pdf`](docs/Db2_Cheat_Sheet.pdf) |

---

## Sequential and indexed files

### PROG0010 - Employee Listing with Page Break and Control Totals

Reads a sequential employee file and produces an 80-column paginated report: title, run date and page number on every page, repeated column headings, a page break every 15 detail lines, and control totals (records read, records printed, total salary).

Input: `EMPLEADOS.TXT` (50 bytes, line sequential). Output: `REPORTE_MF.TXT`. Data names in this first program are in Spanish (e.g., `EMPLEADOS` = employees, `SALARIO` = salary).

### PROG0020 / PROG0021 - Indexed File Processing

**PROG0020 - Load the employee master file**
- Reads `EMPLOYEES.TXT` and writes `EMPLOYEES.IDX`, an indexed file keyed on employee number.
- Checks FILE STATUS after every OPEN, and uses INVALID KEY on every WRITE.
- Skips records with employee number zero; rejects duplicate or out-of-sequence keys.
- Control totals: records read, written, skipped, rejected, and total salary.

**PROG0021 - Read the employee master file**
- `ACCESS MODE IS DYNAMIC`, so one program reads the file both ways.
- **Part 1:** reads the whole file in key order, with record count and total salary.
- **Part 2:** looks up employees by key: first, middle and last records, plus a key that does not exist, to exercise the INVALID KEY path.

**Record layout (50 bytes)**

| Positions | Field      | Picture | Description                |
|-----------|------------|---------|----------------------------|
| 1-5       | Number     | 9(05)   | Employee number (key)      |
| 6-35      | Name       | X(30)   | Employee name              |
| 36        | Status     | 9(01)   | Employee status code       |
| 37-39     | Department | 9(03)   | Department code            |
| 40-41     | Position   | 9(02)   | Position code              |
| 42-50     | Salary     | 9(7)V99 | Salary, 2 implied decimals |

**Test results.** The three programs use the same 120-record employee test data, so their control totals can be checked against each other.

| Control       | PROG0020      | PROG0021                         |
|---------------|---------------|----------------------------------|
| Records       | 120 written   | 120 read                         |
| Total salary  | $1,769,195.84 | $1,769,195.84                    |
| Keyed lookups | -             | 3 found, 1 not found (status 23) |

Error handling was also tested with a file containing a zero key, a duplicate key and an out-of-sequence key: 9 read = 6 written + 1 skipped + 2 rejected (status 21).

**How to run (GnuCOBOL).** Place `EMPLOYEES.TXT` in `C:\REPOSITORIO_DATOS\` (or edit the `ASSIGN` clauses), then compile and run:

    cobc -x -Wall PROG0020.CBL
    cobc -x -Wall PROG0021.CBL
    .\PROG0020.exe
    .\PROG0021.exe

GnuCOBOL must be built with indexed file support (`cobc --info` shows the handler, for example BDB).

---

## VSAM on z/OS

Three exercises built around an **ACCOUNTS** KSDS (61-byte records, key = account number) for a banking system. They ran on IBM z/OS through IBM Z Xplore, in this order, and every result matched the values predicted before the run:

| Order | Job | What it does | Result |
|-------|-----|--------------|--------|
| 1 | `ACCTLOAD` | Defines the KSDS and loads 12 accounts | CC 0000, 12 records |
| 2 | `ACCTUPDJ` | Applies 12 maintenance transactions with random access | 1 added, 4 updated, 1 deleted, 6 rejected (RC 4, as designed) |
| 3 | `ACCTAIX` | Adds 3 accounts, defines and builds a non-unique alternate index on the holder name | CC 0000 |
| 4 | `ACCTNAMJ` | Inquiry by holder name through the alternate index | File status 02, 02, 00 for duplicates; 15 accounts listed by name |

Each folder has the JCL, the COBOL source, the real job output and a README that explains the results, including the compiler messages.

---

## Db2 and Embedded SQL

Programs and scripts for IBM Db2, built around the `ACCOUNT` table of a banking system capstone project (schema `Z79583`). They are developed and tested on a PC with Visual COBOL and Db2 Community Edition (Db2 LUW), and written to move to Db2 for z/OS with small changes.

- **ACCOUNT DDL** - the same table defined for PostgreSQL, Db2 LUW and Db2 for z/OS (SPUFI format), with a comparison of the three. [`db2/ddl/`](db2/ddl/)
- **ACCTINS** - a COBOL program with embedded SQL that runs seven INSERT tests and checks the SQLCODE of each: a complete row, default values, a duplicate key (-803), two check constraints (-545), an invalid date (-181) and a missing NOT NULL column (-407). It rolls back at the end so it can be run again. **Result: 7 of 7 tests pass.** [`db2/acctins/`](db2/acctins/)
- **SELECT Set 1** - 15 single-table queries (WHERE, BETWEEN, LIKE, IN, IS NULL, COALESCE, CASE, FETCH FIRST), with the setup script and the complete output. **All 15 returned the expected rows.** [`db2/select-set1/`](db2/select-set1/)
- **Db2 cheat sheet** - my cumulative notes: environments, SQLCODEs and SQLSTATEs, building COBOL/Db2 programs on the PC and on z/OS, and everyday procedures. [`docs/Db2_Cheat_Sheet.pdf`](docs/Db2_Cheat_Sheet.pdf)

---

## About this portfolio

Written and tested by Lorenzo David Díaz, with help from Claude (Anthropic's AI assistant) as a coding and review assistant and in preparing the documentation.

Coming next: more SELECT and UPDATE exercises, and a banking system capstone project with batch (JCL/COBOL/Db2) and online (CICS) components.
