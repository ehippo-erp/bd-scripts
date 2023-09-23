--------------------------------------------------------
--  DDL for Type REC_SALDOS_DOCUMENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SALDOS_DOCUMENTOS" AS OBJECT (
    numint    NUMBER,
    numite    NUMBER,
    tipinv    NUMBER,
    codart    VARCHAR2(40),
    codalm    NUMBER,
    cantidad  NUMERIC(16, 4),
    entrega   NUMERIC(16, 4),
    saldo     NUMERIC(16, 4)
);

/
