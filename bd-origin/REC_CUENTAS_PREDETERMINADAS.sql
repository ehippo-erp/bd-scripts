--------------------------------------------------------
--  DDL for Type REC_CUENTAS_PREDETERMINADAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CUENTAS_PREDETERMINADAS" AS OBJECT (
    id_cia      NUMBER,
    periodo     NUMBER,
    mes         NUMBER,
    libro       VARCHAR2(3),
    item        NUMBER,
    sitem       NUMBER,
    concep      VARCHAR2(75 CHAR),
    fecha       DATE,
    tasien      NUMBER,
    topera      VARCHAR2(3),
    cuenta      VARCHAR2(16),
    dh          CHAR(1),
    moneda      CHAR(3),
    importe     NUMBER(16, 2),
    impor01     NUMBER(16, 2),
    impor02     NUMBER(16, 2),
    debe        NUMBER(16, 2),
    debe01      NUMBER(16, 2),
    debe02      NUMBER(16, 2),
    haber       NUMBER(16, 2),
    haber01     NUMBER(16, 2),
    haber02     NUMBER(16, 2),
    tcambio01   NUMBER(14, 6),
    tcambio02   NUMBER(14, 6),
    ccosto      VARCHAR2(16),
    subccosto   VARCHAR2(16),
	proyec      VARCHAR2(16),
    tipo        NUMBER,
    docume      NUMBER,
    codigo      VARCHAR2(20),
    razon       VARCHAR2(100 CHAR),
    tident      CHAR(2),
    dident      VARCHAR2(20),
    tdocum      CHAR(2),
    serie       VARCHAR2(20),
    numero      VARCHAR2(20),
    fdocum      TIMESTAMP(6),
    regcomcol   NUMBER,
	fondo           NUMBER(16,2)
);

/
