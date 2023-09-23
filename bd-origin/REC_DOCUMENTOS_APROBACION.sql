--------------------------------------------------------
--  DDL for Type REC_DOCUMENTOS_APROBACION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DOCUMENTOS_APROBACION" AS OBJECT (
    numint     NUMBER,
    tipdoc     NUMBER,
    dtipdoc    VARCHAR2(30),
    series     VARCHAR2(5),
    numdoc     NUMBER,
    femisi     DATE,
    codcli     VARCHAR2(20),
    ruc        VARCHAR2(15),
    razonc     VARCHAR2(80 CHAR),
    tipmon     VARCHAR2(5),
    preven     NUMERIC(16, 2),
    tipcam     NUMERIC(10, 6),
    prevensol  NUMERIC(16, 2),
    situac     VARCHAR2(1),
    fcreac     TIMESTAMP,
    factua     TIMESTAMP,
    ucreac     VARCHAR2(10),
    usercre    VARCHAR2(70),
    uactua     VARCHAR2(10),
    useract    VARCHAR2(70),
    codpag     NUMBER,
    observ     VARCHAR2(3000 CHAR),
    fecter     DATE
);

/
