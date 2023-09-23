--------------------------------------------------------
--  DDL for Package PACK_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_MOVIMIENTOS" AS
    TYPE rec_sp_sel_saldo_cuenta4 IS RECORD (
        cuenta    VARCHAR2(20),
        nombre    VARCHAR2(80),
        codigo    VARCHAR2(20),
        tdocum    VARCHAR2(5),
        serie     VARCHAR2(20),
        numero    VARCHAR2(20),
        saldo01   NUMERIC(16, 4),
        saldo02   NUMERIC(16, 4),
        razon     VARCHAR2(100),
        abrevi    VARCHAR2(10),
        moneda    VARCHAR2(5),
        simbolo   VARCHAR2(5),
        tcambio01 NUMERIC(14, 6),
        tcambio02 NUMERIC(14, 6),
        dh        VARCHAR2(1)
    );
    TYPE tbl_sp_sel_saldo_cuenta4 IS
        TABLE OF rec_sp_sel_saldo_cuenta4;
    FUNCTION sp_sel_saldo_cuenta4 (
        pin_id_cia  IN NUMBER,
        pin_cuenta  IN VARCHAR2,
        pin_codigo  IN VARCHAR2,
        pin_tdocum  IN VARCHAR2,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_serie   IN VARCHAR2,
        pin_numero  IN VARCHAR2
    ) RETURN tbl_sp_sel_saldo_cuenta4
        PIPELINED;

    TYPE rec_saldos IS RECORD (
        saldoanterior NUMERIC(16, 5),
        saldoactual   NUMERIC(16, 5)
    );
    TYPE tbl_saldos IS
        TABLE OF rec_saldos;
    TYPE rec_saldos_periodo_cuenta IS RECORD (
        cuenta        pcuentas.cuenta%TYPE,
        periodo       NUMBER,
        mes           NUMBER,
        saldoanterior NUMERIC(16, 5),
        saldoactual   NUMERIC(16, 5)
    );
    TYPE datatable_saldos_periodo_cuenta IS
        TABLE OF rec_saldos_periodo_cuenta;
    FUNCTION sp_saldos_por_cuenta (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes_desde IN NUMBER,
        pin_mes_hasta IN NUMBER,
        pin_cuenta    IN VARCHAR2,
        pin_codmon    IN VARCHAR2
    ) RETURN tbl_saldos
        PIPELINED;

    FUNCTION sp_saldos_por_periodo_cuenta (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes_desde IN NUMBER,
        pin_mes_hasta IN NUMBER,
        pin_cuenta    IN VARCHAR2,
        pin_codmon    IN VARCHAR2
    ) RETURN datatable_saldos_periodo_cuenta
        PIPELINED;

    TYPE rec_sp_ranking_por_proveedor_daot IS RECORD (
        tipo       NUMBER,
        docume     NUMBER,
        signo      NUMBER,
        fecha      DATE,
        desdoc     VARCHAR2(100),
        tdocum     VARCHAR2(100),
        serie      VARCHAR2(100),
        numdoc     VARCHAR2(100),
        codigo     VARCHAR2(100),
        razon      VARCHAR2(120),
        apepat     VARCHAR2(60),
        apemat     VARCHAR2(60),
        nombre     VARCHAR2(60),
        tident     VARCHAR2(100),
        dident     VARCHAR2(100),
        codtpe     NUMBER,
        mes        NUMBER,
        femisi     DATE,
        concep     VARCHAR2(220),
        tcrefis    NUMBER(16, 2),
        tinafecto  NUMBER(16, 2),
        tncrefis   NUMBER(16, 2),
        tbaseimp   NUMBER(16, 2),
        timpuesto  NUMBER(16, 2),
        tgeneral   NUMBER(16, 2),
        tgeneral2  NUMBER(16, 2),
        tdcrefis   NUMBER(16, 2),
        tdinafecto NUMBER(16, 2),
        tdncrefis  NUMBER(16, 2),
        tdbaseimp  NUMBER(16, 2),
        tdimpuesto NUMBER(16, 2),
        tdgeneral  NUMBER(16, 2),
        tdgeneral2 NUMBER(16, 2)
    );
    TYPE tbl_sp_ranking_por_proveedor_daot IS
        TABLE OF rec_sp_ranking_por_proveedor_daot;
    FUNCTION sp_ranking_por_proveedor_daot (
        pin_id_cia     IN NUMBER,
        pin_periodo    IN NUMBER,
        pin_mes_desde  IN NUMBER,
        pin_mes_hasta  IN NUMBER,
        pin_codmon     IN VARCHAR2,
        pin_tipocompra IN NUMBER,
        pin_topmin     IN NUMBER
    ) RETURN tbl_sp_ranking_por_proveedor_daot
        PIPELINED;

    FUNCTION daotprovedor_txt (
        pin_id_cia     IN NUMBER,
        pin_periodo    IN NUMBER,
        pin_mes_desde  IN NUMBER,
        pin_mes_hasta  IN NUMBER,
        pin_codmon     IN VARCHAR2,
        pin_tipocompra IN NUMBER,
        pin_topmin     IN NUMBER
    ) RETURN tbl_sp_ranking_por_proveedor_daot
        PIPELINED;

END pack_movimientos;

/
