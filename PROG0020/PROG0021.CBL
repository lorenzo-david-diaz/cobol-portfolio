      *================================================================*
      * PROGRAM : PROG0021                                             *
      * AUTHOR  : LORENZO DAVID DIAZ (OPTIMISTA001)                    *
      * WRITTEN : 2026-10-06                                           *
      * PURPOSE : READ THE INDEXED EMPLOYEE MASTER FILE IN TWO WAYS:   *
      *           1. SEQUENTIALLY, IN KEY ORDER, WITH CONTROL TOTALS   *
      *           2. RANDOMLY, BY EMPLOYEE NUMBER (KEYED LOOKUP)       *
      * INPUT   : EMPLOYEES.IDX  (CREATED BY PROG0020)                 *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROG0021.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLOYEE-MASTER
               ASSIGN TO "C:\REPOSITORIO_DATOS\EMPLOYEES.IDX"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS MST-EMP-NUMBER
               FILE STATUS IS WS-MASTER-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLOYEE-MASTER.
       01  MASTER-RECORD.
           05 MST-EMP-NUMBER      PIC 9(05).
           05 MST-EMP-NAME        PIC X(30).
           05 MST-EMP-STATUS      PIC 9(01).
           05 MST-EMP-DEPT        PIC 9(03).
           05 MST-EMP-POSITION    PIC 9(02).
           05 MST-EMP-SALARY      PIC 9(07)V99.

       WORKING-STORAGE SECTION.
       01  WS-MASTER-STATUS       PIC X(02).
           88 MASTER-OK                      VALUE "00".
           88 MASTER-EOF                     VALUE "10".

       01  WS-COUNTERS.
           05 WS-RECORDS-READ     PIC 9(06)    VALUE ZERO.
           05 WS-TOTAL-SALARY     PIC 9(09)V99 VALUE ZERO.
           05 WS-LOOKUPS-FOUND    PIC 9(02)    VALUE ZERO.
           05 WS-LOOKUPS-MISSING  PIC 9(02)    VALUE ZERO.

      *    EMPLOYEE NUMBERS FOR THE KEYED LOOKUP TEST:
      *    FIRST KEY, A MIDDLE KEY, LAST KEY, AND ONE THAT DOES NOT
      *    EXIST, TO EXERCISE THE INVALID KEY PATH.
       01  WS-LOOKUP-VALUES.
           05 FILLER              PIC 9(05)    VALUE 10001.
           05 FILLER              PIC 9(05)    VALUE 10421.
           05 FILLER              PIC 9(05)    VALUE 10834.
           05 FILLER              PIC 9(05)    VALUE 99999.
       01  WS-LOOKUP-TABLE REDEFINES WS-LOOKUP-VALUES.
           05 WS-LOOKUP-KEY       PIC 9(05)    OCCURS 4 TIMES.
       01  WS-IDX                 PIC 9(02).

       01  WS-DETAIL-LINE.
           05 FILLER              PIC X(05)    VALUE "NUM: ".
           05 DET-EMP-NUMBER      PIC 9(05).
           05 FILLER              PIC X(08)    VALUE "  NAME: ".
           05 DET-EMP-NAME        PIC X(30).
           05 FILLER              PIC X(10)    VALUE "  STATUS: ".
           05 DET-EMP-STATUS      PIC 9(01).
           05 FILLER              PIC X(08)    VALUE "  DEPT: ".
           05 DET-EMP-DEPT        PIC 9(03).
           05 FILLER              PIC X(07)    VALUE "  POS: ".
           05 DET-EMP-POSITION    PIC 9(02).
           05 FILLER              PIC X(10)    VALUE "  SALARY: ".
           05 DET-EMP-SALARY      PIC Z,ZZZ,ZZ9.99.

       01  WS-EDITED-TOTAL        PIC $$$$,$$$,$$9.99.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-SEQUENTIAL-LISTING
           PERFORM 3000-KEYED-LOOKUPS
           PERFORM 9000-FINALIZE
           STOP RUN.

       1000-INITIALIZE.
           OPEN INPUT EMPLOYEE-MASTER
           IF NOT MASTER-OK
              DISPLAY "*** ERROR OPENING EMPLOYEES.IDX - STATUS: "
                      WS-MASTER-STATUS
              DISPLAY "*** RUN PROG0020 FIRST TO CREATE THE FILE"
              STOP RUN
           END-IF.

      *----------------------------------------------------------------*
      * PART 1: READ THE WHOLE FILE IN KEY ORDER                       *
      *----------------------------------------------------------------*
       2000-SEQUENTIAL-LISTING.
           DISPLAY "================================================"
           DISPLAY "  PROG0021 - PART 1: SEQUENTIAL LISTING"
           DISPLAY "================================================"
           PERFORM 2100-READ-NEXT
           PERFORM UNTIL MASTER-EOF
              ADD 1              TO WS-RECORDS-READ
              ADD MST-EMP-SALARY TO WS-TOTAL-SALARY
              PERFORM 8000-DISPLAY-DETAIL
              PERFORM 2100-READ-NEXT
           END-PERFORM
           MOVE WS-TOTAL-SALARY TO WS-EDITED-TOTAL
           DISPLAY "------------------------------------------------"
           DISPLAY "RECORDS READ     : " WS-RECORDS-READ
           DISPLAY "TOTAL SALARY     : " WS-EDITED-TOTAL.

       2100-READ-NEXT.
           READ EMPLOYEE-MASTER NEXT RECORD
                AT END
                   SET MASTER-EOF TO TRUE
           END-READ.

      *----------------------------------------------------------------*
      * PART 2: RANDOM ACCESS BY KEY                                   *
      *----------------------------------------------------------------*
       3000-KEYED-LOOKUPS.
           DISPLAY " "
           DISPLAY "================================================"
           DISPLAY "  PROG0021 - PART 2: LOOKUP BY EMPLOYEE NUMBER"
           DISPLAY "================================================"
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 4
              MOVE WS-LOOKUP-KEY (WS-IDX) TO MST-EMP-NUMBER
              READ EMPLOYEE-MASTER
                   KEY IS MST-EMP-NUMBER
                   INVALID KEY
                      ADD 1 TO WS-LOOKUPS-MISSING
                      DISPLAY "NUM: " WS-LOOKUP-KEY (WS-IDX)
                              "  *** NOT FOUND - STATUS: "
                              WS-MASTER-STATUS
                   NOT INVALID KEY
                      ADD 1 TO WS-LOOKUPS-FOUND
                      PERFORM 8000-DISPLAY-DETAIL
              END-READ
           END-PERFORM
           DISPLAY "------------------------------------------------"
           DISPLAY "LOOKUPS FOUND    : " WS-LOOKUPS-FOUND
           DISPLAY "LOOKUPS NOT FOUND: " WS-LOOKUPS-MISSING.

       8000-DISPLAY-DETAIL.
           MOVE MST-EMP-NUMBER    TO DET-EMP-NUMBER
           MOVE MST-EMP-NAME      TO DET-EMP-NAME
           MOVE MST-EMP-STATUS    TO DET-EMP-STATUS
           MOVE MST-EMP-DEPT      TO DET-EMP-DEPT
           MOVE MST-EMP-POSITION  TO DET-EMP-POSITION
           MOVE MST-EMP-SALARY    TO DET-EMP-SALARY
           DISPLAY WS-DETAIL-LINE.

       9000-FINALIZE.
           CLOSE EMPLOYEE-MASTER
           DISPLAY "================================================"
           DISPLAY "PROG0021 ENDED"
           DISPLAY "================================================".
