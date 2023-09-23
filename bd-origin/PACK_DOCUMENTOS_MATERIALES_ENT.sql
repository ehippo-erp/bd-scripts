--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_MATERIALES_ENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_MATERIALES_ENT" AS
    TYPE datarecord_saldo_documentos_det IS RECORD (
        id_cia    documentos_cab.id_cia%TYPE,
        opnumint  documentos_det.opnumdoc%TYPE,
        opnumite  documentos_det.opnumite%TYPE,
        opseries  documentos_cab.series%TYPE,
        opnumero  documentos_cab.numdoc%TYPE,
        optipinv  documentos_det.tipinv%TYPE,
        opcodart  documentos_det.codart%TYPE,
        poclase1  documentos_det_clase.codigo%TYPE,
        opdesart  articulos.descri%TYPE,
        opcantid  documentos_det.cantid%TYPE,
        oprazonc  documentos_cab.razonc%TYPE,
        opfemisi  documentos_cab.femisi%TYPE,
        numint    documentos_cab.numint%TYPE,
        tipdoc    documentos_cab.tipdoc%TYPE,
        series    documentos_cab.series%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        situac    documentos_cab.situac%TYPE,
        numite    documentos_det.numite%TYPE,
        tipinv    documentos_det.tipinv%TYPE,
        codart    documentos_det.codart%TYPE,
        desart    articulos.descri%TYPE,
        codalm    documentos_det.codalm%TYPE,
        codund    documentos_det.codund%TYPE,
        cantid    documentos_det.cantid%TYPE,
        canped    documentos_det.canped%TYPE,
        pordes1   documentos_det.pordes1%TYPE,
        pordes2   documentos_det.pordes2%TYPE,
        pordes3   documentos_det.pordes3%TYPE,
        pordes4   documentos_det.pordes4%TYPE,
        preuni    documentos_det.preuni%TYPE,
        obsdet    documentos_det.observ%TYPE,
        fcreac    documentos_det.fcreac%TYPE,
        factua    documentos_det.factua%TYPE,
        usuari    documentos_det.usuari%TYPE,
        largo     documentos_det.largo%TYPE,
        piezas    documentos_det.piezas%TYPE,
        ancho     documentos_det.ancho%TYPE,
        altura    documentos_det.altura%TYPE,
        numsec    documentos_materiales.numsec%TYPE,
        opnumsec  documentos_materiales.numsec%TYPE,
        numintpre documentos_det.numintpre%TYPE,
        numitepre documentos_det.numitepre%TYPE,
        stock     NUMERIC(16, 5),
        fstock    DATE
    );
    TYPE datatable_saldo_documentos_det IS
        TABLE OF datarecord_saldo_documentos_det;
    TYPE datarecord_entrega IS RECORD (
        id_cia documentos_materiales.id_cia%TYPE,
        numint documentos_materiales.numint%TYPE,
        numite documentos_materiales.numite%TYPE,
        numsec documentos_materiales.numsec%TYPE,
        entreg documentos_materiales.cantid%TYPE
    );
    TYPE datatable_entrega IS
        TABLE OF datarecord_entrega;
    FUNCTION sp_detalle_entrega (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER,
        pin_numsec NUMBER
    ) RETURN datatable_entrega
        PIPELINED;

    FUNCTION sp_saldo_documentos_det (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_saldo_documentos_det
        PIPELINED;

END;

/
