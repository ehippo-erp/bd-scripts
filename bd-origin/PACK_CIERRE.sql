--------------------------------------------------------
--  DDL for Package PACK_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CIERRE" AS
    TYPE r_cierre IS RECORD (
	    id_cia number,
		sistema number,
        periodo  INTEGER,
        cierre00    NUMBER,
        cierre01    NUMBER,
        cierre02    NUMBER,
        cierre03    NUMBER,
        cierre04    NUMBER,
        cierre05     NUMBER,
        cierre06    NUMBER,
        cierre07    NUMBER,
        cierre08    NUMBER,
        cierre09   NUMBER,
        cierre10    NUMBER,
        cierre11    NUMBER,
        cierre12     NUMBER,
        usuario  VARCHAR2(10),
        fcreac   TIMESTAMP,
        factua   TIMESTAMP
    );
    TYPE t_cierre IS
        TABLE OF r_cierre;
    FUNCTION sp_sel_cierre (
        pin_id_cia   IN  NUMBER,
        pin_sistema  IN  NUMBER
    ) RETURN t_cierre
        PIPELINED;

    PROCEDURE sp_save_cierre (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/
