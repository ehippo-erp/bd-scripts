--------------------------------------------------------
--  DDL for Package PACK_HR_PROCEDURE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PROCEDURE_GENERAL" AS
    PROCEDURE sp_dialab (
        pin_ano      IN INTEGER,
        pin_mes      IN INTEGER,
        pin_fingreso IN DATE,
        pin_fcese    IN DATE,
        pin_formula  IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_mesfactor_proyecciongrati (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_mesgra   IN INTEGER,
        pin_periodo  IN NUMBER,
        pin_fdesde   IN DATE,
        pin_fhasta   IN DATE,
        pout_formula OUT VARCHAR2,
        pin_valcon   OUT NUMBER,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_diafactor_proyecciongrati (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_mesgra   IN INTEGER,
        pin_periodo  IN NUMBER,
        pin_fdesde   IN DATE,
        pin_fhasta   IN DATE,
        pout_formula OUT VARCHAR2,
        pin_valcon   OUT NUMBER,
        pin_mensaje  OUT VARCHAR2
    );

--SET SERVEROUTPUT ON
--DECLARE
--    v_valor NUMBER;
--    v_mensaje VARCHAR2(1000 CHAR);
--    v_pout_formula VARCHAR2(4000 CHAR);
--BEGIN
--    pack_hr_procedure_general.sp_mesfactor_proyecciongrati(66, NULL, NULL,7,2022,'15/01/22','20/06/22',  v_pout_formula, v_valor, v_mensaje);
--    dbms_output.put_line(v_pout_formula);
--    dbms_output.put_line(v_valor);
--    dbms_output.put_line(v_mensaje);
--END;
--
--SET SERVEROUTPUT ON
--DECLARE
--    v_valor NUMBER;
--    v_mensaje VARCHAR2(1000 CHAR);
--    v_pout_formula VARCHAR2(4000 CHAR);
--BEGIN
--    pack_hr_procedure_general.sp_diafactor_proyecciongrati(66, NULL, NULL,7,2022,'15/01/22','20/06/22', v_pout_formula, v_valor, v_mensaje);
--    dbms_output.put_line(v_pout_formula);
--    dbms_output.put_line(v_valor);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/
