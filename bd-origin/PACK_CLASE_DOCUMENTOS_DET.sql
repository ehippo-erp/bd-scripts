--------------------------------------------------------
--  DDL for Package PACK_CLASE_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_DET" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clase_documentos_det.id_cia%TYPE,
        tipdoc   clase_documentos_det.tipdoc%TYPE,
        dtipdoc  documentos_tipo.descri%TYPE,
        clase    clase_documentos_det.clase%TYPE,
        desclase clase_documentos_det.descri%TYPE,
        vreal    clase_documentos_det.vreal%TYPE,
        vstrg    clase_documentos_det.vstrg%TYPE,
        vchar    clase_documentos_det.vchar%TYPE,
        vdate    clase_documentos_det.vdate%TYPE,
        vtime    clase_documentos_det.vtime%TYPE,
        ventero  clase_documentos_det.ventero%TYPE,
        swacti   clase_documentos_det.swacti%TYPE,
        obliga   clase_documentos_det.obliga%TYPE,
        swcodigo clase_documentos_det.swcodigo%TYPE,
        ucreac   clase_documentos_det.codusercrea%TYPE,
        uactua   clase_documentos_det.coduseractu%TYPE,
        fcreac   clase_documentos_det.fcreac%TYPE,
        factua   clase_documentos_det.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clase_documentos_det_codigo.id_cia%TYPE,
        tipdoc    clase_documentos_det_codigo.tipdoc%TYPE,
        dtipdoc   documentos_tipo.descri%TYPE,
        clase     clase_documentos_det_codigo.clase%TYPE,
        desclase  clase_documentos_det.descri%TYPE,
        codigo    clase_documentos_det_codigo.codigo%TYPE,
        descodigo clase_documentos_det_codigo.descri%TYPE,
        abrevi    clase_documentos_det_codigo.abrevi%TYPE,
        swacti    clase_documentos_det_codigo.swacti%TYPE,
        swdefault clase_documentos_det_codigo.swdefaul%TYPE,
        ucreac    clase_documentos_det_codigo.codusercrea%TYPE,
        uactua    clase_documentos_det_codigo.coduseractu%TYPE,
        fcreac    clase_documentos_det_codigo.fcreac%TYPE,
        factua    clase_documentos_det_codigo.factua%TYPE
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;
    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED;

    FUNCTION sp_buscar_clase (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase
        PIPELINED;

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener_clase_codigo (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
        pin_tipdoc    NUMBER,
        pin_clase     NUMBER,
        pin_descodigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED;

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
