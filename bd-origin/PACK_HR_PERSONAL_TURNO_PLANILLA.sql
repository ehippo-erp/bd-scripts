--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_TURNO_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_TURNO_PLANILLA" AS
    TYPE datarecord_personal_turno_planilla IS RECORD (
        id_cia   personal_turno_planilla.id_cia%TYPE,
        codper   personal_turno_planilla.codper%TYPE,
        nomper   VARCHAR2(500),
        id_turno personal_turno_planilla.id_turno%TYPE,
        desturn  asistencia_planilla_turno.desturn%TYPE,
        hingtur  VARCHAR2(20),
        hsaltur  VARCHAR2(20),
        mintur   asistencia_planilla_turno.mintur%TYPE,
        toletur  asistencia_planilla_turno.toletur%TYPE,
        incref   asistencia_planilla_turno.incref%TYPE,
        hingref  VARCHAR2(20),
        hsalref  VARCHAR2(20),
        minref   asistencia_planilla_turno.minref%TYPE,
        toleref  asistencia_planilla_turno.toleref%TYPE,
        dia      asistencia_planilla_turno.dia%TYPE,
        extra    asistencia_planilla_turno.extra%TYPE,
        tipoasig asistencia_planilla_turno.tipoasig%TYPE,
        ucreac   personal_turno_planilla.ucreac%TYPE,
        uactua   personal_turno_planilla.uactua%TYPE,
        fcreac   personal_turno_planilla.fcreac%TYPE,
        factua   personal_turno_planilla.factua%TYPE
    );
    TYPE datatable_personal_turno_planilla IS
        TABLE OF datarecord_personal_turno_planilla;

    TYPE datarecord_exportar IS RECORD(
        id_cia personal.id_cia%TYPE,
        codper personal.codper%TYPE,
        nomper varchar2(500),
        id_turno asistencia_planilla_turno.id_turno%TYPE
    );
    TYPE datatable_exportar IS
        TABLE OF datarecord_exportar;
         TYPE r_errores IS RECORD (
        valor     VARCHAR2(80),
        deserror  VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codper   VARCHAR2,
        pin_id_turno NUMBER
    ) RETURN datatable_personal_turno_planilla
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codper   VARCHAR2,
        pin_id_turno NUMBER
    ) RETURN datatable_personal_turno_planilla
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_exportar (
        pin_id_cia NUMBER,
        pin_codper CLOB
    ) RETURN datatable_exportar
        PIPELINED;

END;

/
