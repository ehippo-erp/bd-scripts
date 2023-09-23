--------------------------------------------------------
--  DDL for Type REC_MAYOR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_MAYOR_GENERAL" AS OBJECT (
    cuenta       VARCHAR2(16),
    nivel        NUMBER,
    nombre       VARCHAR2(150),
    asiento      NUMBER,
    libro        VARCHAR2(3),
    fecha        DATE,
    codigo       VARCHAR2(20),
    tdocum       VARCHAR2(2),
    serie        VARCHAR2(20),
    numero       VARCHAR2(20),
    concep       VARCHAR2(150 CHAR),
    fdocum       TIMESTAMP,
    debe01       NUMERIC(16, 2),
    debe02       NUMERIC(16, 2),
    haber01      NUMERIC(16, 2),
    haber02      NUMERIC(16, 2),
    codsunat     VARCHAR2(10),
    libro2       VARCHAR2(10),
    asiento2     VARCHAR2(10),
    codsunat2    VARCHAR2(10),
    codope1      VARCHAR2(20),
    codope2      VARCHAR2(20),
    tinidebe01   NUMERIC(16, 2),
    tinidebe02   NUMERIC(16, 2),
    tinihaber01  NUMERIC(16, 2),
    tinihaber02  NUMERIC(16, 2)
);

/
