--------------------------------------------------------
--  DDL for Package PACK_ESTADO_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ESTADO_PERSONAL" AS
    TYPE t_estado_personal IS
        TABLE OF estado_personal%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codest IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_estado_personal
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
