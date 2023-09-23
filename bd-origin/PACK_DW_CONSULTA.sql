--------------------------------------------------------
--  DDL for Package PACK_DW_CONSULTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW_CONSULTA" AS
    TYPE datarecord_ventas_mensuales IS RECORD (
        id_cia      NUMBER,
        tipdoc      VARCHAR2(120),
        periodo     NUMBER,
        mes         VARCHAR2(25),
        idmes       NUMBER,
        mesid       NUMBER,
        rotulo      VARCHAR(120),
        categoria   VARCHAR2(120),
        moneda      VARCHAR2(5),
        venta       NUMBER(20, 8),
        proyectado  NUMBER(20, 8),
        codsucn1    NUMBER,
        sucursaln1  NUMBER(20, 8),
        codsucn2    NUMBER,
        sucursaln2  NUMBER(20, 8),
        codsucn3    NUMBER,
        sucursaln3  NUMBER(20, 8),
        codsucn4    NUMBER,
        sucursaln4  NUMBER(20, 8),
        codsucn5    NUMBER,
        sucursaln5  NUMBER(20, 8),
        codsucn6    NUMBER,
        sucursaln6  NUMBER(20, 8),
        codsucn7    NUMBER,
        sucursaln7  NUMBER(20, 8),
        codsucn8    NUMBER,
        sucursaln8  NUMBER(20, 8),
        codsucn9    NUMBER,
        sucursaln9  NUMBER(20, 8),
        codsucn10   NUMBER,
        sucursaln10 NUMBER(20, 8)
    );
    TYPE datatable_ventas_mensuales IS
        TABLE OF datarecord_ventas_mensuales;
    TYPE datarecord_ventas_mensuales_comparativa IS RECORD (
        id_cia     NUMBER,
        sucursal   VARCHAR2(100),
        tipdoc     VARCHAR2(120),
        periodo    NUMBER,
        mes        VARCHAR2(25),
        idmes      NUMBER,
        mesid      NUMBER,
        rotulo     VARCHAR(120),
        categoria  VARCHAR2(120),
        moneda     VARCHAR2(5),
        venta      NUMBER(20, 8),
        proyectado NUMBER(20, 8),
        ventaup    NUMBER(20, 8),
        ventadown  NUMBER(20, 8)
    );
    TYPE datatable_ventas_mensuales_comparativa IS
        TABLE OF datarecord_ventas_mensuales_comparativa;
    TYPE datarecord_ventas_mensuales_vendedor_objetivos IS RECORD (
        id_cia    NUMBER,
        sucursal  VARCHAR2(100),
        tipdoc    VARCHAR2(120),
        codven    NUMBER,
        desven    vendedor.desven%TYPE,
        rotulo    VARCHAR(120),
        periodo   NUMBER,
        mes       VARCHAR2(25),
        idmes     NUMBER,
        mesid     NUMBER,
        moneda    VARCHAR2(5),
        venta     NUMBER(20, 8),
        meta      NUMBER(20, 8),
        ventaup   NUMBER(20, 8),
        ventadown NUMBER(20, 8),
        base      NUMBER(20, 8),
        cumplio   NUMBER(20, 8),
        nocumplio NUMBER(20, 8)
    );
    TYPE datatable_ventas_mensuales_vendedor_objetivos IS
        TABLE OF datarecord_ventas_mensuales_vendedor_objetivos;
    TYPE datarecord_ventas_mensuales_vendedor IS RECORD (
        id_cia   NUMBER,
        tipdoc   VARCHAR2(120),
        codven   documentos_cab.codven%TYPE,
        desven   vendedor.desven%TYPE,
        periodo  NUMBER,
        mes      VARCHAR2(25),
        id_mes   NUMBER,
        moneda   documentos_cab.tipmon%TYPE,
        importe1 NUMBER(20, 8),
        importe2 NUMBER(20, 8)
    );
    TYPE datatable_ventas_mensuales_vendedor IS
        TABLE OF datarecord_ventas_mensuales_vendedor;
    TYPE datarecord_venta_costo_utilidad_articulo IS RECORD (
        id_cia        NUMBER,
        periodo       NUMBER,
        mes           VARCHAR2(25),
        idmes         NUMBER,
        mesid         NUMBER,
        rotulo        VARCHAR(120),
        categoria     VARCHAR2(120),
        tipinv        NUMBER,
        dtipinv       VARCHAR2(100),
        codclase      VARCHAR2(70),
        desclase      VARCHAR2(70),
        codart        articulos.codart%TYPE,
        desart        articulos.descri%TYPE,
        moneda        documentos_cab.tipmon%TYPE,
        cantidad      NUMBER(20, 8),
        venta         NUMBER(20, 8),
        costo         NUMBER(20, 8),
        igv           NUMBER(20, 8),
        rentabilidad  NUMBER(20, 8),
        porcentaje    NUMBER(20, 8),
        fecha VARCHAR2(25),
        tipodocumento VARCHAR2(120),
        numint      NUMBER,
        serie         VARCHAR2(20),
        numero        NUMBER,
        razonc      documentos_cab.razonc%TYPE
    );
    TYPE datatable_venta_costo_utilidad_articulo IS
        TABLE OF datarecord_venta_costo_utilidad_articulo;
    FUNCTION sp_ventas_mensuales (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales
        PIPELINED;

    FUNCTION sp_ventas_mensuales_vendedor_objetivos (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales_vendedor_objetivos
        PIPELINED;

    FUNCTION sp_ventas_mensuales_comparativa (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_ventas_mensuales_comparativa
        PIPELINED;

    FUNCTION sp_venta_costo_utilidad_articulo (
        pin_id_cia     NUMBER,
        pin_jsonfilter VARCHAR2
    ) RETURN datatable_venta_costo_utilidad_articulo
        PIPELINED;

END;

/
