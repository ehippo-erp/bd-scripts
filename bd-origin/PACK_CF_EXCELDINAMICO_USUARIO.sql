--------------------------------------------------------
--  DDL for Package PACK_CF_EXCELDINAMICO_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_EXCELDINAMICO_USUARIO" AS
    TYPE datarecord_exceldinamico_usuario IS RECORD (
        id_cia  exceldinamico_usuario.id_cia%TYPE,
        codexc  exceldinamico_usuario.codexc%TYPE,
        coduser exceldinamico_usuario.coduser%TYPE,
        nomuser usuarios.nombres%TYPE,
        ucreac  exceldinamico_usuario.ucreac%TYPE,
        uactua  exceldinamico_usuario.uactua%TYPE,
        fcreac  exceldinamico_usuario.factua%TYPE,
        factua  exceldinamico_usuario.factua%TYPE
    );
    TYPE datatable_exceldinamico_usuario IS
        TABLE OF datarecord_exceldinamico_usuario;
    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codexc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_exceldinamico_usuario
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codexc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_exceldinamico_usuario
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
