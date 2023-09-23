--------------------------------------------------------
--  DDL for Package PACK_MOVIMIENTOS_ASIENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_MOVIMIENTOS_ASIENTOS" AS
    TYPE datarecord_buscar IS RECORD (
        cuenta   movimientos.cuenta%TYPE,
        nombre   pcuentas.nombre%TYPE,
        codigo   movimientos.codigo%TYPE,
        periodo  movimientos.periodo%TYPE,
        mes      movimientos.mes%TYPE,
        libro    movimientos.libro%TYPE,
        asiento  movimientos.asiento%TYPE,
        item     movimientos.item%TYPE,
        sitem    movimientos.sitem%TYPE,
        fdocum   movimientos.fdocum%TYPE,
        tdocum   movimientos.tdocum%TYPE,
        proyec   movimientos.proyec%TYPE,
        serie    movimientos.serie%TYPE,
        numero   movimientos.numero%TYPE,
        debe01   movimientos.debe01%TYPE,
        haber01  movimientos.haber01%TYPE,
        debe02   movimientos.debe02%TYPE,
        haber02  movimientos.haber02%TYPE,
        aperiodo asiendet.periodo%TYPE,
        ames     asiendet.mes%TYPE,
        alibro   asiendet.libro%TYPE,
        aasiento asiendet.asiento%TYPE,
        aitem    asiendet.item%TYPE,
        asitem   asiendet.sitem%TYPE,
        acodigo  asiendet.codigo%TYPE,
        afdocum  asiendet.fdocum%TYPE,
        atdocum  asiendet.tdocum%TYPE,
        aserie   asiendet.serie%TYPE,
        anumero  asiendet.numero%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes NUMBER,
        pin_cuenta  VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_actualiza (
        pin_id_cia  NUMBER,
        pin_datos   VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
