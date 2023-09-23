--------------------------------------------------------
--  DDL for Type REC_SP_CUOTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_CUOTAS" AS OBJECT (
    numint       INTEGER,
    tipdoc       INTEGER,
    nrocuota     INTEGER,
    fvenci       DATE,
    simbolo      VARCHAR2(3),
    moncuota     NUMBER(16, 2),
    tasa         NUMBER(16, 2),
    label        VARCHAR2(15),
    moncuota_nc  NUMERIC(16, 2),
    montasa      NUMERIC(16, 2),
    montasa_mn   NUMERIC(16, 2),
	simbolo_mn   VARCHAR2(3),
    msjsunat     VARCHAR2(1000)
);

/
