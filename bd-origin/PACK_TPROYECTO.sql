--------------------------------------------------------
--  DDL for Package PACK_TPROYECTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TPROYECTO" AS
    TYPE t_tproyecto IS
        TABLE OF tproyecto%rowtype;
    FUNCTION sp_sel_tproyecto (
        pin_id_cia IN NUMBER
    ) RETURN t_tproyecto
        PIPELINED;

    PROCEDURE sp_save_tproyecto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
