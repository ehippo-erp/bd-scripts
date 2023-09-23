--------------------------------------------------------
--  DDL for Package PACK_CUBO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CUBO_COMPRAS" IS
    TYPE datarecord_cubo_compras1 IS RECORD (
        documento              tdoccobranza.descri%TYPE,
        sucursal               VARCHAR2(250),
        diasemana              VARCHAR2(25),
        mes                    VARCHAR2(25),
        periodo                NUMBER(38),
        mesid                  NUMBER(38),
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          DATE,
        tipo_cambio            documentos_cab.tipcam%TYPE,
        codigo_proveedor         documentos_cab.codcli%TYPE,
        clasificacion_proveedor  VARCHAR2(250),
        tipo_proveedor           VARCHAR2(250),
        proveedor                documentos_cab.razonc%TYPE,--cliente
        ruc                    documentos_cab.ruc%TYPE,
        forma_pago             c_pago.despag%TYPE,
        motivo                 motivos.desmot%TYPE,
        vendedor               VARCHAR2(250),--vendedor
        moneda                 documentos_cab.tipmon%TYPE,
        tipo_inventario        documentos_det.tipinv%TYPE,
        linea_negocio          VARCHAR2(250),
        familia_producto       VARCHAR2(250),
        tipo_producto          VARCHAR2(250),
        clasificacion_producto VARCHAR2(250),
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        etiqueta               kardex001.etiqueta%TYPE,
        dioptria               kardex001.ancho%TYPE,
        lote                   kardex001.lote%TYPE,
        serie_articulo         kardex001.nrocarrete%TYPE,
        fecha_vencimiento      VARCHAR2(20),
        cantidad               NUMBER(38),
        precio_unitario           NUMBER(16, 4),
        importe             NUMBER(16, 4),
        departamento           VARCHAR2(250),
        provincia              VARCHAR2(250),
        distrito               VARCHAR2(250),
        grupo_economico        VARCHAR2(250)
    );
    TYPE datatable_cubo_compras1 IS
        TABLE OF datarecord_cubo_compras1;
        
    TYPE datarecord_cubo_compras2 IS RECORD (
        documento              tdoccobranza.descri%TYPE,
        sucursal               VARCHAR2(250),
        diasemana              VARCHAR2(25),
        mes                    VARCHAR2(25),
        periodo                NUMBER(38),
        mesid                  NUMBER(38),
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          DATE,
        tipo_cambio            documentos_cab.tipcam%TYPE,
        codigo_proveedor         documentos_cab.codcli%TYPE,
        clasificacion_proveedor  VARCHAR2(250),
        tipo_proveedor           VARCHAR2(250),
        proveedor                documentos_cab.razonc%TYPE,--cliente
        ruc                    documentos_cab.ruc%TYPE,
        forma_pago             c_pago.despag%TYPE,
        motivo                 motivos.desmot%TYPE,
        vendedor               VARCHAR2(250),--vendedor
        moneda                 documentos_cab.tipmon%TYPE,
        tipo_inventario        documentos_det.tipinv%TYPE,
        linea_negocio          VARCHAR2(250),
        familia_producto       VARCHAR2(250),
        tipo_producto          VARCHAR2(250),
        clasificacion_producto VARCHAR2(250),
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        etiqueta               kardex001.etiqueta%TYPE,
        dioptria               kardex001.ancho%TYPE,
        lote                   kardex001.lote%TYPE,
        serie_articulo         kardex001.nrocarrete%TYPE,
        fecha_vencimiento      VARCHAR2(20),
        cantidad               NUMBER(38),
        precio_fob_oc          NUMBER(16, 4),
        importe             NUMBER(16, 4),
        costo_unitario_sol NUMBER(16, 4),
        costo_unitario_dol NUMBER(16, 4),
        departamento           VARCHAR2(250),
        provincia              VARCHAR2(250),
        distrito               VARCHAR2(250),
        grupo_economico        VARCHAR2(250)
    );
    TYPE datatable_cubo_compras2 IS
        TABLE OF datarecord_cubo_compras2;
        
    TYPE datarecord_cosunikardex IS RECORD(
        id_cia documentos_cab.id_cia%TYPE,
        ocnumint documentos_cab.numint%TYPE,
        ocnumite documentos_det.numite%TYPE,
        knumint documentos_cab.numint%TYPE,
        knumite documentos_det.numite%TYPE,
        cosunisol NUMBER(16,4),
        cosunidol NUMBER(16,4)
    );
    TYPE datatable_cosunikardex IS
        TABLE OF datarecord_cosunikardex;
        
    FUNCTION sp_cubocompras001 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_compras1
        PIPELINED;

    FUNCTION sp_cubocompras002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_compras2
        PIPELINED;

    FUNCTION sp_cosunikardex (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_cosunikardex
        PIPELINED;

END;

/
