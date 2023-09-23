--------------------------------------------------------
--  DDL for Package PACK_CLI_ASEGURADORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLI_ASEGURADORA" AS
    TYPE t_cli_aseguradora IS
        TABLE OF cli_aseguradora%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_id_aseg IN NUMBER
    ) RETURN t_cli_aseguradora
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_aseguradora
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
