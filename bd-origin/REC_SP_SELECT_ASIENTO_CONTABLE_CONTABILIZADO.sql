--------------------------------------------------------
--  DDL for Type REC_SP_SELECT_ASIENTO_CONTABLE_CONTABILIZADO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_SELECT_ASIENTO_CONTABLE_CONTABILIZADO" AS OBJECT (
    id_cia          NUMBER,
    periodo         NUMBER,
    mes             NUMBER,
    libro           VARCHAR2(20),
    asiento         NUMBER,
    item            NUMBER,
    sitem           NUMBER,
    cuenta          VARCHAR2(20),
    dcuenta         VARCHAR2(120),
    fecha           DATE,
    dh              VARCHAR2(20),
    debe            NUMBER,
    haber           NUMBER,
    debe01          NUMBER,
    haber01         NUMBER,
    debe02          NUMBER,
    haber02         NUMBER,
    concep          VARCHAR2(150 CHAR),
    importe         NUMBER,
    impor01         NUMBER,
    impor02         NUMBER,
    tcambio01       NUMBER,
    tcambio02       NUMBER,
    ccosto          VARCHAR2(20),
    proyec          VARCHAR2(20),
    subcco          VARCHAR2(20),
    codigo          VARCHAR2(20),
    numero          VARCHAR2(50),
    deslib          VARCHAR2(120),
    tdocto          VARCHAR2(6),
    coduser         VARCHAR2(20),
    nomuser         VARCHAR2(80),
    tc              NUMBER,
    ucreac          VARCHAR2(20),
    usuari          VARCHAR2(20),
    fcreac          DATE,
    nomucreac       VARCHAR2(50),
    factua          DATE,
    fecha_asiento   DATE
);

/
