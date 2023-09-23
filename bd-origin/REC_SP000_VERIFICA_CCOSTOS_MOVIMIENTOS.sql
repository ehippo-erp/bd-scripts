--------------------------------------------------------
--  DDL for Type REC_SP000_VERIFICA_CCOSTOS_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP000_VERIFICA_CCOSTOS_MOVIMIENTOS" AS OBJECT (
        periodo    NUMBER(20),
    mes        NUMBER(16),
    libro      VARCHAR2(100),
    asiento    NUMBER(16),
    item       NUMBER(16),
    cuentamovi VARCHAR2(100),
    ccostomovi VARCHAR2(100)
);

/
