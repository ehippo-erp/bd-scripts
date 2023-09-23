--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_RESUMEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_RESUMEN" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia planilla_resumen.id_cia%TYPE,
        numpla planilla_resumen.numpla%TYPE,
        codper planilla_resumen.codper%TYPE,
        nomper VARCHAR2(500),
        diatra planilla_resumen.diatra%TYPE,
        hortra planilla_resumen.hortra%TYPE,
        toting planilla_resumen.toting%TYPE,
        totdsc planilla_resumen.totdsc%TYPE,
        totapt planilla_resumen.totapt%TYPE,
        totape planilla_resumen.totape%TYPE,
        totnet planilla_resumen.totnet%TYPE,
        ucreac planilla_resumen.ucreac%TYPE,
        uactua planilla_resumen.uactua%TYPE,
        fcreac planilla_resumen.fcreac%TYPE,
        factua planilla_resumen.factua%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE datarecord_reporte IS RECORD (
        id_cia      planilla_resumen.id_cia%TYPE,
        numpla      planilla_resumen.numpla%TYPE,
        id_planilla VARCHAR2(100),
        tippla      planilla.tippla%TYPE,
        destippla   tipoplanilla.nombre%TYPE,
        empobr      planilla.empobr%TYPE,
        desempobr   tipo_trabajador.nombre%TYPE,
        mespla      NUMBER,
        desmes      VARCHAR2(100),
        anopla      NUMBER,
        codper      planilla_resumen.codper%TYPE,
        nomper      VARCHAR2(500),
        toting      planilla_resumen.toting%TYPE,
        totdsc      planilla_resumen.totdsc%TYPE,
        totape      planilla_resumen.totape%TYPE,
        totnet      planilla_resumen.totnet%TYPE
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    TYPE datarecord_reporte_concepto IS RECORD (
        id_cia      planilla_resumen.id_cia%TYPE,
        numpla      planilla_resumen.numpla%TYPE,
        id_planilla VARCHAR2(100),
        tippla      planilla.tippla%TYPE,
        destippla   tipoplanilla.nombre%TYPE,
        empobr      planilla.empobr%TYPE,
        desempobr   tipo_trabajador.nombre%TYPE,
        mespla      NUMBER,
        desmes      VARCHAR2(100),
        anopla      NUMBER,
        ingdes      concepto.ingdes%TYPE,
        dingdes     VARCHAR2(100),
        codcon      concepto.codcon%TYPE,
        descon      concepto.nombre%TYPE,
        valcon      planilla_concepto.valcon%TYPE
    );
    TYPE datatable_reporte_concepto IS
        TABLE OF datarecord_reporte_concepto;
    TYPE datarecord_reporte_afp IS RECORD (
        id_cia      planilla_resumen.id_cia%TYPE,
        numpla      planilla_resumen.numpla%TYPE,
        id_planilla VARCHAR2(100),
        tippla      planilla.tippla%TYPE,
        destippla   tipoplanilla.nombre%TYPE,
        empobr      planilla.empobr%TYPE,
        desempobr   tipo_trabajador.nombre%TYPE,
        mespla      NUMBER,
        desmes      VARCHAR2(100),
        anopla      NUMBER,
        codafp      afp.codafp%TYPE,
        desafp      afp.nombre%TYPE,
        posimp      concepto.posimp%TYPE,
        nomimp      concepto.nomimp%TYPE,
        codper      planilla_resumen.codper%TYPE,
        nomper      VARCHAR2(500),
        valcon      planilla_concepto.valcon%TYPE
    );
    TYPE datatable_reporte_afp IS
        TABLE OF datarecord_reporte_afp;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_reporte_planilla (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_reporte_planilla_concepto (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_concepto
        PIPELINED;

    FUNCTION sp_reporte_planilla_afp (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_afp
        PIPELINED;

    FUNCTION sp_reporte_consolidado (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_reporte_consolidado_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_concepto
        PIPELINED;

    FUNCTION sp_reporte_consolidado_afp (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_afp
        PIPELINED;

    PROCEDURE sp_updgen (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
