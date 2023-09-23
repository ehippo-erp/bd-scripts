--------------------------------------------------------
--  DDL for Type REC_STOCK_POR_FAMILIA_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_STOCK_POR_FAMILIA_V2" AS OBJECT (
    periodo   SMALLINT,
    mes       SMALLINT,
    codalm    SMALLINT,
    desalm    VARCHAR2(50),
    tipinv    SMALLINT,
    dtipinv   VARCHAR2(50),
    codart    VARCHAR2(40),
    desart    VARCHAR2(100),
    coduni    VARCHAR2(3),
    nroparte  VARCHAR2(30),
    stock     NUMERIC(20, 4),
    kilos     NUMERIC(20, 4),
    costot    NUMERIC(20, 4),
    cosuni    NUMERIC(20, 4),
    StockAduana NUMERIC(20, 4),
    clase1    SMALLINT,
    descla1   VARCHAR2(60),
    codcla1   VARCHAR2(20),
    descod1   VARCHAR2(60),
    clase2    SMALLINT,
    descla2   VARCHAR2(60),
    codcla2   VARCHAR2(20),
    descod2   VARCHAR2(60)
);

/
