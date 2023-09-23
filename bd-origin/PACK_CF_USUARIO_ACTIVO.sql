--------------------------------------------------------
--  DDL for Package PACK_CF_USUARIO_ACTIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_USUARIO_ACTIVO" AS
    TYPE datatable_usuarios_activos IS
        TABLE OF usuarios_activos%rowtype;
    TYPE datarecord_usuario_activo IS RECORD (
        id_cia  usuarios_activos.id_cia%TYPE,
        id      usuarios_activos.id%TYPE,
        coduser usuarios_activos.coduser%TYPE,
        nombres usuarios.nombres%TYPE,
        ip      usuarios_activos.ip%TYPE,
        codpro  usuarios_activos.codpro%TYPE,
        despro  producto_licencia.despro%TYPE,
        factua  DATE,
        hactua  VARCHAR2(100 CHAR)
    );
    TYPE datatable_usuario_activo IS
        TABLE OF datarecord_usuario_activo;
    TYPE datarecord_alerta IS RECORD (
        id_cia        usuarios_activos.id_cia%TYPE,
        codpro        VARCHAR2(10 CHAR),
        despro        producto_licencia.despro%TYPE,
        connectuser   NUMBER,
        noconnectuser NUMBER,
        totaluser     NUMBER
    );
    TYPE datatable_alerta IS
        TABLE OF datarecord_alerta;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_usuario_activo
        PIPELINED;

    FUNCTION sp_alerta (
        pin_id_cia NUMBER
    ) RETURN datatable_alerta
        PIPELINED;

    FUNCTION sp_alerta_aux (
        pin_id_cia NUMBER,
        pin_codpro VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED;

    PROCEDURE sp_clean (
        pin_id_cia  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_valida (
        pin_id_cia  IN INTEGER,
        pin_codpro  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
