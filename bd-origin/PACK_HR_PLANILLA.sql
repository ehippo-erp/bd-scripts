--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA" AS
    TYPE datarecord_planilla IS RECORD (
        id_cia      planilla.id_cia%TYPE,
        numpla      planilla.numpla%TYPE,
        id_planilla VARCHAR2(100),
        tippla      planilla.tippla%TYPE,
        destippla   tipoplanilla.nombre%TYPE,
        empobr      planilla.empobr%TYPE,
        desempobr   tipo_trabajador.nombre%TYPE,
        anopla      planilla.anopla%TYPE,
        mespla      planilla.mespla%TYPE,
        sempla      planilla.sempla%TYPE,
        fecini      planilla.fecini%TYPE,
        fecfin      planilla.fecfin%TYPE,
        dianor      planilla.dianor%TYPE,
        hornor      planilla.hornor%TYPE,
        tcambio     planilla.tcambio%TYPE,
        situac      planilla.situac%TYPE,
        dessituac   VARCHAR2(100),
        ucreac      planilla.ucreac%TYPE,
        uactua      planilla.uactua%TYPE,
        fcreac      planilla.fcreac%TYPE,
        factua      planilla.factua%TYPE
    );
    TYPE datatable_planilla IS
        TABLE OF datarecord_planilla;
    TYPE datarecord_autocompletar IS RECORD (
        fdesde  DATE,
        fhasta  DATE,
        semana  NUMBER,
        dias    NUMBER,
        horas   NUMBER,
        mensaje VARCHAR2(250)
    );
    TYPE datatable_autocompletar IS
        TABLE OF datarecord_autocompletar;
    TYPE datarecord_personal_incluido IS RECORD (
        id_cia   personal.id_cia%TYPE,
        id_planilla VARCHAR2(100),
        codper   personal.codper%TYPE,
        nomper   VARCHAR2(500),
        situac   personal.situac%TYPE,
        desituac situacion_personal.nombre%TYPE,
        finicio  DATE,
        ffinal   DATE
    );
    TYPE datatable_personal_incluido IS
        TABLE OF datarecord_personal_incluido;
    TYPE datarecord_periodolaboral IS RECORD (
        id_cia    personal.id_cia%TYPE,
        codper    personal.codper%TYPE,
        nomper    VARCHAR2(500),
        tiptra    personal.tiptra%TYPE,
        situac    personal.situac%TYPE,
        id_plab   personal_periodolaboral.id_plab%TYPE,
        finicio   personal_periodolaboral.finicio%TYPE,
        ffinal    personal_periodolaboral.ffinal%TYPE,
        diatratot NUMBER,
        diatrames NUMBER
    );
    TYPE datatable_periodolaboral IS
        TABLE OF datarecord_periodolaboral;
    TYPE r_errores IS RECORD (
        orden    NUMBER,
        concepto VARCHAR2(250),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_planilla
        PIPELINED;

    FUNCTION sp_autocompletar (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_autocompletar
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_situac VARCHAR2
    ) RETURN datatable_planilla
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_generar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_refrescar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_datos  CLOB
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_valida_objeto_ordenado (
        pin_id_cia  NUMBER,
        pin_datos   CLOB,
        pin_orderby NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_periodolaboral (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_periodolaboral
        PIPELINED;

    FUNCTION sp_personal_incluido (
        pin_id_cia NUMBER,
        pin_datos  CLOB
    ) RETURN datatable_personal_incluido
        PIPELINED;

    PROCEDURE sp_planilla_cerrada (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
