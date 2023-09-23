--------------------------------------------------------
--  DDL for Type REC_SP_CONSIS_CENTRO_COSTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_CONSIS_CENTRO_COSTOS" AS OBJECT (
    periodo            NUMBER(38),
    mes                NUMBER(38),
    libro              VARCHAR2(3),
    asiento            NUMBER(38),
    item               NUMBER(38),
    cuentaenmovimiento VARCHAR2(16),
    cuentaenpcuentas   VARCHAR2(1)
);

/
