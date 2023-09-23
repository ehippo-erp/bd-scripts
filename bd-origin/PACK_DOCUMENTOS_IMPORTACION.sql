--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_IMPORTACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_IMPORTACION" AS
    TYPE datarecord_obtener IS RECORD (
        id_cia   documentos_cab.id_cia%TYPE,
        numint   documentos_cab.numint%TYPE,
        tipdoc   documentos_cab.tipdoc%TYPE,
        series   documentos_cab.series%TYPE,
        numdoc   documentos_cab.numdoc%TYPE,
        femisi   documentos_cab.femisi%TYPE,
        razonc   documentos_cab.razonc%TYPE,
        direc1   documentos_cab.direc1%TYPE,
        ruc      documentos_cab.ruc%TYPE,
        obscab   documentos_cab.observ%TYPE,
        tipcam   documentos_cab.tipcam%TYPE,
        ordcom   documentos_cab.ordcom%TYPE,
        fordcom  documentos_cab.fordcom%TYPE,
        facpro   documentos_cab.facpro%TYPE,
        ffacpro  documentos_cab.ffacpro%TYPE,
        numped   documentos_cab.numped%TYPE,
        id       documentos_cab.id%TYPE,
        porigv   documentos_cab.porigv%TYPE,
        codmon   tmoneda.codmon%TYPE,
        simbolo  tmoneda.simbolo%TYPE,
        desmon   tmoneda.desmon%TYPE,
        dircli1  cliente.direc1%TYPE,
        aliassit situacion.alias%TYPE,
        codmot   documentos_cab.codmot%TYPE,
        desmot   motivos.desmot%TYPE,
        opnumdoc documentos_cab.opnumdoc%TYPE,
        numite   documentos_det.numite%TYPE,
        tipinv   documentos_det.tipinv%TYPE,
        dtipinv  t_inventario.dtipinv%TYPE,
        codart   documentos_det.codart%TYPE,
        desart   VARCHAR2(200),
        cantid   documentos_det.cantid%TYPE,
        canref   documentos_det.canref%TYPE,
        ancho    documentos_det.ancho%TYPE,
        tara     documentos_det.tara%TYPE,
        codund   documentos_det.codund%TYPE,
        preuni   documentos_det.preuni%TYPE,
        importe  documentos_det.importe%TYPE,
        obsdet   documentos_det.observ%TYPE,
        codcalid documentos_det.codadd01%TYPE,
        codcolor documentos_det.codadd02%TYPE,
        dcalidad VARCHAR2(500),
        dcolor   VARCHAR2(500),
        canitem  NUMBER(12, 2),
        abrund   unidad.abrevi%TYPE
    );
    TYPE datatable_obtener IS
        TABLE OF datarecord_obtener;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_obtener
        PIPELINED;

    PROCEDURE sp_valida (
        pin_id_cia   IN NUMBER,
        pin_opnumdoc IN NUMBER,
        pin_opnumite IN NUMBER,
        pin_tipinv   IN NUMBER,
        pin_codart   IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

END;

/
