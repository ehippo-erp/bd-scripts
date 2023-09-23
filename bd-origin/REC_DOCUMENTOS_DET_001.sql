--------------------------------------------------------
--  DDL for Type REC_DOCUMENTOS_DET_001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DOCUMENTOS_DET_001" AS OBJECT (
  TIPDOC number,
  NUMINT number,
  NUMITE number,
  CODART VARCHAR2(40),
  TIPINV number,
  MONAFE number(16, 2),
  MONINA number(16, 2),
  MONIGV number(16, 5),
  CANTIDAD number(16, 5),
  ENTREGA number(16, 5),
  SALDO number(16, 5)
);

/
