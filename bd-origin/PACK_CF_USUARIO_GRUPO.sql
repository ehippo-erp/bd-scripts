--------------------------------------------------------
--  DDL for Package PACK_CF_USUARIO_GRUPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_USUARIO_GRUPO" AS
    TYPE datarecord_usuario_grupo IS RECORD (
        id_cia   usuario_grupo.id_cia%TYPE,
        codgrupo usuario_grupo.codgrupo%TYPE,
        desgrupo grupo_usuario.desgrupo%TYPE,
        coduser  usuario_grupo.coduser%TYPE,
        nomuser  usuarios.nombres%TYPE,
        ucreac   usuario_grupo.ucreac%TYPE,
        uactua   usuario_grupo.uactua%TYPE,
        fcreac   usuario_grupo.factua%TYPE,
        factua   usuario_grupo.factua%TYPE
    );
    TYPE datatable_usuario_grupo IS
        TABLE OF datarecord_usuario_grupo;
    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER,
        pin_coduser  VARCHAR2
    ) RETURN datatable_usuario_grupo
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER,
        pin_coduser  VARCHAR2
    ) RETURN datatable_usuario_grupo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
