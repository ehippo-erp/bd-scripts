--------------------------------------------------------
--  DDL for Package PACK_NACIONALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_NACIONALIDAD" AS
    TYPE t_nacionalidad IS
        TABLE OF nacionalidad%rowtype;
    FUNCTION sp_sel_nacionalidad (
        pin_id_cia  IN  NUMBER,
        pin_codnac  IN  VARCHAR2,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_nacionalidad
        PIPELINED;

    PROCEDURE sp_save_nacionalidad (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
