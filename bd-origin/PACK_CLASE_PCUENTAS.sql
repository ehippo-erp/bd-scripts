--------------------------------------------------------
--  DDL for Package PACK_CLASE_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_PCUENTAS" AS
    TYPE datarecord_clase IS RECORD (
        id_cia   clase_pcuentas.id_cia%TYPE,
        clase    clase_pcuentas.clase%TYPE,
        desclase clase_pcuentas.descri%TYPE,
        vreal    clase_pcuentas.vreal%TYPE,
        vstrg    clase_pcuentas.vstrg%TYPE,
        vchar    clase_pcuentas.vchar%TYPE,
        vdate    clase_pcuentas.vdate%TYPE,
        vtime    clase_pcuentas.vtime%TYPE,
        ventero  clase_pcuentas.ventero%TYPE,
        swacti   clase_pcuentas.swacti%TYPE,
        obliga   clase_pcuentas.obliga%TYPE,
        ucreac   clase_pcuentas.ucreac%TYPE,
        uactua   clase_pcuentas.usuari%TYPE,
        fcreac   clase_pcuentas.fcreac%TYPE,
        factua   clase_pcuentas.factua%TYPE
    );
    TYPE datatable_clase IS
        TABLE OF datarecord_clase;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    clase_pcuentas_codigo.id_cia%TYPE,
        clase     clase_pcuentas_codigo.clase%TYPE,
        desclase  clase_pcuentas.descri%TYPE,
        codigo    clase_pcuentas_codigo.codigo%TYPE,
        descodigo clase_pcuentas_codigo.descri%TYPE,
        abrevi    clase_pcuentas_codigo.abrevi%TYPE,
        swacti    clase_pcuentas_codigo.swacti%TYPE,
        ucreac    clase_pcuentas_codigo.codusercrea%TYPE,
        uactua    clase_pcuentas_codigo.coduseractu%TYPE,
        fcreac    clase_pcuentas_codigo.fcreac%TYPE,
        factua    clase_pcuentas_codigo.factua%TYPE
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
