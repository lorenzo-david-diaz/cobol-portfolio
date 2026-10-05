# COBOL Portfolio

COBOL programs by **Lorenzo David Diaz**, written with **Micro Focus Visual COBOL for Eclipse** and also tested with **GnuCOBOL 3.2**.

Decades of experience with COBOL, PL/I, FORTRAN, Assembler and IBM MVS systems, now applied with modern tools: Visual COBOL, GnuCOBOL, Git and GitHub.

---

## PROG0010 - Employee Listing with Page Break and Control Totals

Reads a sequential employee file and produces an 80-column paginated report with:

- Page title, run date (4-digit year) and page number on every page
- Column headings repeated on every page
- One detail line per employee, with a page break every 15 detail lines
- Control totals: employees read, employees printed, and total salary (up to 9 integer digits)
- A run summary on the console: records read, records printed, pages printed

### Input record layout - `EMPLEADOS.TXT` (50 bytes, line sequential)

| Positions | Field      | Picture | Description                |
|-----------|------------|---------|----------------------------|
| 1-5       | Number     | 9(05)   | Employee number            |
| 6-35      | Name       | X(30)   | Employee name              |
| 36        | Status     | 9(01)   | Employee status code       |
| 37-39     | Department | 9(03)   | Department code            |
| 40-41     | Position   | 9(02)   | Position code              |
| 42-50     | Salary     | 9(7)V99 | Salary, 2 implied decimals |

A sample file with 120 fictitious employees is included in this repository.

### Output - `REPORTE_MF.TXT` (80 columns, line sequential)

Paginated employee report with headings, detail lines and control totals.

### Program structure

| Paragraph                 | Purpose                                              |
|---------------------------|------------------------------------------------------|
| 0000-PRINCIPAL            | Main control                                         |
| 1000-INICIALIZAR          | Get system date, open files, print first headings    |
| 1100-IMPRIMIR-ENCABEZADOS | Count pages and print the page headings              |
| 2000-PROCESAR-EMPLEADOS   | Accumulate totals for each employee                  |
| 2100-LEER-REGISTRO        | Read next input record (read-ahead pattern)          |
| 2200-IMPRIMIR-DETALLE     | Check for page break, format and write a detail line |
| 3000-FINALIZAR            | Print control totals, close files, show run summary  |

### Test results with the sample data

| Control           | Expected value |
|-------------------|----------------|
| Employees read    | 120            |
| Employees printed | 120            |
| Pages printed     | 8              |
| Total salary      | $1,769,195.84  |

Identical results with Micro Focus Visual COBOL and GnuCOBOL.

### How to run

1. Place `EMPLEADOS.TXT` in `C:\REPOSITORIO_PROGRAMAS_GIT\PROG0010\`. The report is written to `C:\COBOL_102\ARCHIVOS_PLANOS\REPORTE_MF.TXT`. To use other locations, edit the `ASSIGN` clauses in `FILE-CONTROL`.
2. Compile and run:
   - **Visual COBOL for Eclipse:** add `PROG0010.CBL` to a COBOL project, build it, and run it as a COBOL Application.
   - **GnuCOBOL:** `cobc -x -Wall PROG0010.CBL`, then run `PROG0010.exe`.
3. The program waits for ENTER at the end, so the console summary stays visible.

> Note: data names and paragraph names are in Spanish (e.g., `EMPLEADOS` = employees, `SALARIO` = salary, `PAGINA` = page).
