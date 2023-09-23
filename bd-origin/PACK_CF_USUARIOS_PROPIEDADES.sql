--------------------------------------------------------
--  DDL for Package PACK_CF_USUARIOS_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_USUARIOS_PROPIEDADES" AS
    TYPE datarecord_usuarios IS RECORD (
        coduser usuarios.coduser%TYPE,
        nombres usuarios.nombres%TYPE
    );
    TYPE datatable_usuarios IS
        TABLE OF datarecord_usuarios;
    FUNCTION sp_buscar_usuarios (
        pin_id_cia NUMBER,
        pin_codigo NUMBER
    ) RETURN datatable_usuarios
        PIPELINED;

END;

/
