--------------------------------------------------------
--  DDL for Package PACK_CARGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CARGO" AS
    TYPE t_cargo IS
        TABLE OF cargo%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codcar IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_cargo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
