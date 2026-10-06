# COBOL Portfolio

COBOL programs by **Lorenzo David Diaz**, written with **Micro Focus Visual COBOL for Eclipse** and tested with **GnuCOBOL 3.2**.

Decades of experience with COBOL, PL/I, FORTRAN, Assembler and IBM MVS systems, now applied with modern tools: Visual COBOL, GnuCOBOL, Git and GitHub.

## Program index

| Program  | Topic                                              | Location    |
|----------|----------------------------------------------------|-------------|
| PROG0010 | Sequential report with page break and totals       | PROG0010/   |
| PROG0020 | Load an indexed (keyed) file from a sequential one | PROG0020/   |
| PROG0021 | Read an indexed file sequentially and by key       | PROG0020/   |

All programs use the same 120-record employee test data, so their control totals can be checked against each other: **120 records, total salary $1,769,195.84**.

---

## PROG0010 - Employee Listing with Page Break and Control Totals

Reads a sequential employee file and produces an 80-column paginated report: title, run date and page number on every page, repeated column headings, a page break every 15 detail lines, and control totals (records read, records printed, total salary).

Input: `EMPLEADOS.TXT` (50 bytes, line sequential). Output: `REPORTE_MF.TXT`. Data names in this first program are in Spanish (e.g., `EMPLEADOS` = employees, `SALARIO` = salary).

---

## PROG0020 / PROG0021 - Indexed File Processing

### PROG0020 - Load the employee master file
- Reads `EMPLOYEES.TXT` and writes `EMPLOYEES.IDX`, an indexed file keyed on employee number.
- Checks FILE STATUS after every OPEN, and uses INVALID KEY on every WRITE.
- Skips records with employee number zero; rejects duplicate or out-of-sequence keys.
- Control totals: records read, written, skipped, rejected, and total salary.

### PROG0021 - Read the employee master file
- `ACCESS MODE IS DYNAMIC`, so one program reads the file both ways.
- **Part 1:** reads the whole file in key order, with record count and total salary.
- **Part 2:** looks up employees by key: first, middle and last records, plus a key that does not exist, to exercise the INVALID KEY path.

### Record layout (50 bytes)

| Positions | Field      | Picture | Description                |
|-----------|------------|---------|----------------------------|
| 1-5       | Number     | 9(05)   | Employee number (key)      |
| 6-35      | Name       | X(30)   | Employee name              |
| 36        | Status     | 9(01)   | Employee status code       |
| 37-39     | Department | 9(03)   | Department code            |
| 40-41     | Position   | 9(02)   | Position code              |
| 42-50     | Salary     | 9(7)V99 | Salary, 2 implied decimals |

### Test results

| Control       | PROG0020      | PROG0021                         |
|---------------|---------------|----------------------------------|
| Records       | 120 written   | 120 read                         |
| Total salary  | $1,769,195.84 | $1,769,195.84                    |
| Keyed lookups | -             | 3 found, 1 not found (status 23) |

Error handling was also tested with a file containing a zero key, a duplicate key and an out-of-sequence key: 9 read = 6 written + 1 skipped + 2 rejected (status 21).

### How to run (GnuCOBOL)

Place `EMPLOYEES.TXT` in `C:\REPOSITORIO_DATOS\` (or edit the `ASSIGN` clauses), then compile and run:

    cobc -x -Wall PROG0020.CBL
    cobc -x -Wall PROG0021.CBL
    .\PROG0020.exe
    .\PROG0021.exe

GnuCOBOL must be built with indexed file support (`cobc --info` shows the handler, for example BDB).
