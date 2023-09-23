--------------------------------------------------------
--  DDL for Package PACK_ASISTENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ASISTENCIA" AS
    TYPE datarecord_asistencia IS RECORD (
        codasist  asistencia.codasist%TYPE,
        coduser   asistencia.usuari%TYPE,
        codsuc asistencia.codsuc%TYPE,
        dessuc VARCHAR2(1000),
        direccion asistencia.direccion%TYPE,
        latitud   asistencia.latitud%TYPE,
        longitug  asistencia.longitud%TYPE,
        fcreac    asistencia.fcreac%TYPE,
        codturno  asistencia.codturno%TYPE,
        nombres   usuarios.nombres%TYPE,
        descturno turno_asistencia.descri%TYPE
    );
    TYPE datatable_asistencia IS
        TABLE OF datarecord_asistencia;
    TYPE datarecord_reporte IS RECORD (
        id_cia    asistencia.id_cia%TYPE,
        mes       VARCHAR2(25),
        diasemana VARCHAR2(25),
        fecha     tiempo.fecha%TYPE,
        codper  usuarios.coduser%TYPE,
        nombres   VARCHAR2(500),
        nrodoc    personal_documento.nrodoc%TYPE,
        desdoc    clase_codigo_personal.descri%TYPE,
        codcar    personal.codcar%TYPE,--
        descar    VARCHAR2(500),
        desmot    motivo_planilla.descri%TYPE,
        desturn   asistencia_planilla_turno.desturn%TYPE,
        hortur    NUMBER(16, 4),
        horref    NUMBER(16, 4),
        uentrada  asistencia.usuari%TYPE,
        fentrada   VARCHAR2(100),
        usalida   asistencia.usuari%TYPE,
        fsalida    VARCHAR2(100),
        rentrada  VARCHAR2(100),
        rsalida    VARCHAR2(100),
        hextra VARCHAR2(20),
        dextra NUMBER(16, 4)
    );
    TYPE datatable_reporte IS
        TABLE OF datarecord_reporte;
    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codasist NUMBER
    ) RETURN datatable_asistencia
        PIPELINED;

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_reporte
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codtar  NUMBER,
        pin_codturn NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_asistencia
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
