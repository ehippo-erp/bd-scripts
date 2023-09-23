--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_PLAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_PLAME" AS
    TYPE datarecord_ingtrides IS RECORD (
        id_cia      planilla.id_cia%TYPE,
        titulo      VARCHAR2(100),
        coddid      clase_codigo_personal.abrevi%TYPE,
        coddidsunat clase_codigo_personal.codigo%TYPE,
        desdid      personal_documento.nrodoc%TYPE,
        codper      personal.codper%TYPE,
        nomper      VARCHAR2(500 CHAR),
        codcon      concepto.codcon%TYPE,
        codconsunat concepto.codpdt%TYPE,
        descon      concepto.nombre%TYPE,
        mondev      NUMBER(16, 2),
        monpag      NUMBER(16, 2)
    );
    TYPE datatable_ingtrides IS
        TABLE OF datarecord_ingtrides;
    TYPE datarecord_ingtrides_detalle IS RECORD (
        id_cia      planilla.id_cia%TYPE,
        coddid      clase_codigo_personal.abrevi%TYPE,
        coddidsunat clase_codigo_personal.codigo%TYPE,
        desdid      personal_documento.nrodoc%TYPE,
        codper      personal.codper%TYPE,
        nomper      VARCHAR2(500 CHAR),
        ingdes      VARCHAR2(1 CHAR),
        codcon      concepto.codcon%TYPE,
        codconsunat concepto.codpdt%TYPE,
        descon      concepto.nombre%TYPE,
        mondev      NUMBER(16, 2),
        monpag      NUMBER(16, 2)
    );
    TYPE datatable_ingtrides_detalle IS
        TABLE OF datarecord_ingtrides_detalle;
    TYPE datarecord_diajorlab IS RECORD (
        id_cia      planilla.id_cia%TYPE,
        titulo      VARCHAR2(100),
        coddid      clase_codigo_personal.abrevi%TYPE,
        coddidsunat clase_codigo_personal.codigo%TYPE,
        desdid      personal_documento.nrodoc%TYPE,
        codper      personal.codper%TYPE,
        apepat      personal.apepat%TYPE,
        apemat      personal.apemat%TYPE,
        nombre      personal.nombre%TYPE,
        nomper      VARCHAR2(500 CHAR),
        diaslab     NUMBER(16, 2),
        hrosord     NUMBER(16, 2),
        minsord     NUMBER(16, 2),
        hrosext     NUMBER(16, 2),
        minsext     NUMBER(16, 2)
    );
    TYPE datatable_diajorlab IS
        TABLE OF datarecord_diajorlab;
    TYPE datarecord_detalle_dias IS RECORD (
        diaslab   NUMBER(16, 2),
        diasnolab NUMBER(16, 2),
        hrosord   NUMBER(16, 2),
        minsord   NUMBER(16, 2),
        hrosext   NUMBER(16, 2),
        minsext   NUMBER(16, 2)
    );
    TYPE datatable_detalle_dias IS
        TABLE OF datarecord_detalle_dias;
    TYPE datarecord_diasubnolab IS RECORD (
        id_cia      planilla.id_cia%TYPE,
        titulo      VARCHAR2(100),
        coddid      clase_codigo_personal.abrevi%TYPE,
        coddidsunat clase_codigo_personal.codigo%TYPE,
        desdid      personal_documento.nrodoc%TYPE,
        codper      personal.codper%TYPE,
        nomper      VARCHAR2(500 CHAR),
        fincio      DATE,
        ffinal      DATE,
        dias        NUMBER,
        codigo      planilla_rango.codigo%TYPE,
        descodigo   motivo_planilla.descri%TYPE
    );
    TYPE datatable_diasubnolab IS
        TABLE OF datarecord_diasubnolab;

--    SELECT * FROM  pack_hr_planilla_plame.sp_diajorlab(66,'E',2022,09);

--    SELECT * FROM  pack_hr_planilla_plame.sp_diasubnolab(66,'E',2022,09);

    FUNCTION sp_concepto_tiptra (
        pin_id_cia NUMBER,
        pin_codfac VARCHAR2,
        pin_tiptra VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION sp_ingtrides (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_ingtrides
        PIPELINED;

    FUNCTION sp_ingtrides_txt (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_ingtrides
        PIPELINED;

    FUNCTION sp_ingtrides_detalle (
        pin_id_cia    NUMBER,
        pin_empobr    VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_numpla    NUMBER,
        pin_provicion NUMBER
    ) RETURN datatable_ingtrides_detalle
        PIPELINED;

    FUNCTION sp_diajorlab (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_diajorlab
        PIPELINED;

    FUNCTION sp_diasubnolab (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_diasubnolab
        PIPELINED;

    FUNCTION sp_detalle_dias (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_dias
        PIPELINED;

END;

/
