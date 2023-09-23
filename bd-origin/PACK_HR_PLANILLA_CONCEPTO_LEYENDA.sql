--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_CONCEPTO_LEYENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_CONCEPTO_LEYENDA" AS
    TYPE datarecord_leyenda IS RECORD (
        id_cia  planilla_concepto_leyenda.id_cia%TYPE,
        numpla  planilla_concepto_leyenda.numpla%TYPE,
        codper  planilla_concepto_leyenda.codper%TYPE,
        codori  planilla_concepto_leyenda.codori%TYPE,
        coddes  planilla_concepto_leyenda.coddes%TYPE,
        tipori  planilla_concepto_leyenda.tipori%TYPE,
        dtipori planilla_concepto_leyenda.dtipori%TYPE,
        nivel   planilla_concepto_leyenda.nivel%TYPE,
        codley  planilla_concepto_leyenda.desley%TYPE,
        desley  planilla_concepto_leyenda.desley%TYPE,
        valcon  planilla_concepto_leyenda.valcon%TYPE,
        formula planilla_concepto_leyenda.formul%TYPE
    );
    TYPE datatable_leyenda IS
        TABLE OF datarecord_leyenda;
    PROCEDURE sp_insgen (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codori   IN VARCHAR2,
        pin_coddes   IN VARCHAR2,
        pin_tipori   IN VARCHAR2,
        pin_nivel    IN NUMBER,
        pin_formula  IN OUT VARCHAR2,
        pout_formula IN OUT VARCHAR2,
        pin_valor    IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_nivel  NUMBER
    ) RETURN datatable_leyenda
        PIPELINED;

END;

/
