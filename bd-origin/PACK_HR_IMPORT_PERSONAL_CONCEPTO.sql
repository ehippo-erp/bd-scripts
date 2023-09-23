--------------------------------------------------------
--  DDL for Package PACK_HR_IMPORT_PERSONAL_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_IMPORT_PERSONAL_CONCEPTO" AS
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
        codcon  personal_concepto.codcon%TYPE,
        valcon personal_concepto.valcon%TYPE
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
--    pack_hr_import_personal_concepto.sp_valida_objeto(25, '{"tiptra":"E","codper":"72776354","nomper":"NOMBRE DEL PERSONAL","codcon":"1100","valcon":"0","periodo":2023,"mes":1}'
--    );
--
--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje VARCHAR2(2000);
--    cadjson VARCHAR2(2000);
--BEGIN
--    cadjson := '{"tiptra":"E","codper":"72776354","nomper":"NOMBRE DEL PERSONAL","codcon":"001","valcon":"2000","periodo":2023,"mes":1}';
--    pack_hr_import_personal_concepto.sp_importar(25, cadjson, 'admin', mensaje);
--    dbms_output.put_line(mensaje);
--END;
--
--SELECT * FROM pack_hr_import_personal_concepto.sp_exportar(25,'E','001',2023,01,'N');

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_codcon  IN VARCHAR2,
        pin_periodo IN NUMBER,
        pin_mes IN NUMBER,
        pin_inccla IN VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED;

END;

/
