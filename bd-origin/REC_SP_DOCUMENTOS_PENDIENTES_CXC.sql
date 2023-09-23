--------------------------------------------------------
--  DDL for Type REC_SP_DOCUMENTOS_PENDIENTES_CXC
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_SP_DOCUMENTOS_PENDIENTES_CXC" AS OBJECT (
    id_cia       NUMBER(38),
	periodo      number,
	mes          number,
    numint       INTEGER,
    tipdoc       NUMBER(38),
    docume       VARCHAR2(40),
    refere01     VARCHAR2(25),
    femisi       DATE,
    fvenci       DATE,
    seriesdoc    VARCHAR2(5),
    numerodoc    NUMBER(38),
    fcance       DATE,
    numbco       VARCHAR2(50),
    tipmon       VARCHAR2(3),
    importe      NUMBER,
    saldox       NUMBER,
    codban       NUMBER(38),
    codcli       VARCHAR2(20),
    razonc       VARCHAR2(100),
    limcre1      NUMBER(9, 2),
    limcre2      NUMBER(9, 2),
    chedev       INTEGER,
    letpro       INTEGER,
    renova       INTEGER,
    refina       INTEGER,
    fecing       DATE,
    dtido        VARCHAR2(6),
    destipdoc    VARCHAR2(50),
    tipcam       NUMBER,
    codven       INTEGER,
    desven       VARCHAR2(15),
    desban       VARCHAR2(70),
    operac       INTEGER,
    credito      VARCHAR2(10),
    vencar       VARCHAR2(50),
    saldopercep  NUMBER(16, 2),
    tpercepcion  NUMBER(16, 2),
    concpag      NUMBER(38),
    descpag      VARCHAR2(50 CHAR),
	operacion    varchar2(20)
);

/
