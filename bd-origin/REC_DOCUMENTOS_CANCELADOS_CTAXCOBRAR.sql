--------------------------------------------------------
--  DDL for Type REC_DOCUMENTOS_CANCELADOS_CTAXCOBRAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "USR_TSI_SUITE"."REC_DOCUMENTOS_CANCELADOS_CTAXCOBRAR" AS OBJECT (
    ATipdoc     VARCHAR2(4),
    libro      VARCHAR2(3),
    periodo    NUMBER,
    mes        NUMBER,
    secuencia  NUMBER,
    tipdoc     NUMBER,
    docume     VARCHAR2(40),
    codcli     VARCHAR2(20),
    razonc     VARCHAR2(80 CHAR),
    limcre1    NUMBER(9, 2),
    limcre2    NUMBER(9, 2),
    chedev     NUMBER,
    letpro     NUMBER,
    renova     NUMBER,
    refina     NUMBER,
    fecing     DATE,
    refere01   VARCHAR2(25),
    femisi     DATE,
    fvenci     DATE,
    fcance     DATE,
    fproce     DATE,
    numbco     VARCHAR2(50),
    impor01    NUMBER(16, 2),
    impor02    NUMBER(16, 2),
    doccan     VARCHAR2(25),
    tipcan     NUMBER,
    codban     NUMBER,
    dtipdoc    VARCHAR2(50),
    dtipcan    VARCHAR2(50),
    tipmon     VARCHAR2(5),
    importe    NUMBER(16, 2),
    comisi     NUMBER(14, 4),
    tipcam     NUMBER(14, 6),
    codven     NUMBER,
    concpag    NUMBER,
    despag     VARCHAR2(50 CHAR),
    vendedor   VARCHAR2(50)
);

/
