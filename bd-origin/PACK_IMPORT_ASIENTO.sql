--------------------------------------------------------
--  DDL for Package PACK_IMPORT_ASIENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_ASIENTO" AS
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
    -- PASO 2 SE IMPORTA (ASIENHEA / ASIENDET )
    PROCEDURE importa_asiento (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    );
    PROCEDURE importa_asiento_detalle (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    );
    -- PASO 3 SE CONTABILIZA
    PROCEDURE contabiliza_asiento_migracion (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_contabilizar_asiento_importacion (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuario   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

END;

/
