--------------------------------------------------------
--  DDL for Package PACK_E_FINANCIERA_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_E_FINANCIERA_TIPO" AS
    TYPE t_E_Financiera_Tipo IS
        TABLE OF E_Financiera_Tipo%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_TipCta IN NUMBER,
        pin_descri IN VARCHAR2
    ) RETURN t_E_Financiera_Tipo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
