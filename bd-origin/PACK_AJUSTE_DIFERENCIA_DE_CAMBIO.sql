--------------------------------------------------------
--  DDL for Package PACK_AJUSTE_DIFERENCIA_DE_CAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_AJUSTE_DIFERENCIA_DE_CAMBIO" AS
    TYPE rec_sp001_saca_solo_documentos_pagar_saldos_fecha IS RECORD (
        id_cia NUMBER,
        codcli VARCHAR2(20),
        tipdoc VARCHAR2(2),
        desdoc VARCHAR2(50 CHAR),
        abrdoc VARCHAR2(6),
        docume VARCHAR2(40),
        tipo   INTEGER,
        docu   INTEGER,
        femisi DATE,
        fvenci DATE,
        dh     VARCHAR2(1),
        tipmon VARCHAR2(5),
        saldo  NUMERIC(16, 4)
    );
    TYPE tbl_sp001_saca_solo_documentos_pagar_saldos_fecha IS
        TABLE OF rec_sp001_saca_solo_documentos_pagar_saldos_fecha;
    FUNCTION sp001_saca_solo_documentos_pagar_saldos_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp001_saca_solo_documentos_pagar_saldos_fecha
        PIPELINED;

    TYPE rec_sp_sel_saldo_cuenta3 IS RECORD (
        id_cia    NUMBER,
        cuenta    VARCHAR2(20),
        nombre    pcuentas.nombre%TYPE,
        moncta01  VARCHAR2(3),
        moncta02  VARCHAR2(3),
        codtana   SMALLINT,
        codigo    VARCHAR2(20),
        tdocum    VARCHAR2(2),
        serie     VARCHAR(20),
        numero    VARCHAR2(20),
        saldo01   NUMERIC(15, 4),
        saldo02   NUMERIC(15, 4),
        razon     VARCHAR2(80 CHAR),
        abrevi    VARCHAR2(6),
        femisi    DATE,
        moneda    VARCHAR2(3),
        simbolo   VARCHAR2(3),
        importe   NUMERIC(16, 2),
        impor01   NUMERIC(16, 2),
        impor02   NUMERIC(16, 2),
        tcambio01 NUMERIC(14, 6),
        tcambio02 NUMERIC(14, 6),
        dh        VARCHAR2(1)
    );
    TYPE tbl_sp_sel_saldo_cuenta3 IS
        TABLE OF rec_sp_sel_saldo_cuenta3;
    FUNCTION sp_sel_saldo_cuenta3 (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codtana IN NUMBER,
        pin_moneda  IN VARCHAR2
    ) RETURN tbl_sp_sel_saldo_cuenta3
        PIPELINED;
        
    TYPE rec_sp001_saca_documentos_pagar_saldos_fecha IS RECORD (
        id_cia         NUMBER,
        codcli         VARCHAR2(20),
        swflag         VARCHAR2(1),
        tipdoc         VARCHAR2(2),
        desdoc         VARCHAR2(50),
        abrdoc         VARCHAR2(6),
        docume         VARCHAR2(40),
        tipo           INTEGER,
        docu           INTEGER,
        femisi         DATE,
        fvenci         DATE,
        dh             VARCHAR2(1),
        tipmon         VARCHAR2(5),
        importedebe    NUMERIC(16, 4),
        importehaber   NUMERIC(16, 4),
        importedebe01  NUMERIC(16, 4),
        importehaber01 NUMERIC(16, 4),
        importedebe02  NUMERIC(16, 4),
        importehaber02 NUMERIC(16, 4),
        saldo          NUMERIC(16, 4)
    );
    TYPE tbl_sp001_saca_documentos_pagar_saldos_fecha IS
        TABLE OF rec_sp001_saca_documentos_pagar_saldos_fecha;
    FUNCTION sp001_saca_documentos_pagar_saldos_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp001_saca_documentos_pagar_saldos_fecha
        PIPELINED;

    TYPE rec_sp000_saca_documentos_pagar_fecha IS RECORD (
        id_cia         NUMBER,
        codcli         VARCHAR2(20),
        swflag         VARCHAR2(1),
        tipdoc         VARCHAR2(2),
        desdoc         VARCHAR2(50 CHAR),
        abrdoc         VARCHAR2(6),
        docume         VARCHAR2(40),
        tipo           INTEGER,
        docu           INTEGER,
        operac         INTEGER,
        femisi         DATE,
        fvenci         DATE,
        dh             VARCHAR2(1),
        tipmon         VARCHAR2(5),
        importedebe    NUMERIC(16, 4),
        importehaber   NUMERIC(16, 4),
        importedebe01  NUMERIC(16, 4),
        importehaber01 NUMERIC(16, 4),
        importedebe02  NUMERIC(16, 4),
        importehaber02 NUMERIC(16, 4)
    );
    TYPE tbl_sp000_saca_documentos_pagar_fecha IS
        TABLE OF rec_sp000_saca_documentos_pagar_fecha;
    FUNCTION sp000_saca_documentos_pagar_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp000_saca_documentos_pagar_fecha
        PIPELINED;



    ------------------------------------------------------
    -- AJUSTE DE TIPO DE CAMBIO POR TIPO ANALITICA

    PROCEDURE x_tipo_analitica (
        pin_id_cia         IN NUMBER,
        pin_codtana        IN NUMBER,
        pin_codtana_descri IN VARCHAR2,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_codprov        IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    );


  ------------------------------------------------------
  -----  AJUSTE DE TIPO DE CAMBIO POR CUENTA.
    PROCEDURE x_cuenta (
        pin_id_cia         IN NUMBER,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_cuentas        IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    );

    -------------------------------------
    PROCEDURE sp_genera_asiento (
        rec_asiendet asiendet%rowtype,
        wtipcam      IN NUMBER,
        wmoneda      IN VARCHAR2,
        swinvierte   IN VARCHAR2 /* S OR N*/,
        swusasaldo01 IN VARCHAR2 /* S OR N*/,
        saldo01      IN NUMBER,
        saldo02      IN NUMBER,
        item         IN OUT NUMBER
    );

    PROCEDURE sp_actualiza_ctas_cobrar_pagar (
        pin_id_cia         IN NUMBER,
        pin_codtana        IN NUMBER,
        pin_codtana_descri IN VARCHAR2,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_moneda_cia     IN VARCHAR2,
        pin_codprov        IN VARCHAR2
    );

         ------------------------------------------------------
  -----  Ajuste por dolarización de cuentas contables en soles
    PROCEDURE dolarizacion_cuentas_soles (
        pin_id_cia         IN NUMBER,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    );

END pack_ajuste_diferencia_de_cambio;

/
