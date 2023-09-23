--------------------------------------------------------
--  DDL for Package PACK_ASIENTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ASIENTO_VENTA" AS
    TYPE datarecord_reporte_clase IS RECORD (
        tipinv          articulos.tipinv%TYPE,
        tipo_inventario t_inventario.dtipinv%TYPE,
        codart          articulos.codart%TYPE,
        articulo        articulos.descri%TYPE,
        observacion     VARCHAR(250)
    );
    TYPE datatable_reporte_clase IS
        TABLE OF datarecord_reporte_clase;
    TYPE datarecord_reporte_cuenta IS RECORD (
        id_cia   documentos_cab.id_cia%TYPE,
        tipinv   articulos.tipinv%TYPE,
        codart   articulos.codart%TYPE,
        articulo articulos.descri%TYPE,
        clase    articulos_clase.clase%TYPE,
        cuienta  articulos_clase.codigo%TYPE,
        observ   VARCHAR(250)
    );
    TYPE datatable_reporte_cuenta IS
        TABLE OF datarecord_reporte_cuenta;
    FUNCTION sp_reporte_clase (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_clase
        PIPELINED;

    FUNCTION sp_reporte_clase_basic (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_clase
        PIPELINED;

    FUNCTION sp_reporte_cuenta (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER
    ) RETURN datatable_reporte_cuenta
        PIPELINED;

    FUNCTION sp_reporte_cuentav2 (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER
    ) RETURN datatable_reporte_cuenta
        PIPELINED;

END;

/
