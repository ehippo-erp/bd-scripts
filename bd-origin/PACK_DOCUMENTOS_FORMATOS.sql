--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_FORMATOS" AS
    TYPE documentoformatodatarecord IS RECORD (
        tipdoc    NUMBER,
        item      NUMBER,
        descri    VARCHAR2(100 BYTE),
        formato   VARCHAR2(100 BYTE),
        activo   VARCHAR2(100)
    );
    TYPE documentoformatodatatable IS
        TABLE OF documentoformatodatarecord;
    TYPE t_documento_formato IS
        TABLE OF documentos_formatos%rowtype;
    FUNCTION sp_sel_documentos_formatos (
        pin_tipdoc   IN   NUMBER,
        pin_item     IN   NUMBER,
        pin_activo     IN   VARCHAR2
    ) RETURN documentoformatodatatable
        PIPELINED;

    PROCEDURE sp_save_documentos_formatos (
        pin_datos     IN    VARCHAR2,
        pin_opcdml    INTEGER,
        pin_mensaje   OUT   VARCHAR2
    );

END;

/
