--------------------------------------------------------
--  DDL for Package PACK_E_FINANCIERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_E_FINANCIERA" AS
    TYPE t_E_FINANCIERA IS
        TABLE OF E_FINANCIERA%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codigo IN NUMBER,
        pin_descri IN VARCHAR2,
		pin_situac IN VARCHAR2
    ) RETURN t_E_FINANCIERA
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
