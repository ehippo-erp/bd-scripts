--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_DEPRECIACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_DEPRECIACION" AS
    TYPE datatable_articulos_depreciacion IS
        TABLE OF articulos_depreciacion%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_locali NUMBER
    ) RETURN datatable_articulos_depreciacion
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_numint NUMBER
    ) RETURN datatable_articulos_depreciacion
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
