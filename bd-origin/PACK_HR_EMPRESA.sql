--------------------------------------------------------
--  DDL for Package PACK_HR_EMPRESA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_EMPRESA" AS

--SET SERVEROUTPUT ON;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--
--    pack_hr_empresa.sp_generar(233,5,'admin',v_mensaje);
--    dbms_output.put_line(v_mensaje);
--
--END;

    PROCEDURE sp_generar (
        pin_id_cia      IN NUMBER,
        pin_id_cia_orig IN NUMBER,
        pin_coduser     IN VARCHAR2,
        pin_mensaje     OUT VARCHAR2
    );

    PROCEDURE sp_eliminar (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--SET SERVEROUTPUT ON;
--
--DECLARE
--   v_sql_query VARCHAR2(4000);
--   v_table_name user_tables.table_name%TYPE;
--   v_insert_script CLOB := '';
--   v_row_count NUMBER;
--BEGIN
--   -- Cursor para seleccionar las tablas
--   FOR tab IN (SELECT table_name
--               FROM user_tables
--               WHERE table_name LIKE 'PLANILLA%') 
--   LOOP
--      v_table_name := tab.table_name;
--
--      -- Construir la consulta de selección para la tabla actual
--      v_sql_query := 'SELECT */*insert*/ FROM ' || v_table_name || ' WHERE id_cia = 129;';
--     DBMS_OUTPUT.PUT_LINE(v_sql_query); 
--   END LOOP;
--
--END;

--SELECT table_name
--FROM user_tables
--WHERE table_name LIKE 'PERSONAL%';

--SELECT table_name
--FROM user_tables
--WHERE table_name LIKE 'PLANILLA%';

END;

/
