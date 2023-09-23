--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_RANGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_RANGO" AS
    TYPE datarecord_reporte IS RECORD (
        id_cia      INTEGER,
        numpla      INTEGER,
        id_planilla VARCHAR2(20 CHAR),
        tiptra      VARCHAR2(1 CHAR),
        destiptra   tipo_trabajador.nombre%TYPE,
        codper      personal.codper%TYPE,
        nomper      VARCHAR(125),
        codcon      concepto.codcon%TYPE,
        descon      concepto.nombre%TYPE,
        item        planilla_rango.item%TYPE,
        periodo     NUMBER,
        mes         VARCHAR2(20 CHAR),
        finicio     DATE,
        ffinal      DATE,
        dias        INTEGER,
        clase       planilla_rango.clase%TYPE,
        desclase    clase_personal.descri%TYPE,
        codigo      planilla_rango.codigo%TYPE,
        descodigo   clase_codigo_personal.descri%TYPE,
        refere      planilla_rango.refere%TYPE
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_planilla_rango IS RECORD (
        id_cia    planilla_rango.id_cia%TYPE,
        numpla    planilla_rango.numpla%TYPE,
        despla    VARCHAR2(500),
        codper    planilla_rango.codper%TYPE,
        nomper    VARCHAR2(500),
        codcon    planilla_rango.codcon%TYPE,
        descon    concepto.nombre%TYPE,
        item      planilla_rango.item%TYPE,
        finicio   planilla_rango.finicio%TYPE,
        ffinal    planilla_rango.ffinal%TYPE,
        dias      planilla_rango.dias%TYPE,
        clase     planilla_rango.clase%TYPE,
        desclase  clase_personal.descri%TYPE,
        codigo    planilla_rango.codigo%TYPE,
        descodigo clase_codigo_personal.descri%TYPE,
        refere    planilla_rango.refere%TYPE,
        ucreac    planilla_rango.ucreac%TYPE,
        uactua    planilla_rango.uactua%TYPE,
        fcreac    planilla_rango.factua%TYPE,
        factua    planilla_rango.factua%TYPE
    );
    TYPE datatable_planilla_rango IS
        TABLE OF datarecord_planilla_rango;
    TYPE datarecord_concepto IS RECORD (
        id_cia planilla_rango.id_cia%TYPE,
        codcon concepto.codcon%TYPE,
        descon concepto.nombre%TYPE,
        filtro concepto_clase.codigo%TYPE,
        clase  clase_personal.clase%TYPE,
        descla clase_personal.descri%TYPE
    );
    TYPE datatable_concepto IS
        TABLE OF datarecord_concepto;
    TYPE datarecord_motivo IS RECORD (
        id_cia   planilla_rango.id_cia%TYPE,
        codmot   motivo_planilla.codmot%TYPE,
        desmot   motivo_planilla.descri%TYPE,
        codsunat motivo_planilla.codrel%TYPE
    );
    TYPE datatable_motivo IS
        TABLE OF datarecord_motivo;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_planilla_rango
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_planilla_rango
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mdesde  NUMBER,
        pin_mhasta  NUMBER,
        pin_codper  VARCHAR2,
        pin_codcon  VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED;

    FUNCTION sp_motivo (
        pin_id_cia NUMBER,
        pin_tipo   VARCHAR2
    ) RETURN datatable_motivo
        PIPELINED;

END;

/
