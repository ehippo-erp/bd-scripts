--------------------------------------------------------
--  DDL for Type REC_CREDITOSIMPLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CREDITOSIMPLE" AS OBJECT (
    swresultado   VARCHAR2(1),
    codcli        VARCHAR2(20),
    razonc        VARCHAR2(80 CHAR),
    ruc           VARCHAR2(20),
    codpag        NUMBER,
    monlimcred    VARCHAR2(5),
    simbolo       VARCHAR2(5),
    limcre2       NUMBER(9, 2),
    codpag2       NUMBER,
    despag2       VARCHAR2(50 CHAR),
    observ        VARCHAR2(3000 CHAR),
    desfidelidad  VARCHAR2(60 CHAR),
    saldo         NUMBER(16, 2),
    tipdoc        NUMBER,
    descri        VARCHAR2(30),
    series        VARCHAR2(5),
    numdoc        NUMBER,
    codcpag       NUMBER,
    descpag       VARCHAR2(50 CHAR),
    tipmon        VARCHAR2(5),
    totdoc        NUMBER(16, 5),
    tipcam        NUMBER(9, 6),
    total         NUMBER(16, 5),
    mensaje       VARCHAR2(1000)
);

/
