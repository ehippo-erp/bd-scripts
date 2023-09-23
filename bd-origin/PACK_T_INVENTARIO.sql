--------------------------------------------------------
--  DDL for Package PACK_T_INVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_T_INVENTARIO" AS
    TYPE datatable_t_inventario IS
        TABLE OF t_inventario%rowtype;

    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_tipinv IN VARCHAR2
    ) RETURN datatable_t_inventario
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_descri IN VARCHAR2
    ) RETURN datatable_t_inventario
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_patron IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_genera_correlativo(
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_patron IN VARCHAR2
    ) RETURN
        VARCHAR2;

END;

/
