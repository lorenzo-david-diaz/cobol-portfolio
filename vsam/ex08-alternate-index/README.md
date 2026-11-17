# VSAM Exercise 8: Alternate Index by Holder Name

This exercise adds a **non-unique alternate index (AIX)** to the ACCOUNTS KSDS
from [Exercise 3](../ex03-ksds-load). A COBOL program uses it to find every
account that belongs to a holder, and to list all accounts in name order. It ran
on **IBM z/OS** (Enterprise COBOL) through IBM Z Xplore.

## Files

| File | Purpose |
|---|---|
| `ACCTAIX.jcl` | Adds 3 accounts that repeat existing holder names, defines the AIX and the PATH, builds the AIX with BLDINDEX, and checks it with PRINT and LISTCAT |
| `ACCTAIX_output.txt` | The PRINT through the path and the LISTCAT, from the run of November 16, 2026 |
| `ACCTNAME.cbl` | COBOL program that reads the KSDS through the alternate key |
| `ACCTNAMJ.jcl` | Compiles and links ACCTNAME, then runs it with six test inquiries |
| `ACCTNAMJ_output.txt` | The program's output from the same run |

## The alternate index

| Item | Value |
|---|---|
| Base cluster | `Z79583.MY.ACCOUNTS.KSDS` (61-byte records, key = account number) |
| Alternate key | Holder name, columns 11-40: `KEYS(30 10)` |
| Key type | `NONUNIQUEKEY` - one holder can own several accounts |
| Maintenance | `UPGRADE` - VSAM keeps the AIX current when the base cluster changes |
| Record size | `RECORDSIZE(45 135)` = 5 + 30 + (10 x accounts per name), for 1 to 10 accounts |
| Path | `Z79583.MY.ACCOUNTS.PATH` |

## The program

```cobol
           SELECT ACCOUNT-FILE
               ASSIGN TO ACCTFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS ACCT-NUMBER
               ALTERNATE RECORD KEY IS ACCT-HOLDER
                   WITH DUPLICATES
               FILE STATUS IS WS-FILE-STATUS.
```

- **Part 1, inquiry by name:** `START ... KEY IS EQUAL TO ACCT-HOLDER`, then
  `READ NEXT` until the name changes.
- **Part 2, list by name:** `START ... KEY IS NOT LESS THAN` with LOW-VALUES,
  then `READ NEXT` to the end.

The path's DD name is the base DD name plus the digit 1, for the first
alternate key. `ACCTFILE` already has 8 characters, so its last character is
dropped: `ACCTFIL1`.

## Results (run of November 16, 2026)

ACCTAIX ended with condition code 0000 in all four steps. ACCTNAMJ:

| Inquiry | Accounts | File status per read |
|---|---|---|
| DIAZ MENDOZA, LUISA | 3 (one blocked) | **02, 02, 00** |
| RAMIREZ SILVA, ELENA | 2 | **02, 00** |
| BRICENO LUGO, CARMEN | 1 | 00 |
| SALAZAR PINTO, RAFAEL | 1 | 00 |
| LOPEZ GARCIA, PEDRO | not found | 23 |
| (blank line) | skipped | - |

**Totals:** 6 inquiries, 4 found, 1 not found, 1 blank; **15 accounts** listed
in holder-name order. Condition code **0004**, as expected.

**File status 02 on z/OS** means another record with the same alternate key
follows; the last record for that key returns 00. The program also compares the
name on each read, so it does not depend on 02 alone (GnuCOBOL, for example,
returns 00 for every duplicate).

**The run also shows Exercise 5's changes:** account 1000000001 has 32,500.00
after the deposit, the added account 1000000045 appears, the deleted account
1000000033 does not, and Salazar Pinto, Rafael is now **active**. (The test-case
comment in `ACCTNAMJ.jcl` still describes him as blocked, from before Exercise 5
changed his status.)

**Compiler message:** the compile step ends with 0004 because of
**IGYCB7310-W**: the fatal-error paragraph ends with `STOP RUN`, so its PERFORM
never returns. This is by design.

---

*I write and test this code myself; Claude (Anthropic's AI assistant) helps me
review it and prepare the documentation.*
