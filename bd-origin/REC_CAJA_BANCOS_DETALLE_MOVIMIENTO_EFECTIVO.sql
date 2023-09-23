--------------------------------------------------------
--  DDL for Type REC_CAJA_BANCOS_DETALLE_MOVIMIENTO_EFECTIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CAJA_BANCOS_DETALLE_MOVIMIENTO_EFECTIVO" AS OBJECT (
    cuenta      VARCHAR2(16),
    nombre      VARCHAR2(50),
    moneda01    VARCHAR2(5),
    entidadfin  VARCHAR2(65),
    cuentaban   VARCHAR2(25),
    codsunban   VARCHAR2(10),
    desmon      VARCHAR2(50),
    periodo     NUMBER,
    mes         SMALLINT,
    libro       VARCHAR2(3),
    asiento     NUMBER,
    item        NUMBER,
    sitem       NUMBER,
    cuentam     VARCHAR2(16),
    nombrem     VARCHAR2(50),
    topera      VARCHAR2(3),
    fecha       DATE,
    dh          VARCHAR2(1),
    fdocum      TIMESTAMP,
    concep      VARCHAR2(100 CHAR),
    serie       VARCHAR2(20),
    numero      VARCHAR2(30),
    debe01      NUMERIC(16, 2),
    haber01     NUMERIC(16, 2),
    debe02      NUMERIC(16, 2),
    haber02     NUMERIC(16, 2),
    razon       VARCHAR2(100 CHAR),
    codope1     VARCHAR2(20),
    codope2     VARCHAR2(20)
);

/
