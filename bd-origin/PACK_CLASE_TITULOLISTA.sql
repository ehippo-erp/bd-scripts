--------------------------------------------------------
--  DDL for Package PACK_CLASE_TITULOLISTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_TITULOLISTA" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clases_titulolista.id_cia%TYPE,
        clase    clases_titulolista.clase%TYPE,
        desclase clases_titulolista.descri%TYPE,
        vreal    clases_titulolista.vreal%TYPE,
        vstrg    clases_titulolista.vstrg%TYPE,
        vchar    clases_titulolista.vchar%TYPE,
        vdate    clases_titulolista.vdate%TYPE,
        vtime    clases_titulolista.vtime%TYPE,
        ventero  clases_titulolista.ventero%TYPE,
        swacti   clases_titulolista.swacti%TYPE,
        ucreac   clases_titulolista.codusercrea%TYPE,
        uactua   clases_titulolista.coduseractu%TYPE,
        fcreac   clases_titulolista.fcreac%TYPE,
        factua   clases_titulolista.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clases_titulolista_codigo.id_cia%TYPE,
        codtit    clases_titulolista_codigo.codtit%TYPE,
        destit    titulolista.titulo%TYPE,
        clase     clases_titulolista_codigo.clase%TYPE,
        desclase  clases_titulolista.descri%TYPE,
        codigo    clases_titulolista_codigo.codigo%TYPE,
        descodigo clases_titulolista_codigo.descri%TYPE,
        abrevi    clases_titulolista_codigo.abrevi%TYPE,
        swacti    clases_titulolista_codigo.swacti%TYPE,
        ucreac    clases_titulolista_codigo.codusercrea%TYPE,
        uactua    clases_titulolista_codigo.coduseractu%TYPE,
        fcreac    clases_titulolista_codigo.fcreac%TYPE,
        factua    clases_titulolista_codigo.factua%TYPE
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
        pin_codtit NUMBER,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
        pin_codtit NUMBER,
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
