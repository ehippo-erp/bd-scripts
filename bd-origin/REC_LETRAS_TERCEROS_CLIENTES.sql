--------------------------------------------------------
--  DDL for Type REC_LETRAS_TERCEROS_CLIENTES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_LETRAS_TERCEROS_CLIENTES" AS OBJECT (
    numint       NUMBER,
    tipdoc       NUMBER,
    abrevi       VARCHAR2(4),
    desdoc       VARCHAR2(30),
    docume       VARCHAR2(40),
    refere01     VARCHAR2(25),
    femisi       DATE,
    fvenci       DATE,
    fcance       DATE,
    mora         NUMBER,
    tipmon       VARCHAR2(5),
    tpercepcion  NUMERIC(16, 2),
    tdocumento   NUMERIC(16, 2),
    debe         NUMERIC(16, 2),
    haber        NUMERIC(16, 2),
    saldo        NUMERIC(16, 2),
    planilla     VARCHAR2(20),
    descri       VARCHAR2(50),
    libro        VARCHAR2(3),
    periodo      NUMBER,
    mes          NUMBER,
    secuencia    NUMBER,
    planiletra   VARCHAR2(40),
    codban       NUMBER,
    desban       VARCHAR2(70),
    numbco       VARCHAR2(50),
    tipcan       NUMBER,
    dtipcan      VARCHAR2(60),
    operac       NUMBER,
    protes       NUMBER,
    codubi       NUMBER,
    desubi       VARCHAR2(50),
    tipcam       NUMERIC(14, 6),
    signo        NUMBER,
    xlibro       VARCHAR2(3),
    xperiodo     NUMBER,
    xmes         NUMBER,
    xsecuencia   NUMBER,
    xplanilla    VARCHAR2(40),
    xdescri      VARCHAR2(50),
    xprotes      NUMERIC(16, 4),
    fonocli      VARCHAR2(50),
    limcre2      NUMERIC(9, 2),
    tippla       NUMBER,
    desmot       VARCHAR2(50),
    codcli       VARCHAR2(20),
    razonc       VARCHAR2(100)
);

/
