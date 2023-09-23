--------------------------------------------------------
--  DDL for Package PACK_SITUACION_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_SITUACION_PERSONAL" AS
    TYPE t_situacion_personal IS
        TABLE OF situacion_personal%rowtype;
    FUNCTION sp_sel_situacion_personal (
        pin_id_cia IN NUMBER,
        pin_codsit IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_situacion_personal
        PIPELINED;

    PROCEDURE sp_save_situacion_personal (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
