--------------------------------------------------------
--  DDL for Type REC_STK_COSTO_ART_POR_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_STK_COSTO_ART_POR_ALMACEN" AS OBJECT (
    codAlm integer,
	desalm    VARCHAR2(50),
	Abrevi    Varchar2(10),
    stock numeric(11,4),
    costot01 numeric(11,4),
    costot02 numeric(11,4),
    cosuni01 numeric(11,4),
    cosuni02 numeric(11,4)
);


/
