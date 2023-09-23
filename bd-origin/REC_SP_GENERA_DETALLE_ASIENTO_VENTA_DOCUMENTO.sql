--------------------------------------------------------
--  DDL for Type REC_SP_GENERA_DETALLE_ASIENTO_VENTA_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_GENERA_DETALLE_ASIENTO_VENTA_DOCUMENTO" AS OBJECT (

    cuenta    VARCHAR(20 CHAR),
    dh        VARCHAR(1),
    codcli    VARCHAR(20),
    razonc    VARCHAR(100 CHAR),
    tident    VARCHAR(5),
    ruc       VARCHAR(20),
    femisi    DATE,
    tipdoc    INTEGER,
    series    VARCHAR(20),
    numdoc    INTEGER,
    tipmon    VARCHAR(5),
    tipcam    NUMERIC(9, 6),
    importe01 NUMERIC(16, 2),
    importe02 NUMERIC(16, 2)
);

/
