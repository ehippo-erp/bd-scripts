--------------------------------------------------------
--  DDL for Package PACK_ANTICIPOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ANTICIPOS" AS
    TYPE datarecord_reporte_anticipo IS RECORD (
        id_cia    documentos_cab.id_cia%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        desdoc    documentos_tipo.descri%TYPE,
        numint    documentos_cab.numint%TYPE,
        serie     documentos_cab.series%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        femisi    documentos_cab.femisi%TYPE,
        codcli    documentos_cab.codcli%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        ruc       cliente.dident%TYPE,
        direccion documentos_cab.direc1%TYPE,
        codven    documentos_cab.codven%TYPE,
        incigv    documentos_cab.incigv%TYPE,
        destin    documentos_cab.destin%TYPE,
        totbru    documentos_cab.totbru%TYPE,
        descue    documentos_cab.descue%TYPE,
        desesp    documentos_cab.desesp%TYPE,
        monafe    documentos_cab.monafe%TYPE,
        monina    documentos_cab.monina%TYPE,
        porigv    documentos_cab.porigv%TYPE,
        monigv    documentos_cab.monigv%TYPE,
        costo     documentos_cab.costo%TYPE,
        tipmon    documentos_cab.tipmon%TYPE,
        simbolo   tmoneda.simbolo%TYPE,
        tipcam    documentos_cab.tipcam%TYPE,
        seguro    documentos_cab.seguro%TYPE,
        flete     documentos_cab.flete%TYPE,
        desexp    documentos_cab.desexp%TYPE,
        gasadu    documentos_cab.gasadu%TYPE,
        pesbru    documentos_cab.pesbru%TYPE,
        pesnet    documentos_cab.pesnet%TYPE,
        bultos    documentos_cab.bultos%TYPE,
        valfob    documentos_cab.valfob%TYPE,
        ffacpro   documentos_cab.ffacpro%TYPE,
        cargo     documentos_cab.cargo%TYPE,
        codsuc    documentos_cab.codsuc%TYPE,
        desseg    documentos_cab.desseg%TYPE,
        desgasa   documentos_cab.desgasa%TYPE,
        desnext   documentos_cab.desnetx%TYPE,
        despreven documentos_cab.despreven%TYPE,
        codcod    documentos_cab.codcob%TYPE,
        preven    dcta106.importe%TYPE,
        facturado dcta106.importe%TYPE,
        saldo     dcta106.importe%TYPE,
        numintap  documentos_cab.numint%TYPE,
        femisiap  documentos_cab.femisi%TYPE,
        tipdocap  documentos_cab.tipdoc%TYPE,
        serieap   documentos_cab.series%TYPE,
        numdocap  documentos_cab.numdoc%TYPE,
        importeap dcta106.importe%TYPE
    );
    TYPE datatable_reporte_anticipo IS
        TABLE OF datarecord_reporte_anticipo;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_situac NUMBER,
        pin_detapl NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_anticipo
        PIPELINED;

END;

/
