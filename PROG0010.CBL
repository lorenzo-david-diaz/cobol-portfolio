       IDENTIFICATION DIVISION.
       PROGRAM-ID.                PROG0010.
       AUTHOR.                    OPTIMISTA001.
       DATE-WRITTEN.              06/09/26
       DATE-COMPILED.
       SECURITY.                  NO CONFIDENCIAL.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.           IBM-360.
       OBJECT-COMPUTER.           IBM-360.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLEADOS 
           ASSIGN TO "C:\COBOL_102\ARCHIVOS_PLANOS\EMPLEADOS.TXT"
           ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REPORTE   ASSIGN  "C:\COBOL_102\ARCHIVOS_PLANOS\PARTO.TXT"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLEADOS
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 50 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           DATA RECORDS ARE REG-EMPLEADOS.
       01  REG-EMPLEADOS          PIC X(50).
       FD  REPORTE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 80 CHARACTERS
           BLOCK CONTAINS 0 RECORDS
           DATA RECORDS ARE REG-REPORTE.
       01  REG-REPORTE            PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-FIN-ARCHIVO          PIC X(01) VALUE 'N'.
           88  FIN-ARCHIVO         VALUE 'S'.

       01   WS-AREAS-A-USAR.
           05 WS-REG-EMPLEADOS.
              10 WS-NUMERO-EMP    PIC 9(05).
              10 WS-NOMBRE-EMP    PIC X(30).
              10 WS-STATUS-EMP    PIC 9(1).
              10 WS-DEPTO-EMP     PIC 9(03).
              10 WS-PUESTO-EMP    PIC 9(02).
              10 WS-SALARIO-EMP   PIC 9(7)V99.
           05 WS-LEIDOS-EMP       PIC 9(05) VALUE ZEROS.
           05 WS-IMPRESOS         PIC 9(05) VALUE ZEROS.
           05 WS-TOTAL-SALARIOS   PIC 9(09)V99 VALUE ZEROS.

       01  WS-TITULO-1.
           05 FILLER              PIC X(28) VALUE SPACES.
           05 WS-TIT-1            PIC X(25)
                                  VALUE "EMPLEADOS DE LA EMPRESA  ".
           05 FILLER              PIC X(27) VALUE SPACES.

       01 WS-SUBTITULO-1.
           05 FILLER              PIC X(4) VALUE SPACES.
           05 FILLER              PIC X(6) VALUE "NUMERO".
           05 FILLER              PIC X(12) VALUE SPACES.
           05 FILLER              PIC X(06) VALUE "NOMBRE".
           05 FILLER              PIC X(15) VALUE SPACES.
           05 FILLER              PIC X(06) VALUE "STATUS".
           05 FILLER              PIC X(02) VALUE SPACES.
           05 FILLER              PIC X(05) VALUE "DEPTO".
           05 FILLER              PIC X(01) VALUE SPACES.
           05 FILLER              PIC X(06) VALUE "PUESTO".
           05 FILLER              PIC X(04) VALUE SPACES.
           05 FILLER              PIC X(07) VALUE "SALARIO".
           05 FILLER              PIC X(06) VALUE SPACES.

       01 WS-TITULO-2.
           05 FILLER              PIC X(08) VALUE " FECHA ".
           05 WS-TIT-2-DIA        PIC 9(02).
           05 FILLER              PIC X(01) VALUE "/".
           05 WS-TIT-2-MES        PIC 9(02).
           05 FILLER              PIC X(01) VALUE "/".
           05 WS-TIT-2-ANIO       PIC 9(02).
           05 FILLER              PIC X(17) VALUE SPACES.
           05 WS-TIT-2            PIC X(23)
                                  VALUE "CENTRO DEL OPTIMISMO  ".
           05 FILLER              PIC X(08) VALUE "PAGINA: ".
           05 WS-TIT-2-PAGINA     PIC ZZ9.
           05 FILLER              PIC X(11) VALUE SPACES.

       01  WS-DETALLE-LEIDOS.
           05 FILLER              PIC X(1).
           05 FILLER              PIC X(29)
                                  VALUE "TOTAL DE EMPLEADOS LEIDOS: ".
           05 WS-TOT-LEIDOS       PIC 9(05).
           05 FILLER              PIC X(45) VALUE SPACES.

       01  WS-DETALLE-IMPRESOS.
           05 FILLER              PIC X(01).
           05 FILLER              PIC X(29)
                                  VALUE "TOTAL DE EMPLEADOS IMPRESOS: ".
           05 WS-TOT-IMPRESOS     PIC 9(05).
           05 FILLER              PIC X(45) VALUE SPACES.

       01 WS-GUIONES.
           05 FILLER              PIC X(01).
           05 FILLER              PIC X(78) VALUE ALL "-".
           05 FILLER              PIC X(1) VALUE SPACES.

       01 WS-DETALLE.
           05 FILLER              PIC X(04)    VALUE SPACES.
           05 WS-DET-NUMERO       PIC ZZZZ9.
           05 FILLER              PIC X(04)    VALUE SPACES.
           05 WS-DET-NOMBRE       PIC X(30).
           05 FILLER              PIC X(04)    VALUE SPACES.
           05 WS-DET-STATUS       PIC 9(01).
           05 FILLER              PIC X(04)    VALUE SPACES.
           05 WS-DET-DEPTO        PIC 9(03).
           05 FILLER              PIC X(04)    VALUE SPACES.
           05 WS-DET-PUESTO       PIC 9(02).
           05 FILLER              PIC X(03)    VALUE SPACES.
           05 WS-DET-SALARIO      PIC Z,ZZZ,ZZ9.99.
           05 FILLER              PIC X(04)    VALUE SPACE.

       01  WS-DETALLE-SALARIOS.
           05 FILLER              PIC X(01).
           05 FILLER              PIC X(29)
                                  VALUE "SUMA TOTAL DE SALARIOS    : ".
           05 WS-DET-SALARIO2     PIC $$$,$$$,$$9.99.
           05 FILLER              PIC X(36)    VALUE SPACES.

       01  WS-FECHA-SISTEMA.
           05 WS-FS-ANIO          PIC 9(04).
           05 WS-FS-MES           PIC 9(02).
           05 WS-FS-DIA           PIC 9(02).

       PROCEDURE DIVISION.

       0000-PRINCIPAL.
           PERFORM 1000-INICIALIZAR
           PERFORM 2000-PROCESAR-EMPLEADOS UNTIL FIN-ARCHIVO
           PERFORM 3000-FINALIZAR
           STOP RUN.

       1000-INICIALIZAR.
           ACCEPT WS-FECHA-SISTEMA FROM DATE YYYYMMDD
           MOVE WS-FS-ANIO TO WS-TIT-2-ANIO
           MOVE WS-FS-MES TO WS-TIT-2-MES
           MOVE WS-FS-DIA TO WS-TIT-2-DIA
           OPEN INPUT EMPLEADOS
                OUTPUT REPORTE
           MOVE 1 TO WS-TIT-2-PAGINA
           WRITE REG-REPORTE FROM WS-TITULO-1
           WRITE REG-REPORTE FROM WS-TITULO-2 AFTER ADVANCING 1 LINE
           WRITE REG-REPORTE FROM WS-GUIONES AFTER ADVANCING 1 LINE
           WRITE REG-REPORTE FROM WS-SUBTITULO-1 AFTER ADVANCING 1 LINE
           WRITE REG-REPORTE FROM WS-GUIONES AFTER ADVANCING 1 LINE
           PERFORM 2100-LEER-REGISTRO.

       2000-PROCESAR-EMPLEADOS.
           ADD 1                  TO WS-LEIDOS-EMP
           ADD WS-SALARIO-EMP     TO WS-TOTAL-SALARIOS
           PERFORM 2200-IMPRIMIR-DETALLE
           PERFORM 2100-LEER-REGISTRO.

       2100-LEER-REGISTRO.
           READ EMPLEADOS INTO WS-REG-EMPLEADOS
                AT END
                    SET FIN-ARCHIVO TO TRUE
           END-READ.

       2200-IMPRIMIR-DETALLE.
           MOVE WS-NUMERO-EMP     TO WS-DET-NUMERO
           MOVE WS-NOMBRE-EMP     TO WS-DET-NOMBRE
           MOVE WS-STATUS-EMP     TO WS-DET-STATUS
           MOVE WS-DEPTO-EMP      TO WS-DET-DEPTO
           MOVE WS-PUESTO-EMP     TO WS-DET-PUESTO
           MOVE WS-SALARIO-EMP    TO WS-DET-SALARIO
           WRITE REG-REPORTE FROM WS-DETALLE AFTER ADVANCING 1 LINE
           ADD 1 TO WS-IMPRESOS.

       3000-FINALIZAR.
           MOVE WS-LEIDOS-EMP TO WS-TOT-LEIDOS
           WRITE REG-REPORTE FROM WS-DETALLE-LEIDOS
                 AFTER ADVANCING 1 LINE
           MOVE WS-IMPRESOS TO WS-TOT-IMPRESOS
           WRITE REG-REPORTE FROM WS-DETALLE-IMPRESOS
                 AFTER ADVANCING 1 LINE
           MOVE WS-TOTAL-SALARIOS   TO WS-DET-SALARIO2
           WRITE REG-REPORTE FROM WS-DETALLE-SALARIOS
                 AFTER ADVANCING 1 LINE
           CLOSE EMPLEADOS
                 REPORTE.