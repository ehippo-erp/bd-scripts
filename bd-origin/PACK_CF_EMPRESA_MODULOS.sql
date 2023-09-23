--------------------------------------------------------
--  DDL for Package PACK_CF_EMPRESA_MODULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_EMPRESA_MODULOS" AS
    TYPE datarecord_empresa_modulos IS RECORD (
        id_cia  empresa_modulos.id_cia%TYPE,
        codmod  empresa_modulos.codmod%TYPE,
        desmod  modulos.descri%TYPE,
        swacti  empresa_modulos.swacti%TYPE,
        maxuser empresa_modulos.maxuser%TYPE,
        ucreac  empresa_modulos.ucreac%TYPE,
        uactua  empresa_modulos.uactua%TYPE,
        fcreac  empresa_modulos.factua%TYPE,
        factua  empresa_modulos.factua%TYPE
    );
    TYPE datatable_empresa_modulos IS
        TABLE OF datarecord_empresa_modulos;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codmod NUMBER
    ) RETURN datatable_empresa_modulos
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_swacti VARCHAR2
    ) RETURN datatable_empresa_modulos
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
