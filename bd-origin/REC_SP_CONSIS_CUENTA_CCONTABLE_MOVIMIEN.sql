--------------------------------------------------------
--  DDL for Type REC_SP_CONSIS_CUENTA_CCONTABLE_MOVIMIEN
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_CONSIS_CUENTA_CCONTABLE_MOVIMIEN" AS OBJECT (
    centrodecosto     VARCHAR2(16),
    destino           VARCHAR2(16),
    ccostoenpcuentas  VARCHAR2(1),
    destinoenpcuentas VARCHAR2(1)
);

/
