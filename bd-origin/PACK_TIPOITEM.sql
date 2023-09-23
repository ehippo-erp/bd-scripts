--------------------------------------------------------
--  DDL for Package PACK_TIPOITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TIPOITEM" AS
    TYPE t_tipoitem IS
        TABLE OF tipoitem%rowtype;
    FUNCTION sp_sel_tipoitem (
        pin_id_cia  IN  NUMBER,
        pin_codtip  IN  VARCHAR2,		
        pin_codite  IN  NUMBER,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_tipoitem
        PIPELINED;

    PROCEDURE sp_save_tipoitem (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
