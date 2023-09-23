--------------------------------------------------------
--  DDL for Type REC_SALDO_BANCARIO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SALDO_BANCARIO" AS OBJECT (
    abonos_pendiente    NUMERIC(16, 4),
    cargos_pendientes   NUMERIC(16, 4),
    saldo_contable      NUMERIC(16, 4),
    inicial_banco       NUMERIC(16, 4),
    saldo_banco         NUMERIC(16, 4)
);

/
