      $SET DB2(DB=BANKDB)
      *================================================================
      * PROGRAM : ACCTINS
      * PURPOSE : REPEAT THE DB2 INSERT TESTS FROM A COBOL PROGRAM
      *           WITH EMBEDDED SQL. EACH TEST SHOWS THE SQLCODE AND
      *           SQLSTATE RETURNED, THE EXPECTED SQLCODE, AND
      *           PASS/FAIL. AT THE END ALL CHANGES ARE ROLLED BACK,
      *           SO THE PROGRAM CAN BE RUN AGAIN AND AGAIN.
      * AUTHOR  : LORENZO DAVID DIAZ (WITH HELP FROM CLAUDE)
      * TABLE   : Z79583.ACCOUNT
      * NOTES   : VISUAL COBOL + DB2 LUW: $SET DB2 LINE ABOVE.
      *           DB2 LUW (COMMUNITY EDITION): KEEP THE CONNECT.
      *           DB2 FOR Z/OS: REMOVE THE CONNECT PARAGRAPH; THE
      *           CONNECTION COMES FROM THE JCL (DSN RUN PROGRAM).
      *           ALSO REMOVE THE 'PRESS ENTER' ACCEPT STATEMENTS.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTINS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *----------------------------------------------------------------
      * SQL COMMUNICATION AREA (SQLCODE, SQLSTATE, SQLERRMC)
      *----------------------------------------------------------------
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *----------------------------------------------------------------
      * HOST VARIABLES FOR TABLE Z79583.ACCOUNT
      * (ACCOUNT-STATUS INSTEAD OF STATUS: STATUS IS RESERVED IN COBOL)
      *----------------------------------------------------------------
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-ACCOUNT-NUMBER       PIC S9(10)      COMP-3.
       01  HV-NAME                 PIC X(30).
       01  HV-ACCOUNT-TYPE         PIC X(1).
       01  HV-BALANCE              PIC S9(9)V9(2)  COMP-3.
       01  HV-OPENING-DATE         PIC X(10).
       01  HV-ACCOUNT-STATUS       PIC X(1).
       01  HV-ROW-COUNT            PIC S9(9)       COMP.
           EXEC SQL END DECLARE SECTION END-EXEC.

      *----------------------------------------------------------------
      * TEST CONTROL FIELDS
      *----------------------------------------------------------------
       01  WS-TEST-NUMBER          PIC 9(2)        VALUE ZERO.
       01  WS-TEST-NAME            PIC X(30).
       01  WS-EXPECTED-SQLCODE     PIC S9(9)       COMP.
       01  WS-PASS-COUNT           PIC 9(2)        VALUE ZERO.
       01  WS-FAIL-COUNT           PIC 9(2)        VALUE ZERO.

      *----------------------------------------------------------------
      * REPORT LINE
      *----------------------------------------------------------------
       01  WS-REPORT-LINE.
           05 RPT-TEST-NUMBER      PIC Z9.
           05 FILLER               PIC X(2)   VALUE SPACES.
           05 RPT-TEST-NAME        PIC X(30).
           05 FILLER               PIC X(1)   VALUE SPACES.
           05 RPT-SQLCODE          PIC -(6)9.
           05 FILLER               PIC X(2)   VALUE SPACES.
           05 RPT-SQLSTATE         PIC X(5).
           05 FILLER               PIC X(2)   VALUE SPACES.
           05 RPT-EXPECTED         PIC -(7)9.
           05 FILLER               PIC X(2)   VALUE SPACES.
           05 RPT-RESULT           PIC X(4).

       01  WS-HEADER-1.
           05 FILLER               PIC X(35)
              VALUE ' #  TEST'.
           05 FILLER               PIC X(36)
              VALUE 'SQLCODE  STATE  EXPECTED  RESULT'.
       01  WS-ROW-COUNT-DISPLAY    PIC ZZZ,ZZ9.
       01  WS-PAUSE                PIC X.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0100-CONNECT
           DISPLAY 'ACCTINS - DB2 INSERT TESTS ON Z79583.ACCOUNT'
           DISPLAY ' '
           DISPLAY WS-HEADER-1
           PERFORM 1000-TEST-COMPLETE-ROW
           PERFORM 1100-TEST-DEFAULTS
           PERFORM 1200-TEST-DUPLICATE-KEY
           PERFORM 1300-TEST-BAD-TYPE
           PERFORM 1400-TEST-NEGATIVE-BALANCE
           PERFORM 1500-TEST-BAD-DATE
           PERFORM 1600-TEST-NAME-MISSING
           PERFORM 8000-COUNT-ROWS
           PERFORM 9000-ROLLBACK
           DISPLAY ' '
           DISPLAY 'TESTS PASSED: ' WS-PASS-COUNT
                   '   TESTS FAILED: ' WS-FAIL-COUNT
           IF WS-FAIL-COUNT > ZERO
               MOVE 4 TO RETURN-CODE
           END-IF
           DISPLAY 'PRESS ENTER TO END'
           ACCEPT WS-PAUSE
           GOBACK.

      *----------------------------------------------------------------
      * DB2 LUW ONLY. REMOVE THIS PARAGRAPH (AND ITS PERFORM) ON Z/OS.
      *----------------------------------------------------------------
       0100-CONNECT.
           EXEC SQL CONNECT TO BANKDB END-EXEC
           IF SQLCODE NOT = 0
               DISPLAY 'CONNECT FAILED. SQLCODE = ' SQLCODE
               DISPLAY 'PRESS ENTER TO END'
               ACCEPT WS-PAUSE
               MOVE 12 TO RETURN-CODE
               GOBACK
           END-IF.

      *----------------------------------------------------------------
      * TEST 1: A COMPLETE ROW. EXPECTED SQLCODE 0.
      *  (NEW ACCOUNT NUMBERS 2000000001/2, SO THE TWO ROWS 
      *  ALREADY IN THE TABLE, 1000000001/2, ARE NOT DISTURBED.)
      * ---------------------------------------------------------------
       1000-TEST-COMPLETE-ROW.
           MOVE 'COMPLETE ROW'          TO WS-TEST-NAME
           MOVE 0                       TO WS-EXPECTED-SQLCODE
           MOVE 2000000001              TO HV-ACCOUNT-NUMBER
           MOVE 'CARLOS RUIZ'           TO HV-NAME
           MOVE 'S'                     TO HV-ACCOUNT-TYPE
           MOVE 2500.75                 TO HV-BALANCE
           MOVE '2024-06-01'            TO HV-OPENING-DATE
           MOVE 'A'                     TO HV-ACCOUNT-STATUS
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE,
                  BALANCE, OPENING_DATE, STATUS)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-BALANCE, :HV-OPENING-DATE,
                       :HV-ACCOUNT-STATUS)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 2: LEAVE OUT BALANCE AND STATUS. DEFAULTS ARE USED.
      *----------------------------------------------------------------
       1100-TEST-DEFAULTS.
           MOVE 'DEFAULTS USED'         TO WS-TEST-NAME
           MOVE 0                       TO WS-EXPECTED-SQLCODE
           MOVE 2000000002              TO HV-ACCOUNT-NUMBER
           MOVE 'ELENA SOTO'            TO HV-NAME
           MOVE 'C'                     TO HV-ACCOUNT-TYPE
           MOVE '2025-04-20'            TO HV-OPENING-DATE
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE, OPENING_DATE)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-OPENING-DATE)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 3: SAME ACCOUNT NUMBER AS TEST 1. EXPECTED -803.
      *----------------------------------------------------------------
       1200-TEST-DUPLICATE-KEY.
           MOVE 'DUPLICATE KEY'         TO WS-TEST-NAME
           MOVE -803                    TO WS-EXPECTED-SQLCODE
           MOVE 2000000001              TO HV-ACCOUNT-NUMBER
           MOVE 'CARLOS RUIZ'           TO HV-NAME
           MOVE 'S'                     TO HV-ACCOUNT-TYPE
           MOVE 2500.75                 TO HV-BALANCE
           MOVE '2024-06-01'            TO HV-OPENING-DATE
           MOVE 'A'                     TO HV-ACCOUNT-STATUS
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE,
                  BALANCE, OPENING_DATE, STATUS)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-BALANCE, :HV-OPENING-DATE,
                       :HV-ACCOUNT-STATUS)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 4: ACCOUNT TYPE 'X'. EXPECTED -545 (CK_ACCOUNT_TYPE).
      *----------------------------------------------------------------
       1300-TEST-BAD-TYPE.
           MOVE 'ACCOUNT TYPE X'        TO WS-TEST-NAME
           MOVE -545                    TO WS-EXPECTED-SQLCODE
           MOVE 2000000003              TO HV-ACCOUNT-NUMBER
           MOVE 'ANA TORRES'            TO HV-NAME
           MOVE 'X'                     TO HV-ACCOUNT-TYPE
           MOVE '2025-02-01'            TO HV-OPENING-DATE
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE, OPENING_DATE)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-OPENING-DATE)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 5: NEGATIVE BALANCE. EXPECTED -545 (CK_BALANCE).
      *----------------------------------------------------------------
       1400-TEST-NEGATIVE-BALANCE.
           MOVE 'NEGATIVE BALANCE'      TO WS-TEST-NAME
           MOVE -545                    TO WS-EXPECTED-SQLCODE
           MOVE 2000000004              TO HV-ACCOUNT-NUMBER
           MOVE 'LUIS RAMOS'            TO HV-NAME
           MOVE 'S'                     TO HV-ACCOUNT-TYPE
           MOVE -50.00                  TO HV-BALANCE
           MOVE '2025-03-01'            TO HV-OPENING-DATE
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE,
                  BALANCE, OPENING_DATE)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-BALANCE, :HV-OPENING-DATE)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 6: FEBRUARY 30. EXPECTED -181.
      *----------------------------------------------------------------
       1500-TEST-BAD-DATE.
           MOVE 'DATE 2025-02-30'       TO WS-TEST-NAME
           MOVE -181                    TO WS-EXPECTED-SQLCODE
           MOVE 2000000005              TO HV-ACCOUNT-NUMBER
           MOVE 'ROSA MENDEZ'           TO HV-NAME
           MOVE 'C'                     TO HV-ACCOUNT-TYPE
           MOVE '2025-02-30'            TO HV-OPENING-DATE
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, NAME, ACCOUNT_TYPE, OPENING_DATE)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-NAME, :HV-ACCOUNT-TYPE,
                       :HV-OPENING-DATE)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * TEST 7: NAME LEFT OUT (NOT NULL, NO DEFAULT). EXPECTED -407.
      *----------------------------------------------------------------
       1600-TEST-NAME-MISSING.
           MOVE 'NAME LEFT OUT'         TO WS-TEST-NAME
           MOVE -407                    TO WS-EXPECTED-SQLCODE
           MOVE 2000000006              TO HV-ACCOUNT-NUMBER
           MOVE 'S'                     TO HV-ACCOUNT-TYPE
           MOVE '2025-01-10'            TO HV-OPENING-DATE
           EXEC SQL
               INSERT INTO Z79583.ACCOUNT
                 (ACCOUNT_NUMBER, ACCOUNT_TYPE, OPENING_DATE)
               VALUES (:HV-ACCOUNT-NUMBER, :HV-ACCOUNT-TYPE,
                       :HV-OPENING-DATE)
           END-EXEC
           PERFORM 7000-CHECK-RESULT.

      *----------------------------------------------------------------
      * COMPARE THE SQLCODE RECEIVED WITH THE SQLCODE EXPECTED
      *----------------------------------------------------------------
       7000-CHECK-RESULT.
           ADD 1                        TO WS-TEST-NUMBER
           MOVE WS-TEST-NUMBER          TO RPT-TEST-NUMBER
           MOVE WS-TEST-NAME            TO RPT-TEST-NAME
           MOVE SQLCODE                 TO RPT-SQLCODE
           MOVE SQLSTATE                TO RPT-SQLSTATE
           MOVE WS-EXPECTED-SQLCODE     TO RPT-EXPECTED
           IF SQLCODE = WS-EXPECTED-SQLCODE
               MOVE 'PASS'              TO RPT-RESULT
               ADD 1                    TO WS-PASS-COUNT
           ELSE
               MOVE 'FAIL'              TO RPT-RESULT
               ADD 1                    TO WS-FAIL-COUNT
           END-IF
           DISPLAY WS-REPORT-LINE.

      *----------------------------------------------------------------
      * ROWS IN THE TABLE BEFORE THE ROLLBACK (EXPECTED: 2 + 2 = 4)
      *----------------------------------------------------------------
       8000-COUNT-ROWS.
           EXEC SQL
               SELECT COUNT(*)
                 INTO :HV-ROW-COUNT
                 FROM Z79583.ACCOUNT
           END-EXEC
           MOVE HV-ROW-COUNT            TO WS-ROW-COUNT-DISPLAY
           DISPLAY ' '
           DISPLAY 'ROWS BEFORE ROLLBACK: ' WS-ROW-COUNT-DISPLAY.

      *----------------------------------------------------------------
      * UNDO THE TWO GOOD INSERTS, SO THE TEST CAN BE REPEATED
      *----------------------------------------------------------------
       9000-ROLLBACK.
           EXEC SQL ROLLBACK END-EXEC
           DISPLAY 'ROLLBACK DONE. TABLE IS BACK TO ITS STARTING ROWS.'.
