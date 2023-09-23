--------------------------------------------------------
--  DDL for Package PACK_CONSISTENCIAS_LOGISTICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CONSISTENCIAS_LOGISTICA" AS
    TYPE datarecord_stock IS RECORD (
        observacion     VARCHAR2(500),
        periodo         NUMBER,
        mes             NUMBER,
        tipinv          t_inventario.tipinv%TYPE,
        tipo_inventario t_inventario.dtipinv%TYPE,
        codart          articulos.codart%TYPE,
        articulo        articulos.descri%TYPE,
        cantidad        kardex.cantid%TYPE,
        costo_soles     kardex.costot01%TYPE,
        costo_dolares   kardex.costot02%TYPE
    );
    TYPE datatable_stock IS
        TABLE OF datarecord_stock;
    TYPE datarecord_stock_cero IS RECORD (
        observacion     VARCHAR2(500),
        periodo         NUMBER,
        mes             NUMBER,
        tipinv          t_inventario.tipinv%TYPE,
        tipo_inventario t_inventario.dtipinv%TYPE,
        codart          articulos.codart%TYPE,
        articulo        articulos.descri%TYPE,
        cantidad        kardex.cantid%TYPE,
        costo_soles     kardex.costot01%TYPE,
        costo_dolares   kardex.costot02%TYPE,
        salidas         NUMBER,
        maxlocalisal    NUMBER
    );
    TYPE datatable_stock_cero IS
        TABLE OF datarecord_stock_cero;
    FUNCTION sp_stock_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock
        PIPELINED;

    FUNCTION sp_stock_articulos_costo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock
        PIPELINED;

    FUNCTION sp_buscar_cantidad_cero (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock_cero
        PIPELINED;

    PROCEDURE sp_ajustar_cantidad_cero (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--SELECT * FROM  pack_consistencias_logistica.sp_stock_kardex(78,2022,12,1); --TSI REPORTES
--
--SELECT * FROM  pack_consistencias_logistica.sp_stock_articulos_costo(78,2022,12,1); --TSI REPORTES
--
--SELECT * FROM  pack_consistencias_logistica.sp_buscar_cantidad_cero(78,2022,11,1);
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_consistencias_logistica.sp_ajustar_cantidad_cero(78,2022,11,1,'admin',v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
