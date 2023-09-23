--------------------------------------------------------
--  DDL for Type REC_COSTOS_ORDEN_IMPORTACION_02_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_COSTOS_ORDEN_IMPORTACION_02_V2" AS OBJECT (
    numint      INTEGER,
    numite      SMALLINT,
    tipinv      INTEGER,
    codart      VARCHAR2(50),
    desart      VARCHAR2(100),
    cantid      NUMERIC(16, 5),
    tipcam      NUMERIC(10, 4),
    tipcam2     NUMERIC(10, 4),
    tfobsol     NUMERIC(16, 2),
    tfobdol     NUMERIC(16, 2),
    segurosol   NUMERIC(16, 3),
    segurodol   NUMERIC(16, 3),
    segurofac   NUMERIC(10, 6),
    fletesol    NUMERIC(16, 3),
    fletedol    NUMERIC(16, 3),
    fletefac    NUMERIC(10, 6),
    gasvinsol   NUMERIC(16, 3),
    gasvindol   NUMERIC(16, 3),
    gasvinfac   NUMERIC(10, 6),
    poraran     NUMERIC(16, 3),
    arancedol   NUMERIC(16, 3),
    tcostotsol  NUMERIC(16, 3),
    tcostotdol  NUMERIC(16, 3),
    dinumdoc    INTEGER,
    dinumite    INTEGER,
    ocnumdoc    INTEGER,
    ocnumite    INTEGER,
    totsegsol   NUMERIC(16, 3),
    totsegdol   NUMERIC(16, 3),
    totflesol   NUMERIC(16, 3),
    totfledol   NUMERIC(16, 3),
    totfobsol   NUMERIC(16, 3),
    totfobdol   NUMERIC(16, 3),
    tgasvinsol  NUMERIC(16, 3),
    tgasvindol  NUMERIC(16, 3)
);

/
