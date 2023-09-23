--------------------------------------------------------
--  DDL for Package PACK_DETRACCION_DET_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DETRACCION_DET_ENVIO_SUNAT" AS
    TYPE datatable_detraccion_det_envio_sunat IS
        TABLE OF detraccion_det_envio_sunat%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER
    ) RETURN datatable_detraccion_det_envio_sunat
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_detraccion_det_envio_sunat
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
