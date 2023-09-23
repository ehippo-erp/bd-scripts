--------------------------------------------------------
--  DDL for Package PACK_USUARIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_USUARIOS" AS
    TYPE datarecord_usuarios IS RECORD (
        id_cia     usuarios.id_cia%TYPE,
        coduser    usuarios.coduser%TYPE,
        nombres    usuarios.nombres%TYPE,
        clave      usuarios.clave%TYPE,
        atributos  usuarios.atributos%TYPE,
        fexpira    usuarios.fexpira%TYPE,
        situac     usuarios.situac%TYPE,
        fcreac     usuarios.fcreac%TYPE,
        factua     usuarios.factua%TYPE,
        swacti     usuarios.swacti%TYPE,
        usuari     usuarios.usuari%TYPE,
        comentario usuarios.comentario%TYPE,
        impeti     usuarios.impeti%TYPE,
        numcaja    usuarios.numcaja%TYPE,
        cargo      usuarios.cargo%TYPE,
        codsuc     usuarios.codsuc%TYPE,
        email      usuarios.email%TYPE
    );
    TYPE datatable_usuarios IS
        TABLE OF datarecord_usuarios;

    PROCEDURE sp_clean_sessions (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_validacion_eliminar_usuario(
        pin_id_cia IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_usuarios
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_nombre VARCHAR2
    ) RETURN datatable_usuarios
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
