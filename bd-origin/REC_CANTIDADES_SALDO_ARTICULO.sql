--------------------------------------------------------
--  DDL for Type REC_CANTIDADES_SALDO_ARTICULO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_CANTIDADES_SALDO_ARTICULO" AS OBJECT (
  FEMISI DATE,
  TIPINV number,
  CODALM number,
  CODART varchar2(50),
  DESCRI varchar2(100),
  CODADD01 varchar2(10),
  CODADD02 varchar2(10),
  CODUNI varchar2(3),
  CONSTO SMALLINT,
  SWSTKNEG varchar2(1),
  ETIQUETA varchar2(100),
  SALDO NUMERIC(16, 4),
  SALIDAMAX NUMERIC(16, 4),
  PORTOTSAL NUMERIC(16, 4),
  COMPROMETIDO NUMERIC(16, 4),
  SALDO_ALM NUMERIC(16, 4)
);

/
