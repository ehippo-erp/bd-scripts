--------------------------------------------------------
--  DDL for Package PACK_IMPORT_CLIENTECONTACTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_CLIENTECONTACTO" AS
    TYPE r_errores IS RECORD (
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

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--SELECT * FROM pack_import_clientecontacto.sp_valida_objeto(25,'{
--                "codcli":"72776354",
--                "nomcont":"CONTACTO DE PRUEBA",
--                "direccion":"DIRECCION DE PRUEBA",
--                "email":"EMAIL DE PRUEBA",
--                "telefono":"TEF 999",
--                "hobby":"HOBBY DE PRUEBA",
--                "cargo":"CARGO DE PRUEBA",
--                "observacion":"OBS PRUEBA",
--                "dident":"72776354"
--                }');
--
--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codcli":"00000000003",
--                "nomcont":"CONTACTO DE PRUEBA",
--                "direccion":"DIRECCION DE PRUEBA",
--                "email":"EMAIL DE PRUEBA",
--                "telefono":"TEF 999",
--                "hobby":"HOBBY DE PRUEBA",
--                "cargo":"CARGO DE PRUEBA",
--                "observacion":"OBS PRUEBA",
--                "dident":"72776354"
--                }';
--pack_import_clientecontacto.sp_importar(25, cadjson, 'admin', mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;

END;

/
