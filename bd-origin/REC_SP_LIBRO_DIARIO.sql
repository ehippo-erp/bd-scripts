--------------------------------------------------------
--  DDL for Type REC_SP_LIBRO_DIARIO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_LIBRO_DIARIO" AS OBJECT (
    id_cia    NUMBER,
    fecha     DATE,
    concep    VARCHAR2(150 CHAR),
    moneda    VARCHAR2(120),
    codsunat2 VARCHAR2(120),
    codope1   VARCHAR2(120),
    serie     VARCHAR2(120),
    numero    VARCHAR2(60),
    cuenta    VARCHAR2(120),
    nombre    VARCHAR2(120),
    debe01    NUMBER,
    haber01   NUMBER
);

/
