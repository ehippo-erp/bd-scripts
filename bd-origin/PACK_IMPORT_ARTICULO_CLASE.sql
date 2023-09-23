--------------------------------------------------------
--  DDL for Package PACK_IMPORT_ARTICULO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_ARTICULO_CLASE" AS
    TYPE datarecord_buscar IS RECORD (
        tipinv clase_codigo.tipinv%TYPE,
        clase  clase_codigo.clase%TYPE,
        codigo clase_codigo.codigo%TYPE,
        descri clase_codigo.descri%TYPE,
        situac clase_codigo.situac%TYPE,
        defaul VARCHAR2(10 CHAR)
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE r_errores IS RECORD (
        fila     NUMBER,
        columna  VARCHAR2(80),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_clase  IN NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

--SELECT * FROM pack_import_articulo_clase.sp_exportar(25,1,2)
--
--SELECT* FROM pack_import_articulo_clase.sp_valida_objeto(25,'{"tipinv":1,"clase":145,"codigo":"10","descodigo":"TRANFERENCIA NO DEFINIDA","situac":"S"}');
--
--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje varchar2(2000);
--    cadjson VARCHAR2(2000);
--BEGIN
--
--    cadjson := '{"tipinv":1,"clase":2,"codigo":"1099","descodigo":"ERP TEST","situac":"S"}';
--
--    pack_import_articulo_clase.sp_importar(25,cadjson,'admin',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_usuari  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END pack_import_articulo_clase;

/
