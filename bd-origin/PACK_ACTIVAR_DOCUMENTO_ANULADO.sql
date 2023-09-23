--------------------------------------------------------
--  DDL for Package PACK_ACTIVAR_DOCUMENTO_ANULADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ACTIVAR_DOCUMENTO_ANULADO" AS
    PROCEDURE comprobante_electronico ( 
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE guia_remision (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
