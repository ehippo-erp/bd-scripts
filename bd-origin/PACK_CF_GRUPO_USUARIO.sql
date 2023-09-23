--------------------------------------------------------
--  DDL for Package PACK_CF_GRUPO_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_GRUPO_USUARIO" AS
    TYPE datarecord_grupo_usuario IS RECORD (
        id_cia   grupo_usuario.id_cia%TYPE,
        codgrupo grupo_usuario.codgrupo%TYPE,
        desgrupo grupo_usuario.desgrupo%TYPE,
        swacti   grupo_usuario.swacti%TYPE,
        ucreac   grupo_usuario.ucreac%TYPE,
        uactua   grupo_usuario.uactua%TYPE,
        fcreac   grupo_usuario.factua%TYPE,
        factua   grupo_usuario.factua%TYPE
    );
    TYPE datatable_grupo_usuario IS
        TABLE OF datarecord_grupo_usuario;
    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_grupo_usuario
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_desgrupo VARCHAR2,
        pin_swacti   VARCHAR2
    ) RETURN datatable_grupo_usuario
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
