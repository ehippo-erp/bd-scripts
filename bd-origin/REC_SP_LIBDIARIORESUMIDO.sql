--------------------------------------------------------
--  DDL for Type REC_SP_LIBDIARIORESUMIDO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_LIBDIARIORESUMIDO" AS OBJECT ( /* TODO enter attribute and method declarations here */
    id_cia   NUMBER,
    ncuenta  VARCHAR2(120),
    periodo  NUMBER,
    mes      NUMBER,
    libro    VARCHAR2(120),
    cuenta   VARCHAR2(120),
    nombre   VARCHAR2(120),
    dh       VARCHAR2(120),
    debe01   NUMBER(16, 2),
    haber01  NUMBER(16, 2),
    debe02   NUMBER(16, 2),
    haber02  NUMBER(16, 2),
    asiento  NUMBER,
    concep   VARCHAR2(120),
    ccosto   VARCHAR2(120),
    subcco   VARCHAR2(120),
    codigo   VARCHAR2(120),
    serie    VARCHAR2(120),
    tdocum   VARCHAR2(120),
    numero   VARCHAR2(120),
    fdocum   DATE,
    cuepad   VARCHAR2(120)
);

/
