--------------------------------------------------------
--  DDL for Package PACK_REPORTES_ANALITICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_ANALITICA" AS
    TYPE datarecord_detalle_saldo IS RECORD (
        cuenta              pcuentas.cuenta%TYPE,
        denominacion        pcuentas.nombre%TYPE,
        tipodoc             cliente.tident%TYPE,
        tipo_documento      identidad.abrevi%TYPE,
        documento_identidad cliente.dident%TYPE,
        codigo              cliente.codcli%TYPE,
        razon_social        cliente.razonc%TYPE,
        saldo_pen           NUMBER(16, 2),
        saldo_usd           NUMBER(16, 2)
    );
    TYPE datatable_detalle_saldo IS
        TABLE OF datarecord_detalle_saldo;
    TYPE datarecord_detalle_documento_saldo IS RECORD (
        cuenta              pcuentas.cuenta%TYPE,
        denominacion        pcuentas.nombre%TYPE,
        tipodoc             cliente.tident%TYPE,
        tipo_documento      identidad.abrevi%TYPE,
        documento_identidad cliente.dident%TYPE,
        codigo              cliente.codcli%TYPE,
        razon_social        cliente.razonc%TYPE,
        tdocum              movimientos.tdocum%TYPE,
        documento_tipo      documentos_tipo.descri%TYPE,
        serie               movimientos.serie%TYPE,
        numero              movimientos.numero%TYPE,
        fecha_emision       VARCHAR2(100),
        debe_pen            NUMBER(16, 2),
        haber_pen           NUMBER(16, 2),
        debe_usd            NUMBER(16, 2),
        haber_usd           NUMBER(16, 2),
        saldo_pen           NUMBER(16, 2),
        saldo_usd           NUMBER(16, 2)
    );
    TYPE datatable_detalle_documento_saldo IS
        TABLE OF datarecord_detalle_documento_saldo;
    TYPE datarecord_detalle_movimientos IS RECORD (
        cuenta              pcuentas.cuenta%TYPE,
        denominacion        pcuentas.nombre%TYPE,
        tipodoc             cliente.tident%TYPE,
        tipo_documento      identidad.abrevi%TYPE,
        documento_identidad cliente.dident%TYPE,
        codigo              cliente.codcli%TYPE,
        razon_social        cliente.razonc%TYPE,
        periodo             movimientos.periodo%TYPE,
        mes                 movimientos.mes%TYPE,
        libro               movimientos.libro%TYPE,
        asiento             movimientos.asiento%TYPE,
        tdocum              movimientos.tdocum%TYPE,
        documento_tipo      documentos_tipo.descri%TYPE,
        serie               movimientos.serie%TYPE,
        numero              movimientos.numero%TYPE,
        fecha_emision       VARCHAR2(100),
        concepto            movimientos.concep%TYPE,
        debe01              NUMBER(16, 2),
        haber01             NUMBER(16, 2),
        debe02              NUMBER(16, 2),
        haber02             NUMBER(16, 2)
    );
    TYPE datatable_detalle_movimientos IS
        TABLE OF datarecord_detalle_movimientos;
    TYPE datarecord_cajban_saldo IS RECORD (
        cuenta        pcuentas.cuenta%TYPE,
        denominacion  pcuentas.nombre%TYPE,
        codban        tbancos.codban%TYPE,
        codbansunat   tbancos.codsunat%TYPE,
        numero_cuenta tbancos.cuenta%TYPE,
        tipmon        tmoneda.codmon%TYPE,
        tipmonsunat   tmoneda.codsunat%TYPE,
        deudor        movimientos.debe01%TYPE,
        acreedor      movimientos.haber01%TYPE,
        saldo_pen     NUMBER(16, 2),
        saldo_usd     NUMBER(16, 2)
    );
    TYPE datatable_cajban_saldo IS
        TABLE OF datarecord_cajban_saldo;
    TYPE datarecord_estado_saldo IS RECORD (
        tipinv       t_inventario.tipinv%TYPE,
        codtinvsunat t_inventario.codsunat%TYPE,
        dtipinv      t_inventario.dtipinv%TYPE,
        codart       articulos.codart%TYPE,
        desart       articulos.descri%TYPE,
        codund       unidad.coduni%TYPE,
        codundsunat  unidad.codsunat%TYPE,
        cantid       articulos_costo.cantid%TYPE,
        cosuni_pen   articulos_costo.costo01%TYPE,
        cosuni_usd   articulos_costo.costo02%TYPE,
        costo_pen    articulos_costo.costo01%TYPE,
        costo_usd    articulos_costo.costo02%TYPE
    );
    TYPE datatable_estado_saldo IS
        TABLE OF datarecord_estado_saldo;
    TYPE datarecord_estado_saldo2 IS RECORD (
        titulo       VARCHAR2(20 CHAR),
        destitulo    VARCHAR2(500 CHAR),
        tipinv       t_inventario.tipinv%TYPE,
        codtinvsunat t_inventario.codsunat%TYPE,
        dtipinv      t_inventario.dtipinv%TYPE,
        codart       articulos.codart%TYPE,
        desart       articulos.descri%TYPE,
        codund       unidad.coduni%TYPE,
        codundsunat  unidad.codsunat%TYPE,
        cantid       articulos_costo.cantid%TYPE,
        cosuni_pen   articulos_costo.costo01%TYPE,
        cosuni_usd   articulos_costo.costo02%TYPE,
        costo_pen    articulos_costo.costo01%TYPE,
        costo_usd    articulos_costo.costo02%TYPE
    );
    TYPE datatable_estado_saldo2 IS
        TABLE OF datarecord_estado_saldo2;
    TYPE datarecord_saldo IS RECORD (
        titulo       VARCHAR2(20 CHAR),
        destitulo    VARCHAR2(500 CHAR),
        cuenta       pcuentas.cuenta%TYPE,
        denominacion pcuentas.nombre%TYPE,
        saldo_pen    NUMBER(16, 2),
        saldo_usd    NUMBER(16, 2)
    );
    TYPE datatable_saldo IS
        TABLE OF datarecord_saldo;
    FUNCTION sp_detalle_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_detalle_saldo
        PIPELINED;

    FUNCTION sp_detalle_documento_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_documento_saldo
        PIPELINED;

    FUNCTION sp_detalle_documento_movimientos_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_movimientos
        PIPELINED;

    FUNCTION sp_estado_saldo (
        pin_id_cia  NUMBER,
        pin_tipo    INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_estado_saldo
        PIPELINED;

    FUNCTION sp_cajban_saldo (
        pin_id_cia  NUMBER,
        pin_codban  VARCHAR2,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_cajban_saldo
        PIPELINED;

    FUNCTION sp_detalle_movimientos (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_movimientos
        PIPELINED;

    FUNCTION sp_estado_saldo2 (
        pin_id_cia  NUMBER,
        pin_tipo    INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_estado_saldo2
        PIPELINED;

--select * from pack_reportes_analitica.sp_estado_saldo(56,1,2022,07);

    FUNCTION sp_saldo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_saldo
        PIPELINED;

END;

/
