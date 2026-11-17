# VSAM Exercise 3: Define and Load the ACCOUNTS KSDS

This job creates the **ACCOUNTS** key-sequenced data set (KSDS) that Exercises 5
and 8 use, and loads it with 12 test accounts. It ran on **IBM z/OS** through
IBM Z Xplore.

## Files

| File | Purpose |
|---|---|
| `ACCTLOAD.jcl` | Deletes and redefines the KSDS, sorts the input, loads it, then prints it and lists its catalog entry |
| `ACCTLOAD_output.txt` | The IDCAMS output of the load step (REPRO, PRINT, LISTCAT) from the run of November 16, 2026 |

## Record layout (61 bytes)

| Columns | Field | Notes |
|---|---|---|
| 1-10 | Account number | Primary key |
| 11-40 | Holder name | Alternate key in Exercise 8 |
| 41 | Account type | A = savings, C = checking |
| 42-52 | Balance | 9(9)V99, no decimal point |
| 53-60 | Opening date | YYYYMMDD |
| 61 | Status | A = active, B = blocked, C = closed |

## The job

| Step | Program | What it does |
|---|---|---|
| DEFINE | IDCAMS | `DELETE ... CLUSTER PURGE`, then `DEFINE CLUSTER` with `KEYS(10 0)` and `RECORDSIZE(61 61)`. `SET MAXCC = 0` lets the job run even when the cluster does not exist yet. |
| SORTACCT | SORT | Sorts the 12 input records by account number. The input is deliberately unsorted, because a KSDS must be loaded in key order. |
| LOAD | IDCAMS | `REPRO` loads the KSDS, `PRINT` lists it, `LISTCAT` shows the catalog entry. |

## Results

- REPRO: **12 records** loaded, condition code 0.
- PRINT: the 12 accounts in key order, from 1000000001 to 1000000041.
- Maximum condition code: **0**.

**A detail from the LISTCAT:** before this run, the cluster had an alternate
index and a path from Exercise 8. After the run, the cluster's ASSOCIATIONS list
only its DATA and INDEX components, and the summary shows `AIX 0, PATH 0`.
Deleting a base cluster also deletes its alternate indexes and paths; Exercise 8
rebuilds them.

## Run order for the VSAM exercises

| Order | Job | Exercise |
|---|---|---|
| 1 | `ACCTLOAD` | 3 - load the 12 original accounts |
| 2 | `ACCTUPDJ` | [5](../ex05-account-maintenance) - apply the maintenance transactions |
| 3 | `ACCTAIX` | [8](../ex08-alternate-index) - add 3 accounts, build the alternate index |
| 4 | `ACCTNAMJ` | [8](../ex08-alternate-index) - inquiry by holder name |

All four were run in this order on November 16, 2026, and every result matched
the expected values.

---

*I write and test this code myself; Claude (Anthropic's AI assistant) helps me
review it and prepare the documentation.*
