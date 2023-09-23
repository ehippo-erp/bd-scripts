--------------------------------------------------------
--  DDL for Package PACK_CLASE_DOCUMENTOS_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_TIPO" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clase_documentos_tipo.id_cia%TYPE,
        clase    clase_documentos_tipo.clase%TYPE,
        desclase clase_documentos_tipo.descri%TYPE,
        vreal    clase_documentos_tipo.vreal%TYPE,
        vstrg    clase_documentos_tipo.vstrg%TYPE,
        vchar    clase_documentos_tipo.vchar%TYPE,
        vdate    clase_documentos_tipo.vdate%TYPE,
        vtime    clase_documentos_tipo.vtime%TYPE,
        ventero  clase_documentos_tipo.ventero%TYPE,
        swacti   clase_documentos_tipo.swacti%TYPE,
        swcodigo clase_documentos_tipo.swcodigo%TYPE,
        ucreac   clase_documentos_tipo.ucreac%TYPE,
        uactua   clase_documentos_tipo.uactua%TYPE,
        fcreac   clase_documentos_tipo.fcreac%TYPE,
        factua   clase_documentos_tipo.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clase_documentos_tipo_codigo.id_cia%TYPE,
        clase     clase_documentos_tipo_codigo.clase%TYPE,
        desclase  clase_documentos_tipo.descri%TYPE,
        codigo    clase_documentos_tipo_codigo.codigo%TYPE,
        descodigo clase_documentos_tipo_codigo.descri%TYPE,
        abrevi    clase_documentos_tipo_codigo.abrevi%TYPE,
        swacti    clase_documentos_tipo_codigo.swacti%TYPE,
        ucreac    clase_documentos_tipo_codigo.ucreac%TYPE,
        uactua    clase_documentos_tipo_codigo.uactua%TYPE,
        fcreac    clase_documentos_tipo_codigo.fcreac%TYPE,
        factua    clase_documentos_tipo_codigo.factua%TYPE
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;
    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED;

    FUNCTION sp_buscar_clase (
        pin_id_cia   NUMBER,
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
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
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
