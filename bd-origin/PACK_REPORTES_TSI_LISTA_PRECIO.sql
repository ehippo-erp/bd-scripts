--------------------------------------------------------
--  DDL for Package PACK_REPORTES_TSI_LISTA_PRECIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_TSI_LISTA_PRECIO" AS
    TYPE datarecord_buscar IS RECORD (
        tipinv                      documentos_det.tipinv%TYPE,
        tipo_inventario             t_inventario.dtipinv%TYPE,
        codart                      documentos_det.codart%TYPE,
        articulo                    articulos.descri%TYPE,
        articulo_des_interna        articulos.descri%TYPE,
        moneda                      VARCHAR2(5 CHAR),
        lista_de_precio_general     NUMBER(16, 2),
        lista_de_precio_mimo        NUMBER(16, 2),
        lista_de_precio_fidelidad   NUMBER(16, 2),
        lista_de_precio_leadtad     NUMBER(16, 2),
        lista_de_precio_vip         NUMBER(16, 2),
        lista_de_precio_mayor       NUMBER(16, 2),
        lista_de_precio_reda        NUMBER(16, 2),
        lista_de_precio_misti       NUMBER(16, 2),
        lista_de_precio_geral2021   NUMBER(16, 2),
        lista_de_precio_mstdr2021   NUMBER(16, 2),
        lista_de_precio_fidel2021   NUMBER(16, 2),
        lista_de_precio_laltad2021  NUMBER(16, 2),
        lista_de_precio_vipal2021   NUMBER(16, 2),
        lista_de_precio_mayor2021   NUMBER(16, 2),
        lista_de_precio_redav2021   NUMBER(16, 2),
        lista_de_precio_misti2021   NUMBER(16, 2),
        lista_de_precio_dunas2021   NUMBER(16, 2),
        lista_de_precio_navidad2021 NUMBER(16, 2),
        familia                     clase_codigo.descri%TYPE,
        subfamilia                  clase_codigo.descri%TYPE,
        subsubfamilia               clase_codigo.descri%TYPE,
        coment_aplicacion           VARCHAR2(4000),
        unidad_medida               unidad.desuni%TYPE,
        villa                       VARCHAR2(4000),
        brena                       VARCHAR2(4000),
        almacen_transito            NUMBER(16, 2)
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE datarecord_kanban IS RECORD (
        fecha          VARCHAR2(200),
        kanban         kanban_cab.descri%TYPE,
        familia        VARCHAR2(200),
        codart         articulos.codart%TYPE,
        articulo       articulos.descri%TYPE,
        stock          NUMBER,
        stock_minimo   NUMBER,
        costo_unitario NUMBER,
        costo_total    NUMBER,
        precio_soles   NUMBER,
        precio_dolares   NUMBER
    );
    TYPE datatable_kanban IS
        TABLE OF datarecord_kanban;
    TYPE datarecord_costo IS RECORD (
        stock NUMBER,
        costo NUMBER
    );
    TYPE datatable_costo IS
        TABLE OF datarecord_costo;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_kanban (
        pin_id_cia NUMBER,
        pin_kanban NUMBER
    ) RETURN datatable_kanban
        PIPELINED;

    FUNCTION sp_stock_articulo_costo (
        pin_id_cia   NUMBER,
        pin_tipinv   NUMBER,
        pin_codart   VARCHAR2,
        pin_codadd01 IN VARCHAR2,
        pin_codadd02 IN VARCHAR2,
        pin_pdesde   NUMBER,
        pin_phasta   NUMBER
    ) RETURN datatable_costo
        PIPELINED;

    FUNCTION sp_calcula (
        pin_preuni  NUMBER,
        pin_pordes1 NUMBER,
        pin_pordes2 NUMBER,
        pin_pordes3 NUMBER,
        pin_pordes4 NUMBER
    ) RETURN NUMBER;

END;

/
