--------------------------------------------------------
--  DDL for Type REC_SP_ANALITICA_DE_CUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_ANALITICA_DE_CUENTAS" AS OBJECT (
    n01      VARCHAR2(10),
    n02      VARCHAR2(10),
    n03      VARCHAR2(10),
    cuenta   VARCHAR2(16),
    nombre   VARCHAR2(50),
    codigo   VARCHAR2(20),
    concep   VARCHAR2(150 CHAR),
    razonc   VARCHAR2(80 CHAR),
    tdocum   VARCHAR2(2),
    desdoc   VARCHAR2(50 CHAR),
    abrevi   VARCHAR2(6),
    serie    VARCHAR2(20),
    numero   VARCHAR2(20),
    xnrodoc  VARCHAR2(30),
    debe01   NUMERIC(16, 2),
    haber01  NUMERIC(16, 2),
    debe02   NUMERIC(16, 2),
    haber02  NUMERIC(16, 2),
    libro    VARCHAR2(3),
    deslib   VARCHAR2(50),
    asiento  INTEGER,
    fecha    DATE,
    periodo  INTEGER,
    mes      INTEGER,
    item     INTEGER,
    sitem    INTEGER,
    saldoc   NUMERIC(16, 2)
);

/
