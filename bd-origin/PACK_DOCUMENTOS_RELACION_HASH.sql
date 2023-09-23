--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_RELACION_HASH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_RELACION_HASH" AS
    TYPE t_documentos_relacion_hash IS
        TABLE OF documentos_relacion_hash%rowtype;
    FUNCTION sp_sel_documentos_relacion_hash (
        pin_id_cia IN NUMBER
    ) RETURN t_documentos_relacion_hash
        PIPELINED;

    PROCEDURE sp_save_documentos_relacion_hash (
        pin_id_cia    IN    NUMBER,
        pin_datos     IN    VARCHAR2,
        pin_opcdml    INTEGER,
        pin_mensaje   OUT   VARCHAR2
    );

END;


/
