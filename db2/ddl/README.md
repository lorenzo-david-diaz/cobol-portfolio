# ACCOUNT table DDL

This folder holds the DDL that creates the **ACCOUNT** table for my banking
capstone project. The table is defined three times, once for each SQL
environment I practice in, so the same design can be compared side by side.

| Script | Environment | How to run it |
|---|---|---|
| `account_postgresql.sql` | PostgreSQL | `psql -d <database> -f account_postgresql.sql` |
| `account_db2luw.sql` | Db2 Community Edition (Db2 for Linux, UNIX and Windows) | `db2 -tvf account_db2luw.sql` in a Db2 Command Window |
| `account_db2zos.sql` | Db2 for z/OS | SPUFI or DSNTEP2 (text kept in columns 1-72) |

## Table design

All three scripts create the same table, `Z79583.ACCOUNT`:

| Column | SQL type | COBOL host variable | Rule |
|---|---|---|---|
| ACCOUNT_NUMBER | DECIMAL(10,0) | PIC S9(10) COMP-3 | Primary key |
| NAME | CHAR(30) | PIC X(30) | Required |
| ACCOUNT_TYPE | CHAR(1) | PIC X(01) | S = savings, C = checking |
| BALANCE | DECIMAL(11,2) | PIC S9(9)V99 COMP-3 | Default 0, cannot be negative |
| OPENING_DATE | DATE | PIC X(10) | Format YYYY-MM-DD |
| STATUS | CHAR(1) | PIC X(01) | A, B or C; default A |

Every column is NOT NULL, so COBOL programs that use the table need no null
indicators.

## Differences between the environments

| Topic | PostgreSQL | Db2 LUW | Db2 for z/OS |
|---|---|---|---|
| Schema | `CREATE SCHEMA IF NOT EXISTS` | `CREATE SCHEMA` | Implicit: created when the table name is qualified |
| Column default | `DEFAULT` | `DEFAULT` | `WITH DEFAULT` |
| Storage | Automatic | Automatic table spaces | Implicit database and table space (Option A), or explicit ones (Option B, commented in the script) |
| Verification | `\d z79583.account` | `DESCRIBE TABLE` | `SELECT` from `SYSIBM.SYSCOLUMNS` |

The PostgreSQL and Db2 LUW scripts have been run successfully on my PC. The
z/OS script is written for SPUFI and is kept ready for a z/OS Db2 system.

## Related work

- [`../acctins`](../acctins) - COBOL program with embedded SQL that tests
  INSERT statements against this table.

---

*I write and test this code myself; Claude (Anthropic's AI assistant) helps
me review it and prepare the documentation.*
