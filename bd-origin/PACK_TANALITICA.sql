--------------------------------------------------------
--  DDL for Package PACK_TANALITICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TANALITICA" AS
    TYPE t_tanalitica IS
        TABLE OF tanalitica%rowtype;
    FUNCTION sp_sel_tanalitica (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  CHAR
    ) RETURN t_tanalitica
        PIPELINED;

    PROCEDURE sp_save_tanalitica (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
