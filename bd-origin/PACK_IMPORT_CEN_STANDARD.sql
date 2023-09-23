--------------------------------------------------------
--  DDL for Package PACK_IMPORT_CEN_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_CEN_STANDARD" AS
    TYPE r_errores IS RECORD (
        orden    NUMBER,
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_valida_objeto_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    TYPE datarecord_orden_pedido IS RECORD (
        id_cia                documentos_cab.id_cia%TYPE,
        numint                documentos_cab.numint%TYPE,
        serie                 documentos_cab.series%TYPE,
        numero                documentos_cab.numdoc%TYPE,
        codcli                documentos_cab.codcli%TYPE,
        tident                documentos_cab.tident%TYPE,
        dident                cliente.dident%TYPE,
        razonsocial           documentos_cab.razonc%TYPE,
        direccion             documentos_cab.direc1%TYPE,
        telefono              cliente.telefono%TYPE,
        femisi                documentos_cab.femisi%TYPE,
        fentreg               documentos_cab.fentreg%TYPE,
        horapactada           VARCHAR2(500 CHAR),
        lugemi                documentos_cab.lugemi%TYPE,
        situac                documentos_cab.situac%TYPE,
        situacnombre          situacion.dessit%TYPE,
        id                    documentos_cab.id%TYPE,
        codmot                documentos_cab.codmot%TYPE,
        incigv                VARCHAR2(500 CHAR),
        porigv                documentos_cab.porigv%TYPE,
        codven                documentos_cab.codven%TYPE,
        vendedor              VARCHAR2(500 CHAR),
        codsuc                documentos_cab.codsuc%TYPE,
        moneda                documentos_cab.tipmon%TYPE,
        tipcam                documentos_cab.tipcam%TYPE,
        codcpag               documentos_cab.codcpag%TYPE,
        condicionpago         c_pago.despag%TYPE,
        coduser               documentos_cab.usuari%TYPE,
        usuario               VARCHAR2(500 CHAR),
        importebruto          documentos_cab.preven%TYPE,
        importe               documentos_cab.preven%TYPE,
        observacion           documentos_cab.observ%TYPE,
        referencia            documentos_cab.observ%TYPE,
        comentario            documentos_cab.preven%TYPE,
        monafe                documentos_cab.monafe%TYPE,
        monina                documentos_cab.monina%TYPE,
        monigv                documentos_cab.monigv%TYPE,
        preven                documentos_cab.preven%TYPE,
        ucreac                documentos_cab.ucreac%TYPE,
        usuari                documentos_cab.usuari%TYPE,
        fcreac                documentos_cab.fcreac%TYPE,
        factua                documentos_cab.factua%TYPE,
        countadj              documentos_cab.countadj%TYPE,
        monisc                documentos_cab.monisc%TYPE,
        direccionenvio_codenv clientes_almacen.codenv%TYPE,
        direccionenvio_direc1 clientes_almacen.direc1%TYPE,
        direccionenvio_direc2 clientes_almacen.direc2%TYPE,
        ordencompra_fecha     documentos_cab_ordcom.fecha%TYPE,
        ordencompra_numero    documentos_cab_ordcom.numero%TYPE,
        ordencompra_contacto  documentos_cab_ordcom.contacto%TYPE
    );
    TYPE datatable_orden_pedido IS
        TABLE OF datarecord_orden_pedido;
    TYPE datarecord_orden_pedido_detalle IS RECORD (
        id_cia       documentos_det.id_cia%TYPE,
        numint       documentos_det.numint%TYPE,
        numite       documentos_det.numite%TYPE,
        tipinv       documentos_det.tipinv%TYPE,
        codart       documentos_det.codart%TYPE,
        desart       articulos.descri%TYPE,
        undmed       documentos_det.codund%TYPE,
        pordes1      documentos_det.pordes1%TYPE,
        pordes2      documentos_det.pordes2%TYPE,
        pordes3      documentos_det.pordes3%TYPE,
        pordes4      documentos_det.pordes4%TYPE,
        preuni       documentos_det.preuni%TYPE,
        importebruto documentos_det.importe_bruto%TYPE,
        importe      documentos_det.importe%TYPE,
        observ       documentos_det.observ%TYPE,
        cantid       documentos_det.cantid%TYPE,
        codalm       documentos_det.codalm%TYPE,
        etiqueta     documentos_det.etiqueta%TYPE,
        codadd01     documentos_det.codadd01%TYPE,
        descodadd01  VARCHAR2(500 CHAR),
        codadd02     documentos_det.codadd02%TYPE,
        descodadd02  VARCHAR2(500 CHAR),
        positi       documentos_det.positi%TYPE,
        refnumint    documentos_det.numint%TYPE,
        refnumite    documentos_det.numite%TYPE,
        nrocarrete   documentos_det.nrocarrete%TYPE,
        acabado      documentos_det.acabado%TYPE,
        chasis       documentos_det.chasis%TYPE,
        motor        documentos_det.motor%TYPE,
        lote         documentos_det.lote%TYPE,
        ancho        documentos_det.ancho%TYPE,
        fvenci       documentos_det.fvenci%TYPE,
--    actionDelete;
        codprv       articulos.codprv%TYPE,
        monisc       documentos_det.monisc%TYPE,
        valporisc    documentos_det.valporisc%TYPE,
        tipisc       documentos_det.tipisc%TYPE
    );
    TYPE datatable_orden_pedido_detalle IS
        TABLE OF datarecord_orden_pedido_detalle;
    FUNCTION sp_orden_pedido (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable_orden_pedido
        PIPELINED;

    FUNCTION sp_orden_pedido_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable_orden_pedido_detalle
        PIPELINED;

END;

/
