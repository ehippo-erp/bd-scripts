--------------------------------------------------------
--  DDL for Package PACK_CLI_TIPO_ENFERMEDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLI_TIPO_ENFERMEDAD" AS
    TYPE t_cli_tipo_enfermedad IS
        TABLE OF cli_tipo_enfermedad%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_id_tipo IN NUMBER
    ) RETURN t_cli_tipo_enfermedad
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_tipo_enfermedad
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
