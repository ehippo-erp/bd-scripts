--------------------------------------------------------
--  DDL for Type REC_DETALLE_RELACION_CUBO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DETALLE_RELACION_CUBO" AS OBJECT (
    numintfac   INTEGER,
    tipdocfac   SMALLINT,
    femisifac   DATE,
    idfac       VARCHAR2(1),
    seriefac    VARCHAR2(5),
    numdocfac   INTEGER,
    situacfac   CHAR(1),
    codsucfac   SMALLINT,
    numitefac   INTEGER,
    codmotfac   INTEGER,
    codclifac   VARCHAR2(20),
    rucfac      VARCHAR2(20),
    razoncfac   VARCHAR2(80 CHAR),
    direc1fac   VARCHAR2(100 CHAR),
    tipmonfac   VARCHAR2(5),
    tipcamfac   NUMERIC(10, 6),
    codvenfac   SMALLINT,
    codcpagfac  SMALLINT,
    comisifac   NUMERIC(9, 3),
    numintgui   INTEGER,
    tipdocgui   SMALLINT,
    femisigui   DATE,
    idgui       VARCHAR2(1),
    seriegui    VARCHAR2(5),
    numdocgui   INTEGER,
    situacgui   CHAR(1),
    codsucgui   SMALLINT,
    numitegui   INTEGER,
    codmotgui   INTEGER,
    porcomisi   DOUBLE PRECISION,
    tipoventa   VARCHAR2(50),
    destin      VARCHAR2(20),
    codenvfac   SMALLINT,
    desenvfac   VARCHAR2(50 CHAR),
    codadd01    VARCHAR2(10),
    codadd02    VARCHAR2(10),
    deskardex   VARCHAR2(1)
);

/
