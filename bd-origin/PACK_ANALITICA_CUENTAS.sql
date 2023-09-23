--------------------------------------------------------
--  DDL for Package PACK_ANALITICA_CUENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ANALITICA_CUENTAS" AS
    TYPE datarecord_detallado_movimientos IS RECORD (
        n01     VARCHAR2(10),
        n02     VARCHAR2(10),
        n03     VARCHAR2(10),
        cuenta  pcuentas.cuenta%TYPE,
        nombre  pcuentas.nombre%TYPE,
        codigo  movimientos.codigo%TYPE,
        concep  movimientos.concep%TYPE,
        razonc  cliente.razonc%TYPE,
        tdocum  tdocume.codigo%TYPE,
        desdoc  tdocume.descri%TYPE,
        abrevi  tdocume.abrevi%TYPE,
        serie   movimientos.serie%TYPE,
        numero  movimientos.numero%TYPE,
        xnrodoc VARCHAR2(30),
        debe01  NUMERIC(16, 2),
        haber01 NUMERIC(16, 2),
        debe02  NUMERIC(16, 2),
        haber02 NUMERIC(16, 2),
        libro   VARCHAR2(3),
        deslib  VARCHAR2(50),
        asiento INTEGER,
        fecha   DATE,
        periodo INTEGER,
        mes     INTEGER,
        item    INTEGER,
        sitem   INTEGER,
        saldoc  NUMERIC(16, 2)
    );
    TYPE datatable_detallado_movimientos IS
        TABLE OF datarecord_detallado_movimientos;
    TYPE datarecord_detallado_movimientos_tsi IS RECORD (
        n01     VARCHAR2(10),
        n02     VARCHAR2(10),
        n03     VARCHAR2(10),
        cuenta  pcuentas.cuenta%TYPE,
        nombre  pcuentas.nombre%TYPE,
        codigo  movimientos.codigo%TYPE,
        concep  movimientos.concep%TYPE,
        tident  cliente.tident%TYPE,
        abrent  identidad.abrevi%TYPE,
        dident  cliente.dident%TYPE,
        razonc  cliente.razonc%TYPE,
        tdocum  tdocume.codigo%TYPE,
        desdoc  tdocume.descri%TYPE,
        abrevi  tdocume.abrevi%TYPE,
        serie   movimientos.serie%TYPE,
        numero  movimientos.numero%TYPE,
        xnrodoc VARCHAR2(30),
        debe01  NUMERIC(16, 2),
        haber01 NUMERIC(16, 2),
        debe02  NUMERIC(16, 2),
        haber02 NUMERIC(16, 2),
        libro   VARCHAR2(3),
        deslib  VARCHAR2(50),
        asiento INTEGER,
        fecha   DATE,
        periodo INTEGER,
        mes     INTEGER,
        item    INTEGER,
        sitem   INTEGER,
        saldoc  NUMERIC(16, 2)
    );
    TYPE datatable_detallado_movimientos_tsi IS
        TABLE OF datarecord_detallado_movimientos_tsi;
    TYPE datarecord_saldo IS RECORD (
        n01        VARCHAR2(10),
        n02        VARCHAR2(10),
        n03        VARCHAR2(10),
        cuenta     pcuentas.cuenta%TYPE,
        nombre     pcuentas.nombre%TYPE,
        codigo     VARCHAR2(20),
        razonc     cliente.razonc%TYPE,
        dident     VARCHAR2(20),
        tdocum     tdocume.codigo%TYPE,
        desdoc     tdocume.descri%TYPE,
        abrevi     tdocume.abrevi%TYPE,
        serie      movimientos.serie%TYPE,
        numero     movimientos.numero%TYPE,
        tipdoc     NUMBER,
        femisi     DATE,
        fvenci     DATE,
        referencia VARCHAR2(1000),
        debe01     NUMERIC(16, 2),
        haber01    NUMERIC(16, 2),
        saldo01    NUMERIC(16, 2),
        debe02     NUMERIC(16, 2),
        haber02    NUMERIC(16, 2),
        saldo02    NUMERIC(16, 2),
        debe01sal  NUMERIC(16, 2),
        haber01sal NUMERIC(16, 2),
        debe02sal  NUMERIC(16, 2),
        haber02sal NUMERIC(16, 2)
    );
    TYPE datatable_saldo IS
        TABLE OF datarecord_saldo;
    TYPE datarecord_resumen_codigo IS RECORD (
        codtana NUMBER,
        destana tanalitica.descri%TYPE,
        codigo  saldos_tanalitica.codigo%TYPE,
        razonc  cliente.razonc%TYPE,
        debe01  NUMBER(16, 4),
        debe02  NUMBER(16, 4),
        haber01 NUMBER(16, 4),
        haber02 NUMBER(16, 4),
        saldo01 NUMBER(16, 4),
        saldo02 NUMBER(16, 4)
    );
    TYPE datatable_resumen_codigo IS
        TABLE OF datarecord_resumen_codigo;
    TYPE datarecord_analitica_de_cuentas IS RECORD (
        n01        VARCHAR2(15),
        n02        VARCHAR2(15),
        n03        VARCHAR2(15),
        cuenta     VARCHAR2(16),
        nombre     VARCHAR2(160),
        codigo     VARCHAR2(20),
        razonc     VARCHAR2(80 CHAR),
        dident     VARCHAR2(20 CHAR),
        tdocum     VARCHAR2(2),
        desdoc     VARCHAR2(50 CHAR),
        abrevi     VARCHAR2(6),
        serie      VARCHAR2(20 CHAR),
        numero     VARCHAR2(20 CHAR),
        tipdoc     INTEGER,
        femisi     DATE,
        fvenci     DATE,
        referencia VARCHAR2(200),
        debe01     NUMERIC(16, 2),
        haber01    NUMERIC(16, 2),
        debe02     NUMERIC(16, 2),
        haber02    NUMERIC(16, 2)
    );
    TYPE datatable_analitica_de_cuentas IS
        TABLE OF datarecord_analitica_de_cuentas;
    FUNCTION sp_detallado_movimientos (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    ) RETURN datatable_detallado_movimientos
        PIPELINED;

    FUNCTION sp_detallado_movimientos_tsi (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER,
        pin_codtana VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_detallado_movimientos_tsi
        PIPELINED;

    FUNCTION sp_saldo (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    ) RETURN datatable_saldo
        PIPELINED;

    PROCEDURE sp_actualiza_saldos_det (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_cuenta  IN VARCHAR2,
        pin_codigo  IN VARCHAR2,
        pin_tdocum  IN VARCHAR2,
        pin_serie   IN VARCHAR2,
        pin_numero  IN VARCHAR2
    );

    PROCEDURE sp_actualiza_saldos (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    );

    FUNCTION sp_resumen_codigo (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2,
        pin_cheack  IN INTEGER
    ) RETURN datatable_resumen_codigo
        PIPELINED;

    FUNCTION sp_select_analitica (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER,
        pin_codtana VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_analitica_de_cuentas
        PIPELINED;

END;

/
