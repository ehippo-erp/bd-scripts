--------------------------------------------------------
--  DDL for Type REC_CAJACHICA_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "USR_TSI_SUITE"."REC_CAJACHICA_001" AS OBJECT (
    id_cia          NUMBER,
    codpro          VARCHAR2(20),
    razon           VARCHAR2(100 CHAR),
    tdocum          VARCHAR2(20),
    nserie          VARCHAR2(20),
    numero          VARCHAR2(20),
    femisi          TIMESTAMP(6),
    tident          VARCHAR2(20),
    dident          VARCHAR2(16),
    fvenci          TIMESTAMP(6),
    impor01         NUMBER(16, 2),
    base01          NUMBER(16, 2),
    igv01           NUMBER(16, 2),
    ddetrac         VARCHAR2(15),
    fdetrac         DATE,
    impdetrac       NUMBER(16, 4),
    tipcaja         NUMBER,
    doccaja         NUMBER,
    tipo            NUMBER,
    docume          NUMBER,
    sitdoc          NUMBER,
    abrsitdoc       VARCHAR2(15),
    ccosdoc         VARCHAR2(16),
    ctagasto        VARCHAR2(16),
    concepd         VARCHAR2(75),
    impor01p        NUMBER(16, 2),
    impor02p        NUMBER(16, 2),
    impor01px       NUMBER(16, 2),
    impor02px       NUMBER(16, 2),
    tcambiop        NUMBER(14, 6),
    monprov         VARCHAR2(3),
    feccaja         DATE,
    codper          VARCHAR2 ( 20 CHAR ),
    concep          VARCHAR2(75),
    motivo          INTEGER,
    desmot          varchar2(20),
    moneda          CHAR(3),
    codarea         INTEGER,
    ccosto          VARCHAR(16),
    subccosto       VARCHAR2(16),
    proyec          VARCHAR2(16),
    ctaalternativa  VARCHAR2(16),
    aprobado        VARCHAR2(1),
    caprob          VARCHAR2(10),
    --descaprob    VARCHAR2(70),
    faprob          DATE,
    tippago         SMALLINT,
    ctapago         VARCHAR2(16),
    periodo         INTEGER,
    mes             INTEGER,
    libro           VARCHAR2(3),
    asiento         INTEGER,
    situac          SMALLINT,
	dessit          VARCHAR2(15),
    abrevi          VARCHAR2(6),
    nomper          VARCHAR2(80 CHAR),
    desmon          VARCHAR2(50),
    simbolo         VARCHAR2(3),
    desarea         VARCHAR2(50),
    desccos         VARCHAR2(50),
    nomuser         VARCHAR2(70),
    despago         VARCHAR2(50),
    nomcta          VARCHAR2(50),
    deslib          VARCHAR2(50),
    desdoc          VARCHAR2(50 CHAR),
    ncosdoc         VARCHAR2(100),
    nctagasto       VARCHAR2(100),
    impord          NUMBER(16, 2),
    fondo           NUMBER(16,2)
);

/
