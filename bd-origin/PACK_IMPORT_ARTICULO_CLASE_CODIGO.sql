--------------------------------------------------------
--  DDL for Package PACK_IMPORT_ARTICULO_CLASE_CODIGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_ARTICULO_CLASE_CODIGO" AS
    TYPE r_errores IS RECORD (
        orden    VARCHAR2(80),
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    TYPE datarecord_exportar IS RECORD (
        id_cia articulos.id_cia%TYPE,
        tipinv articulos.tipinv%TYPE,
        codart articulos.codart%TYPE,
        desart articulos.descri%TYPE,
        clase  articulos_clase.clase%TYPE,
        codigo articulos_clase.codigo%TYPE
    );
    TYPE datatable_exportar IS
        TABLE OF datarecord_exportar;
    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

--    SELECT* FROM pack_import_cliente_clase.sp_valida_objeto(66,'{"tipcli":"X","codcli":"205126094SS58","clase":145,"codigo":"ND","situac":"F"}');
--    
--    SET SERVEROUTPUT ON;
--
--    DECLARE
--        mensaje varchar2(2000);
--        cadjson VARCHAR2(2000);
--    BEGIN
--    
--        cadjson := '{"tipcli":"A","codcli":"20512609458","clase":14,"codigo":"ND","situac":"S"}';
--    
--        pack_import_cliente_clase.sp_importa_saldos(66,cadjson,'admin',mensaje);
--        DBMS_OUTPUT.PUT_LINE(mensaje);
--    
--    END;

--SET SERVEROUTPUT ON;
--
--DECLARE
--    v_mensaje VARCHAR2(1000 CHAR) := '';
--BEGIN
--
--    pack_import_articulo_clase_codigo.sp_asigna_conceptos_fijos(129, 'admin',
--                                                                       v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_clase  IN NUMBER,
        pin_inccla IN VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED;

END;

/
