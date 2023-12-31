--------------------------------------------------------
--  DDL for Type REC_DETALLE_ASIENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DETALLE_ASIENTO" AS OBJECT (
    id_cia          NUMBER,
    periodo         NUMBER,
    mes             NUMBER,
    libro           VARCHAR2(3),
    asiento         NUMBER,
    item            NUMBER,
    sitem           NUMBER,
    concep          VARCHAR2(75 CHAR),
    fecha           DATE,
    tasien          NUMBER,
    topera          VARCHAR2(3),
    cuenta          VARCHAR2(16),
    dh              VARCHAR2(1),
    moneda          VARCHAR2(3),
    importe         NUMBER(16, 2),
    impor01         NUMBER(16, 2),
    impor02         NUMBER(16, 2),
    debe            NUMERIC(16, 2),
    debe01          NUMERIC(16, 2),
    debe02          NUMERIC(16, 2),
    haber           NUMERIC(16, 2),
    haber01         NUMERIC(16, 2),
    haber02         NUMERIC(16, 2),
    tcambio01       NUMBER(16, 2),
    tcambio02       NUMBER(16, 2),
    ccosto          VARCHAR2(16),
    proyec          VARCHAR2(16),
    subcco          VARCHAR2(20),
    tipo            NUMBER,
    docume          NUMBER,
    codigo          VARCHAR2(20),
    razon           VARCHAR2(75 CHAR),
    tident          VARCHAR2(2),
    dident          VARCHAR(16),
    tdocum          VARCHAR2(2),
    serie           VARCHAR2(20),
    numero          VARCHAR2(20),
    fdocum          TIMESTAMP(6),
    usuari          VARCHAR(10),
    fcreac          TIMESTAMP,
    factua          TIMESTAMP,
    regcomcol       NUMBER,
    swprovicion     VARCHAR2(1),
    saldo           NUMERIC(16, 2),
    swgasoper       NUMBER,
    codporret       VARCHAR2(4),
    swchkconcilia   VARCHAR2(1),
    ctaalternativa  VARCHAR(16)
);

/
