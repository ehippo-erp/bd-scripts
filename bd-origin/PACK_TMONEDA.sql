--------------------------------------------------------
--  DDL for Package PACK_TMONEDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TMONEDA" AS
    TYPE t_TMoneda IS
        TABLE OF TMoneda%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codmon IN NUMBER,
        pin_desmot IN VARCHAR2
    ) RETURN t_TMoneda
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
