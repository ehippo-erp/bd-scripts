--------------------------------------------------------
--  DDL for Type REC_SALDOS_ORDENES_PEDIDOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SALDOS_ORDENES_PEDIDOS" AS OBJECT (
    tipinv    NUMBER,
    codart    VARCHAR2(40),
    codalm    NUMBER,
    cantidad  NUMERIC(16, 4),
    entrega   NUMERIC(16, 4),
    saldo     NUMERIC(16, 4)
);

/
