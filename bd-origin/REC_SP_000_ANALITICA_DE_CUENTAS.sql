--------------------------------------------------------
--  DDL for Type REC_SP_000_ANALITICA_DE_CUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_000_ANALITICA_DE_CUENTAS" AS OBJECT (
    n01         VARCHAR2(15),
    n02         VARCHAR2(15),
    n03         VARCHAR2(15),
    cuenta      VARCHAR2(16),
    nombre      VARCHAR2(160),
    codigo      VARCHAR2(20),
    razonc      VARCHAR2(80 CHAR),
    dident      VARCHAR2(20 CHAR),
    tdocum      VARCHAR2(2),
    desdoc      VARCHAR2(50 CHAR),
    abrevi      VARCHAR2(6),
    serie       VARCHAR2(20 CHAR),
    numero      VARCHAR2(20 CHAR),
    tipdoc      INTEGER,
    femisi      DATE,
    fvenci      DATE,
    referencia  VARCHAR2(200),
    debe01      NUMERIC(16, 2),
    haber01     NUMERIC(16, 2),
    debe02      NUMERIC(16, 2),
    haber02     NUMERIC(16, 2)
);

/
