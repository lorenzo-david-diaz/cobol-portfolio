       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTNAME.
      *-----------------------------------------------------------
      * VSAM EXERCISE 8 - ACCOUNT INQUIRY BY HOLDER NAME
      * READS Z79583.MY.ACCOUNTS.KSDS THROUGH ITS ALTERNATE INDEX
      * (HOLDER NAME, NON-UNIQUE).
      *
      * PART 1: FOR EACH NAME IN INQIN, START ON THE ALTERNATE
      *         KEY AND READ NEXT UNTIL THE NAME CHANGES. EACH LINE
      *         SHOWS THE FILE STATUS: 02 = MORE ACCOUNTS WITH THE
      *         SAME NAME FOLLOW, 00 = LAST ONE FOR THAT NAME.
      * PART 2: LIST ALL ACCOUNTS IN HOLDER-NAME ORDER.
      *
      * JCL DD NAMES:
      *   ACCTFILE - BASE CLUSTER
      *   ACCTFIL1 - PATH FOR THE FIRST ALTERNATE RECORD KEY
      *              (ACCTFILE HAS 8 CHARACTERS, SO THE LAST ONE
      *              IS DROPPED AND THE DIGIT 1 IS ADDED)
      *   INQIN    - NAMES TO LOOK UP, COLUMNS 1-30
      *-----------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO ACCTFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS ACCT-NUMBER
               ALTERNATE RECORD KEY IS ACCT-HOLDER
                   WITH DUPLICATES
               FILE STATUS IS WS-FILE-STATUS.

           SELECT INQUIRY-FILE
               ASSIGN TO INQIN
               FILE STATUS IS WS-INQ-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  ACCT-NUMBER             PIC X(10).
           05  ACCT-HOLDER             PIC X(30).
           05  ACCT-TYPE               PIC X(01).
           05  ACCT-BALANCE            PIC 9(09)V99.
           05  ACCT-OPEN-DATE          PIC 9(08).
           05  ACCT-STATUS             PIC X(01).

       FD  INQUIRY-FILE
           RECORDING MODE IS F.
       01  INQUIRY-RECORD.
           05  INQ-HOLDER              PIC X(30).
           05  FILLER                  PIC X(50).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS              PIC X(02).
           88  FS-OK                   VALUE '00'.
           88  FS-DUPLICATE-FOLLOWS    VALUE '02'.
           88  FS-END-OF-FILE          VALUE '10'.
           88  FS-NOT-FOUND            VALUE '23'.
       01  WS-INQ-STATUS               PIC X(02).
           88  INQ-END-OF-FILE         VALUE '10'.

       01  WS-SEARCH-NAME              PIC X(30).
       01  WS-MORE-FOR-NAME            PIC X(01).
           88  MORE-FOR-NAME           VALUE 'Y'.
           88  NO-MORE-FOR-NAME        VALUE 'N'.

       01  WS-COUNTERS.
           05  WS-INQUIRIES            PIC 9(05) VALUE ZERO.
           05  WS-NAMES-FOUND          PIC 9(05) VALUE ZERO.
           05  WS-NAMES-NOT-FOUND      PIC 9(05) VALUE ZERO.
           05  WS-NAMES-INVALID        PIC 9(05) VALUE ZERO.
           05  WS-ACCTS-FOR-NAME       PIC 9(05) VALUE ZERO.
           05  WS-ACCTS-LISTED         PIC 9(05) VALUE ZERO.

       01  WS-DETAIL-LINE.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  DL-NUMBER               PIC X(10).
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  DL-HOLDER               PIC X(30).
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  DL-TYPE                 PIC X(08).
           05  FILLER                  PIC X(01) VALUE SPACES.
           05  DL-BALANCE              PIC ZZZ,ZZZ,ZZ9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  DL-STATUS               PIC X(07).

       01  WS-COUNT-EDIT               PIC ZZ,ZZ9.
       01  WS-SEPARATOR                PIC X(80) VALUE ALL '-'.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-INQUIRIES
           PERFORM 3000-LIST-BY-NAME
           PERFORM 9000-FINALIZE
           STOP RUN.

       1000-INITIALIZE.
           OPEN INPUT ACCOUNT-FILE
           IF NOT FS-OK
               DISPLAY 'ERROR OPENING ACCTFILE - FILE STATUS: '
                       WS-FILE-STATUS
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF
           OPEN INPUT INQUIRY-FILE
           IF WS-INQ-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING INQIN - FILE STATUS: '
                       WS-INQ-STATUS
               CLOSE ACCOUNT-FILE
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF
           DISPLAY 'VSAM EXERCISE 8 - ACCOUNT INQUIRY BY HOLDER NAME'
           DISPLAY WS-SEPARATOR.

      *-----------------------------------------------------------
      * PART 1: ONE INQUIRY PER INPUT LINE (READ-AHEAD LOOP)
      *-----------------------------------------------------------
       2000-PROCESS-INQUIRIES.
           PERFORM 2100-READ-INQUIRY
           PERFORM UNTIL INQ-END-OF-FILE
               ADD 1 TO WS-INQUIRIES
               PERFORM 2200-FIND-NAME
               PERFORM 2100-READ-INQUIRY
           END-PERFORM.

       2100-READ-INQUIRY.
           READ INQUIRY-FILE
               AT END
                   SET INQ-END-OF-FILE TO TRUE
           END-READ.

       2200-FIND-NAME.
           MOVE INQ-HOLDER TO WS-SEARCH-NAME
           IF WS-SEARCH-NAME = SPACES
               ADD 1 TO WS-NAMES-INVALID
               DISPLAY 'INQUIRY ' WS-INQUIRIES
                       ': BLANK NAME - SKIPPED'
               DISPLAY WS-SEPARATOR
           ELSE
               DISPLAY 'INQUIRY ' WS-INQUIRIES ': '
                       WS-SEARCH-NAME
      *        POSITION ON THE FIRST ACCOUNT WITH THIS NAME
               MOVE WS-SEARCH-NAME TO ACCT-HOLDER
               START ACCOUNT-FILE
                   KEY IS EQUAL TO ACCT-HOLDER
               END-START
               EVALUATE TRUE
                   WHEN FS-OK
                       ADD 1 TO WS-NAMES-FOUND
                       PERFORM 2300-READ-ALL-FOR-NAME
                   WHEN FS-NOT-FOUND
                       ADD 1 TO WS-NAMES-NOT-FOUND
                       DISPLAY '  NO ACCOUNTS FOR THIS NAME'
                               ' (FILE STATUS 23)'
                   WHEN OTHER
                       PERFORM 8000-FATAL-ERROR
               END-EVALUATE
               DISPLAY WS-SEPARATOR
           END-IF.

      *-----------------------------------------------------------
      * READ NEXT UNTIL THE NAME CHANGES OR THE FILE ENDS.
      * ON Z/OS EACH READ RETURNS 02 WHEN ANOTHER ACCOUNT WITH THE
      * SAME NAME FOLLOWS, AND 00 ON THE LAST ONE. THE NAME IS
      * COMPARED AS WELL, SO THE LOOP DOES NOT DEPEND ON 02 ALONE
      * (GNUCOBOL, FOR EXAMPLE, RETURNS 00 FOR EVERY DUPLICATE).
      *-----------------------------------------------------------
       2300-READ-ALL-FOR-NAME.
           MOVE ZERO TO WS-ACCTS-FOR-NAME
           SET MORE-FOR-NAME TO TRUE
           PERFORM UNTIL NO-MORE-FOR-NAME
               READ ACCOUNT-FILE NEXT RECORD
               END-READ
               EVALUATE TRUE
                   WHEN FS-OK
                   WHEN FS-DUPLICATE-FOLLOWS
                       IF ACCT-HOLDER = WS-SEARCH-NAME
                           PERFORM 2400-SHOW-ACCOUNT
                       ELSE
                           SET NO-MORE-FOR-NAME TO TRUE
                       END-IF
                   WHEN FS-END-OF-FILE
                       SET NO-MORE-FOR-NAME TO TRUE
                   WHEN OTHER
                       PERFORM 8000-FATAL-ERROR
               END-EVALUATE
           END-PERFORM
           MOVE WS-ACCTS-FOR-NAME TO WS-COUNT-EDIT
           DISPLAY '  ACCOUNTS FOR THIS NAME: ' WS-COUNT-EDIT.

       2400-SHOW-ACCOUNT.
           ADD 1 TO WS-ACCTS-FOR-NAME
           PERFORM 7000-FORMAT-DETAIL
           DISPLAY WS-DETAIL-LINE '  FS ' WS-FILE-STATUS
           IF ACCT-STATUS = 'B'
               DISPLAY '    WARNING: ACCOUNT IS BLOCKED'
           END-IF
           IF ACCT-STATUS = 'C'
               DISPLAY '    WARNING: ACCOUNT IS CLOSED'
           END-IF.

      *-----------------------------------------------------------
      * PART 2: ALL ACCOUNTS IN HOLDER-NAME ORDER
      *-----------------------------------------------------------
       3000-LIST-BY-NAME.
           DISPLAY ' '
           DISPLAY 'ALL ACCOUNTS IN HOLDER-NAME ORDER'
           DISPLAY WS-SEPARATOR
           MOVE LOW-VALUES TO ACCT-HOLDER
           START ACCOUNT-FILE
               KEY IS NOT LESS THAN ACCT-HOLDER
           END-START
           IF NOT FS-OK
               PERFORM 8000-FATAL-ERROR
           END-IF
           PERFORM UNTIL FS-END-OF-FILE
               READ ACCOUNT-FILE NEXT RECORD
               END-READ
               EVALUATE TRUE
                   WHEN FS-OK
                   WHEN FS-DUPLICATE-FOLLOWS
                       ADD 1 TO WS-ACCTS-LISTED
                       PERFORM 7000-FORMAT-DETAIL
                       DISPLAY WS-DETAIL-LINE
                   WHEN FS-END-OF-FILE
                       CONTINUE
                   WHEN OTHER
                       PERFORM 8000-FATAL-ERROR
               END-EVALUATE
           END-PERFORM.

       7000-FORMAT-DETAIL.
           MOVE ACCT-NUMBER  TO DL-NUMBER
           MOVE ACCT-HOLDER  TO DL-HOLDER
           MOVE ACCT-BALANCE TO DL-BALANCE
           EVALUATE ACCT-TYPE
               WHEN 'A'    MOVE 'SAVINGS'  TO DL-TYPE
               WHEN 'C'    MOVE 'CHECKING' TO DL-TYPE
               WHEN OTHER  MOVE 'UNKNOWN'  TO DL-TYPE
           END-EVALUATE
           EVALUATE ACCT-STATUS
               WHEN 'A'    MOVE 'ACTIVE'   TO DL-STATUS
               WHEN 'B'    MOVE 'BLOCKED'  TO DL-STATUS
               WHEN 'C'    MOVE 'CLOSED'   TO DL-STATUS
               WHEN OTHER  MOVE 'UNKNOWN'  TO DL-STATUS
           END-EVALUATE.

       8000-FATAL-ERROR.
           DISPLAY 'UNEXPECTED FILE STATUS ON ACCTFILE: '
                   WS-FILE-STATUS
           CLOSE ACCOUNT-FILE INQUIRY-FILE
           MOVE 16 TO RETURN-CODE
           STOP RUN.

       9000-FINALIZE.
           CLOSE ACCOUNT-FILE INQUIRY-FILE
           DISPLAY WS-SEPARATOR
           MOVE WS-INQUIRIES TO WS-COUNT-EDIT
           DISPLAY 'INQUIRIES         : ' WS-COUNT-EDIT
           MOVE WS-NAMES-FOUND TO WS-COUNT-EDIT
           DISPLAY 'NAMES FOUND       : ' WS-COUNT-EDIT
           MOVE WS-NAMES-NOT-FOUND TO WS-COUNT-EDIT
           DISPLAY 'NAMES NOT FOUND   : ' WS-COUNT-EDIT
           MOVE WS-NAMES-INVALID TO WS-COUNT-EDIT
           DISPLAY 'BLANK NAMES       : ' WS-COUNT-EDIT
           MOVE WS-ACCTS-LISTED TO WS-COUNT-EDIT
           DISPLAY 'ACCOUNTS LISTED   : ' WS-COUNT-EDIT
           IF WS-NAMES-NOT-FOUND > ZERO OR WS-NAMES-INVALID > ZERO
               MOVE 4 TO RETURN-CODE
           END-IF.
