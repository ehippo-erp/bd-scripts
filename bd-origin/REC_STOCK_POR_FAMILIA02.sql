--------------------------------------------------------
--  DDL for Type REC_STOCK_POR_FAMILIA02
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_STOCK_POR_FAMILIA02" AS OBJECT (
    periodo   SMALLINT,
    mes       SMALLINT,
    codalm    SMALLINT,
    desalm    VARCHAR2(50),
	Abrevi    Varchar2(10),
    tipinv    SMALLINT,
    dtipinv   VARCHAR2(50),
    codart    VARCHAR2(40),
    desart    VARCHAR2(100),
    coduni    VARCHAR2(3),
    nroparte  VARCHAR2(30),
    stock     NUMERIC(11, 4),
    kilos     NUMERIC(11, 4),
    costot01 numeric(11,4),
    costot02 numeric(11,4),
    cosuni01 numeric(11,4),
    cosuni02 numeric(11,4)
);

/
