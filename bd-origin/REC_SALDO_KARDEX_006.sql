--------------------------------------------------------
--  DDL for Type REC_SALDO_KARDEX_006
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SALDO_KARDEX_006" AS OBJECT (
    tipinv    INTEGER,
    codart    VARCHAR(40),
    codalm    INTEGER,
    etiqueta  VARCHAR(100),
    saldo     NUMERIC(16, 4),
    royos     NUMERIC(16, 4),
    fingreso  DATE,
    numint    INTEGER,
    numite    INTEGER,
    opnumdoc  VARCHAR(30),
    optramo   SMALLINT,
    costot01  NUMERIC(16, 4),
    costot02  NUMERIC(16, 4)
);

/
