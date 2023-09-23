--------------------------------------------------------
--  DDL for Package PACK_HR_AFP_NET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_AFP_NET" AS
    TYPE datarecord_afp_net IS RECORD (
        id_cia                    personal.id_cia%TYPE,
        coddid      clase_codigo_personal.abrevi%TYPE,
        coddidsunat clase_codigo_personal.codigo%TYPE,
        desdid      personal_documento.nrodoc%TYPE,
        codper                    personal.codper%TYPE,
        apepat                    personal.apepat%TYPE,
        apemat                    personal.apemat%TYPE,
        nombre                    personal.nombre%TYPE,
        finicio                   planilla_auxiliar.finicio%TYPE,
        ffinal                    planilla_auxiliar.ffinal%TYPE,
        sueldoneto                personal_concepto.valcon%TYPE,
        sueldobruto               personal_concepto.valcon%TYPE,
        tiptra                    personal.tiptra%TYPE,
        direcc                    personal.direcc%TYPE,
        situac                    personal.situac%TYPE,
        dni                       personal_documento.nrodoc%TYPE,
        cuss                      personal_documento.nrodoc%TYPE,
        codafp                    personal.codafp%TYPE,
        abrafp                    afp.abrevi%TYPE,
        tdafp                     personal_clase.codigo%TYPE,
        esjubinv                  personal_concepto.valcon%TYPE,
        estrabmay65               personal_concepto.valcon%TYPE,
        esjubretfon               personal_concepto.valcon%TYPE,
        esjubconpen               personal_concepto.valcon%TYPE,
        relavig                   VARCHAR2(1 CHAR),
        inicrel                   VARCHAR2(1 CHAR),
        ceserel                   VARCHAR2(1 CHAR),
        exception_apt             VARCHAR2(1 CHAR),
        apt_remaseg             NUMBER,
        apt_voluntario_finprov    NUMBER,
        apt_voluntario_sinfinprov NUMBER,
        apt_voluntario_empleador  NUMBER,
        tipo_trabajo              VARCHAR2(1 CHAR),
        rotulo                    VARCHAR2(1000 CHAR)
    );
    TYPE datatable_afp_net IS
        TABLE OF datarecord_afp_net;
    TYPE datarecord_detalle_relacionlaboral IS RECORD (
        codafp                    afp.codafp%TYPE,
        desafp                    afp.nombre%TYPE,
        abrafp                    afp.abrevi%TYPE,
        situacper                 planilla_auxiliar.situacper%TYPE,
        finicio                   planilla_auxiliar.finicio%TYPE,
        ffinal                    planilla_auxiliar.ffinal%TYPE,
                esjubinv                  personal_concepto.valcon%TYPE,
        estrabmay65               personal_concepto.valcon%TYPE,
        esjubretfon               personal_concepto.valcon%TYPE,
        esjubconpen               personal_concepto.valcon%TYPE,
        perdev                    NUMBER,
        pering                    NUMBER,
        perces                    NUMBER,
        relavig                   VARCHAR2(1 CHAR),
        inicrel                   VARCHAR2(1 CHAR),
        ceserel                   VARCHAR2(1 CHAR),
        finalrel                  VARCHAR2(3 CHAR),
        exception_apt             VARCHAR2(1 CHAR),
        apt_remaseg             NUMBER,
        apt_voluntario_finprov    NUMBER,
        apt_voluntario_sinfinprov NUMBER,
        apt_voluntario_empleador  NUMBER,
        tipo_trabajo              VARCHAR2(1 CHAR),
        rotulo                    VARCHAR2(1000 CHAR)
    );
    TYPE datatable_detalle_relacionlaboral IS
        TABLE OF datarecord_detalle_relacionlaboral;
    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_afp_net
        PIPELINED;

    FUNCTION sp_detalle_relacionlaboral (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_relacionlaboral
        PIPELINED;

END;

/
