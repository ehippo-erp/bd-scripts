--------------------------------------------------------
--  DDL for Type REC_ARTICULO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_ARTICULO_CLASE" AS OBJECT (
    tipinv     number,
    codart     VARCHAR2(40),
    clase      number,
    desclase   VARCHAR2(70),
    codigo     VARCHAR2(20),
    descodigo  VARCHAR2(70)
);

/
