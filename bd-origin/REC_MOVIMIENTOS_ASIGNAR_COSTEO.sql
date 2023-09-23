--------------------------------------------------------
--  DDL for Type REC_MOVIMIENTOS_ASIGNAR_COSTEO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_MOVIMIENTOS_ASIGNAR_COSTEO" AS OBJECT (
    cuenta     VARCHAR2(16),
    descuenta  VARCHAR2(50),
    codigo     VARCHAR2(20),
    razon      VARCHAR2(100 CHAR),
    periodo    NUMBER,
    mes        NUMBER,
    fecha      DATE,
    libro      VARCHAR2(3),
    asiento    NUMBER,
    item       NUMBER,
    sitem      NUMBER,
    tdocum     VARCHAR2(2),
    numero     VARCHAR2(20),
    moneda01   VARCHAR2(3),
    debe       NUMERIC(16, 2),
    haber      NUMERIC(16, 2),
    saldo      NUMERIC(16, 2),
    concep     VARCHAR2(150 CHAR),
    proyecto   VARCHAR2(50),
    swgasoper  NUMBER,
    refere     VARCHAR2(30),
    razonc_cr  VARCHAR2(70)
);

/
