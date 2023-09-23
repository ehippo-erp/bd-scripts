--------------------------------------------------------
--  DDL for Type REC_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_GASTOS_VINCULADOS_ORDEN_IMPORTACION_V2" AS OBJECT (
    swgasoper  INTEGER,
    libro      VARCHAR2(3),
    asiento    INTEGER,
    tdocum     VARCHAR2(2),
    nserie     VARCHAR2(20),
    numero     VARCHAR2(20),
    femisi     DATE,
    moneda     VARCHAR2(3),
    tipcam     NUMERIC(10, 6),
    codcli     VARCHAR2(20),
    razon      VARCHAR2(100 CHAR),
    concep     VARCHAR2(150 CHAR),
    signo      FLOAT,
    tgeneral1  NUMERIC(16, 3),
    tgeneral2  NUMERIC(16, 3),
    tgeneral3  NUMERIC(16, 3)
);

/
