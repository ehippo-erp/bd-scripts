--------------------------------------------------------
--  DDL for Type REC_DETALLES_DCTA102_CAJA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DETALLES_DCTA102_CAJA" AS OBJECT (
  LIBRO VARCHAR2(3),
  DESLIBRO VARCHAR2(50),
  PERIODO NUMBER,
  MES NUMBER,
  SECUENCIA NUMBER,
  CONCEP VARCHAR2(150),
  SITUAC VARCHAR2(1),
  DESSITUAC VARCHAR2(20),
  PAGOMN NUMERIC(16, 2),
  PAGOME NUMERIC(16, 2)
  );

/
