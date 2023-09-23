--------------------------------------------------------
--  DDL for Package PACK_IMPORT_CANCELACION_PLANILLA_COBRANZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_CANCELACION_PLANILLA_COBRANZA" AS
    TYPE r_errores IS RECORD (
        orden    NUMBER,
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE sp_importa (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
