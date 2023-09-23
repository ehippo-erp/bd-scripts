--------------------------------------------------------
--  DDL for Package PACK_CF_EXCELDINAMICO_GRUPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_EXCELDINAMICO_GRUPO" AS
    TYPE datarecord_exceldinamico_grupo IS RECORD (
        id_cia   exceldinamico_grupo.id_cia%TYPE,
        codexc   exceldinamico_grupo.codexc%TYPE,
        codgrupo exceldinamico_grupo.codgrupo%TYPE,
        desgrupo grupo_usuario.desgrupo%TYPE,
        ucreac   exceldinamico_grupo.ucreac%TYPE,
        uactua   exceldinamico_grupo.uactua%TYPE,
        fcreac   exceldinamico_grupo.factua%TYPE,
        factua   exceldinamico_grupo.factua%TYPE
    );
    TYPE datatable_exceldinamico_grupo IS
        TABLE OF datarecord_exceldinamico_grupo;
    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codexc   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_exceldinamico_grupo
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codexc   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_exceldinamico_grupo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
