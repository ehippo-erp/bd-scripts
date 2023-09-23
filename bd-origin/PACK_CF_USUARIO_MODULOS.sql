--------------------------------------------------------
--  DDL for Package PACK_CF_USUARIO_MODULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_USUARIO_MODULOS" AS
    TYPE datarecord_usuario_modulos IS RECORD (
        id_cia  usuario_modulos.id_cia%TYPE,
        codmod  usuario_modulos.codmod%TYPE,
        desmod  modulos.descri%TYPE,
        coduser usuario_modulos.coduser%TYPE,
        nomuser usuarios.nombres%TYPE,
        swacti  usuario_modulos.swacti%TYPE,
        ucreac  usuario_modulos.ucreac%TYPE,
        uactua  usuario_modulos.uactua%TYPE,
        fcreac  usuario_modulos.factua%TYPE,
        factua  usuario_modulos.factua%TYPE
    );
    TYPE datatable_usuario_modulos IS
        TABLE OF datarecord_usuario_modulos;
    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codmod  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_usuario_modulos
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codmod  NUMBER,
        pin_coduser VARCHAR2,
        pin_swacti  VARCHAR2
    ) RETURN datatable_usuario_modulos
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
