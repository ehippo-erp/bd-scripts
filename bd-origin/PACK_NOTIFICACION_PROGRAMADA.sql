--------------------------------------------------------
--  DDL for Package PACK_NOTIFICACION_PROGRAMADA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_NOTIFICACION_PROGRAMADA" AS
    TYPE datarecord_notificacion_programada IS RECORD (
        id_cia      notificacion_programada.id_cia%TYPE,
        numint      notificacion_programada.numint%TYPE,
        titulo      notificacion_programada.titulo%TYPE,
        sqlnot      notificacion_programada.sqlnot%TYPE,
        emails      notificacion_programada.emails%TYPE,
        head_html   notificacion_programada.head_html%TYPE,
        footer_html notificacion_programada.footer_html%TYPE,
        swacti      notificacion_programada.swacti%TYPE,
        ucreac      notificacion_programada.ucreac%TYPE,
        uactua      notificacion_programada.uactua%TYPE,
        fcreac      notificacion_programada.factua%TYPE,
        factua      notificacion_programada.factua%TYPE
    );
    TYPE datatable_notificacion_programada IS
        TABLE OF datarecord_notificacion_programada;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notificacion_programada
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_titulo VARCHAR2,
        pin_swacti VARCHAR2
    ) RETURN datatable_notificacion_programada
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia      IN NUMBER,
        pin_sqlnot      IN BLOB,
        pin_head_html   IN BLOB,
        pin_footer_html IN BLOB,
        pin_datos       IN VARCHAR2,
        pin_opcdml      IN INTEGER,
        pin_mensaje     OUT VARCHAR2
    );

END;

/
