//ACCTAIX  JOB ,NOTIFY=&SYSUID
//*-----------------------------------------------------------
//* VSAM EXERCISE 8 - ALTERNATE INDEX BY HOLDER NAME
//* BASE CLUSTER : Z79583.MY.ACCOUNTS.KSDS (EXERCISE 3)
//* ALTERNATE KEY: HOLDER NAME, COLUMNS 11-40
//*                KEYS(30 10) - LENGTH 30, OFFSET 10
//*                NONUNIQUEKEY - TWO ACCOUNTS CAN SHARE A NAME
//* THE JOB CAN BE RERUN: IT DELETES AND REBUILDS THE AIX.
//*-----------------------------------------------------------
//* STEP 1: ADD 3 ACCOUNTS THAT REPEAT EXISTING HOLDER NAMES,
//*         SO THE AIX HAS DUPLICATE KEYS TO SHOW.
//*         DIAZ MENDOZA, LUISA  -> 3 ACCOUNTS IN TOTAL
//*         RAMIREZ SILVA, ELENA -> 2 ACCOUNTS IN TOTAL
//*         SORT CUTS EACH LINE TO 61 BYTES; REPRO REPLACE
//*         LETS THE JOB RUN AGAIN WITHOUT DUPLICATE-KEY ERRORS.
//*-----------------------------------------------------------
//SORTNEW  EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTOUT  DD DSN=&&NEWACCT,DISP=(NEW,PASS),
//            SPACE=(TRK,(1,1)),RECFM=FB,LRECL=61
//SYSIN    DD *
  SORT FIELDS=(1,10,CH,A)
  OUTREC BUILD=(1,61)
/*
//SORTIN   DD *
1000000901DIAZ MENDOZA, LUISA           C0000045000020220516A
1000000902DIAZ MENDOZA, LUISA           A0000120005020250103B
1000000903RAMIREZ SILVA, ELENA          C0000009876520230807A
/*
//ADDACCT  EXEC PGM=IDCAMS,COND=(4,LT)
//SYSPRINT DD SYSOUT=*
//SEQIN    DD DSN=&&NEWACCT,DISP=(OLD,DELETE)
//SYSIN    DD *
  REPRO INFILE(SEQIN) OUTDATASET(Z79583.MY.ACCOUNTS.KSDS) REPLACE
/*
//*-----------------------------------------------------------
//* STEP 2: DEFINE THE AIX AND THE PATH, THEN BUILD THE AIX.
//*   RECORDSIZE: 5 + 30 + (10 X DUPLICATES)
//*     AVERAGE (1 ACCOUNT PER NAME)  : 5 + 30 + 10  =  45
//*     MAXIMUM (UP TO 10 PER NAME)   : 5 + 30 + 100 = 135
//*   NO VOLUMES: SMS CHOOSES THE VOLUME ON Z XPLORE.
//*-----------------------------------------------------------
//DEFAIX   EXEC PGM=IDCAMS,COND=(4,LT)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE Z79583.MY.ACCOUNTS.AIX ALTERNATEINDEX PURGE
  SET MAXCC = 0
  DEFINE ALTERNATEINDEX                              -
         (NAME(Z79583.MY.ACCOUNTS.AIX)               -
         RELATE(Z79583.MY.ACCOUNTS.KSDS)             -
         KEYS(30 10)                                 -
         NONUNIQUEKEY                                -
         UPGRADE                                     -
         RECORDSIZE(45 135)                          -
         FREESPACE(10 10)                            -
         SHAREOPTIONS(2 3)                           -
         TRACKS(1 1))                                -
         DATA  (NAME(Z79583.MY.ACCOUNTS.AIX.DATA))   -
         INDEX (NAME(Z79583.MY.ACCOUNTS.AIX.INDEX))
  IF LASTCC = 0 THEN                                 -
     DEFINE PATH                                     -
         (NAME(Z79583.MY.ACCOUNTS.PATH)              -
         PATHENTRY(Z79583.MY.ACCOUNTS.AIX)           -
         UPDATE)
  IF LASTCC = 0 THEN                                 -
     BLDINDEX INDATASET(Z79583.MY.ACCOUNTS.KSDS)     -
              OUTDATASET(Z79583.MY.ACCOUNTS.AIX)     -
              INTERNALSORT
/*
//*-----------------------------------------------------------
//* STEP 3: CHECK THE RESULT
//*   PRINT THROUGH THE PATH LISTS THE ACCOUNTS IN NAME ORDER.
//*   LISTCAT SHOWS THE AIX, ITS PATH AND THE UPGRADE SET.
//*-----------------------------------------------------------
//CHECK    EXEC PGM=IDCAMS,COND=(4,LT)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  PRINT INDATASET(Z79583.MY.ACCOUNTS.PATH) CHARACTER
  LISTCAT ENTRIES(Z79583.MY.ACCOUNTS.AIX) ALL
/*
