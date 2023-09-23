--------------------------------------------------------
--  DDL for Package PACK_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TIPO" AS
    TYPE t_tipo IS
        TABLE OF tipo%rowtype;
    FUNCTION sp_sel_tipo (
        pin_id_cia  IN  NUMBER,
        pin_codtip  IN  VARCHAR2,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_tipo
        PIPELINED;

    PROCEDURE sp_save_tipo (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
