--------------------------------------------------------
--  DDL for Package PACK_DETRACCION_CAB_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DETRACCION_CAB_ENVIO_SUNAT" AS
    TYPE datatable_detraccion_cab_envio_sunat IS
        TABLE OF detraccion_cab_envio_sunat%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_detraccion_cab_envio_sunat
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_detraccion_cab_envio_sunat
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_txt     IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
