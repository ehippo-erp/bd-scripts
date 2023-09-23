--------------------------------------------------------
--  DDL for Package PACK_REPORTES_CONTABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_CONTABLES" AS
    TYPE datarecord_movimientos_por_cuenta IS RECORD (
        cuenta         pcuentas.cuenta%TYPE,
        nombre         pcuentas.nombre%TYPE,
        ccosto         movimientos.ccosto%TYPE,
        desccosto      tccostos.descri%TYPE,
        subcco         movimientos.subcco%TYPE,
        dessubccosto   cliente.razonc%TYPE,
        ctaalternativa movimientos.ctaalternativa%TYPE,
        cuentan1       VARCHAR2(20),
        nombren1       pcuentas.nombre%TYPE,
        cuentan2       VARCHAR2(20),
        nombren2       pcuentas.nombre%TYPE,
        cuentan3       VARCHAR2(20),
        nombren3       pcuentas.nombre%TYPE,
        cuentan4       VARCHAR2(20),
        nombren4       pcuentas.nombre%TYPE,
        cuentan5       VARCHAR2(20),
        nombren5       pcuentas.nombre%TYPE,
        cuentan6       VARCHAR2(20),
        nombren6       pcuentas.nombre%TYPE,
        fecha          movimientos.fecha%TYPE,
        libro          movimientos.libro%TYPE,
        asiento        movimientos.asiento%TYPE,
        concepto       movimientos.concep%TYPE,
        razonc         VARCHAR2(200),
        tident         cliente.tident%TYPE,
        dident         cliente.dident%TYPE,
        tdocum         movimientos.tdocum%TYPE,
        serie          movimientos.serie%TYPE,
        numero         movimientos.numero%TYPE,
        fdocum         movimientos.fdocum%TYPE,
        moneda         movimientos.moneda%TYPE,
        mes            movimientos.mes%TYPE,
        debe           movimientos.debe01%TYPE,
        haber          movimientos.haber01%TYPE
    );
    TYPE datatable_movimientos_por_cuenta IS
        TABLE OF datarecord_movimientos_por_cuenta;
    FUNCTION sp_movimientos_por_cuenta (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes_ini IN NUMBER,
        pin_mes_fin IN NUMBER,
        pin_moneda  IN VARCHAR2,
        pin_cuentas IN VARCHAR2
    ) RETURN datatable_movimientos_por_cuenta
        PIPELINED;

END;

/
