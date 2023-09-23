--------------------------------------------------------
--  DDL for Package PACK_IMPORT_CLIENTE_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_CLIENTE_CLASE" AS
    TYPE r_errores IS RECORD (
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_buscar IS RECORD (
        tipcli clase_cliente_codigo.tipcli%TYPE,
        clase  clase_cliente_codigo.clase%TYPE,
        codigo clase_cliente_codigo.codigo%TYPE,
        descodigo clase_cliente_codigo.descri%TYPE,
        situac clase_cliente_codigo.situac%TYPE,
        defaul clase_cliente_codigo.swdefaul%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipcli IN VARCHAR2,
        pin_clase  IN NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

--SELECT * FROM pack_import_cliente_clase.sp_exportar(25,'B',13)
--
--SELECT* FROM pack_import_cliente_clase.sp_valida_objeto(25,'{"tipcli":"A","clase":145,"codigo":"10","descodigo":"TRANFERENCIA NO DEFINIDA","situac":"S","defaul":"S"}');
--
--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje varchar2(2000);
--    cadjson VARCHAR2(2000);
--BEGIN
--
--    cadjson := '{"tipcli":"B","clase":13,"codigo":"10","descodigo":"TRANFERENCIA NO DEFINIDA","situac":"S","defaul":"S"}';
--
--    pack_import_cliente_clase.sp_importar(25,cadjson,'admin',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_usuari  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END pack_import_cliente_clase;

/
