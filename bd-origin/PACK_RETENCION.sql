--------------------------------------------------------
--  DDL for Package PACK_RETENCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RETENCION" AS
    TYPE datarecord_regimen_retencion IS RECORD (
        tope regimen_retenciones_vigencia.tope%TYPE,
        tasa regimen_retenciones_vigencia.tasa%TYPE
    );
    TYPE datatable_regimen_retencion IS
        TABLE OF datarecord_regimen_retencion;
    FUNCTION sp_regimen_retencion (
        pin_id_cia NUMBER,
        pin_codigo NUMBER,
        pin_codcli VARCHAR2,
        pin_fhasta DATE
    ) RETURN datatable_regimen_retencion
        PIPELINED;

    PROCEDURE sp_contabilizar (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_descontabilizar (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_anular (
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
--    pack_retencion.sp_contabilizar(25,1109,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_retencion.sp_descontabilizar(25,1109,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_retencion.sp_anular(25,1109,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
