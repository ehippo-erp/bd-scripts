--------------------------------------------------------
--  DDL for Package PACK_CUBO_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CUBO_KARDEX" AS
    TYPE datarecord_cubo_kardex001 IS RECORD (
        id_cia     kardex.id_cia%TYPE,
        periodo    kardex.periodo%TYPE,
        mes        kardex.periodo%TYPE,
        mes_nombre VARCHAR2(100),
        numdoc     documentos_cab.numdoc%TYPE,
        series     documentos_cab.series%TYPE,
        dtipdoc    documentos_tipo.descri%TYPE,
        codalm     kardex.codalm%TYPE,
        desalm     almacen.descri%TYPE,
        ubica      kardex.ubica%TYPE,
        desubi     almacen_ubicacion.descri%TYPE,
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     kardex.codart%TYPE,
        desart     articulos.descri%TYPE,
        cantid     kardex.cantid%TYPE,
        codadd01   kardex.codadd01%TYPE,
        dcodadd01  cliente_articulos_clase.descri%TYPE,
        codadd02   kardex.codadd02%TYPE,
        dcodadd02  cliente_articulos_clase.descri%TYPE,
        toneladas  NUMBER(10, 3),
        codcli     kardex.codcli%TYPE,
        descli     cliente.razonc%TYPE,
        codmot     kardex.codmot%TYPE,
        codfab01   kardex.cosfab01%TYPE,
        cosmat01   kardex.cosmat01%TYPE,
        cosmob01   kardex.cosmob01%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        cosuni01   kardex.costot01%TYPE,
        coduni02   kardex.costot02%TYPE,
        etiqueta   kardex.etiqueta%TYPE,
        factua     kardex.factua%TYPE,
        fcreac     kardex.fcreac%TYPE,
        femisi     kardex.femisi%TYPE,
        fobtot01   kardex.fobtot01%TYPE,
        fobtot02   kardex.fobtot02%TYPE,
        id         kardex.id%TYPE,
        movimiento kardex.movimiento%TYPE,
        numint     kardex.numint%TYPE,
        numite     kardex.numite%TYPE,
        opcargo    kardex.opcargo%TYPE,
        opcodart   kardex.opcodart%TYPE,
        opnumdoc   kardex.opnumdoc%TYPE,
        opnumite   kardex.opnumite%TYPE,
        optipinv   kardex.optipinv%TYPE,
        optramo    kardex.optramo%TYPE,
        royos      kardex.royos%TYPE,
        situac     kardex.situac%TYPE,
        swacti     kardex.swacti%TYPE,
        tipcam     kardex.tipcam%TYPE,
        tipdoc     kardex.tipdoc%TYPE,
        usuari     kardex.usuari%TYPE,
        ancho      kardex001.ancho%TYPE,
        desmot     motivos.desmot%TYPE
    );
    TYPE datatable_cubo_kardex001 IS
        TABLE OF datarecord_cubo_kardex001;
    TYPE datarecord_cubo_kardex002 IS RECORD (
        periodo           kardex.periodo%TYPE,
        mes               kardex.periodo%TYPE,
        mes_nombre        VARCHAR2(100),
        fecha_emision     VARCHAR2(100),
        numdoc            documentos_cab.numdoc%TYPE,
        serie             documentos_cab.series%TYPE,
        tipo_documento    documentos_tipo.descri%TYPE,
        codalm            kardex.codalm%TYPE,
        almacen           VARCHAR2(1000),
        codubi            kardex.ubica%TYPE,
        ubicacion         almacen_ubicacion.descri%TYPE,
        codcli            kardex.codcli%TYPE,
        cliente           VARCHAR2(1000),
        tipinv            kardex.tipinv%TYPE,
        inventario        t_inventario.dtipinv%TYPE,
        codart            kardex.codart%TYPE,
        articulo          articulos.descri%TYPE,
        codmot            kardex.codmot%TYPE,
        motivo            motivos.desmot%TYPE,
        id                kardex.id%TYPE,
        tipo              VARCHAR2(100),
        cantid            kardex.cantid%TYPE,
        costot01          kardex.costot01%TYPE,
        costot02          kardex.costot02%TYPE,
        cosuni01          kardex.costot01%TYPE,
        coduni02          kardex.costot02%TYPE,
        etiqueta          kardex.etiqueta%TYPE,
        serie_articulo    kardex001.nrocarrete%TYPE,
        lote              kardex001.lote%TYPE,
        dioptria          kardex001.ancho%TYPE,
        fecha_vencimiento VARCHAR2(100),
        numint            kardex.numint%TYPE,
        numite            kardex.numite%TYPE,
        tipo_cambio       kardex.tipcam%TYPE,
        usuari            kardex.usuari%TYPE
    );
    TYPE datatable_cubo_kardex002 IS
        TABLE OF datarecord_cubo_kardex002;
    TYPE datarecord_cubo_kardex003 IS RECORD (
        periodo        kardex.periodo%TYPE,
        mes            kardex.periodo%TYPE,
        mes_nombre     VARCHAR2(100),
        fecha_emision  VARCHAR2(100),
        numdoc         documentos_cab.numdoc%TYPE,
        serie          documentos_cab.series%TYPE,
        tipo_documento documentos_tipo.descri%TYPE,
        codalm         kardex.codalm%TYPE,
        almacen        VARCHAR2(1000),
        codubi         kardex.ubica%TYPE,
        ubicacion      almacen_ubicacion.descri%TYPE,
        codcli         kardex.codcli%TYPE,
        cliente        VARCHAR2(1000),
        tipinv         kardex.tipinv%TYPE,
        inventario     t_inventario.dtipinv%TYPE,
        codart         kardex.codart%TYPE,
        articulo       articulos.descri%TYPE,
        codmot         kardex.codmot%TYPE,
        motivo         motivos.desmot%TYPE,
        id             kardex.id%TYPE,
        tipo           VARCHAR2(100),
        cantid         kardex.cantid%TYPE,
        costot01       kardex.costot01%TYPE,
        costot02       kardex.costot02%TYPE,
        cosuni01       kardex.costot01%TYPE,
        coduni02       kardex.costot02%TYPE,
        etiqueta       kardex.etiqueta%TYPE,
        chasis         kardex001.chasis%TYPE,
        motor          kardex001.motor%TYPE,
        numint         kardex.numint%TYPE,
        numite         kardex.numite%TYPE,
        tipo_cambio    kardex.tipcam%TYPE,
        usuari         kardex.usuari%TYPE
    );
    TYPE datatable_cubo_kardex003 IS
        TABLE OF datarecord_cubo_kardex003;
    TYPE datarecord_cubo_kardex004 IS RECORD (
        periodo        kardex.periodo%TYPE,
        mes            kardex.periodo%TYPE,
        mes_nombre     VARCHAR2(100),
        fecha_emision  VARCHAR2(100),
        numdoc         documentos_cab.numdoc%TYPE,
        serie          documentos_cab.series%TYPE,
        tipo_documento documentos_tipo.descri%TYPE,
        codalm         kardex.codalm%TYPE,
        almacen        VARCHAR2(1000),
        codubi         kardex.ubica%TYPE,
        ubicacion      almacen_ubicacion.descri%TYPE,
        codcli         kardex.codcli%TYPE,
        cliente        VARCHAR2(1000),
        tipinv         kardex.tipinv%TYPE,
        inventario     t_inventario.dtipinv%TYPE,
        codart         kardex.codart%TYPE,
        articulo       articulos.descri%TYPE,
        codmot         kardex.codmot%TYPE,
        motivo         motivos.desmot%TYPE,
        id             kardex.id%TYPE,
        tipo           VARCHAR2(100),
        cantid         kardex.cantid%TYPE,
        costot01       kardex.costot01%TYPE,
        costot02       kardex.costot02%TYPE,
        cosuni01       kardex.costot01%TYPE,
        coduni02       kardex.costot02%TYPE,
        etiqueta       kardex.etiqueta%TYPE,
        numint         kardex.numint%TYPE,
        numite         kardex.numite%TYPE,
        tipo_cambio    kardex.tipcam%TYPE,
        usuari         kardex.usuari%TYPE
    );
    TYPE datatable_cubo_kardex004 IS
        TABLE OF datarecord_cubo_kardex004;
    FUNCTION sp_cubo_kardex001 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex001
        PIPELINED;

    -- ASG Y TAGA
    FUNCTION sp_cubo_kardex002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex002
        PIPELINED;

    -- BULOS
    FUNCTION sp_cubo_kardex003 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex003
        PIPELINED;
    -- GENERAL
    FUNCTION sp_cubo_kardex004 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_kardex004
        PIPELINED;

END;

/
