--------------------------------------------------------
--  DDL for Package PACK_CF_COMPANIAS_CONFIG_EMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_COMPANIAS_CONFIG_EMAIL" AS
    PROCEDURE sp_valida_emision (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_cf_companias_config_email.sp_valida_emision(25,1, NULL, v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
