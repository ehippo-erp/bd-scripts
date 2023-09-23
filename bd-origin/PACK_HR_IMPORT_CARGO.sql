--------------------------------------------------------
--  DDL for Package PACK_HR_IMPORT_CARGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_IMPORT_CARGO" AS
    TYPE r_errores IS RECORD (
        orden    VARCHAR2(80),
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

--SELECT
--    *
--FROM
--    pack_hr_import_cargo.sp_valida_objeto(66, '{"codcar":"01","nombre":"CARGO DE PRUEBA"}');
--
--
--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje VARCHAR2(2000);
--    cadjson VARCHAR2(2000);
--BEGIN
--    cadjson := '{"codcar":"99","nombre":"CARGO DE PRUEBA"}';
--    pack_hr_import_cargo.sp_importar(66, cadjson, 'admin', mensaje);
--    dbms_output.put_line(mensaje);
--END;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
