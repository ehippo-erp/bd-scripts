--------------------------------------------------------
--  DDL for Package PACK_NOTIFICACION_PROGRAMADA_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_NOTIFICACION_PROGRAMADA_ADJUNTO" AS
    TYPE datarecord_notificacion_programada_adjunto IS RECORD (
        id_cia  notificacion_programada_adjunto.id_cia%TYPE,
        numint  notificacion_programada_adjunto.numint%TYPE,
        titulo  notificacion_programada.titulo%TYPE,
        numite  notificacion_programada_adjunto.numite%TYPE,
        nombre  notificacion_programada_adjunto.nombre%TYPE,
        formato notificacion_programada_adjunto.formato%TYPE,
        archivo notificacion_programada_adjunto.archivo%TYPE,
        ucreac  notificacion_programada_adjunto.ucreac%TYPE,
        uactua  notificacion_programada_adjunto.uactua%TYPE,
        fcreac  notificacion_programada_adjunto.factua%TYPE,
        factua  notificacion_programada_adjunto.factua%TYPE
    );
    TYPE datatable_notificacion_programada_adjunto IS
        TABLE OF datarecord_notificacion_programada_adjunto;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_notificacion_programada_adjunto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_nombre VARCHAR2
    ) RETURN datatable_notificacion_programada_adjunto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
