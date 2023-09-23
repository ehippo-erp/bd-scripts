--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_CALCULO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_CALCULO" AS
    TYPE datarecord_concepto_noincluido IS RECORD (
        codcon concepto.codcon%TYPE,
        nomcon concepto.nombre%TYPE
    );
    TYPE datatable_concepto_noincluido IS
        TABLE OF datarecord_concepto_noincluido;
    TYPE r_errores IS RECORD (
        orden    NUMBER,
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_valida_objeto_ordenado (
        pin_id_cia  NUMBER,
        pin_numpla  NUMBER,
        pin_codper  VARCHAR2,
        pin_orderby NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_valida_concepto_noincluido (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_concepto_noincluido
        PIPELINED;

    TYPE datarecord_planilla_calculo IS RECORD (
        id_cia planilla_concepto.id_cia%TYPE,
        numpla planilla_concepto.numpla%TYPE,
        codper personal.codper%TYPE,
        nomper VARCHAR2(500 CHAR),
        codcon concepto.codcon%TYPE,
        nomcon concepto.nombre%TYPE,
        valcon NUMBER(16, 4),
        tipori concepto.fijvar%TYPE,
        formul concepto.formul%TYPE
    );
    TYPE datatable_planilla_calculo IS
        TABLE OF datarecord_planilla_calculo;
    FUNCTION sp_planilla_calculo (
        pin_id_cia IN NUMBER,
        pin_numpla IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_codcon IN VARCHAR2
    ) RETURN datatable_planilla_calculo
        PIPELINED;

    PROCEDURE sp_calcular (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(1000);
--    v_resultado  VARCHAR2(1000);
--    v_pin_formula  VARCHAR2(1000);
--    v_pin_decodificado  VARCHAR2(1000);
--BEGIN
--
--pack_hr_planilla_calculo.sp_calcular_concepto(66, 1, '42983203', '006','FT', 'admin',
--                                             v_pin_formula, v_pin_decodificado, v_resultado, v_mensaje);
--                                          
--dbms_output.put_line(v_pin_formula);
--                                             
--dbms_output.put_line(v_pin_decodificado);
--
--dbms_output.put_line(v_resultado);
--
--dbms_output.put_line(v_mensaje);
--
--end;

    PROCEDURE sp_calcular_concepto (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      OUT VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    );

    PROCEDURE sp_calcular_concepto_pseudocodigo (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      OUT VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(1000);
--    v_resultado  VARCHAR2(1000);
--    v_pin_formula  VARCHAR2(1000);
--    v_pin_decodificado  VARCHAR2(1000);
--BEGIN
--
--pack_hr_planilla_calculo.sp_calcular_concepto_pseudocodigo(25, 1, '72776354', '101','C', 'admin',
--                                             v_pin_formula, v_pin_decodificado, v_resultado, v_mensaje);
--                                          
--dbms_output.put_line(v_pin_formula);
--                                             
--dbms_output.put_line(v_pin_decodificado);
--
--dbms_output.put_line(v_resultado);
--
--dbms_output.put_line(v_mensaje);
--
--end;

    PROCEDURE sp_calcular_concepto_test (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      IN VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    );

END;

/
