      *----------------------------------------------------------------*
      * PROGRAMA : PROG0010                                            *
      * AUTOR    : OPTIMISTA001 (LORENZO DAVID DIAZ)                   *
      * ESCRITO  : 06/09/26                                            *
      * PROPOSITO: REPORTE DE EMPLEADOS CON TOTALES DE CONTROL         *
      *            VERSION ESTRUCTURADA (READ-AHEAD)                   *
      *            CON SALTO DE PAGINA CADA WS-MAX-LINEAS DETALLES     *
      * PROYECTO : PRUEBA_100 - VISUAL COBOL FOR ECLIPSE / GNUCOBOL    *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID.                PROG0010.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLEADOS
           ASSIGN TO
           "C:\REPOSITORIO_PROGRAMAS_GIT\PROG0010\EMPLEADOS.TXT"
           ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REPORTE
           ASSIGN TO "C:\COBOL_102\ARCHIVOS_PLANOS\REPORTE_MF.TXT"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLEADOS.
       01  REG-EMPLEADOS          PIC X(50).

       FD  REPORTE.
       01  REG-REPORTE            PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-FIN-ARCHIVO          PIC X(01) VALUE 'N'.
           88  FIN-ARCHIVO                   VALUE 'S'.

       01  WS-AREAS-A-USAR.
           05 WS-REG-EMPLEADOS.
              10 WS-NUMERO-EMP    PIC 9(05).
              10 WS-NOMBRE-EMP    PIC X(30).
              10 WS-STATUS-EMP    PIC 9(01).
              10 WS-DEPTO-EMP     PIC 9(03).
              10 WS-PUESTO-EMP    PIC 9(02).
              10 WS-SALARIO-EMP   PIC 9(07)V99.
           05 WS-LEIDOS-EMP       PIC 9(05)    VALUE ZEROS.
           05 WS-IMPRESOS         PIC 9(05)    VALUE ZEROS.
           05 WS-TOTAL-SALARIOS   PIC 9(09)V99 VALUE ZEROS.

       01  WS-TITULO-1.
           05 FILLER              PIC X(28) VALUE SPACES.
           05 WS-TIT-1            PIC X(25)
                VALUE "EMPLEADOS DE LA EMPRESA  ".
           05 FILLER              PIC X(27) VALUE SPACES.

       01  WS-TITULO-2.
           05 FILLER              PIC X(08) VALUE "  FECHA ".
           05 WS-TIT-2-DIA        PIC 9(02).
           05 FILLER              PIC X(01) VALUE "/".
           05 WS-TIT-2-MES        PIC 9(02).
           05 FILLER              PIC X(01) VALUE "/".
           05 WS-TIT-2-ANIO       PIC 9(04).
           05 FILLER              PIC X(17) VALUE SPACES.
           05 WS-TIT-2            PIC X(23)
                VALUE "CENTRO DEL OPTIMISMO  ".
           05 FILLER              PIC X(08) VALUE "PAGINA: ".
           05 WS-TIT-2-PAGINA     PIC ZZ9.
           05 FILLER              PIC X(11) VALUE SPACES.

       01  WS-SUBTITULO-1.
           05 FILLER              PIC X(04) VALUE SPACES.
           05 FILLER              PIC X(06) VALUE "NUMERO".
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

       01  WS-GUIONES.
           05 FILLER              PIC X(01) VALUE SPACES.
           05 FILLER              PIC X(78) VALUE ALL "-".
           05 FILLER              PIC X(01) VALUE SPACES.

       01  WS-DETALLE.
           05 FILLER              PIC X(04) VALUE SPACES.
           05 WS-DET-NUMERO       PIC ZZZZ9.
           05 FILLER              PIC X(04) VALUE SPACES.
           05 WS-DET-NOMBRE       PIC X(30).
           05 FILLER              PIC X(04) VALUE SPACES.
           05 WS-DET-STATUS       PIC 9(01).
           05 FILLER              PIC X(04) VALUE SPACES.
           05 WS-DET-DEPTO        PIC 9(03).
           05 FILLER              PIC X(04) VALUE SPACES.
           05 WS-DET-PUESTO       PIC 9(02).
           05 FILLER              PIC X(03) VALUE SPACES.
           05 WS-DET-SALARIO      PIC Z,ZZZ,ZZ9.99.
           05 FILLER              PIC X(04) VALUE SPACES.

       01  WS-DETALLE-LEIDOS.
           05 FILLER              PIC X(01) VALUE SPACES.
           05 FILLER              PIC X(29)
                VALUE "TOTAL DE EMPLEADOS LEIDOS  : ".
           05 WS-TOT-LEIDOS       PIC 9(05).
           05 FILLER              PIC X(45) VALUE SPACES.

       01  WS-DETALLE-IMPRESOS.
           05 FILLER              PIC X(01) VALUE SPACES.
           05 FILLER              PIC X(29)
                VALUE "TOTAL DE EMPLEADOS IMPRESOS: ".
           05 WS-TOT-IMPRESOS     PIC 9(05).
           05 FILLER              PIC X(45) VALUE SPACES.

       01  WS-DETALLE-SALARIOS.
           05 FILLER              PIC X(01) VALUE SPACES.
           05 FILLER              PIC X(29)
                VALUE "SUMA TOTAL DE SALARIOS     : ".
           05 WS-DET-SALARIO2     PIC $$$$,$$$,$$9.99.
           05 FILLER              PIC X(35) VALUE SPACES.

       01  WS-FECHA-SISTEMA.
           05 WS-FS-ANIO          PIC 9(04).
           05 WS-FS-MES           PIC 9(02).
           05 WS-FS-DIA           PIC 9(02).

       01  WS-PAUSA               PIC X(01).

       01  WS-CONTROL-PAGINAS.
           05 WS-PAGINA           PIC 9(03)    VALUE ZEROS.
           05 WS-CONT-LINEAS      PIC 9(03)    VALUE ZEROS.
           05 WS-MAX-LINEAS       PIC 9(03)    VALUE 15.

       01  WS-LINEA-BLANCO        PIC X(80)    VALUE SPACES.

       PROCEDURE DIVISION.

       0000-PRINCIPAL.
           PERFORM 1000-INICIALIZAR
           PERFORM 2000-PROCESAR-EMPLEADOS UNTIL FIN-ARCHIVO
           PERFORM 3000-FINALIZAR
           STOP RUN.

       1000-INICIALIZAR.
           ACCEPT WS-FECHA-SISTEMA FROM DATE YYYYMMDD
           MOVE WS-FS-ANIO        TO WS-TIT-2-ANIO
           MOVE WS-FS-MES         TO WS-TIT-2-MES
           MOVE WS-FS-DIA         TO WS-TIT-2-DIA
           OPEN INPUT  EMPLEADOS
                OUTPUT REPORTE
           PERFORM 1100-IMPRIMIR-ENCABEZADOS
           PERFORM 2100-LEER-REGISTRO.

       1100-IMPRIMIR-ENCABEZADOS.
           ADD 1                  TO WS-PAGINA
           MOVE WS-PAGINA         TO WS-TIT-2-PAGINA
           IF WS-PAGINA > 1
              WRITE REG-REPORTE FROM WS-LINEA-BLANCO
              WRITE REG-REPORTE FROM WS-LINEA-BLANCO
           END-IF
           WRITE REG-REPORTE FROM WS-TITULO-1
           WRITE REG-REPORTE FROM WS-TITULO-2
           WRITE REG-REPORTE FROM WS-GUIONES
           WRITE REG-REPORTE FROM WS-SUBTITULO-1
           WRITE REG-REPORTE FROM WS-GUIONES
           MOVE ZEROS             TO WS-CONT-LINEAS.

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
           IF WS-CONT-LINEAS >= WS-MAX-LINEAS
              PERFORM 1100-IMPRIMIR-ENCABEZADOS
           END-IF
           MOVE WS-NUMERO-EMP     TO WS-DET-NUMERO
           MOVE WS-NOMBRE-EMP     TO WS-DET-NOMBRE
           MOVE WS-STATUS-EMP     TO WS-DET-STATUS
           MOVE WS-DEPTO-EMP      TO WS-DET-DEPTO
           MOVE WS-PUESTO-EMP     TO WS-DET-PUESTO
           MOVE WS-SALARIO-EMP    TO WS-DET-SALARIO
           WRITE REG-REPORTE FROM WS-DETALLE
           ADD 1                  TO WS-CONT-LINEAS
           ADD 1                  TO WS-IMPRESOS.

       3000-FINALIZAR.
           WRITE REG-REPORTE FROM WS-GUIONES
           MOVE WS-LEIDOS-EMP     TO WS-TOT-LEIDOS
           WRITE REG-REPORTE FROM WS-DETALLE-LEIDOS
           MOVE WS-IMPRESOS       TO WS-TOT-IMPRESOS
           WRITE REG-REPORTE FROM WS-DETALLE-IMPRESOS
           MOVE WS-TOTAL-SALARIOS TO WS-DET-SALARIO2
           WRITE REG-REPORTE FROM WS-DETALLE-SALARIOS
           CLOSE EMPLEADOS
                 REPORTE
           DISPLAY "PROG0010 TERMINADO"
           DISPLAY "EMPLEADOS LEIDOS  : " WS-LEIDOS-EMP
           DISPLAY "EMPLEADOS IMPRESOS: " WS-IMPRESOS
           DISPLAY "PAGINAS IMPRESAS  : " WS-PAGINA
           DISPLAY "REPORTE EN: "
           DISPLAY "C:\COBOL_102\ARCHIVOS_PLANOS\REPORTE_MF.TXT"
           DISPLAY "Presione ENTER para terminar"
           ACCEPT WS-PAUSA.
