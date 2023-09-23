--------------------------------------------------------
--  DDL for Package PACK_HR_ASISTENCIA_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA" AS
    TYPE datarecord_asistencia_planilla IS RECORD (
        id_cia    asistencia_planilla.id_cia%TYPE,
        codasist  asistencia_planilla.codasist%TYPE,
        codsuc    asistencia_planilla.codsuc%TYPE,
        dessuc    VARCHAR2(120),
        codper    asistencia_planilla.codper%TYPE,
        nomper    VARCHAR2(500),
        fecha     asistencia_planilla.fecha%TYPE,
--        hora      asistencia_planilla.hora%TYPE,
        hora      VARCHAR2(20),
        fregis    asistencia_planilla.fregis%TYPE,
        tipo      asistencia_planilla.tipo%TYPE,
        destipo   VARCHAR2(20),
        codmot    asistencia_planilla.codmot%TYPE,
        desmot    motivo_planilla.descri%TYPE,
        id_tuno   asistencia_planilla.id_turno%TYPE,
        desturn   asistencia_planilla_turno.desturn%TYPE,
        flagmarca asistencia_planilla.flagmarca%TYPE,
        desmarca  VARCHAR2(20),
        situac    asistencia_planilla.situac%TYPE,
        direcc    asistencia_planilla.direcc%TYPE,
        latitud   asistencia_planilla.latitud%TYPE,
        longitud  asistencia_planilla.longitud%TYPE,
        ucreac    asistencia_planilla.ucreac%TYPE,
        uactua    asistencia_planilla.uactua%TYPE,
        fcreac    asistencia_planilla.fcreac%TYPE,
        factua    asistencia_planilla.factua%TYPE
    );
    TYPE datatable_asistencia_planilla IS
        TABLE OF datarecord_asistencia_planilla;

    TYPE datarecord_turno IS RECORD (
        id_cia   asistencia_planilla_turno.id_cia%TYPE,
        id_turno asistencia_planilla_turno.id_turno%TYPE,
        desturn  asistencia_planilla_turno.desturn%TYPE
    );
    TYPE datatable_turno IS
        TABLE OF datarecord_turno;
    TYPE datarecord_reporte IS RECORD (
        id_cia    asistencia.id_cia%TYPE,
        mes       VARCHAR2(25),
        diasemana VARCHAR2(25),
        fecha     tiempo.fecha%TYPE,
        codper    personal.codper%TYPE,
        nombres   VARCHAR2(500),
        nrodoc    personal_documento.nrodoc%TYPE,
        desdoc    clase_codigo_personal.descri%TYPE,
        codcar    personal.codcar%TYPE,--
        descar    cargo.nombre%TYPE,
        desmot    motivo_planilla.descri%TYPE,
        desturn   asistencia_planilla_turno.desturn%TYPE,
        hortur    NUMBER(16, 4),
        horref    NUMBER(16, 4),
        uentrada  personal.codper%TYPE,
        fentrada   VARCHAR2(100),
        usalida   personal.codper%TYPE,
        fsalida    VARCHAR2(100),
        rentrada  VARCHAR2(100),
        rsalida    VARCHAR2(100),
        hextra    VARCHAR2(20),
        dextra    NUMBER(16, 4)
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;

    FUNCTION sp_reporte_mref (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN NUMBER;

        FUNCTION sp_reporte_mtur (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN NUMBER;

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codasist NUMBER
    ) RETURN datatable_asistencia_planilla
        PIPELINED;

    FUNCTION sp_turno (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_turno
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codsuc NUMBER,
        pin_codmot NUMBER,
        pin_tiptra VARCHAR2,
        pin_codper VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_asistencia_planilla
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
