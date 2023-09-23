--------------------------------------------------------
--  DDL for Package PACK_RPT_COMPROBA_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RPT_COMPROBA_BALANCE" AS
    TYPE datarecord_buscar_317 IS RECORD (
        id_cia     documentos_cab.id_cia%TYPE,
        cuenta1    pcuentas.cuenta%TYPE,
        nombre1    pcuentas.nombre%TYPE,
        cuenta     pcuentas.cuenta%TYPE,
        nombre     pcuentas.nombre%TYPE,
        balancecol pcuentas.balancecol%TYPE,
        debeant    movimientos.importe%TYPE,
        haberant   movimientos.importe%TYPE,
        debeact    movimientos.importe%TYPE,
        haberact   movimientos.importe%TYPE,
        debeacu    movimientos.importe%TYPE,
        haberacu   movimientos.importe%TYPE
    );
    TYPE datatable_buscar_317 IS
        TABLE OF datarecord_buscar_317;
    FUNCTION sp_buscar_317 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipmon  VARCHAR2
    ) RETURN datatable_buscar_317
        PIPELINED;

    TYPE datarecord_buscar_txt IS RECORD (
        titulo       VARCHAR2(100 CHAR),
        cuenta_sunat VARCHAR2(100 CHAR),
        colum01      VARCHAR2(100 CHAR),
        colum02      VARCHAR2(100 CHAR),
        colum03      VARCHAR2(100 CHAR),
        colum04      VARCHAR2(100 CHAR),
        colum05      VARCHAR2(100 CHAR),
        colum06      VARCHAR2(100 CHAR),
        colum07      VARCHAR2(100 CHAR),
        colum08      VARCHAR2(100 CHAR)
    );
    TYPE datatable_buscar_txt IS
        TABLE OF datarecord_buscar_txt;
    FUNCTION sp_buscar_txt (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipmon  VARCHAR2,
        pin_codrent  VARCHAR2
    ) RETURN datatable_buscar_txt
        PIPELINED;

END;

/
