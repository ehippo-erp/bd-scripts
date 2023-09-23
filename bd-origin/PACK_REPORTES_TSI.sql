--------------------------------------------------------
--  DDL for Package PACK_REPORTES_TSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_TSI" AS
    TYPE datarecord_fecha_de_vencimiento_entre_fe IS RECORD (
        marca           clase_codigo.descri%TYPE,
        tipo_inventario t_inventario.dtipinv%TYPE,
        codido_almacen  kardex.codalm%TYPE,
        almacen         VARCHAR(200),
        codigo_articulo kardex.codart%TYPE,
        articulo        articulos.descri%TYPE,
        saldo           NUMBER,
        lote            kardex001.lote%TYPE,
        fvenci          kardex001.fvenci%TYPE
    );
    TYPE datatable_fecha_de_vencimiento_entre_fe IS
        TABLE OF datarecord_fecha_de_vencimiento_entre_fe;
    TYPE datarecord_transferencia_gratuita_cxc IS RECORD (
        numint  documentos_cab.numint%TYPE,
        tipdoc  documentos_cab.tipdoc%TYPE,
        series  documentos_cab.series%TYPE,
        numdoc  documentos_cab.numdoc%TYPE,
        femisi  documentos_cab.femisi%TYPE,
        codmot  documentos_cab.codmot%TYPE,
        desmot  motivos.desmot%TYPE,
        razonc  documentos_cab.razonc%TYPE,
        codcpag documentos_cab.codcpag%TYPE,
        despag  c_pago.despag%TYPE,
        valor   c_pago_clase.valor%TYPE
    );
    TYPE datatable_transferencia_gratuita_cxc IS
        TABLE OF datarecord_transferencia_gratuita_cxc;
    TYPE datarecord_consistencia_tipo_documento IS RECORD (
        numint                documentos_cab.numint%TYPE,
        tipdoc                documentos_cab.tipdoc%TYPE,
        tipo_documento        documentos_tipo.descri%TYPE,
        alerta                VARCHAR2(10),
        serie                 documentos_cab.series%TYPE,
        numero                documentos_cab.numdoc%TYPE,
        fecha                 VARCHAR2(100 CHAR),
        codcli                documentos_cab.codcli%TYPE,
        razon_social          documentos_cab.razonc%TYPE,
        codsit                documentos_cab.situac%TYPE,
        situacion             VARCHAR2(100 CHAR),
        id                    documentos_cab.id%TYPE,
        codmot                motivos.codmot%TYPE,
        motivo                motivos.desmot%TYPE,
        codven                NUMBER,
        vendedor              VARCHAR2(300 CHAR),
        usuario_actualizacion usuarios.nombres%TYPE,
        usuario_creacion      usuarios.nombres%TYPE,
        fecha_actualizacion   VARCHAR2(100 CHAR),
        fecha_creacion        VARCHAR2(100 CHAR)
    );
    TYPE datatable_consistencia_tipo_documento IS
        TABLE OF datarecord_consistencia_tipo_documento;
    TYPE datarecord_stock_kardex IS RECORD (
        id_cia        kardex.id_cia%TYPE,
        tipinv        kardex.tipinv%TYPE,
        dtipinv       t_inventario.dtipinv%TYPE,
        codart        kardex.codart%TYPE,
        desart        articulos.descri%TYPE,
        stock_inicial NUMBER,
        ingresos      NUMBER,
        salidas       NUMBER,
        stock_final   NUMBER
    );
    TYPE datatable_stock_kardex IS
        TABLE OF datarecord_stock_kardex;
    TYPE datarecord_stock_kardex_detalle IS RECORD (
        id_cia  kardex.id_cia%TYPE,
        tipinv  kardex.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codart  kardex.codart%TYPE,
        desart  articulos.descri%TYPE,
        tipdoc  documentos_cab.tipdoc%TYPE,
        numint  documentos_cab.numint%TYPE,
        numite  kardex.numite%TYPE,
        femisi  kardex.femisi%TYPE,
        id      kardex.id%TYPE,
        cantid  kardex.cantid%TYPE,
        stock   NUMBER
    );
    TYPE datatable_stock_kardex_detalle IS
        TABLE OF datarecord_stock_kardex_detalle;
    TYPE datarecord_clase_articulo IS RECORD (
        id_cia          documentos_cab.id_cia%TYPE,
        tipinv          articulos.tipinv%TYPE,
        tipo_inventario t_inventario.dtipinv%TYPE,
        codart          articulos.codart%TYPE,
        articulo        articulos.descri%TYPE,
        observ          VARCHAR(250)
    );
    TYPE datatable_clase_articulo IS
        TABLE OF datarecord_clase_articulo;
    TYPE datarecord_relacion_actaentrega IS RECORD (
        tipo_documento    documentos_tipo.descri%TYPE,
        periodo           NUMBER,
        mes               VARCHAR2(100 CHAR),
        correlativo_de_ae documentos_cab.numint%TYPE,
        serie             documentos_cab.series%TYPE,
        numdoc            documentos_cab.numdoc%TYPE,
        fecha_emision     VARCHAR2(100 CHAR),
        cliente_ruc       documentos_cab.ruc%TYPE,
        cliente_razonc    documentos_cab.razonc%TYPE,
        codmot            motivos.codmot%TYPE,
        motivo            motivos.desmot%TYPE,
        item              documentos_det.numite%TYPE,
        tipinv            documentos_det.tipinv%TYPE,
        tipo_inventario   t_inventario.dtipinv%TYPE,
        codart            documentos_det.codart%TYPE,
        articulo          articulos.descri%TYPE,
        cantidad          documentos_det.cantid%TYPE,
        importe_unitario  documentos_det.preuni%TYPE,
        importe           documentos_det.importe%TYPE,
        etiqueta          documentos_det.etiqueta%TYPE,
        chasis            documentos_det.chasis%TYPE,
        motor             documentos_det.motor%TYPE,
        dam               documentos_det.dam%TYPE,
        placa             kardex000.placa%TYPE,
        dam_item          documentos_det.dam_item%TYPE,
        departamento      clase_codigo.descri%TYPE,
        clase             clase_codigo.descri%TYPE,
        subclase          clase_codigo.descri%TYPE,
        marca             clase_codigo.descri%TYPE,
        año_modelo        articulo_especificacion.ventero%TYPE,
        año_fabricación   articulo_especificacion.ventero%TYPE,
        color             articulo_especificacion.vstrg%TYPE
    );
    TYPE datatable_relacion_actaentrega IS
        TABLE OF datarecord_relacion_actaentrega;
    PROCEDURE sp_importar (
        pin_id_cia      IN NUMBER,
        pin_id_cia_orig IN NUMBER
    );

    FUNCTION fecha_de_vencimiento_entre_fe (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_fecha_de_vencimiento_entre_fe
        PIPELINED;

    FUNCTION sp_transferencia_gratuita_cxc (
        pin_id_cia NUMBER
    ) RETURN datatable_transferencia_gratuita_cxc
        PIPELINED;

    FUNCTION sp_stock_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_stock_kardex
        PIPELINED;

    FUNCTION sp_stock_kardex_detalle (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_stock_kardex_detalle
        PIPELINED;

    FUNCTION sp_consistencia_tipo_documento (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_consistencia_tipo_documento
        PIPELINED;

    FUNCTION sp_sin_clase_articulo (
        pin_id_cia NUMBER,
        pin_clase  NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_clase_articulo
        PIPELINED;

    FUNCTION sp_relacion_actaentrega (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_relacion_actaentrega
        PIPELINED;

END;

/
