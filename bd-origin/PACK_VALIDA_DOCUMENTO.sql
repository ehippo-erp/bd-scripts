--------------------------------------------------------
--  DDL for Package PACK_VALIDA_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_VALIDA_DOCUMENTO" AS
    FUNCTION sp_propiedad (
        pin_id_cia  INTEGER,
        pin_codigo  INTEGER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE sp_permiso (
        pin_id_cia  IN INTEGER,
        pin_tipdoc  IN INTEGER,
        pin_accion  IN VARCHAR2,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_detalle (
        pin_id_cia  IN INTEGER,
        pin_tipdoc  IN INTEGER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--SET SERVEROUTPUT ON;
--
--DECLARE
--    v_mensaje VARCHAR2(1000 CHAR) := '';
--BEGIN
--
--    pack_valida_documento.sp_permiso(66, 101, 'A',100028, '003',
--                                                                       v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

--SET SERVEROUTPUT ON;
--
--DECLARE
--    v_mensaje VARCHAR2(1000 CHAR) := '';
--BEGIN
--
--    pack_valida_documento.sp_detalle(25, 100, 180947, '003',
--                                                                       v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--SELECT * FROM documentos_cab WHERE id_cia = 25 AND tipdoc = 100 ORDER BY numint DESC
--
--SELECT cosuni, tipcam FROM documentos_det WHERE id_cia = 25 AND numint = 180947

END;

/
