--------------------------------------------------------
--  DDL for Package PACK_TCCOSTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TCCOSTOS" AS
    TYPE t_tccostos IS
        TABLE OF tccostos%rowtype;
    FUNCTION sp_sel_tccostos (
        pin_id_cia IN NUMBER
    ) RETURN t_tccostos
        PIPELINED;

    PROCEDURE sp_save_tccostos (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
