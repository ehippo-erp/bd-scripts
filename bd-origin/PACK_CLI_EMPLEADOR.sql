--------------------------------------------------------
--  DDL for Package PACK_CLI_EMPLEADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLI_EMPLEADOR" AS
    TYPE t_cli_empleador IS
        TABLE OF cli_empleador%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_id_emp IN NUMBER
    ) RETURN t_cli_empleador
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_empleador
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
