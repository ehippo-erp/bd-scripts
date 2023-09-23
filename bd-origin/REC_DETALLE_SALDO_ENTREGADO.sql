--------------------------------------------------------
--  DDL for Type REC_DETALLE_SALDO_ENTREGADO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."REC_DETALLE_SALDO_ENTREGADO" AS OBJECT (
    numint     NUMBER,
    numite     NUMBER,
    positi     NUMBER,
    tipinv     NUMBER,
    codart     VARCHAR2(40),
    desart     VARCHAR2(100),
    codadd01   VARCHAR2(20),
    codadd02   VARCHAR2(20),
    codund     VARCHAR2(5),
    codalm     NUMBER,
    observ     VARCHAR2(3000 CHAR),
    largo      NUMERIC(9, 3),
    ancho      NUMERIC(9, 3),
    etiqueta   VARCHAR2(100),
    lote       VARCHAR2(20),
    nrocarrete VARCHAR2(15),
    codcli     VARCHAR2(20),
    tara       NUMERIC(16, 5),
    royos      NUMERIC(16, 5),
    ubica      VARCHAR2(10),
    combina    VARCHAR2(20),
    empalme    VARCHAR2(20),
    diseno     VARCHAR2(20),
    acabado    VARCHAR2(20),
    chasis     VARCHAR2(20 CHAR),
    motor      VARCHAR2(20 CHAR),
    fvenci     DATE,
    valporisc  NUMERIC(12, 6),
    tipisc     VARCHAR2(2),
    cantid     NUMERIC(16, 5),
    preuni     NUMERIC(16, 5),
    pordes1    NUMERIC(16, 5),
    pordes2    NUMERIC(16, 5),
    pordes3    NUMERIC(16, 5),
    pordes4    NUMERIC(16, 5),
    modpre     VARCHAR2(1),
    stock      NUMERIC(16, 5),
    tipcam      NUMERIC(10, 6),
    costo      NUMERIC(16, 5)
);

/
