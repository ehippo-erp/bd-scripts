--------------------------------------------------------
--  DDL for Package PACK_DCTA106
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA106" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    TYPE t_doccab IS
        TABLE OF dcta106%rowtype;
    FUNCTION sp_next_numite (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    -- ELIMINA LA APLICACION
    PROCEDURE sp_eliminar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    -- PROCESA APLICACION OPCARGO = 'APLI-106?'
    PROCEDURE sp_insertar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    -- REGISTRO DE ANTICIPO, ITEM = 0
    -- REVISAR MOTIVO 25/26
    PROCEDURE sp_actualizar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    -- TODO EL PROCESO EN SI, ELIMINA, GENERA EL ANTICIPO, REALIZA LA APLICACION
    PROCEDURE sp_procesar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_dcta106.sp_insertar_aplicacion(30, 120049,'', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_dcta106.sp_eliminar_aplicacion(30, 120049,'', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_dcta106.sp_actualizar_aplicacion(30, 120026,'', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_dcta106.sp_procesar_aplicacion(30,119315,'', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END pack_dcta106;

/
