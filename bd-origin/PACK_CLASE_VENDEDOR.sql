--------------------------------------------------------
--  DDL for Package PACK_CLASE_VENDEDOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_VENDEDOR" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clase_vendedor.id_cia%TYPE,
        clase    clase_vendedor.clase%TYPE,
        desclase clase_vendedor.descri%TYPE,
        vreal    clase_vendedor.vreal%TYPE,
        vstrg    clase_vendedor.vstrg%TYPE,
        vchar    clase_vendedor.vchar%TYPE,
        vdate    clase_vendedor.vdate%TYPE,
        vtime    clase_vendedor.vtime%TYPE,
        ventero  clase_vendedor.ventero%TYPE,
        swacti   clase_vendedor.swacti%TYPE,
        ucreac   clase_vendedor.codusercrea%TYPE,
        uactua   clase_vendedor.coduseractu%TYPE,
        fcreac   clase_vendedor.fcreac%TYPE,
        factua   clase_vendedor.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clase_vendedor_codigo.id_cia%TYPE,
        clase     clase_vendedor_codigo.clase%TYPE,
        desclase  clase_vendedor.descri%TYPE,
        codigo    clase_vendedor_codigo.codigo%TYPE,
        descodigo clase_vendedor_codigo.descri%TYPE,
        abrevi    clase_vendedor_codigo.abrevi%TYPE,
        swacti    clase_vendedor_codigo.swacti%TYPE,
        ucreac    clase_vendedor_codigo.codusercrea%TYPE,
        uactua    clase_vendedor_codigo.coduseractu%TYPE,
        fcreac    clase_vendedor_codigo.fcreac%TYPE,
        factua    clase_vendedor_codigo.factua%TYPE
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
