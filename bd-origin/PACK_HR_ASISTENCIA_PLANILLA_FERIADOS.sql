--------------------------------------------------------
--  DDL for Package PACK_HR_ASISTENCIA_PLANILLA_FERIADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA_FERIADOS" AS
    TYPE datarecord_asistencia_planilla_feriados IS RECORD (
        id_cia    asistencia_planilla_feriados.id_cia%TYPE,
        periodo   asistencia_planilla_feriados.periodo%TYPE,
        fecha     asistencia_planilla_feriados.fecha%TYPE,
        desfer    asistencia_planilla_feriados.desfer%TYPE,
        fijvar    asistencia_planilla_feriados.fijvar%TYPE,
        desfijvar VARCHAR2(20),
        situac    asistencia_planilla_feriados.situac%TYPE,
        ucreac    asistencia_planilla_feriados.ucreac%TYPE,
        uactua    asistencia_planilla_feriados.uactua%TYPE,
        fcreac    asistencia_planilla_feriados.factua%TYPE,
        factua    asistencia_planilla_feriados.factua%TYPE
    );
    TYPE datatable_asistencia_planilla_feriados IS
        TABLE OF datarecord_asistencia_planilla_feriados;
    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_fecha   DATE
    ) RETURN datatable_asistencia_planilla_feriados
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_asistencia_planilla_feriados
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_replicar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
