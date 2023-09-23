--------------------------------------------------------
--  DDL for Package PACK_SCRIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_SCRIPT" AS
    PROCEDURE sp_despues_migrar (
        pin_id_cia    IN NUMBER,
        pin_id_modelo IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    );

END;

/
