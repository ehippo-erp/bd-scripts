--------------------------------------------------------
--  DDL for Type REC_CANTIDADES_SALDO_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CANTIDADES_SALDO_DOCUMENTO" AS OBJECT (
    tipdoc        NUMBER,
    numdoc        NUMBER,
    femisi        DATE,
    tipinv        NUMBER,
    codalm        NUMBER,
    codart        VARCHAR2(50),
    descri        VARCHAR2(100),
    codadd01      VARCHAR2(10),
    codadd02      VARCHAR2(10),
    coduni        VARCHAR2(3),
    consto        NUMBER,
    swstkneg      VARCHAR2(1),
    etiqueta      VARCHAR2(100),
    cantid        NUMERIC(16, 4),
    saldo         NUMERIC(16, 4),
    salidamax     NUMERIC(16, 4),
    portotsal     NUMERIC(16, 4),
    comprometido  NUMERIC(16, 4),
    saldo_alm     NUMERIC(16, 4)
);

/
