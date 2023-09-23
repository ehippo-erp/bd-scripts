--------------------------------------------------------
--  DDL for Package PACK_CLI_MEDICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLI_MEDICO" AS
    TYPE t_cli_medico IS
        TABLE OF cli_medico%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_id_med IN NUMBER
    ) RETURN t_cli_medico
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre VARCHAR2
    ) RETURN t_cli_medico
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ); 
END;

/
