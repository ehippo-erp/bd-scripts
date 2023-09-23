--------------------------------------------------------
--  DDL for Package PACK_RETENDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RETENDET" AS
    TYPE datatable_retendet IS
        TABLE OF retendet%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_item NUMBER
    ) RETURN datatable_retendet
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_numint NUMBER,
        pin_tdocum VARCHAR2,
        pin_serie VARCHAR2,
        pin_numero NUMBER
    ) RETURN datatable_retendet
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
