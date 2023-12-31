--------------------------------------------------------
--  DDL for Type REC_SP_GETBYNUMINT_TOMAINVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_GETBYNUMINT_TOMAINVENTARIO" AS OBJECT (
    tipdoc          NUMBER(38),
    numint          NUMBER(38),
    id              CHAR(1),
    codmot          NUMBER(38),
    series          VARCHAR2(5),
    numdoc          NUMBER(38),
    femisi          DATE,
    codcli          VARCHAR2(20),
    razonc          VARCHAR2(80 CHAR),
    direc1          VARCHAR2(100 CHAR),
    ruc             VARCHAR2(20),
    tipcam          NUMBER(10, 6),
    situac          CHAR(1),
    obscab          VARCHAR2(3000 CHAR),
    fentreg         DATE,
    opnumdoc        NUMBER(38),
    ordcom          VARCHAR2(20),
    fordcom         DATE,
    guipro          VARCHAR2(20),
    fguipro         DATE,
    facpro          VARCHAR2(20),
    ffacpro         DATE,
    dd_numite       NUMBER(38),
    dd_tipinv       NUMBER(38),
    dd_codalm       NUMBER(38),
    dd_codart       VARCHAR2(40),
    dd_codund       VARCHAR2(3),
    dd_cantid       NUMBER(16, 5),
    dd_monlinneto   NUMBER(16, 2),
    dd_monuni       NUMBER(16, 2),
    dd_obsdet       VARCHAR2(3000),
    dd_opronumdoc   VARCHAR2(30),
    dd_dopnumdoc    NUMBER(38),
    dd_dopcargo     VARCHAR2(10),
    dd_dopnumite    NUMBER(38),
    dd_desart       VARCHAR2(100),
    dd_faccon       NUMBER(9, 5),
    desarea         VARCHAR2(50),---FALTA ,
    dircli1         VARCHAR2(100 CHAR),
    dircli2         VARCHAR2(100 CHAR),
    desmon          VARCHAR2(50),
    simbolo         CHAR(3),
    dessit          VARCHAR2(50),
    aliassit        VARCHAR2(50),
    desmot          VARCHAR2(50),
    piepag05        VARCHAR2(80),
    ciaruc          VARCHAR2(20),
    ciafax          VARCHAR2(50),
    ciatelefo       VARCHAR2(50),
    ocseries        NUMBER(38),
    ocnumdoc        NUMBER(38),
    ocfemisi        NUMBER(38),
    dd_ocnumite     NUMBER(38),
    dd_codcalid     VARCHAR2(10),
    dd_codcolor     VARCHAR2(10),
    dd_dcalidad     VARCHAR2(100),
    dd_dcolor       VARCHAR2(100),
    situacimp       CHAR(1),
    dessituacimp    VARCHAR2(100),
    dd_numint       NUMBER(38),
    dd_largo        NUMBER(9, 3),
    dd_piezas       NUMBER(16, 5),
    dd_tottramo     NUMBER(38),
    dd_preuni       NUMBER(16, 5),
    dd_costot01     NUMBER(16, 5),
    dd_costot02     NUMBER(16, 5),
    codsuc          NUMBER(38),
    moneda          VARCHAR2(5),
    optipinv        NUMBER(38),
    codalm          NUMBER(38)
);

/
