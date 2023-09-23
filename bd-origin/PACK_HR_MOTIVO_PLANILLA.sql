--------------------------------------------------------
--  DDL for Package PACK_HR_MOTIVO_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_MOTIVO_PLANILLA" AS
    TYPE t_motivo_planilla IS
        TABLE OF motivo_planilla%rowtype;
    FUNCTION sp_tipo (
        pin_id_cia IN NUMBER,
        pin_tipo   IN VARCHAR2
    ) RETURN t_motivo_planilla
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codmot IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_motivo_planilla
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
