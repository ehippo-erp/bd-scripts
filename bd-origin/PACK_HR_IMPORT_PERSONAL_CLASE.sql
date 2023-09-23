--------------------------------------------------------
--  DDL for Package PACK_HR_IMPORT_PERSONAL_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_IMPORT_PERSONAL_CLASE" AS
    TYPE r_errores IS RECORD (
        orden    VARCHAR2(80),
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_exportar IS RECORD (
        id_cia personal.id_cia%TYPE,
        tiptra personal.tiptra%TYPE,
        codper personal.codper%TYPE,
        nomper VARCHAR2(2000 CHAR),
        clase  personal_clase.clase%TYPE,
        codigo personal_clase.codigo%TYPE
    );
    TYPE datatable_exportar IS
        TABLE OF datarecord_exportar;
    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

--SELECT
--    *
--FROM
--    pack_import_personal_clase.sp_valida_objeto(25, '{"tiptra":"E","codper":"72776354","nomper":"NOMBRE DEL PERSONAL","clase":1100,"codigo":"ND"}'
--    );
--
--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje VARCHAR2(2000);
--    cadjson VARCHAR2(2000);
--BEGIN
--    cadjson := '{"tiptra":"E","codper":"72776354","nomper":"NOMBRE DEL PERSONAL","clase":1100,"codigo":"N"}';
--    pack_import_personal_clase.sp_importar(25, cadjson, 'admin', mensaje);
--    dbms_output.put_line(mensaje);
--END;
--
--SELECT * FROM pack_import_personal_clase.sp_exportar(25,'E',1100,'N');

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_clase  IN NUMBER,
        pin_inccla IN VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED;

END;

/
