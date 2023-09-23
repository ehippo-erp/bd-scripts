--------------------------------------------------------
--  DDL for Package PACK_HR_CONCEPTO_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CONCEPTO_FORMULA" AS
    TYPE datarecord_concepto_formula IS RECORD (
        id_cia concepto_formula.id_cia%TYPE,
        codcon concepto_formula.codcon%TYPE,
        descon concepto.nombre%TYPE,
        tiptra concepto_formula.tiptra%TYPE,
        destra concepto.nombre%TYPE,
        tippla concepto_formula.tippla%TYPE,
        despla concepto.nombre%TYPE,
        formul concepto_formula.formul%TYPE,
        swacti concepto_formula.swacti%TYPE,
        codcta concepto_formula.codcta%TYPE,
        descta pcuentas.nombre%TYPE,
        ctagasto concepto_formula.ctagasto%TYPE,
        desgasto pcuentas.nombre%TYPE,
        ucreac concepto_formula.ucreac%TYPE,
        uactua concepto_formula.uactua%TYPE,
        fcreac concepto_formula.fcreac%TYPE,
        factua concepto_formula.factua%TYPE
    );
    TYPE datatable_concepto_formula IS
        TABLE OF datarecord_concepto_formula;
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
    TYPE datarecord_leyenda_concepto IS RECORD (
        codley planilla_concepto_leyenda.desley%TYPE,
        desley planilla_concepto_leyenda.desley%TYPE,
        formul planilla_concepto_leyenda.formul%TYPE
    );
    TYPE datatable_leyenda_concepto IS
        TABLE OF datarecord_leyenda_concepto;
    FUNCTION sp_leyenda_concepto (
        pin_id_cia NUMBER,
        pin_tipcon VARCHAR2 --  F ( CONCEPTO FIJO ) , C ( CONCEPTO CALCULADO ), V ( CONCEPTO VARIABLE ), S ( CONCEPTO DE SISTEMA), P (CONCEPTO DE PRESTAMO)  , FT ( FACTOR ), SS ( FORMULA DEL SISTEMA )  
    ) RETURN datatable_leyenda_concepto
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_leyenda
        PIPELINED;

    PROCEDURE sp_refrescar (
        pin_id_cia  NUMBER,
        pin_codcon  VARCHAR2,
        pin_tiptra  VARCHAR2,
        pin_tippla  VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_sintaxis (
        pin_id_cia   IN NUMBER,
        pin_codcon   IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    FUNCTION sp_ayuda (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
