--------------------------------------------------------
--  DDL for Type REC_GASTOS_GENERALES_POR_PROYECTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_GASTOS_GENERALES_POR_PROYECTO" AS OBJECT (
    codproy    VARCHAR2(16),
    desproy    VARCHAR2(50),
    tipgas     NUMBER,
    desgas     VARCHAR2(65),
    cuenta     VARCHAR2(16),
    descuenta  VARCHAR2(50),
    periodo    NUMBER,
    mespro     NUMBER,
    saldo01    NUMERIC(16, 4),
    saldo02    NUMERIC(16, 4)
);

/
