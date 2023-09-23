--------------------------------------------------------
--  DDL for Package PACK_ETIQUETAS_TSIPRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ETIQUETAS_TSIPRINT" AS
    TYPE datarecord_info_cliente IS RECORD (
        codcli cliente.codcli%TYPE,
        razonc cliente.razonc%TYPE
    );
    TYPE datatable_info_cliente IS
        TABLE OF datarecord_info_cliente;
    TYPE datarecord_info_guia IS RECORD (
        numint documentos_cab.numint%TYPE,
        razonc documentos_cab.razonc%TYPE,
        codcli documentos_cab.codcli%TYPE
    );
    TYPE datatable_info_guia IS
        TABLE OF datarecord_info_guia;
    TYPE datarecord_tipo_etiqueta IS RECORD (
        numint       kardex001.numint%TYPE,
        numite       kardex001.numite%TYPE,
        series       documentos_cab.series%TYPE,
        numdoc       documentos_cab.numdoc%TYPE,
        desart       articulos.descri%TYPE,
        tipinv       kardex001.tipinv%TYPE,
        codart       kardex001.codart%TYPE,
        etiqueta     kardex001.etiqueta%TYPE,
        lote         kardex001.lote%TYPE,
        codadd01     kardex001.codadd01%TYPE,
        codadd02     kardex001.codadd02%TYPE,
        codcli       documentos_cab.codcli%TYPE,
        razonc       documentos_cab.razonc%TYPE,
        cantid       kardex001.ingreso%TYPE,
        ubica        kardex001.ubica%TYPE,
        desubica     almacen_ubicacion.descri%TYPE,
        femisi       documentos_cab.femisi%TYPE,
        nrocarrete   kardex001.nrocarrete%TYPE,
        combina      kardex001.combina%TYPE,
        empalme      kardex001.empalme%TYPE,
        prvabv       clientes_especificacion.vstrg%TYPE,
        ancho        kardex001.ancho%TYPE,
        largo        kardex001.largo%TYPE,
        ordcom       documentos_cab.ordcom%TYPE,
        facpro       documentos_cab.facpro%TYPE,
        numped       documentos_cab.numped%TYPE,
        fimporta     VARCHAR2(10),
        diseno       kardex001.diseno%TYPE,
        acabado      kardex001.acabado%TYPE,
        codalm       kardex001.codalm%TYPE,
        desalm       almacen.descri%TYPE,
        desadd01     cliente_articulos_clase.descri%TYPE,
        desadd02     cliente_articulos_clase.descri%TYPE,
        codenc       documentos_cab_clase.codigo%TYPE,
        abreviuni    unidad.abrevi%TYPE,
        swimpr       NUMBER,
        codcapmega   articulos_clase.codigo%TYPE,
        descapmega   clase_codigo.descri%TYPE,
        codcappro    articulos_clase.codigo%TYPE,
        descappro    clase_codigo.descri%TYPE,
        codclase91   VARCHAR2(20),
        desresmingar VARCHAR2(70),
        codclase93   VARCHAR2(20),
        desmaterial  VARCHAR2(70),
        codclase96   VARCHAR2(20),
        desfactordis VARCHAR2(70),
        codclase97   VARCHAR2(20),
        desanchocin  VARCHAR2(70),
        codclase98   VARCHAR2(20),
        descolorcin  VARCHAR2(70),
        capaciver    VARCHAR2(70),
        capacienu    VARCHAR2(70),
        capacilaz    VARCHAR2(70),
        numerocert   VARCHAR2(500),
        cert_agrupa  certificadocal_det.agrupa%TYPE,
        cert_periodo certificadocal_det.periodo%TYPE,
        cert_numero  certificadocal_det.numero%TYPE,
        usocantid    certificadocal_cab.usocantid%TYPE,
        nro_orcom    documentos_cab_ordcom.numero%TYPE,
        nro_ramales  documentos_det_clase.ventero%TYPE,
        capacidad60  documentos_det_clase.vreal%TYPE,
        capacidad45  documentos_det_clase.vreal%TYPE,
        capacidad30  documentos_det_clase.vreal%TYPE,
        serie_op     documentos_cab.series%TYPE,
        numdoc_op    documentos_cab.numdoc%TYPE,
        cantid_ori   kardex001.cantid_ori%TYPE
    );
    TYPE datatable_tipo_etiqueta IS
        TABLE OF datarecord_tipo_etiqueta;
    TYPE datarecord_tipo_tomainventario IS RECORD (
        numint       kardex001.numint%TYPE,
        numite       kardex001.numite%TYPE,
        series       documentos_cab.series%TYPE,
        numdoc       documentos_cab.numdoc%TYPE,
        desart       articulos.descri%TYPE,
        tipinv       kardex001.tipinv%TYPE,
        codart       kardex001.codart%TYPE,
        etiqueta     kardex001.etiqueta%TYPE,
        lote         kardex001.lote%TYPE,
        codadd01     kardex001.codadd01%TYPE,
        codadd02     kardex001.codadd02%TYPE,
        codcli       documentos_cab.codcli%TYPE,
        razonc       documentos_cab.razonc%TYPE,
        cantid       kardex001.ingreso%TYPE,
        ubica        kardex001.ubica%TYPE,
        desubica     almacen_ubicacion.descri%TYPE,
        femisi       documentos_cab.femisi%TYPE,
        nrocarrete   kardex001.nrocarrete%TYPE,
        combina      kardex001.combina%TYPE,
        empalme      kardex001.empalme%TYPE,
        prvabv       clientes_especificacion.vstrg%TYPE,
        ancho        kardex001.ancho%TYPE,
        largo        kardex001.largo%TYPE,
        ordcom       documentos_cab.ordcom%TYPE,
        facpro       documentos_cab.facpro%TYPE,--NO
        numped       documentos_cab.numped%TYPE,--NO
        fimporta     VARCHAR2(10),--NO
        diseno       kardex001.diseno%TYPE,
        acabado      kardex001.acabado%TYPE,
        codalm       kardex001.codalm%TYPE,
        desalm       almacen.descri%TYPE,
        desadd01     cliente_articulos_clase.descri%TYPE,
        desadd02     cliente_articulos_clase.descri%TYPE,
        codenc       documentos_cab_clase.codigo%TYPE,
        abreviuni    unidad.abrevi%TYPE,
        swimpr       NUMBER,
        codcapmega   articulos_clase.codigo%TYPE,
        descapmega   clase_codigo.descri%TYPE,
        codcappro    articulos_clase.codigo%TYPE,
        descappro    clase_codigo.descri%TYPE,
        codclase91   VARCHAR2(20),
        desresmingar VARCHAR2(70),
        codclase93   VARCHAR2(20),
        desmaterial  VARCHAR2(70),
        codclase96   VARCHAR2(20),
        desfactordis VARCHAR2(70),
        codclase97   VARCHAR2(20),
        desanchocin  VARCHAR2(70),
        codclase98   VARCHAR2(20),
        descolorcin  VARCHAR2(70),
        capaciver    VARCHAR2(70),
        capacienu    VARCHAR2(70),
        capacilaz    VARCHAR2(70),
        numerocert   VARCHAR2(500),
        cert_agrupa  certificadocal_det.agrupa%TYPE,
        cert_periodo certificadocal_det.periodo%TYPE,
        cert_numero  certificadocal_det.numero%TYPE,
        usocantid    certificadocal_cab.usocantid%TYPE,
        nro_orcom    documentos_cab_ordcom.numero%TYPE,
        nro_ramales  documentos_det_clase.ventero%TYPE,
        capacidad60  documentos_det_clase.vreal%TYPE,
        capacidad45  documentos_det_clase.vreal%TYPE,
        capacidad30  documentos_det_clase.vreal%TYPE,
        serie_op     documentos_cab.series%TYPE,
        numdoc_op    documentos_cab.numdoc%TYPE,
        cantid_ori   kardex001.cantid_ori%TYPE--NO
    );
    TYPE datatable_tipo_tomainventario IS
        TABLE OF datarecord_tipo_tomainventario;
    TYPE datarecord_tipo_guiainterna IS RECORD (
        numint               kardex001.numint%TYPE,
        numite               kardex001.numite%TYPE,
        series               documentos_cab.series%TYPE,
        numdoc               documentos_cab.numdoc%TYPE,
        desart               articulos.descri%TYPE,
        tipinv               kardex001.tipinv%TYPE,
        codart               kardex001.codart%TYPE,
        etiqueta             kardex001.etiqueta%TYPE,
        lote                 kardex001.lote%TYPE,
        codadd01             kardex001.codadd01%TYPE,
        codadd02             kardex001.codadd02%TYPE,
        codcli               documentos_cab.codcli%TYPE,
        razonc               documentos_cab.razonc%TYPE,
        cantid               kardex001.ingreso%TYPE,
        ubica                kardex001.ubica%TYPE,
        desubica             almacen_ubicacion.descri%TYPE,
        femisi               documentos_cab.femisi%TYPE,
        nrocarrete           kardex001.nrocarrete%TYPE,
        combina              kardex001.combina%TYPE,
        empalme              kardex001.empalme%TYPE,
        prvabv               clientes_especificacion.vstrg%TYPE,
        ancho                kardex001.ancho%TYPE,
        largo                kardex001.largo%TYPE,
        ordcom               documentos_cab.ordcom%TYPE,
        facpro               documentos_cab.facpro%TYPE,
        numped               documentos_cab.numped%TYPE,
        fimporta             VARCHAR2(10),
        diseno               kardex001.diseno%TYPE,
        acabado              kardex001.acabado%TYPE,
        codalm               kardex001.codalm%TYPE,
        desalm               almacen.descri%TYPE,
        desadd01             cliente_articulos_clase.descri%TYPE,
        desadd02             cliente_articulos_clase.descri%TYPE,
        codenc               documentos_cab_clase.codigo%TYPE,
        abreviuni            unidad.abrevi%TYPE,
        swimpr               NUMBER,
        desclase3            clase_codigo.descri%TYPE, --NO
        desclase6            clase_codigo.descri%TYPE, --NO
        codcapmega           articulos_clase.codigo%TYPE,
        descapmega           clase_codigo.descri%TYPE,
        codcappro            articulos_clase.codigo%TYPE,
        descappro            clase_codigo.descri%TYPE,
        codclase91           VARCHAR2(20),
        desresmingar         VARCHAR2(70),
        codclase93           VARCHAR2(20),
        desmaterial          VARCHAR2(70),
        codclase96           VARCHAR2(20),
        desfactordis         VARCHAR2(70),
        codclase97           VARCHAR2(20),
        desanchocin          VARCHAR2(70),
        codclase98           VARCHAR2(20),
        descolorcin          VARCHAR2(70),
        capaciver            VARCHAR2(70),
        capacienu            VARCHAR2(70),
        capacilaz            VARCHAR2(70),
        numerocert           VARCHAR2(500),
        cert_agrupa          certificadocal_det.agrupa%TYPE,
        cert_periodo         certificadocal_det.periodo%TYPE,
        cert_numero          certificadocal_det.numero%TYPE,
        usocantid            certificadocal_cab.usocantid%TYPE,
        razonccert           cliente.razonc%TYPE, --NO
        tipo_terminal        clase_documentos_det_codigo.descri%TYPE, --NO
        abrevi_tipo_terminal clase_documentos_det_codigo.abrevi%TYPE, --NO
        nro_orcom            documentos_cab_ordcom.numero%TYPE,
        nro_ramales          documentos_det_clase.ventero%TYPE,
        capacidad60          documentos_det_clase.vreal%TYPE,
        capacidad45          documentos_det_clase.vreal%TYPE,
        capacidad30          documentos_det_clase.vreal%TYPE,
        serie_op             documentos_cab.series%TYPE,
        numdoc_op            documentos_cab.numdoc%TYPE,
        cantid_ori           kardex001.cantid_ori%TYPE,
        positi_op            documentos_det.positi%TYPE --NO
    );
    TYPE datatable_tipo_guiainterna IS
        TABLE OF datarecord_tipo_guiainterna;

    TYPE datarecord_buscar IS RECORD (
        numint               kardex001.numint%TYPE,
        numite               kardex001.numite%TYPE,
        series               documentos_cab.series%TYPE,
        numdoc               documentos_cab.numdoc%TYPE,
        desart               articulos.descri%TYPE,
        tipinv               kardex001.tipinv%TYPE,
        codart               kardex001.codart%TYPE,
        etiqueta             kardex001.etiqueta%TYPE,
        lote                 kardex001.lote%TYPE,
        codadd01             kardex001.codadd01%TYPE,
        codadd02             kardex001.codadd02%TYPE,
        codcli               documentos_cab.codcli%TYPE,
        razonc               documentos_cab.razonc%TYPE,
        cantid               kardex001.ingreso%TYPE,
        ubica                kardex001.ubica%TYPE,
        desubica             almacen_ubicacion.descri%TYPE,
        femisi               documentos_cab.femisi%TYPE,
        nrocarrete           kardex001.nrocarrete%TYPE,
        combina              kardex001.combina%TYPE,
        empalme              kardex001.empalme%TYPE,
        prvabv               clientes_especificacion.vstrg%TYPE,
        ancho                kardex001.ancho%TYPE,
        largo                kardex001.largo%TYPE,
        ordcom               documentos_cab.ordcom%TYPE,
        facpro               documentos_cab.facpro%TYPE,
        numped               documentos_cab.numped%TYPE,
        fimporta             VARCHAR2(10),
        diseno               kardex001.diseno%TYPE,
        acabado              kardex001.acabado%TYPE,
        codalm               kardex001.codalm%TYPE,
        desalm               almacen.descri%TYPE,
        desadd01             cliente_articulos_clase.descri%TYPE,
        desadd02             cliente_articulos_clase.descri%TYPE,
        codenc               documentos_cab_clase.codigo%TYPE,
        abreviuni            unidad.abrevi%TYPE,
        swimpr               NUMBER,
        desclase3            clase_codigo.descri%TYPE, --NO
        desclase6            clase_codigo.descri%TYPE, --NO
        codcapmega           articulos_clase.codigo%TYPE,
        descapmega           clase_codigo.descri%TYPE,
        codcappro            articulos_clase.codigo%TYPE,
        descappro            clase_codigo.descri%TYPE,
        codclase91           VARCHAR2(20),
        desresmingar         VARCHAR2(70),
        codclase93           VARCHAR2(20),
        desmaterial          VARCHAR2(70),
        codclase96           VARCHAR2(20),
        desfactordis         VARCHAR2(70),
        codclase97           VARCHAR2(20),
        desanchocin          VARCHAR2(70),
        codclase98           VARCHAR2(20),
        descolorcin          VARCHAR2(70),
        capaciver            VARCHAR2(70),
        capacienu            VARCHAR2(70),
        capacilaz            VARCHAR2(70),
        numerocert           VARCHAR2(500),
        cert_agrupa          certificadocal_det.agrupa%TYPE,
        cert_periodo         certificadocal_det.periodo%TYPE,
        cert_numero          certificadocal_det.numero%TYPE,
        usocantid            certificadocal_cab.usocantid%TYPE,
        razonccert           cliente.razonc%TYPE, --NO
        tipo_terminal        clase_documentos_det_codigo.descri%TYPE, --NO
        abrevi_tipo_terminal clase_documentos_det_codigo.abrevi%TYPE, --NO
        nro_orcom            documentos_cab_ordcom.numero%TYPE,
        nro_ramales          documentos_det_clase.ventero%TYPE,
        capacidad60          documentos_det_clase.vreal%TYPE,
        capacidad45          documentos_det_clase.vreal%TYPE,
        capacidad30          documentos_det_clase.vreal%TYPE,
        serie_op             documentos_cab.series%TYPE,
        numdoc_op            documentos_cab.numdoc%TYPE,
        cantid_ori           kardex001.cantid_ori%TYPE,
        positi_op            documentos_det.positi%TYPE --NO
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;

    TYPE datarecord_buscar_doc IS RECORD(
        id_cia documentos_cab.id_cia%TYPE,
        series documentos_cab.series%TYPE,
        numdoc documentos_cab.numdoc%TYPE,
        numint documentos_cab.numint%TYPE,
        femisi documentos_cab.femisi%TYPE,
        codcli documentos_cab.codcli%TYPE,
        razonc documentos_cab.razonc%TYPE,
        ruc documentos_cab.ruc%TYPE,
        situac documentos_cab.situac%TYPE,
        id documentos_cab.id%TYPE,
        opnumdoc documentos_cab.opnumdoc%TYPE,
        observ documentos_cab.observ%TYPE,
        proyec documentos_cab.proyec%TYPE,
        dessit situacion.dessit%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        desmot motivos.desmot%TYPE,
        codalm documentos_cab.codalm%TYPE,
        desalm almacen.descri%TYPE,
        optipinv documentos_cab.optipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        tipmon documentos_cab.tipmon%TYPE,
        tipcam documentos_cab.tipcam%TYPE,
        porigv documentos_cab.porigv%TYPE,
        preven documentos_cab.preven%TYPE,
        dircli1 cliente.direc1%TYPE,
        dircli2 cliente.direc2%TYPE,
        desmon tmoneda.desmon%TYPE,
        simbolo tmoneda.simbolo%TYPE,
        numped documentos_cab.numped%TYPE,
        oc_fecha  documentos_cab_ordcom.fecha%TYPE,
        oc_numero  documentos_cab_ordcom.numero%TYPE,
        presen documentos_cab.presen%TYPE
    );
    TYPE datatable_buscar_doc IS
        TABLE OF datarecord_buscar_doc;

-- AYUDAS Y ACTUALIZACION
    FUNCTION sp_info_cliente (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_info_cliente
        PIPELINED;

    FUNCTION sp_info_guia (
        pin_id_cia NUMBER,
        pin_numdoc NUMBER
    ) RETURN datatable_info_guia
        PIPELINED;

    PROCEDURE sp_insertar_etiquetas (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_buscar_tipo_etiqueta (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_etiqueta01 VARCHAR2,
        pin_etiqueta02 VARCHAR2
    ) RETURN datatable_tipo_guiainterna
        PIPELINED;

    FUNCTION sp_buscar_tipo_tomainventario (
        pin_id_cia   NUMBER,
        pin_numint   NUMBER,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2,
        pin_ubica    VARCHAR2
    ) RETURN datatable_tipo_guiainterna
        PIPELINED;

    FUNCTION sp_buscar_tipo_guiainterna (
        pin_id_cia   NUMBER,
        pin_numint   NUMBER,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2,
        pin_ubica    VARCHAR2
    ) RETURN datatable_tipo_guiainterna
        PIPELINED;

    FUNCTION sp_buscar(
        pin_id_cia NUMBER,
        pin_tipo NUMBER,-- 0 T.GuiaInterna / 1 T.Etiqueta / 2 TomaInventario 
        pin_numint NUMBER,--T.GuiaInterna/TomaInventario
        pin_codadd01 VARCHAR2,--T.GuiaInterna/TomaInventario
        pin_codadd02 VARCHAR2,--T.GuiaInterna/TomaInventario
        pin_ubica VARCHAR2,--T.GuiaInterna/TomaInventario
        pin_tipinv NUMBER,--T.Etiqueta
        pin_codart VARCHAR2,--T.Etiqueta
        pin_etiqueta01 VARCHAR2,--T.Etiqueta
        pin_etiqueta02 VARCHAR2--T.Etiqueta
    ) RETURN datatable_buscar
        PIPELINED;

     FUNCTION sp_buscar_doc (
        pin_id_cia    NUMBER,
        pin_tipdoc NUMBER,
        pin_codmot NUMBER,
        pin_femisi DATE,
        pin_codcli VARCHAR2
    ) RETURN datatable_buscar_doc
        PIPELINED;

END;

/
