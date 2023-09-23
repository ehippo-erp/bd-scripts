--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_DET" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    TYPE t_docdet IS
        TABLE OF documentos_det%rowtype;
    PROCEDURE sp_save (
        pin_id_cia       IN NUMBER,
        pin_datos        IN VARCHAR2,
        pin_opcdml       INTEGER,
        pin_responsecode OUT NUMBER,
        pin_response     OUT VARCHAR2
    );

END pack_documentos_det;

/
