--------------------------------------------------------
--  DDL for Package PACK_CLI_CLASE_ENFERMEDAD_CODIGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLI_CLASE_ENFERMEDAD_CODIGO" AS
    TYPE t_cli_clase_enfermedad_codigo IS
        TABLE OF cli_clase_enfermedad_codigo%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_id_tipo IN NUMBER,
        pin_id_clase IN NUMBER,
        pin_id_codigo VARCHAR2
    ) RETURN t_cli_clase_enfermedad_codigo
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_cli_clase_enfermedad_codigo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
