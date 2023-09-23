--------------------------------------------------------
--  DDL for Package PACK_OPERACIONES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_OPERACIONES" AS
    TYPE t_operaciones IS
        TABLE OF tbancos%rowtype;
    FUNCTION sp_sel_operaciones (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  CHAR
    ) RETURN t_operaciones
        PIPELINED;

    PROCEDURE sp_save_operaciones (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );
---TBANCOS_CLASE

    TYPE r_tbancos_clase IS RECORD (
        id_cia       tbancos_clase.id_cia%TYPE,
        codban       tbancos_clase.codban%TYPE,
        clase        tbancos_clase.clase%TYPE,
        desclase     VARCHAR2(80),
        codigo       tbancos_clase.codigo%TYPE,
        descodigo    VARCHAR2(80),
        vreal        tbancos_clase.vreal%TYPE,
        vstrg        tbancos_clase.vstrg%TYPE,
        vchar        tbancos_clase.vchar%TYPE,
        vdate        tbancos_clase.vdate%TYPE,
        vtime        tbancos_clase.vtime%TYPE,
        ventero      tbancos_clase.ventero%TYPE,
        codusercrea  tbancos_clase.codusercrea%TYPE,
        coduseractu  tbancos_clase.coduseractu%TYPE,
        fcreac       tbancos_clase.fcreac%TYPE,
        factua       tbancos_clase.factua%TYPE
    );
    TYPE t_tbancos_clase IS
        TABLE OF r_tbancos_clase;
    FUNCTION sp_sel_tbancos_clase (
        pin_id_cia  IN  NUMBER,
        pin_codban  IN  VARCHAR2
    ) RETURN t_tbancos_clase
        PIPELINED;

    PROCEDURE sp_save_tbancos_clase (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
