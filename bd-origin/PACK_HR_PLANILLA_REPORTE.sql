--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_REPORTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_REPORTE" AS
    TYPE datarecord_leyenda IS RECORD (
        id_cia NUMBER,
        codper VARCHAR2(20 CHAR),
        codigo VARCHAR2(20 CHAR),
        rotulo VARCHAR2(200 CHAR)
    );
    TYPE datatable_leyenda IS
        TABLE OF datarecord_leyenda;
    TYPE datarecord_personal_concepto IS RECORD (
        id_cia      planilla_resumen.id_cia%TYPE,
        numpla      planilla_resumen.numpla%TYPE,
        id_planilla VARCHAR2(100),
        tiptra      planilla.empobr%TYPE,
        destiptra   tipo_trabajador.nombre%TYPE,
        anopla      NUMBER,
        mespla      NUMBER,
        desmes      VARCHAR2(100),
        codper      personal.codper%TYPE,
        nomper      VARCHAR2(500),
        codcon      concepto.codcon%TYPE,
        descon      concepto.nombre%TYPE,
        valcon      planilla_concepto.valcon%TYPE
    );
    TYPE datatable_personal_concepto IS
        TABLE OF datarecord_personal_concepto;
    TYPE datarecord_descuento_proyectado IS RECORD (
        id_cia    planilla_resumen.id_cia%TYPE,
        tiptra    planilla.empobr%TYPE,
        destiptra tipo_trabajador.nombre%TYPE,
        codper    VARCHAR(20),
        nomper    VARCHAR(250),
        situac    VARCHAR(2),
        dessituac VARCHAR(250),
        id_pre    INTEGER,
        fecpre    TIMESTAMP,
        observ    VARCHAR2(4000 CHAR),
        monpre    NUMERIC(15, 4),
        dscpre    NUMERIC(15, 4),
        salpre    NUMERIC(15, 4),
        valcuo    NUMERIC(15, 4),
        cancuo    INTEGER,
        nrocuo    INTEGER,
        nrocuofal INTEGER,
        candes    NUMERIC(15, 4),
        impdes    NUMERIC(15, 4)
    );
    TYPE datatable_descuento_proyectado IS
        TABLE OF datarecord_descuento_proyectado;
    FUNCTION sp_leyenda_constancia (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_leyenda
        PIPELINED;

    FUNCTION sp_personal_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mdesde NUMBER,
        pin_mhasta NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_personal_concepto
        PIPELINED;

    FUNCTION sp_descuento_proyectado (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_codper  VARCHAR2,
        pin_situacs VARCHAR2
    ) RETURN datatable_descuento_proyectado
        PIPELINED;

END;

/
