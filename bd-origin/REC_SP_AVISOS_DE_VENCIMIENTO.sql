--------------------------------------------------------
--  DDL for Type REC_SP_AVISOS_DE_VENCIMIENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_AVISOS_DE_VENCIMIENTO" AS OBJECT (
    codcli     VARCHAR2(60),
    razonc     VARCHAR2(120),
    codenv     VARCHAR2(10),
    sumcont    NUMBER,
    cancon     NUMBER,
    CONEMAILVACIO  NUMBER 
);

/
