--------------------------------------------------------
--  DDL for Package PACK_CUENTAS_POR_LIBROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CUENTAS_POR_LIBROS" AS
--Plan de cuentas
    TYPE r_pcuentas IS RECORD (
        id_cia  pcuentas.id_cia%TYPE,
        cuenta  pcuentas.cuenta%TYPE,
        nombre  pcuentas.nombre%TYPE
    );
    TYPE t_pcuentas IS
        TABLE OF r_pcuentas;
    FUNCTION sp_sel_pcuentas (
        pin_id_cia IN NUMBER
    ) RETURN t_pcuentas
        PIPELINED;       

--Cuentas_CChica        

    TYPE t_cuentas_cchica IS
        TABLE OF cuentas_cchica%rowtype;
    FUNCTION sp_sel_cuentas_cchica (
        pin_id_cia  IN  NUMBER,
        pin_motivo  IN  NUMBER
    ) RETURN t_cuentas_cchica
        PIPELINED;

    PROCEDURE sp_save_cuentas_cchica (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

    PROCEDURE sp_ins_masivo_cuentas_cchica (
        pin_id_cia  IN  NUMBER,
        pin_datos   IN  CLOB
    );

END;

/
