--------------------------------------------------------
--  DDL for Package PACK_RETENHEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RETENHEA" AS
    TYPE datatable_retenhea IS
        TABLE OF retenhea%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_retenhea
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_libro   VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_asiento NUMBER
    ) RETURN datatable_retenhea
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
