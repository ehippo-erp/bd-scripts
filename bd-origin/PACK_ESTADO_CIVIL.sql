--------------------------------------------------------
--  DDL for Package PACK_ESTADO_CIVIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ESTADO_CIVIL" AS
    TYPE t_estado_civil IS
        TABLE OF estado_civil%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codeci IN VARCHAR2
    ) RETURN t_estado_civil
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_estado_civil
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
