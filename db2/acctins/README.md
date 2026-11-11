# ACCTINS — Db2 INSERT Tests with Embedded SQL

A COBOL program with embedded SQL that runs seven INSERT tests against a Db2 table and checks that Db2 returns the expected SQLCODE for each one. It tests the successful cases and the integrity rules that Db2 enforces: primary key, check constraints, date validation and NOT NULL.

At the end, the program rolls back all changes, so the table goes back to its starting rows and the tests can be run again and again.

## What it tests

| # | Test | What it checks | Expected SQLCODE |
|---|------|----------------|------------------|
| 1 | Complete row | Insert with every column supplied | 0 |
| 2 | Defaults used | BALANCE and STATUS left out, so their defaults apply | 0 |
| 3 | Duplicate key | Same ACCOUNT_NUMBER as test 1 (primary key) | -803 |
| 4 | Account type X | Invalid account type (check constraint CK_ACCOUNT_TYPE) | -545 |
| 5 | Negative balance | Balance below zero (check constraint CK_BALANCE) | -545 |
| 6 | Date 2025-02-30 | Invalid date in OPENING_DATE | -181 |
| 7 | Name left out | NAME is NOT NULL and has no default | -407 |

For each test, the program shows the SQLCODE and SQLSTATE returned, the expected SQLCODE, and PASS or FAIL. If any test fails, it sets RETURN-CODE to 4.

## Sample output

```
ACCTINS - DB2 INSERT TESTS ON Z79583.ACCOUNT

 #  TEST                           SQLCODE  STATE  EXPECTED  RESULT
 1  COMPLETE ROW                         0  00000         0  PASS
 2  DEFAULTS USED                        0  00000         0  PASS
 3  DUPLICATE KEY                     -803  23505      -803  PASS
 4  ACCOUNT TYPE X                    -545  23513      -545  PASS
 5  NEGATIVE BALANCE                  -545  23513      -545  PASS
 6  DATE 2025-02-30                   -181  22007      -181  PASS
 7  NAME LEFT OUT                     -407  23502      -407  PASS

ROWS BEFORE ROLLBACK:       4
ROLLBACK DONE. TABLE IS BACK TO ITS STARTING ROWS.

TESTS PASSED: 07   TESTS FAILED: 00
PRESS ENTER TO END
```

The row count of 4 is the two rows already in the table plus the two good inserts from tests 1 and 2.

## Environment

- **Compiler:** Rocket (Micro Focus) Visual COBOL 11 for Eclipse
- **Database:** IBM Db2 Community Edition (Db2 LUW) on Windows, database BANKDB
- **Table:** Z79583.ACCOUNT, part of a banking system capstone project. The DDL will be published in this repository.

## Build notes (Visual COBOL + Db2 LUW)

- The first line, `$SET DB2(DB=BANKDB)`, tells the Visual COBOL compiler to process the embedded SQL against database BANKDB.
- Build the project as a 64-bit application to match the 64-bit Db2 client.
- Link with `db2api.lib` from the Db2 installation.
- Start Db2 (`db2start`) before running the program.

## Running on Db2 for z/OS

The program is written so it can be moved to z/OS with small changes:

- Remove the `0100-CONNECT` paragraph and its PERFORM. On z/OS, the connection comes from the JCL (DSN RUN PROGRAM).
- Remove the "PRESS ENTER" ACCEPT statements, since the program runs as a batch job.
- Remove the `$SET` line, which is specific to Visual COBOL.

## Author

Lorenzo David Díaz, with help from Claude (Anthropic) as a coding and review assistant.
