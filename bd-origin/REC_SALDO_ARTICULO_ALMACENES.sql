--------------------------------------------------------
--  DDL for Type REC_SALDO_ARTICULO_ALMACENES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SALDO_ARTICULO_ALMACENES" AS OBJECT (
    tipinv           NUMBER,
    codalm           NUMBER,
    desalm           VARCHAR2(50),
    codart           VARCHAR2(40),
    fisico           NUMERIC(16, 4),
    comprometido     NUMERIC(16, 4),
    disponible       NUMERIC(16, 4),
    xrecibir         NUMERIC(16, 4),
    comprometido_cv  NUMERIC(16, 4),
    importacion      NUMERIC(16, 4)
);

/
