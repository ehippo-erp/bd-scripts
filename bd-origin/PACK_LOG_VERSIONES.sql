--------------------------------------------------------
--  DDL for Package PACK_LOG_VERSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_LOG_VERSIONES" AS
    TYPE datarecord_log_versiones IS RECORD (
        id_log     log_versiones.id_log%TYPE,
        version    log_versiones.version%TYPE,
        deslog     log_versiones.deslog%TYPE,
        titulo     log_versiones.titulo%TYPE,
        notifica   log_versiones.notifica%TYPE,
        observ     log_versiones.observ%TYPE,
        fecha      log_versiones.fecha%TYPE,
        swacti     log_versiones.swacti%TYPE,
        imgnoti    log_versiones.imgnoti%TYPE,
        url_imagen log_versiones.url_imagen%TYPE,
        fdesde     log_versiones.fdesde%TYPE,
        fhasta     log_versiones.fhasta%TYPE,
        ucreac     log_versiones.ucreac%TYPE,
        uactua     log_versiones.uactua%TYPE,
        fcreac     log_versiones.fcreac%TYPE,
        factua     log_versiones.factua%TYPE
    );
    TYPE datatable_log_versiones IS
        TABLE OF datarecord_log_versiones;
    FUNCTION sp_obtener (
        pin_id_log NUMBER
    ) RETURN datatable_log_versiones
        PIPELINED;

    FUNCTION sp_buscar (
        pin_deslog VARCHAR2
    ) RETURN datatable_log_versiones
        PIPELINED;

    FUNCTION sp_notificar (
        pin_fdesde DATE
    ) RETURN datatable_log_versiones
        PIPELINED;

    PROCEDURE sp_save (
        pin_observ  IN BLOB,
        pin_imgnoti IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
