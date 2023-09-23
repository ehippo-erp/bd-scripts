--------------------------------------------------------
--  DDL for Package PACK_M_DESTINO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_M_DESTINO" AS
    TYPE t_m_destino IS
        TABLE OF m_destino%rowtype;
    FUNCTION sp_sel_m_destino (
        pin_id_cia IN NUMBER
    ) RETURN t_m_destino
        PIPELINED;

    PROCEDURE sp_save_m_destino (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
