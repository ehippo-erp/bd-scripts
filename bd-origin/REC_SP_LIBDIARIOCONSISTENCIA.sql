--------------------------------------------------------
--  DDL for Type REC_SP_LIBDIARIOCONSISTENCIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_LIBDIARIOCONSISTENCIA" AS OBJECT ( /* TODO enter attribute and method declarations here */
    id_cia          NUMBER,
    periodo         NUMBER,
    mes             NUMBER,
    libro           VARCHAR2(220),
    asiento         NUMBER,
    item            NUMBER,
    sitem           NUMBER,
    concep          VARCHAR2(220),
    fecha           DATE,
    tasien          NUMBER,
    topera          VARCHAR2(220),
    cuenta          VARCHAR2(220),
    dh              VARCHAR2(220),
    moneda          VARCHAR2(220),
    importe         NUMBER(16,2),
    impor01         NUMBER(16,2),
    impor02         NUMBER(16,2),
    debe            NUMBER(16,2),
    debe01          NUMBER(16,2),
    debe02          NUMBER(16,2),
    haber           NUMBER(16,2),
    haber01         NUMBER(16,2),
    haber02         NUMBER(16,2),
    tcambio01       NUMBER(16,2),
    tcambio02       NUMBER(16,2),
    ccosto          VARCHAR2(220),
    proyec          VARCHAR2(220),
    subcco          VARCHAR2(220),
    tipo            NUMBER,
    docume          NUMBER,
    codigo          VARCHAR2(220),
    razon           VARCHAR2(220),
    tident          VARCHAR2(220),
    dident          VARCHAR2(220),
    tdocum          VARCHAR2(220),
    serie           VARCHAR2(220),
    numero          VARCHAR2(220),
    fdocum          DATE,
    usuari          VARCHAR2(220),
    fcreac          DATE,
    factua          DATE,
    regcomcol       NUMBER,
    swprovicion     VARCHAR2(220),
    saldo           NUMBER(16,2),
    swgasoper       NUMBER,
    codporret       VARCHAR2(220),
    swchkconcilia   VARCHAR2(220),
    ctaalternativa  VARCHAR2(220),
    descri          VARCHAR2(220),
    nombre          VARCHAR2(220),
    descos          VARCHAR2(220)
);

/
