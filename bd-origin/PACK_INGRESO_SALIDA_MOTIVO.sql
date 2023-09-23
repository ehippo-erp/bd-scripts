--------------------------------------------------------
--  DDL for Package PACK_INGRESO_SALIDA_MOTIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_INGRESO_SALIDA_MOTIVO" AS
    TYPE datarecord_tipo_documento IS RECORD (
        series     documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        numint     documentos_cab.numint%TYPE,
        numite     kardex.numite%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        dtipdoc documentos_tipo.descri%TYPE,
        femisi     kardex.femisi%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     kardex.codart%TYPE,
        desart     articulos.descri%TYPE,
        codfam     articulos.codfam%TYPE,
        desfam     VARCHAR(500),
        codlin     articulos.codlin%TYPE,
        deslin     VARCHAR(500),
        desalm     almacen.descri%TYPE,
        codmot      kardex.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        cantid     kardex.cantid%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        etiqueta kardex001.etiqueta%TYPE,
        ancho kardex001.ancho%TYPE,
        fvenci   documentos_det.fvenci%TYPE,
        desmarca   cliente_articulos_clase.descri%TYPE
    );
    TYPE datatable_tipo_documento IS
        TABLE OF datarecord_tipo_documento;
    TYPE datarecord_resumen IS RECORD (
        ocultokardex VARCHAR2(25),
        id           VARCHAR2(1),
        codmot       SMALLINT,
        desmot       VARCHAR2(50),
        desdoc       VARCHAR2(40),
        desdocmot    VARCHAR2(120),
        totcan       NUMERIC(16, 4),
        totsol       NUMERIC(16, 2),
        totdol       NUMERIC(16, 2)
    );
    TYPE datatable_resumen IS
        TABLE OF datarecord_resumen;
    TYPE datarecord_documento IS RECORD (
        series     documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        numint     documentos_cab.numint%TYPE,
        numite     kardex.numite%TYPE,
        femisi     kardex.femisi%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     kardex.codart%TYPE,
        desart     articulos.descri%TYPE,
        codfam     articulos.codfam%TYPE,
        desfam     VARCHAR(500),
        codlin     articulos.codlin%TYPE,
        deslin     VARCHAR(500),
        desalm     almacen.descri%TYPE,
        codmot      kardex.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        cantid     kardex.cantid%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        ctdocum    compr010.tdocum%TYPE,
        cserie     compr010.nserie%TYPE,
        cnumero    compr010.numero%TYPE,
        cfemisi    compr010.femisi%TYPE,
        cabrevi    tdocume.abrevi%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        etiqueta kardex001.etiqueta%TYPE,
        ancho kardex001.ancho%TYPE,
        fvenci   documentos_det.fvenci%TYPE,
        desmarca   cliente_articulos_clase.descri%TYPE
    );
    TYPE datatable_documento IS
        TABLE OF datarecord_documento;
    TYPE datarecord_familialinea IS RECORD (
        series     documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        numint     documentos_cab.numint%TYPE,
        numite     kardex.numite%TYPE,
        femisi     kardex.femisi%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     kardex.codart%TYPE,
        desart     articulos.descri%TYPE,
        codfam     articulos.codfam%TYPE,
        desfam     VARCHAR(500),
        codlin     articulos.codlin%TYPE,
        deslin     VARCHAR(500),
        desalm     almacen.descri%TYPE,
        codmot      documentos_cab.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        cantid     kardex.cantid%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        ctdocum    compr010.tdocum%TYPE,
        cserie     compr010.nserie%TYPE,
        cnumero    compr010.numero%TYPE,
        cfemisi    compr010.femisi%TYPE,
        cabrevi    tdocume.abrevi%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        etiqueta kardex001.etiqueta%TYPE,
        ancho kardex001.ancho%TYPE,
        fvenci   documentos_det.fvenci%TYPE,
        desmarca   cliente_articulos_clase.descri%TYPE
    );
    TYPE datatable_familialinea IS
        TABLE OF datarecord_familialinea;

    TYPE datarecord_almacen IS RECORD (
        series documentos_cab.series%TYPE,
        numdoc documentos_cab.numdoc%TYPE,
        numint documentos_cab.numint%TYPE,
        numite documentos_det.numite%TYPE,
        femisi kardex.femisi%TYPE,
        razonc documentos_cab.razonc%TYPE,
        tipinv kardex.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codart kardex.codart%TYPE,
        codalm kardex.codalm%TYPE,
        desart     articulos.descri%TYPE,
        codfam     articulos.codfam%TYPE,
        desfam     VARCHAR(500),
        codlin     articulos.codlin%TYPE,
        deslin     VARCHAR(500),
        desalm     almacen.descri%TYPE,
        codmot      kardex.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        cantid     kardex.cantid%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        etiqueta kardex001.etiqueta%TYPE,
        ancho kardex001.ancho%TYPE,
        fvenci   documentos_det.fvenci%TYPE,
        desmarca   cliente_articulos_clase.descri%TYPE
    );
    TYPE datatable_almacen IS
        TABLE OF datarecord_almacen;

    TYPE datarecord_articulo IS RECORD (
        tipinv     kardex.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     articulos.codart%TYPE,
        desart     articulos.descri%TYPE,
        codfam     articulos.codfam%TYPE,
        desfam     VARCHAR(500),
        codlin     articulos.codlin%TYPE,
        deslin     VARCHAR(500),
        desalm     almacen.descri%TYPE,
        codmot      kardex.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        cantid     kardex.cantid%TYPE,
        costot01   kardex.costot01%TYPE,
        costot02   kardex.costot02%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        etiqueta kardex001.etiqueta%TYPE,
        ancho kardex001.ancho%TYPE,
        fvenci   documentos_det.fvenci%TYPE,
        desmarca   cliente_articulos_clase.descri%TYPE
    );
    TYPE datatable_articulo IS
        TABLE OF datarecord_articulo;
    TYPE datarecord_articulo_resumen IS RECORD (
        tipinv   kardex.tipinv%TYPE,
        dtipinv  t_inventario.dtipinv%TYPE,
        codart   articulos.codart%TYPE,
        desart   articulos.descri%TYPE,
        codfam   articulos.codfam%TYPE,
        desfam   VARCHAR(500),
        codlin   articulos.codlin%TYPE,
        deslin   VARCHAR(500),
        desalm   almacen.descri%TYPE,
        codmot      kardex.codmot%TYPE,
        desmot   motivos.desmot%TYPE,
        cantid   kardex.cantid%TYPE,
        costot01 kardex.costot01%TYPE,
        costot02 kardex.costot02%TYPE
    );
    TYPE datatable_articulo_resumen IS
        TABLE OF datarecord_articulo_resumen;
    FUNCTION sp_buscar_tipo_documento (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_tipo_documento
        PIPELINED;
    -- BUSCA POR RANGO DE PERIODO 202205 AL 202205
    FUNCTION sp_buscar_resumen (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_codalm NUMBER,
        pin_tipinv NUMBER
    ) RETURN datatable_resumen
        PIPELINED;

    FUNCTION sp_buscar_articulo (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_articulo
        PIPELINED;

    FUNCTION sp_buscar_articulo_resumen (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_articulo_resumen
        PIPELINED;

    FUNCTION sp_buscar_documento (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_documento
        PIPELINED;

    FUNCTION sp_buscar_familialinea (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_familialinea
        PIPELINED;

    FUNCTION sp_buscar_almacen(
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER,
        pin_tipdoc NUMBER,
        pin_codmot NUMBER,
        pin_codalm NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_almacen
        PIPELINED;

END;

/
