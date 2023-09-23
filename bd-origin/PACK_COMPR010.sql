--------------------------------------------------------
--  DDL for Package PACK_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_COMPR010" AS
    PROCEDURE sp_actualiza_ddetrac (
        pin_id_cia  IN NUMBER,
        pin_datos    IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
