--------------------------------------------------------
--  DDL for Package PACK_HR_ASISTENCIA_PLANILLA_TURNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA_TURNO" AS
    TYPE datarecord_asistencia_planilla_turno IS RECORD (
        id_cia    asistencia_planilla_turno.id_cia%TYPE,
        id_turno  asistencia_planilla_turno.id_turno%TYPE,
        tiptra    asistencia_planilla_turno.tiptra%TYPE,
        destiptra VARCHAR2(20),
        desturn   asistencia_planilla_turno.desturn%TYPE,
--        hingtur   asistencia_planilla_turno.hingtur%TYPE,
--        hsaltur   asistencia_planilla_turno.hsaltur%TYPE,
        hingtur VARCHAR2(20),
        hsaltur VARCHAR2(20),
        mintur    asistencia_planilla_turno.mintur%TYPE,
        toletur   asistencia_planilla_turno.toletur%TYPE,
        incref    asistencia_planilla_turno.incref%TYPE,
--        hincref   asistencia_planilla_turno.hingref%TYPE,
--        hsalref   asistencia_planilla_turno.hsalref%TYPE,
        hingref VARCHAR2(20),
        hsalref VARCHAR2(20),
        minref    asistencia_planilla_turno.minref%TYPE,
        toleref   asistencia_planilla_turno.toleref%TYPE,
        dia       asistencia_planilla_turno.dia%TYPE,
        extra     asistencia_planilla_turno.extra%TYPE,
        tipoasig  asistencia_planilla_turno.tipoasig%TYPE,
        ucreac    asistencia_planilla_turno.ucreac%TYPE,
        uactua    asistencia_planilla_turno.uactua%TYPE,
        fcreac    asistencia_planilla_turno.fcreac%TYPE,
        factua    asistencia_planilla_turno.factua%TYPE
    );
    TYPE datatable_asistencia_planilla_turno IS
        TABLE OF datarecord_asistencia_planilla_turno;
    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_id_turno NUMBER
    ) RETURN datatable_asistencia_planilla_turno
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN datatable_asistencia_planilla_turno
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
