--------------------------------------------------------
--  DDL for Package PACK_RPT_SALDO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RPT_SALDO_CUENTA" AS
    TYPE datarecord_anual IS RECORD (
        id_cia    NUMBER,
        cuenta    pcuentas.cuenta%TYPE,
        nombre    pcuentas.nombre%TYPE,
        saldo0001 NUMERIC(16, 4),
        saldo0101 NUMERIC(16, 4),
        saldo0201 NUMERIC(16, 4),
        saldo0301 NUMERIC(16, 4),
        saldo0401 NUMERIC(16, 4),
        saldo0501 NUMERIC(16, 4),
        saldo0601 NUMERIC(16, 4),
        saldo0701 NUMERIC(16, 4),
        saldo0801 NUMERIC(16, 4),
        saldo0901 NUMERIC(16, 4),
        saldo1001 NUMERIC(16, 4),
        saldo1101 NUMERIC(16, 4),
        saldo1201 NUMERIC(16, 4),
        saldo9901 NUMERIC(16, 4),
        saldo0002 NUMERIC(16, 4),
        saldo0102 NUMERIC(16, 4),
        saldo0202 NUMERIC(16, 4),
        saldo0302 NUMERIC(16, 4),
        saldo0402 NUMERIC(16, 4),
        saldo0502 NUMERIC(16, 4),
        saldo0602 NUMERIC(16, 4),
        saldo0702 NUMERIC(16, 4),
        saldo0802 NUMERIC(16, 4),
        saldo0902 NUMERIC(16, 4),
        saldo1002 NUMERIC(16, 4),
        saldo1102 NUMERIC(16, 4),
        saldo1202 NUMERIC(16, 4),
        saldo9902 NUMERIC(16, 4)
    );
    TYPE datatable_anual IS
        TABLE OF datarecord_anual;
    FUNCTION sp_anual (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_cdesde  VARCHAR2,
        pin_chasta  VARCHAR2,
        pin_nivel   NUMBER
    ) RETURN datatable_anual
        PIPELINED;

END;

/
