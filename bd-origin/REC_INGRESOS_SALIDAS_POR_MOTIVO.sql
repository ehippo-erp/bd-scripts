--------------------------------------------------------
--  DDL for Type REC_INGRESOS_SALIDAS_POR_MOTIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_INGRESOS_SALIDAS_POR_MOTIVO" AS OBJECT (
    ocultokardex  VARCHAR2(25),
    id            CHAR(1),
    codmot        SMALLINT,
    desmot        VARCHAR2(50),
    desdoc        VARCHAR2(40),
    desdocmot     VARCHAR2(120),
	dtipinv varchar(50),
	dalmacen  varchar(50),
    totcan        NUMERIC(16, 4),
    totsol        NUMERIC(16, 2),
    totdol        NUMERIC(16, 2)
);

/
