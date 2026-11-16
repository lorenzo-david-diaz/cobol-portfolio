       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTUPD.
      *-----------------------------------------------------------
      * PROGRAM : ACCTUPD
      * PURPOSE : ACCOUNT MAINTENANCE. APPLIES A TRANSACTION FILE
      *           TO THE ACCOUNTS KSDS WITH RANDOM ACCESS:
      *             ADD - NEW ACCOUNT          (WRITE)
      *             DEP - DEPOSIT              (READ + REWRITE)
      *             WDR - WITHDRAWAL           (READ + REWRITE)
      *             STS - CHANGE STATUS A/B/C  (READ + REWRITE)
      *             DEL - DELETE ACCOUNT       (READ + DELETE)
      *           EVERY TRANSACTION IS VALIDATED. REJECTED ONES
      *           ARE REPORTED AND THE RUN ENDS WITH RC 4.
      *           VSAM PRACTICE PLAN - EXERCISE 5.
      * INPUT   : DD TRANIN   -> TRANSACTIONS, 80-BYTE RECORDS
      * I-O     : DD ACCTFILE -> Z79583.MY.ACCOUNTS.KSDS
      * OUTPUT  : DD SYSOUT   -> TRANSACTION LOG (DISPLAY)
      * AUTHOR  : LORENZO DAVID DIAZ
      * DATE    : 2026-10-19
      *-----------------------------------------------------------
      * TRANSACTION LAYOUT (80 BYTES):
      *   1-3   CODE: ADD, DEP, WDR, STS, DEL
      *   4-13  ACCOUNT NUMBER (ALL CODES)
      *   ADD : 4-64  FULL 61-BYTE ACCOUNT RECORD
      *   DEP/WDR : 14-24 AMOUNT 9(9)V99 (NO DECIMAL POINT)
      *   STS : 25    NEW STATUS A/B/C
      *-----------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRAN-FILE ASSIGN TO TRANIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS  IS WS-TRAN-STATUS.
      *    KSDS OPENED I-O: READ, WRITE, REWRITE AND DELETE.
           SELECT ACCOUNT-FILE ASSIGN TO ACCTFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS ACCT-NUMBER
               FILE STATUS  IS WS-ACCT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  TRAN-FILE
           RECORDING MODE IS F.
       01  TRAN-RECORD.
           05  TRAN-CODE               PIC X(03).
               88  TRAN-ADD            VALUE 'ADD'.
               88  TRAN-DEPOSIT        VALUE 'DEP'.
               88  TRAN-WITHDRAWAL     VALUE 'WDR'.
               88  TRAN-STATUS-CHANGE  VALUE 'STS'.
               88  TRAN-DELETE         VALUE 'DEL'.
           05  TRAN-DATA               PIC X(77).
           05  TRAN-ADD-DATA REDEFINES TRAN-DATA.
               10  TRAN-NEW-ACCOUNT    PIC X(61).
               10  FILLER              PIC X(16).
           05  TRAN-MNT-DATA REDEFINES TRAN-DATA.
               10  TRAN-ACCOUNT        PIC X(10).
               10  TRAN-AMOUNT-X       PIC X(11).
               10  TRAN-AMOUNT REDEFINES TRAN-AMOUNT-X
                                       PIC 9(09)V99.
               10  TRAN-NEW-STATUS     PIC X(01).
               10  FILLER              PIC X(55).

       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  ACCT-NUMBER             PIC 9(10).
           05  ACCT-HOLDER-NAME        PIC X(30).
           05  ACCT-TYPE               PIC X(01).
               88  ACCT-TYPE-VALID     VALUE 'A' 'C'.
           05  ACCT-BALANCE            PIC 9(09)V99.
           05  ACCT-OPEN-DATE          PIC 9(08).
           05  ACCT-STATUS             PIC X(01).
               88  ACCT-ACTIVE         VALUE 'A'.
               88  ACCT-BLOCKED        VALUE 'B'.
               88  ACCT-CLOSED         VALUE 'C'.
               88  ACCT-STATUS-VALID   VALUE 'A' 'B' 'C'.

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05  WS-TRAN-STATUS          PIC X(02).
               88  TRAN-OK             VALUE '00'.
               88  TRAN-EOF            VALUE '10'.
           05  WS-ACCT-STATUS          PIC X(02).
               88  ACCT-OK             VALUE '00'.
               88  ACCT-DUPLICATE      VALUE '22'.
               88  ACCT-NOT-FOUND      VALUE '23'.

       01  WS-COUNTERS.
           05  WS-TRAN-COUNT           PIC 9(05) VALUE ZERO.
           05  WS-ADDED                PIC 9(05) VALUE ZERO.
           05  WS-UPDATED              PIC 9(05) VALUE ZERO.
           05  WS-DELETED              PIC 9(05) VALUE ZERO.
           05  WS-REJECTED             PIC 9(05) VALUE ZERO.

       01  WS-WORK-FIELDS.
           05  WS-TRAN-NUM-OUT         PIC ZZZZ9.
           05  WS-AMOUNT-OUT           PIC ZZZ,ZZZ,ZZ9.99.
           05  WS-BALANCE-OUT          PIC ZZZ,ZZZ,ZZ9.99.
           05  WS-COUNT-OUT            PIC ZZ,ZZ9.
           05  WS-RESULT               PIC X(60).
           05  WS-REJECT-SWITCH        PIC X(01).
               88  TRAN-REJECTED       VALUE 'Y'.
               88  TRAN-ACCEPTED       VALUE 'N'.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-TRANSACTION
               UNTIL TRAN-EOF
           PERFORM 9000-FINALIZE
           STOP RUN.

      *-----------------------------------------------------------
      * OPEN FILES AND READ THE FIRST TRANSACTION
      *-----------------------------------------------------------
       1000-INITIALIZE.
           OPEN INPUT TRAN-FILE
           IF NOT TRAN-OK
               DISPLAY 'ACCTUPD: OPEN ERROR ON TRANIN, STATUS '
                       WS-TRAN-STATUS
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF
           OPEN I-O ACCOUNT-FILE
           IF NOT ACCT-OK
               DISPLAY 'ACCTUPD: OPEN ERROR ON ACCTFILE, STATUS '
                       WS-ACCT-STATUS
               CLOSE TRAN-FILE
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF
           DISPLAY 'ACCTUPD - ACCOUNT MAINTENANCE LOG'
           DISPLAY '------------------------------------------------'
                   '----------------------'
           PERFORM 8000-READ-TRANSACTION.

      *-----------------------------------------------------------
      * VALIDATE AND APPLY ONE TRANSACTION
      *-----------------------------------------------------------
       2000-PROCESS-TRANSACTION.
           ADD 1 TO WS-TRAN-COUNT
           SET TRAN-ACCEPTED TO TRUE
           MOVE SPACES TO WS-RESULT
           EVALUATE TRUE
               WHEN TRAN-ACCOUNT NOT NUMERIC
                   MOVE 'REJECTED: INVALID ACCOUNT NUMBER'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN TRAN-ADD
                   PERFORM 3000-ADD-ACCOUNT
               WHEN TRAN-DEPOSIT
                   PERFORM 4000-DEPOSIT
               WHEN TRAN-WITHDRAWAL
                   PERFORM 5000-WITHDRAWAL
               WHEN TRAN-STATUS-CHANGE
                   PERFORM 6000-CHANGE-STATUS
               WHEN TRAN-DELETE
                   PERFORM 7000-DELETE-ACCOUNT
               WHEN OTHER
                   MOVE 'REJECTED: INVALID TRANSACTION CODE'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
           END-EVALUATE
           IF TRAN-REJECTED
               ADD 1 TO WS-REJECTED
           END-IF
           MOVE WS-TRAN-COUNT TO WS-TRAN-NUM-OUT
           DISPLAY 'TRAN ' WS-TRAN-NUM-OUT ' ' TRAN-CODE ' '
                   TRAN-ACCOUNT ' ' WS-RESULT
           PERFORM 8000-READ-TRANSACTION.

      *-----------------------------------------------------------
      * ADD: VALIDATE THE NEW RECORD, THEN WRITE IT.
      * FILE STATUS 22 = THE KEY ALREADY EXISTS IN THE KSDS.
      *-----------------------------------------------------------
       3000-ADD-ACCOUNT.
           MOVE TRAN-NEW-ACCOUNT TO ACCOUNT-RECORD
           EVALUATE TRUE
               WHEN NOT ACCT-TYPE-VALID
                   MOVE 'REJECTED: ACCOUNT TYPE MUST BE A OR C'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN ACCT-BALANCE NOT NUMERIC
                   MOVE 'REJECTED: OPENING BALANCE NOT NUMERIC'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN NOT ACCT-STATUS-VALID
                   MOVE 'REJECTED: STATUS MUST BE A, B OR C'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN OTHER
                   WRITE ACCOUNT-RECORD
                   EVALUATE TRUE
                       WHEN ACCT-OK
                           ADD 1 TO WS-ADDED
                           MOVE ACCT-BALANCE TO WS-BALANCE-OUT
                           STRING 'ADDED, BALANCE ' WS-BALANCE-OUT
                               DELIMITED BY SIZE INTO WS-RESULT
                       WHEN ACCT-DUPLICATE
                           MOVE 'REJECTED: DUPLICATE KEY (STATUS 22)'
                             TO WS-RESULT
                           SET TRAN-REJECTED TO TRUE
                       WHEN OTHER
                           PERFORM 9900-IO-ERROR
                   END-EVALUATE
           END-EVALUATE.

      *-----------------------------------------------------------
      * DEPOSIT: ONLY ON ACTIVE ACCOUNTS, AMOUNT > ZERO.
      *-----------------------------------------------------------
       4000-DEPOSIT.
           PERFORM 3500-VALIDATE-AMOUNT
           IF TRAN-ACCEPTED
               PERFORM 8100-READ-ACCOUNT
           END-IF
           IF TRAN-ACCEPTED
               PERFORM 3600-CHECK-ACTIVE
           END-IF
           IF TRAN-ACCEPTED
               ADD TRAN-AMOUNT TO ACCT-BALANCE
               PERFORM 8200-REWRITE-ACCOUNT
               MOVE ACCT-BALANCE TO WS-BALANCE-OUT
               STRING 'DEPOSIT APPLIED, NEW BALANCE '
                      WS-BALANCE-OUT
                   DELIMITED BY SIZE INTO WS-RESULT
           END-IF.

      *-----------------------------------------------------------
      * WITHDRAWAL: ONLY ON ACTIVE ACCOUNTS, NO OVERDRAFT.
      *-----------------------------------------------------------
       5000-WITHDRAWAL.
           PERFORM 3500-VALIDATE-AMOUNT
           IF TRAN-ACCEPTED
               PERFORM 8100-READ-ACCOUNT
           END-IF
           IF TRAN-ACCEPTED
               PERFORM 3600-CHECK-ACTIVE
           END-IF
           IF TRAN-ACCEPTED
               IF TRAN-AMOUNT > ACCT-BALANCE
                   MOVE ACCT-BALANCE TO WS-BALANCE-OUT
                   STRING 'REJECTED: INSUFFICIENT FUNDS, BALANCE '
                          WS-BALANCE-OUT
                       DELIMITED BY SIZE INTO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               ELSE
                   SUBTRACT TRAN-AMOUNT FROM ACCT-BALANCE
                   PERFORM 8200-REWRITE-ACCOUNT
                   MOVE ACCT-BALANCE TO WS-BALANCE-OUT
                   STRING 'WITHDRAWAL APPLIED, NEW BALANCE '
                          WS-BALANCE-OUT
                       DELIMITED BY SIZE INTO WS-RESULT
               END-IF
           END-IF.

      *-----------------------------------------------------------
      * STATUS CHANGE: NEW STATUS MUST BE A, B OR C.
      *-----------------------------------------------------------
       6000-CHANGE-STATUS.
           IF TRAN-NEW-STATUS NOT = 'A' AND 'B' AND 'C'
               MOVE 'REJECTED: NEW STATUS MUST BE A, B OR C'
                 TO WS-RESULT
               SET TRAN-REJECTED TO TRUE
           ELSE
               PERFORM 8100-READ-ACCOUNT
           END-IF
           IF TRAN-ACCEPTED
               STRING 'STATUS CHANGED FROM ' ACCT-STATUS
                      ' TO ' TRAN-NEW-STATUS
                   DELIMITED BY SIZE INTO WS-RESULT
               MOVE TRAN-NEW-STATUS TO ACCT-STATUS
               PERFORM 8200-REWRITE-ACCOUNT
           END-IF.

      *-----------------------------------------------------------
      * DELETE: ONLY WHEN THE BALANCE IS ZERO.
      *-----------------------------------------------------------
       7000-DELETE-ACCOUNT.
           PERFORM 8100-READ-ACCOUNT
           IF TRAN-ACCEPTED
               IF ACCT-BALANCE NOT = ZERO
                   MOVE ACCT-BALANCE TO WS-BALANCE-OUT
                   STRING 'REJECTED: BALANCE NOT ZERO '
                          WS-BALANCE-OUT
                       DELIMITED BY SIZE INTO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               ELSE
                   DELETE ACCOUNT-FILE RECORD
                   IF ACCT-OK
                       ADD 1 TO WS-DELETED
                       MOVE 'ACCOUNT DELETED' TO WS-RESULT
                   ELSE
                       PERFORM 9900-IO-ERROR
                   END-IF
               END-IF
           END-IF.

      *-----------------------------------------------------------
      * COMMON CHECKS
      *-----------------------------------------------------------
       3500-VALIDATE-AMOUNT.
           IF TRAN-AMOUNT-X NOT NUMERIC
               MOVE 'REJECTED: AMOUNT NOT NUMERIC' TO WS-RESULT
               SET TRAN-REJECTED TO TRUE
           ELSE
               IF TRAN-AMOUNT = ZERO
                   MOVE 'REJECTED: AMOUNT MUST BE GREATER THAN ZERO'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               END-IF
           END-IF.

       3600-CHECK-ACTIVE.
           EVALUATE TRUE
               WHEN ACCT-BLOCKED
                   MOVE 'REJECTED: ACCOUNT IS BLOCKED' TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN ACCT-CLOSED
                   MOVE 'REJECTED: ACCOUNT IS CLOSED' TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
           END-EVALUATE.

      *-----------------------------------------------------------
      * I/O ROUTINES
      *-----------------------------------------------------------
       8000-READ-TRANSACTION.
           READ TRAN-FILE
           IF NOT TRAN-OK AND NOT TRAN-EOF
               DISPLAY 'ACCTUPD: READ ERROR ON TRANIN, STATUS '
                       WS-TRAN-STATUS
               PERFORM 9900-IO-ERROR
           END-IF.

      *    RANDOM READ BY KEY. STATUS 23 = ACCOUNT NOT FOUND.
       8100-READ-ACCOUNT.
           MOVE TRAN-ACCOUNT TO ACCT-NUMBER
           READ ACCOUNT-FILE
           EVALUATE TRUE
               WHEN ACCT-OK
                   CONTINUE
               WHEN ACCT-NOT-FOUND
                   MOVE 'REJECTED: ACCOUNT NOT FOUND (STATUS 23)'
                     TO WS-RESULT
                   SET TRAN-REJECTED TO TRUE
               WHEN OTHER
                   PERFORM 9900-IO-ERROR
           END-EVALUATE.

      *    REWRITE REPLACES THE RECORD JUST READ. THE KEY MUST NOT
      *    CHANGE: A KSDS NEVER LETS YOU REWRITE THE PRIME KEY.
       8200-REWRITE-ACCOUNT.
           REWRITE ACCOUNT-RECORD
           IF ACCT-OK
               ADD 1 TO WS-UPDATED
           ELSE
               PERFORM 9900-IO-ERROR
           END-IF.

      *-----------------------------------------------------------
      * TOTALS, CLOSE AND RETURN CODE
      *-----------------------------------------------------------
       9000-FINALIZE.
           CLOSE TRAN-FILE ACCOUNT-FILE
           DISPLAY '------------------------------------------------'
                   '----------------------'
           MOVE WS-TRAN-COUNT TO WS-COUNT-OUT
           DISPLAY 'TRANSACTIONS READ  : ' WS-COUNT-OUT
           MOVE WS-ADDED TO WS-COUNT-OUT
           DISPLAY 'ACCOUNTS ADDED     : ' WS-COUNT-OUT
           MOVE WS-UPDATED TO WS-COUNT-OUT
           DISPLAY 'ACCOUNTS UPDATED   : ' WS-COUNT-OUT
           MOVE WS-DELETED TO WS-COUNT-OUT
           DISPLAY 'ACCOUNTS DELETED   : ' WS-COUNT-OUT
           MOVE WS-REJECTED TO WS-COUNT-OUT
           DISPLAY 'REJECTED           : ' WS-COUNT-OUT
           IF WS-REJECTED > ZERO
               MOVE 4 TO RETURN-CODE
           ELSE
               MOVE 0 TO RETURN-CODE
           END-IF.

      *    UNEXPECTED VSAM STATUS: STOP AT ONCE WITH RC 16.
       9900-IO-ERROR.
           DISPLAY 'ACCTUPD: UNEXPECTED I/O ERROR. TRAN '
                   WS-TRAN-COUNT ' ACCTFILE STATUS ' WS-ACCT-STATUS
           CLOSE TRAN-FILE ACCOUNT-FILE
           MOVE 16 TO RETURN-CODE
           STOP RUN.
