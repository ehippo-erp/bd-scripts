--------------------------------------------------------
--  DDL for Package PACK_IMPORT_KARDEX_DETALLADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_KARDEX_DETALLADO" AS
    TYPE r_errores IS RECORD (
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    -- PASO 1 SE VALIDA LA IMPORTACION
    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    FUNCTION valida_objeto_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    -- PASO 2 SE IMPORTA 
    PROCEDURE importa_kardex (
        pin_id_cia IN NUMBER,
        pin_usuari IN VARCHAR2,
        pin_datos  IN CLOB,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE importa_kardex_detallado (
        pin_id_cia IN NUMBER,
        pin_usuari IN VARCHAR2,
        pin_datos  IN CLOB,
        pin_mensaje OUT VARCHAR2
    );

    -- PASO 3 SE RECALCULAN LOS COSTOS DEL DOCUMENTOS_CAB -- SOLO EJECUTA UNA VEZ
    PROCEDURE sp_actualiza_saldos(
        pin_id_cia IN NUMBER,
        pin_usuari IN VARCHAR2,
        pin_datos  IN CLOB,
        pin_mensaje OUT VARCHAR2
    );

END;

/
