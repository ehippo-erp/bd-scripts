--------------------------------------------------------
--  DDL for Type REC_GANANCIAS_PERDIDAS_001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_GANANCIAS_PERDIDAS_001" AS OBJECT (
  CODIGO SMALLINT,
  TITULO VARCHAR2(100),
  TIPO VARCHAR2(5),
  SIGNO VARCHAR2(5),
  SALDO NUMERIC(16, 2)
);

/
