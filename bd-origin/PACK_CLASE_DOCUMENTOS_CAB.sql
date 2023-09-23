--------------------------------------------------------
--  DDL for Package PACK_CLASE_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_CAB" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clase_documentos_cab.id_cia%TYPE,
        tipdoc   clase_documentos_cab.tipdoc%TYPE,
        dtipdoc  documentos_tipo.descri%TYPE,
        clase    clase_documentos_cab.clase%TYPE,
        desclase clase_documentos_cab.descri%TYPE,
        vreal    clase_documentos_cab.vreal%TYPE,
        vstrg    clase_documentos_cab.vstrg%TYPE,
        vchar    clase_documentos_cab.vchar%TYPE,
        vdate    clase_documentos_cab.vdate%TYPE,
        vtime    clase_documentos_cab.vtime%TYPE,
        ventero  clase_documentos_cab.ventero%TYPE,
        vblob    clase_documentos_cab.vblob%TYPE,
        swacti   clase_documentos_cab.swacti%TYPE,
        obliga   clase_documentos_cab.obliga%TYPE,
        editable clase_documentos_cab.editable%TYPE,
        swcodigo clase_documentos_cab.swcodigo%TYPE,
        ucreac   clase_documentos_cab.codusercrea%TYPE,
        uactua   clase_documentos_cab.coduseractu%TYPE,
        fcreac   clase_documentos_cab.fcreac%TYPE,
        factua   clase_documentos_cab.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_cabecera IS RECORD (
        id_cia      clase_documentos_cab.id_cia%TYPE,
        clase       clase_documentos_cab.clase%TYPE,
        desclase    clase_documentos_cab.descri%TYPE,
        vreal       VARCHAR2(100),
        vstrg       VARCHAR2(100),
        vchar       VARCHAR2(100),
        vdate       VARCHAR2(100),
        vtime       VARCHAR2(100),
        ventero     VARCHAR2(100),
        vglosa      VARCHAR2(100),
        obligatorio VARCHAR2(100),
        codigo      clase_documentos_cab_codigo.codigo%TYPE,
        descodigo   clase_documentos_cab_codigo.descri%TYPE
    );
    TYPE datatable_clase_cabecera IS
        TABLE OF datarecord_clase_cabecera;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clase_documentos_cab_codigo.id_cia%TYPE,
        tipdoc    clase_documentos_cab_codigo.tipdoc%TYPE,
        dtipdoc   documentos_tipo.descri%TYPE,
        clase     clase_documentos_cab_codigo.clase%TYPE,
        desclase  clase_documentos_cab.descri%TYPE,
        codigo    clase_documentos_cab_codigo.codigo%TYPE,
        descodigo clase_documentos_cab_codigo.descri%TYPE,
        abrevi    clase_documentos_cab_codigo.abrevi%TYPE,
        swacti    clase_documentos_cab_codigo.swacti%TYPE,
        ucreac    clase_documentos_cab_codigo.codusercrea%TYPE,
        uactua    clase_documentos_cab_codigo.coduseractu%TYPE,
        fcreac    clase_documentos_cab_codigo.fcreac%TYPE,
        factua    clase_documentos_cab_codigo.factua%TYPE
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;

    PROCEDURE sp_valida_clases_obligatoria (
        pin_id_cia  NUMBER,
        pin_tipdoc  NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_buscar_clase_cabecera (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_obliga VARCHAR2
    ) RETURN datatable_clase_cabecera
        PIPELINED;

    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED;

    FUNCTION sp_buscar_clase (
        pin_id_cia   NUMBER,
        pin_tipdoc NUMBER,
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
        pin_tipdoc NUMBER,
        pin_clase NUMBER,
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
