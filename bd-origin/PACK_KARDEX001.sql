--------------------------------------------------------
--  DDL for Package PACK_KARDEX001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KARDEX001" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */


    TYPE rec_kardex001 IS RECORD (
        tipinv     NUMBER,
        destipinv  VARCHAR2(120),
        codart     VARCHAR2(120),
        fingreso   DATE,
        fsalida    DATE,
        stock      NUMBER(10, 2),
        salida     NUMBER(10, 2),
        numint     NUMBER(10, 2),
        codalm     NUMBER(10, 2),
        codcalid   VARCHAR2(120),
        descalid   VARCHAR2(120),
        codcolor   VARCHAR2(120),
        descolor   VARCHAR2(120),
        desubi     VARCHAR2(120),
        desalm     VARCHAR2(120),
        ubica      VARCHAR2(10),
        desart     VARCHAR2(120),
        coduni     VARCHAR2(120),
        codprv     articulos.codprv%TYPE,
        ancho      kardex001.ancho%TYPE,
        largo      kardex001.largo%TYPE,
        lote       VARCHAR2(20),
        etiqueta   VARCHAR2(120),
        nrocarrete VARCHAR2(120),
        combina    VARCHAR2(20),
        empalme    VARCHAR2(20),
        cantid_ori NUMBER(16, 0),
        swacti     NUMBER(16, 2),
        diseno     VARCHAR2(20),
        acabado    VARCHAR2(20),
        fvenci     DATE,
        fmanuf     DATE,
        abrunidad  VARCHAR2(10),
        chasis     documentos_det.chasis%TYPE,
        motor      documentos_det.motor%TYPE
    );
    TYPE tbl_kardex001 IS
        TABLE OF rec_kardex001;
    TYPE datarecord_etiquetas_resumen IS RECORD (
        tipinv     NUMBER,
        destipinv  VARCHAR2(120),
        codart     VARCHAR2(120),
        stock      NUMBER(10, 2),
        ingreso    NUMBER(10, 2),
        salida     NUMBER(10, 2),
        numint     NUMBER(10, 2),
        codalm     NUMBER(10, 2),
        codcalid   VARCHAR2(120),
        descalid   VARCHAR2(120),
        codcolor   VARCHAR2(120),
        descolor   VARCHAR2(120),
        desubi     VARCHAR2(120),
        desalm     VARCHAR2(120),
        ubica      VARCHAR2(10),
        desart     VARCHAR2(120),
        coduni     VARCHAR2(120),
        codprv     articulos.codprv%TYPE,
        ancho      kardex001.ancho%TYPE,
        largo      kardex001.largo%TYPE,
        lote       VARCHAR2(20),
        nrocarrete VARCHAR2(120),
        combina    VARCHAR2(20),
        empalme    VARCHAR2(20),
        diseno     VARCHAR2(20),
        acabado    VARCHAR2(20),
        fvenci     DATE,
        fmanuf     DATE,
        abrunidad  VARCHAR2(10)
    );
    TYPE datatable_etiquetas_resumen IS
        TABLE OF datarecord_etiquetas_resumen;
    TYPE datarecord_obtener_etiqueta IS RECORD (
        etiqueta   kardex001.etiqueta%TYPE,
        saldo      NUMBER(16, 5),
        coduni     articulos.coduni%TYPE,
        fingreso   DATE,
        fsalida    DATE,
        codadd01   kardex001.codadd01%TYPE,
        dcodadd01  cliente_articulos_clase.descri%TYPE,
        codadd02   kardex001.codadd02%TYPE,
        dcodadd02  cliente_articulos_clase.descri%TYPE,
        tipinv     kardex001.tipinv%TYPE,
        codart     kardex001.codart%TYPE,
        desart     articulos.descri%TYPE,
        consto     articulos.consto%TYPE,
        codprv     articulos.codprv%TYPE,
        ancho      kardex001.ancho%TYPE,
        codalm     kardex001.codalm%TYPE,
        ubica      kardex001.ubica%TYPE,
        swacti     kardex001.swacti%TYPE,
        cantid_ori kardex001.cantid_ori%TYPE,
        nrocarrete kardex001.nrocarrete%TYPE,
        lote       kardex001.lote%TYPE,
        combina    kardex001.combina%TYPE,
        empalme    kardex001.empalme%TYPE,
        diseno     kardex001.diseno%TYPE,
        acabado    kardex001.acabado%TYPE,
        fvenci     kardex001.fvenci%TYPE,
        fmanuf     kardex001.fmanuf%TYPE,
        activo     VARCHAR2(10),
        portolvnt  NUMBER,
        chasis     documentos_det.chasis%TYPE,
        motor      documentos_det.motor%TYPE
    );
    TYPE datatable_obtener_etiqueta IS
        TABLE OF datarecord_obtener_etiqueta;
    TYPE rec_help_kardex001 IS RECORD (
        etiqueta   VARCHAR2(120),
        saldo      NUMBER(16, 2),
        coduni     VARCHAR2(120),
        kanban     VARCHAR2(50),
        codcli     kardex001.codcli%TYPE,
        opnumdoc   kardex001.opnumdoc%TYPE,
        optramo    kardex001.optramo%TYPE,
        sucursal   kardex001.sucursal%TYPE,
        fingreso   DATE,
        codadd01   kardex001.codadd01%TYPE,
        codadd02   kardex001.codadd02%TYPE,
        tipinv     kardex001.tipinv%TYPE,
        codart     kardex001.codart%TYPE,
        desart     articulos.descri%TYPE,
        consto     articulos.consto%TYPE,
        codprv     articulos.codprv%TYPE,
        ancho      kardex001.ancho%TYPE,
        largo      kardex001.largo%TYPE,
        combina    kardex001.combina%TYPE,
        codalm     kardex001.codalm%TYPE,
        ubica      kardex001.ubica%TYPE,
        swacti     kardex001.swacti%TYPE,
        cantid_ori kardex001.cantid_ori%TYPE,
        lote       kardex001.lote%TYPE,
        fvenci     kardex001.fvenci%TYPE,
        fmanuf     kardex001.fmanuf%TYPE,
        nrocarrete kardex001.nrocarrete%TYPE,
        acabado    kardex001.acabado%TYPE,
        desadd01   cliente_articulos_clase.descri%TYPE,
        desadd02   cliente_articulos_clase.descri%TYPE,
        chasis     documentos_det.chasis%TYPE,
        motor      documentos_det.motor%TYPE
    );
    TYPE tbl_help_kardex001 IS
        TABLE OF rec_help_kardex001;
    TYPE datarecord_resumen_tipinv IS RECORD (
        codart    articulos.codart%TYPE,
        desart    articulos.descri%TYPE,
        tipinv    articulos.tipinv%TYPE,
        destipinv t_inventario.dtipinv%TYPE,
        codprv    articulos.codprv%TYPE,
        stock     NUMBER,
        ingreso   NUMBER,
        salida    NUMBER,
        coduni    articulos.coduni%TYPE
    );
    TYPE datatable_resumen_tipinv IS
        TABLE OF datarecord_resumen_tipinv;
    TYPE datarecord_resumen_ancho IS RECORD (
        codart    articulos.codart%TYPE,
        desart    articulos.descri%TYPE,
        tipinv    articulos.tipinv%TYPE,
        destipinv t_inventario.dtipinv%TYPE,
        codprv    articulos.codprv%TYPE,
        ancho     kardex001.ancho%TYPE,
        stock     NUMBER,
        ingreso   NUMBER,
        salida    NUMBER,
        coduni    articulos.coduni%TYPE
    );
    TYPE datatable_resumen_ancho IS
        TABLE OF datarecord_resumen_ancho;
    TYPE datarecord_movimientos_etiqueta IS RECORD (
        tipdoc    documentos_cab.tipdoc%TYPE,
        numint    documentos_cab.numint%TYPE,
        numite    kardex001.numite%TYPE,
        codmot    documentos_cab.codmot%TYPE,
        femisi    documentos_cab.femisi%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        series    documentos_cab.series%TYPE,
        codcli    documentos_cab.codcli%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        tipinv    kardex.tipinv%TYPE,
        codart    kardex.codart%TYPE,
        desart    articulos.descri%TYPE,
        cantid    kardex.cantid%TYPE,
        codalm    kardex.codalm%TYPE,
        id        kardex.id%TYPE,
        abringsal VARCHAR2(10),
        ingresos  NUMBER,
        salidas   NUMBER,
        preuni    documentos_det.preuni%TYPE,
        importe   documentos_det.importe%TYPE,
        tipmon    documentos_cab.tipmon%TYPE,
        codven    documentos_cab.codven%TYPE,
        desven    vendedor.desven%TYPE,
        simbolo   tmoneda.simbolo%TYPE,
        desalm    almacen.descri%TYPE,
        abralm    almacen.abrevi%TYPE,
        ordcom    documentos_cab.ordcom%TYPE,
        desdoc    documentos_tipo.descri%TYPE,
        abrdoc    documentos_tipo.abrevi%TYPE,
        dessit    situacion.dessit%TYPE,
        desmot    tmoneda.desmon%TYPE,
        codubi    almacen_ubicacion.codigo%TYPE,
        desubi    almacen_ubicacion.descri%TYPE
    );
    TYPE datatable_movimientos_etiqueta IS
        TABLE OF datarecord_movimientos_etiqueta;

    -- SP MODIFICADO
    FUNCTION sp_buscar_eqtiquetas (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_chasis     VARCHAR2, -- CAMPO ADICIONADO
        pin_motor      VARCHAR2, -- CAMPO ADICIONADO
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN tbl_kardex001
        PIPELINED;

    -- SP MODIFICADO
    FUNCTION sp_exportar_etiquetas (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_chasis     VARCHAR2,
        pin_motor      VARCHAR2,
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN tbl_kardex001
        PIPELINED;

    -- SP NO MODIFICADO
    FUNCTION sp_buscar_etiquetas_resumen (
        pin_id_cia     IN NUMBER,
        pin_tipstock   IN NUMBER,
        pin_codprov    IN VARCHAR2,
        pin_etiqueta   IN VARCHAR2,
        pin_tipinv     IN NUMBER,
        pin_codart     IN VARCHAR2,
        pin_calidad    IN VARCHAR2,
        pin_color      IN VARCHAR2,
        pin_codalm     IN NUMBER,
        pin_ubica      IN VARCHAR2,
        pin_lote       IN VARCHAR2,
        pin_ancho      IN NUMBER,
        pin_largo      IN NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_fdesde     IN DATE,
        pin_fhasta     IN DATE
    ) RETURN datatable_etiquetas_resumen
        PIPELINED;

    FUNCTION sp_help_eqtiquetas (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN tbl_help_kardex001
        PIPELINED;

    FUNCTION sp_help_etiquetasv2 (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_codalm     NUMBER,
        pin_etiqueta   VARCHAR2,
        pin_lote       VARCHAR2,
        pin_ancho      NUMBER,
        pin_nrocarrete VARCHAR2,
        pin_acabado    VARCHAR2,
        pin_chasis     VARCHAR2,
        pin_motor      VARCHAR2
    ) RETURN tbl_help_kardex001
        PIPELINED;

    FUNCTION sp_help_etiquetas_incluye_saldo_cero (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN tbl_help_kardex001
        PIPELINED;

    FUNCTION sp_obtener_etiquetas (
        pin_id_cia     IN NUMBER,
        pin_codalm     IN NUMBER,
        pin_etiqueta   VARCHAR2,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_obtener_etiqueta
        PIPELINED;

    FUNCTION sp_resumen_tipinv (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_desart     VARCHAR2,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_resumen_tipinv
        PIPELINED;

    FUNCTION sp_resumen_ancho (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_ancho      NUMBER,
        pin_checksaldo VARCHAR2
    ) RETURN datatable_resumen_ancho
        PIPELINED;

    FUNCTION sp_movimientos_etiqueta (
        pin_id_cia   NUMBER,
        pin_etiqueta VARCHAR2
    ) RETURN datatable_movimientos_etiqueta
        PIPELINED;

END pack_kardex001;

/
