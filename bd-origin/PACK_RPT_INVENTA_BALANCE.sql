--------------------------------------------------------
--  DDL for Package PACK_RPT_INVENTA_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RPT_INVENTA_BALANCE" AS
    TYPE rec_balance_general IS RECORD (
        codigo SMALLINT,
        titulo VARCHAR2(100),
        tipo   VARCHAR2(10),
        saldo  NUMERIC(16, 2)
    );
    TYPE tbl_balance_general IS
        TABLE OF rec_balance_general;
    FUNCTION sp000_balance_general (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_coddes  SMALLINT,
        pin_codhas  SMALLINT
    ) RETURN tbl_balance_general
        PIPELINED;

    TYPE rec_formato_302 IS RECORD (
        cuenta  VARCHAR2(16),
        nombre  VARCHAR2(160),
        moneda  VARCHAR2(3),
        codban  VARCHAR2(30),
        debe01  NUMBER(16, 2),
        haber01 NUMBER(16, 2)
    );
    TYPE tbl_formato_302 IS
        TABLE OF rec_formato_302;
    FUNCTION sp000_formato_302 (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER
    ) RETURN tbl_formato_302
        PIPELINED;

    TYPE "REC_FORMATO_320" IS RECORD (
        codigo SMALLINT,
        titulo VARCHAR2(100),
        tipo   VARCHAR2(5),
        signo  VARCHAR2(5),
        saldo  NUMERIC(16, 2)
    );
    TYPE "TBL_REC_FORMATO_320" IS
        TABLE OF rec_formato_320;
    FUNCTION sp_formato_320 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER
    ) RETURN tbl_rec_formato_320
        PIPELINED;

    FUNCTION sp_formato_320v2 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_codigo INTEGER
    ) RETURN tbl_rec_formato_320
        PIPELINED;

    FUNCTION sp_formato_320v3 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_codigo INTEGER
    ) RETURN NUMBER;

END;

/
