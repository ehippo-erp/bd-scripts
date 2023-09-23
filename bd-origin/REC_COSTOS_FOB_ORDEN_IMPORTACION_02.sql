--------------------------------------------------------
--  DDL for Type REC_COSTOS_FOB_ORDEN_IMPORTACION_02
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_COSTOS_FOB_ORDEN_IMPORTACION_02" AS OBJECT (
    numint     INTEGER,
    numite     SMALLINT,
    tipinv     SMALLINT,
    codart     VARCHAR2(50),
    desart     VARCHAR2(100),
    cantid     NUMERIC(16, 5),
    tipcam     NUMERIC(10, 6),
    tipcam2    NUMERIC(10, 6),
    tfobsol    NUMERIC(16, 2),
    tfobdol    NUMERIC(16, 2),
    dinumdoc   INTEGER,
    dinumite   INTEGER,
    ocnumdoc   INTEGER,
    ocnumint      INTEGER,
    ocnumite   INTEGER,
    ocflete NUMBER(16,2),
    ocseguro NUMBER(16,2),
    wneto      NUMERIC(16, 5),
    wtipmon    VARCHAR2(5),
    wodcantid  NUMERIC(16, 5),
    arancel    NUMERIC(9, 5)
);

/
