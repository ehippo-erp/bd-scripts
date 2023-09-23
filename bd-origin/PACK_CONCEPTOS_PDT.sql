--------------------------------------------------------
--  DDL for Package PACK_CONCEPTOS_PDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CONCEPTOS_PDT" AS
    TYPE t_conceptos_pdt IS
        TABLE OF conceptos_pdt%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codpdt IN NUMBER,
        pin_descri IN VARCHAR2
    ) RETURN t_conceptos_pdt
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
