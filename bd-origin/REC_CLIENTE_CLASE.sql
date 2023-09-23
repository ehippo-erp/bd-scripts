--------------------------------------------------------
--  DDL for Type REC_CLIENTE_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CLIENTE_CLASE" AS OBJECT (
    tipcli     VARCHAR2(1),
    codcli     VARCHAR2(20),
    clase      NUMBER,
    desclase   VARCHAR2(70),
    codigo     VARCHAR2(20),
    descodigo  VARCHAR2(70),
    abrcodigo  VARCHAR2(10)
);

/
