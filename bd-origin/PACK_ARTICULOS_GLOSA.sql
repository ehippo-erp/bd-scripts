--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_GLOSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_GLOSA" AS
    TYPE datatable_articulos_glosa IS
        TABLE OF articulos_glosa%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2
    ) RETURN datatable_articulos_glosa
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_tipo      NUMBER,
        pin_tipinv    NUMBER,
        pin_codart    VARCHAR2,
        pin_swdefaul VARCHAR2
    ) RETURN datatable_articulos_glosa
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
