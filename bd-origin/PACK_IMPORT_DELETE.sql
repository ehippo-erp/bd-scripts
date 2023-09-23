--------------------------------------------------------
--  DDL for Package PACK_IMPORT_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_DELETE" AS
    PROCEDURE sp_registro_compras (
        pin_id_cia       IN NUMBER,
        pin_fimportacion IN DATE,
        pin_coduser      IN VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--/
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_import_delete.sp_registro_compras(72,to_date('09/11/12','DD/MM/YY'), 'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
