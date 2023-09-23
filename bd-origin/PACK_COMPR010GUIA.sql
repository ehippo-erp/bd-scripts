--------------------------------------------------------
--  DDL for Package PACK_COMPR010GUIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_COMPR010GUIA" AS
    TYPE datarecord_compr010guia IS RECORD (
        id_cia compr010guia.id_cia%TYPE,
        tipo   compr010guia.tipo%TYPE,
        docume compr010guia.docume%TYPE,
        numint compr010guia.numint%TYPE,
        tipdoc compr010guia.tipdoc%TYPE,
        series compr010guia.series%TYPE,
        numdoc compr010guia.numdoc%TYPE,
        ucreac compr010guia.usuari%TYPE,
        uactua compr010guia.usuari%TYPE,
        fcreac compr010guia.fcreac%TYPE,
        factua compr010guia.factua%TYPE
    );
    TYPE datatable_compr010guia IS
        TABLE OF datarecord_compr010guia;
    TYPE datarecord_documentos_no_asignados IS RECORD (
        id_cia   documentos_cab.id_cia%TYPE,
        tipdoc   documentos_cab.tipdoc%TYPE,
        desdoc   documentos_tipo.descri%TYPE,
        series   documentos_cab.series%TYPE,
        numdoc   documentos_cab.numdoc%TYPE,
        numint   documentos_cab.numint%TYPE,
        femisi   documentos_cab.femisi%TYPE,
        codcli   documentos_cab.codcli%TYPE,
        razonc   documentos_cab.razonc%TYPE,
        ruc      documentos_cab.ruc%TYPE,
        situac   documentos_cab.situac%TYPE,
        id       documentos_cab.id%TYPE,
        opnumdoc documentos_cab.opnumdoc%TYPE,
        observ   documentos_cab.observ%TYPE,
        dessit   situacion.dessit%TYPE,
        desmot   motivos.desmot%TYPE,
        codalm   documentos_cab.codalm%TYPE,
        desalm   almacen.descri%TYPE,
        optipinv documentos_cab.optipinv%TYPE,
        dtipinv  t_inventario.dtipinv%TYPE,
        tipmon   documentos_cab.tipmon%TYPE,
        tipcam   documentos_cab.tipcam%TYPE,
        porigv   documentos_cab.porigv%TYPE,
        preven   documentos_cab.preven%TYPE,
        facpro   documentos_cab.facpro%TYPE,
        ffacpro  documentos_cab.ffacpro%TYPE,
        guipro   documentos_cab.guipro%TYPE,
        fguipro  documentos_cab.fguipro%TYPE,
        dircli1  cliente.direc1%TYPE,
        dircli2  cliente.direc2%TYPE,
        numintre documentos_relacion.numintre%TYPE,
        seriesre documentos_cab.series%TYPE,
        numdocre documentos_cab.numdoc%TYPE,
        documre  VARCHAR2(100 CHAR),
        desmon   tmoneda.desmon%TYPE,
        simbolo  tmoneda.simbolo%TYPE,
        numped   documentos_cab.numped%TYPE
    );
    TYPE datatable_documentos_no_asignados IS
        TABLE OF datarecord_documentos_no_asignados;
    FUNCTION sp_buscar_documentos_no_asignados (
        pin_id_cia IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_series IN VARCHAR2,
        pin_numdoc IN NUMBER
    ) RETURN datatable_documentos_no_asignados
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_compr010guia
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER,
        pin_numint NUMBER,
        pin_tipdoc NUMBER,
        pin_series VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_compr010guia
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
