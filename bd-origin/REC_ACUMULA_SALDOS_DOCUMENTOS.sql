--------------------------------------------------------
--  DDL for Type REC_ACUMULA_SALDOS_DOCUMENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_ACUMULA_SALDOS_DOCUMENTOS" AS OBJECT (
    tipinv    NUMBER,
    codart    VARCHAR2(40),
    codalm    NUMBER,
    cantidad  NUMERIC(16, 4),
    entrega   NUMERIC(16, 4),
    saldo     NUMERIC(16, 4)
);

/
