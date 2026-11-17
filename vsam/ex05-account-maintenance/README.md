# VSAM Exercise 5: Account Maintenance (KSDS Random Access)

A COBOL program that applies a file of transactions to the ACCOUNTS KSDS from
[Exercise 3](../ex03-ksds-load), using random access by key. It ran on
**IBM z/OS** (Enterprise COBOL) through IBM Z Xplore.

## Files

| File | Purpose |
|---|---|
| `ACCTUPD.cbl` | The maintenance program |
| `ACCTUPDJ.jcl` | Backs up the KSDS, compiles and links ACCTUPD, runs it with 12 test transactions, and prints the KSDS afterwards |
| `ACCTUPDJ_output.txt` | The transaction log from the run of November 16, 2026 |

## Transactions

| Code | Action | VSAM operation | Business rules |
|---|---|---|---|
| ADD | New account | `WRITE` | Type A or C, numeric balance, status A/B/C; status 22 = duplicate key |
| DEP | Deposit | `READ` + `REWRITE` | Amount > 0; account must be active |
| WDR | Withdrawal | `READ` + `REWRITE` | Amount > 0; account must be active; no overdraft |
| STS | Change status | `READ` + `REWRITE` | New status A, B or C |
| DEL | Delete account | `READ` + `DELETE` | Only when the balance is zero |

Every transaction is validated before the file is touched. Rejected
transactions are logged, and the run ends with RC 4. An unexpected VSAM file
status stops the run at once with RC 16.

## Results (run of November 16, 2026, after reloading with Exercise 3)

| # | Code | Account | Result |
|---|---|---|---|
| 1 | ADD | 1000000045 | Added, balance 5,000.00 |
| 2 | ADD | 1000000013 | Rejected: duplicate key (status 22) |
| 3 | DEP | 1000000001 | Applied: 30,000.00 + 2,500.00 = 32,500.00 |
| 4 | WDR | 1000000017 | Applied: 12,540.75 - 540.75 = 12,000.00 |
| 5 | WDR | 1000000025 | Rejected: account is blocked |
| 6 | WDR | 1000000037 | Rejected: insufficient funds (balance 5,123.45) |
| 7 | DEP | 1000000099 | Rejected: account not found (status 23) |
| 8 | STS | 1000000025 | Status changed from B to A |
| 9 | WDR | 1000000025 | Applied: 980.50 - 50.00 = 930.50 |
| 10 | DEL | 1000000033 | Deleted (balance was zero) |
| 11 | DEL | 1000000041 | Rejected: balance not zero (150,000.00) |
| 12 | XYZ | 1000000005 | Rejected: invalid transaction code |

**Totals:** 12 read, 1 added, 4 updated, 1 deleted, 6 rejected. RUN step
condition code **0004**, as expected. Every line matched the values predicted
before the run.

Transactions 5, 8 and 9 show why the order of transactions matters: the same
withdrawal on account 1000000025 is rejected while the account is blocked, and
accepted after its status changes to active.

## Compiler messages

The compile step ends with condition code 0004. The listing explains why:

- **IGYCB7310-W** - "The PERFORM statement cannot reach its exit." Each
  `PERFORM 9900-IO-ERROR` goes to a paragraph that ends with `STOP RUN`, so
  control never returns. This is by design: an unexpected I/O error stops the
  run immediately.
- **IGYGR1130-I** (information only) - the record key `ACCT-NUMBER` is defined
  as `PIC 9(10)`; the compiler treats it as alphanumeric for file operations.
  Defining it as `PIC X(10)` would remove the message.

---

*I write and test this code myself; Claude (Anthropic's AI assistant) helps me
review it and prepare the documentation.*
