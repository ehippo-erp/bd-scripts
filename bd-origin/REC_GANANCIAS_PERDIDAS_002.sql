--------------------------------------------------------
--  DDL for Type REC_GANANCIAS_PERDIDAS_002
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_GANANCIAS_PERDIDAS_002" AS OBJECT (
    codigo     NUMBER,
    titulo     VARCHAR2(100),
    tipo       VARCHAR2(5),
    signo      VARCHAR2(5),
    cuenta     VARCHAR2(20),
    descuenta  VARCHAR2(100),
    saldo01    NUMERIC(16, 2),
    saldo02    NUMERIC(16, 2),
    saldo03    NUMERIC(16, 2),
    saldo04    NUMERIC(16, 2),
    saldo05    NUMERIC(16, 2),
    saldo06    NUMERIC(16, 2),
    saldo07    NUMERIC(16, 2),
    saldo08    NUMERIC(16, 2),
    saldo09    NUMERIC(16, 2),
    saldo10    NUMERIC(16, 2),
    saldo11    NUMERIC(16, 2),
    saldo12    NUMERIC(16, 2),
    saldo99    NUMERIC(16, 2)
);

/
