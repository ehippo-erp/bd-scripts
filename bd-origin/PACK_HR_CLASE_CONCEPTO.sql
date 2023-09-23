--------------------------------------------------------
--  DDL for Package PACK_HR_CLASE_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CLASE_CONCEPTO" AS
    TYPE t_clase_concepto IS
        TABLE OF clase_concepto%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_concepto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    TYPE t_clase_concepto_codigo IS
        TABLE OF clase_concepto_codigo%rowtype;
    FUNCTION sp_buscar_codigo (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_codigo IN VARCHAR2,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_concepto_codigo
        PIPELINED;

    PROCEDURE sp_save_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );


END;

/
