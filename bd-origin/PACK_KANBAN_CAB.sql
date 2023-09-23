--------------------------------------------------------
--  DDL for Package PACK_KANBAN_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KANBAN_CAB" AS
    TYPE datarecord_kanban_cab IS RECORD (
        id_cia  kanban_cab.id_cia%TYPE,
        codkan  kanban_cab.codkan%TYPE,
        tipinv  kanban_cab.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codalm  kanban_cab.codalm%TYPE,
        desalm  almacen.descri%TYPE,
        deskan  kanban_cab.descri%TYPE,
        swacti  kanban_cab.swacti%TYPE,
        ucreac  kanban_cab.ucreac%TYPE,
        uactua  kanban_cab.uactua%TYPE,
        fcreac  kanban_cab.factua%TYPE,
        factua  kanban_cab.factua%TYPE
    );
    TYPE datatable_kanban_cab IS
        TABLE OF datarecord_kanban_cab;
    TYPE datarecord_reporte IS RECORD (
        id_cia    kanban_cab.id_cia%TYPE,
        codkan    kanban_cab.codkan%TYPE,
        deskan    kanban_cab.descri%TYPE,
        tipinv    t_inventario.tipinv%TYPE,
        dtipinv   t_inventario.dtipinv%TYPE,
        codalm    documentos_det.codalm%TYPE,
        desalm    almacen.descri%TYPE,
        codart    articulos.codart%TYPE,
        desart    articulos.descri%TYPE,
        swactiart VARCHAR2(10),
        swactidesart VARCHAR2(40),
        cantid    kanban_det.cantid%TYPE,
        cantidmin kanban_det.cantidmin%TYPE,
        cantidmax kanban_det.cantidmax%TYPE
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_pedido IS RECORD (
        id_cia       kanban_cab.id_cia%TYPE,
        codkan       kanban_cab.codkan%TYPE,
        deskan       kanban_cab.descri%TYPE,
        tipinv       t_inventario.tipinv%TYPE,
        dtipinv      t_inventario.dtipinv%TYPE,
        codalm       documentos_det.codalm%TYPE,
        abralm       almacen.abrevi%TYPE,
        desalm       almacen.descri%TYPE,
        codart       articulos.codart%TYPE,
        desart       articulos.descri%TYPE,
        cantid       kanban_det.cantid%TYPE,
        cantidmin    kanban_det.cantidmin%TYPE,
        cantidmax    kanban_det.cantidmax%TYPE,
        faccon       articulos.faccon%TYPE,
        cantidabs    NUMBER,
        desclase01   VARCHAR2(100),
        descodigo01  VARCHAR2(100),
        desclase02   VARCHAR2(100),
        descodigo02  VARCHAR2(100),
        stocktotal   NUMBER,
        stock        NUMBER,
        stockrecibir NUMBER,
        cantidped    NUMBER
    );
    TYPE datatable_pedido IS
        TABLE OF datarecord_pedido;
    TYPE datarecord_stock_recibir IS RECORD (
        id_cia documentos_det.id_cia%TYPE,
        tipinv documentos_det.tipinv%TYPE,
        codart documentos_det.codart%TYPE,
        stock  documentos_det.cantid%TYPE
    );
    TYPE datatable_stock_recibir IS
        TABLE OF datarecord_stock_recibir;
    FUNCTION sp_stock_recibir (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_stock_recibir
        PIPELINED;

    FUNCTION sp_pedido (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_pedido
        PIPELINED;

--    SELECT * FROM pack_kanban_cab.sp_reporte(66,'01',1,3);
--
--    SELECT * FROM pack_kanban_cab.sp_pedido(66,'01',1,3,202201,202209);

    FUNCTION sp_reporte (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_kanban_cab
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_swacti VARCHAR2
    ) RETURN datatable_kanban_cab
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
