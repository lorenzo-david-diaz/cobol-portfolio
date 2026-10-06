      *================================================================*
      * PROGRAM : PROG0020                                             *
      * AUTHOR  : LORENZO DAVID DIAZ (OPTIMISTA001)                    *
      * WRITTEN : 2026-10-06                                           *
      * PURPOSE : LOAD THE INDEXED EMPLOYEE MASTER FILE FROM A         *
      *           SEQUENTIAL INPUT FILE, WITH CONTROL TOTALS           *
      * INPUT   : EMPLOYEES.TXT  (LINE SEQUENTIAL, 50-BYTE RECORDS)    *
      * OUTPUT  : EMPLOYEES.IDX  (INDEXED, KEY = EMPLOYEE NUMBER)      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROG0020.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLOYEE-INPUT
               ASSIGN TO "C:\REPOSITORIO_DATOS\EMPLOYEES.TXT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-INPUT-STATUS.

           SELECT EMPLOYEE-MASTER
               ASSIGN TO "C:\REPOSITORIO_DATOS\EMPLOYEES.IDX"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS MST-EMP-NUMBER
               FILE STATUS IS WS-MASTER-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLOYEE-INPUT.
       01  INPUT-RECORD.
           05 IN-EMP-NUMBER       PIC 9(05).
           05 IN-EMP-NAME         PIC X(30).
           05 IN-EMP-STATUS       PIC 9(01).
           05 IN-EMP-DEPT         PIC 9(03).
           05 IN-EMP-POSITION     PIC 9(02).
           05 IN-EMP-SALARY       PIC 9(07)V99.

       FD  EMPLOYEE-MASTER.
       01  MASTER-RECORD.
           05 MST-EMP-NUMBER      PIC 9(05).
           05 MST-EMP-NAME        PIC X(30).
           05 MST-EMP-STATUS      PIC 9(01).
           05 MST-EMP-DEPT        PIC 9(03).
           05 MST-EMP-POSITION    PIC 9(02).
           05 MST-EMP-SALARY      PIC 9(07)V99.

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05 WS-INPUT-STATUS     PIC X(02).
              88 INPUT-OK                    VALUE "00".
              88 INPUT-EOF                   VALUE "10".
           05 WS-MASTER-STATUS    PIC X(02).
              88 MASTER-OK                   VALUE "00".

       01  WS-COUNTERS.
           05 WS-RECORDS-READ     PIC 9(06)    VALUE ZERO.
           05 WS-RECORDS-WRITTEN  PIC 9(06)    VALUE ZERO.
           05 WS-RECORDS-SKIPPED  PIC 9(06)    VALUE ZERO.
           05 WS-RECORDS-REJECTED PIC 9(06)    VALUE ZERO.
           05 WS-TOTAL-SALARY     PIC 9(09)V99 VALUE ZERO.

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
           PERFORM 2000-PROCESS-RECORD UNTIL INPUT-EOF
           PERFORM 3000-FINALIZE
           STOP RUN.

       1000-INITIALIZE.
           OPEN INPUT EMPLOYEE-INPUT
           IF NOT INPUT-OK
              DISPLAY "*** ERROR OPENING EMPLOYEES.TXT - STATUS: "
                      WS-INPUT-STATUS
              STOP RUN
           END-IF
           OPEN OUTPUT EMPLOYEE-MASTER
           IF NOT MASTER-OK
              DISPLAY "*** ERROR CREATING EMPLOYEES.IDX - STATUS: "
                      WS-MASTER-STATUS
              CLOSE EMPLOYEE-INPUT
              STOP RUN
           END-IF
           DISPLAY "================================================"
           DISPLAY "  PROG0020 - LOADING EMPLOYEES.IDX"
           DISPLAY "================================================"
           PERFORM 2100-READ-INPUT.

       2000-PROCESS-RECORD.
           IF IN-EMP-NUMBER = ZERO
              ADD 1 TO WS-RECORDS-SKIPPED
              DISPLAY "*** RECORD " WS-RECORDS-READ
                      " SKIPPED (EMPLOYEE NUMBER IS ZERO)"
           ELSE
              PERFORM 2200-WRITE-MASTER
           END-IF
           PERFORM 2100-READ-INPUT.

       2100-READ-INPUT.
           READ EMPLOYEE-INPUT
                AT END
                   SET INPUT-EOF TO TRUE
                NOT AT END
                   ADD 1 TO WS-RECORDS-READ
           END-READ.

       2200-WRITE-MASTER.
           MOVE INPUT-RECORD      TO MASTER-RECORD
           WRITE MASTER-RECORD
                 INVALID KEY
                    ADD 1 TO WS-RECORDS-REJECTED
                    DISPLAY "*** ERROR WRITING EMPLOYEE "
                            MST-EMP-NUMBER " - STATUS: "
                            WS-MASTER-STATUS
                 NOT INVALID KEY
                    ADD 1 TO WS-RECORDS-WRITTEN
                    ADD MST-EMP-SALARY TO WS-TOTAL-SALARY
                    PERFORM 2300-DISPLAY-DETAIL
           END-WRITE.

       2300-DISPLAY-DETAIL.
           MOVE MST-EMP-NUMBER    TO DET-EMP-NUMBER
           MOVE MST-EMP-NAME      TO DET-EMP-NAME
           MOVE MST-EMP-STATUS    TO DET-EMP-STATUS
           MOVE MST-EMP-DEPT      TO DET-EMP-DEPT
           MOVE MST-EMP-POSITION  TO DET-EMP-POSITION
           MOVE MST-EMP-SALARY    TO DET-EMP-SALARY
           DISPLAY WS-DETAIL-LINE.

       3000-FINALIZE.
           CLOSE EMPLOYEE-INPUT
                 EMPLOYEE-MASTER
           MOVE WS-TOTAL-SALARY   TO WS-EDITED-TOTAL
           DISPLAY "================================================"
           DISPLAY "RECORDS READ     : " WS-RECORDS-READ
           DISPLAY "RECORDS WRITTEN  : " WS-RECORDS-WRITTEN
           DISPLAY "RECORDS SKIPPED  : " WS-RECORDS-SKIPPED
           DISPLAY "RECORDS REJECTED : " WS-RECORDS-REJECTED
           DISPLAY "TOTAL SALARY     : " WS-EDITED-TOTAL
           DISPLAY "================================================".
