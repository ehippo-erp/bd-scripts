--------------------------------------------------------
--  DDL for Package PACK_ACTUALIZA_COSTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ACTUALIZA_COSTO" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia        documentos_cab.id_cia%TYPE,
        tipdoc        documentos_cab.tipdoc%TYPE,
        numint        documentos_cab.numint%TYPE,
        numite        documentos_det.numite%TYPE,
        series        documentos_cab.series%TYPE,
        numdoc        documentos_cab.numdoc%TYPE,
        codcli        documentos_cab.codcli%TYPE,
        femisi        documentos_cab.femisi%TYPE,
        id            documentos_cab.id%TYPE,
        situac        documentos_cab.situac%TYPE,
        presen        documentos_cab.presen%TYPE,
        observ        documentos_cab.observ%TYPE,
        tipmon        documentos_cab.tipmon%TYPE,
        tipcam        documentos_cab.tipcam%TYPE,
        codmot        documentos_cab.codmot%TYPE,
        incigv        documentos_cab.incigv%TYPE,
        guipro        documentos_cab.guipro%TYPE,
        facpro        documentos_cab.facpro%TYPE,
        fguipro       documentos_cab.fguipro%TYPE,
        ffacpro       documentos_cab.ffacpro%TYPE,
        tipinv        documentos_det.tipinv%TYPE,
        codalm        documentos_det.codalm%TYPE,
        codart        documentos_det.codart%TYPE,
        desart        articulos.descri%TYPE,
        cantid        documentos_det.cantid%TYPE,
        peso          articulos.faccon%TYPE,
        coduni        articulos.coduni%TYPE,
        preuni        documentos_det.preuni%TYPE,
        pordes1       documentos_det.pordes1%TYPE,
        pordes2       documentos_det.pordes2%TYPE,
        pordes3       documentos_det.pordes3%TYPE,
        pordes4       documentos_det.pordes4%TYPE,
        codadd01      documentos_det.codadd01%TYPE,
        codadd02      documentos_det.codadd02%TYPE,
        dcodadd01     cliente_articulos_clase.descri%TYPE,
        dcodadd02     cliente_articulos_clase.descri%TYPE,
        opronumdoc    documentos_det.opronumdoc%TYPE,
        opnumite      documentos_det.opnumite%TYPE,
        etiqueta      documentos_det.etiqueta%TYPE,
        importe_bruto documentos_det.importe_bruto%TYPE,
        importe       documentos_det.importe%TYPE,
        porigv        documentos_det.porigv%TYPE,
        monigv        documentos_det.monigv%TYPE,
        monina        documentos_det.monina%TYPE,
        monisc        documentos_det.monisc%TYPE,
        monexo        documentos_det.monexo%TYPE,
        montgr        documentos_det.monotr%TYPE,
        monafe        documentos_det.monafe%TYPE,
        locali        kardex.locali%TYPE,
        knumint       kardex.numint%TYPE,
        knumite       kardex.numite%TYPE,
        costot01      kardex.costot01%TYPE,
        costot02      kardex.costot02%TYPE,
        liquidado     VARCHAR2(200)
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_update(
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER,
        pin_datos IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
