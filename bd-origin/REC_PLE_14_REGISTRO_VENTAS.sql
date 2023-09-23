--------------------------------------------------------
--  DDL for Type REC_PLE_14_REGISTRO_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_PLE_14_REGISTRO_VENTAS" AS OBJECT (
    periodo        SMALLINT,
    mcorrasien     VARCHAR2(30),
    numregope      VARCHAR2(80),
    vfeccom        VARCHAR2(10),
    vfecvenpag     VARCHAR2(10),
    vtipdoccom     VARCHAR2(2),
    vnumser        VARCHAR2(20),
    vnumdoccoi     VARCHAR2(20),
    vmoneda        VARCHAR2(5),
    imptotope      NUMBER,
    vtipdidcli     VARCHAR2(10),
    vnumdidcli     VARCHAR2(20),
    vapenomrso     VARCHAR2(100),
    vvalfacexp     NUMERIC(16, 2),
    vbasimpgra     NUMERIC(16, 2),
    vdesigvipm     NUMERIC(16, 2),
    vdesbasimpgra  NUMERIC(16, 2),
    vimptotexo     NUMERIC(16, 2),
    vimptotina     NUMERIC(16, 2),
    visc           NUMERIC(16, 2),
    vigvipm        NUMERIC(16, 2),
    vbasimivap     NUMERIC(16, 2),
    bivap          NUMERIC(16, 2),
    vicbper        NUMERIC(16, 2),
    votrtricgo     NUMERIC(16, 2),
    vimptotcom     NUMERIC(16, 2),
    vtipcam        NUMERIC(6, 3),
    tipdocre       NUMBER,
    seriere        VARCHAR2(5),
    numdocre       NUMBER,
    femisire       DATE,
    vfobexp        VARCHAR2(2),
    estado         NUMBER
);

/
