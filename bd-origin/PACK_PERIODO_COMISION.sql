--------------------------------------------------------
--  DDL for Package PACK_PERIODO_COMISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PERIODO_COMISION" AS
    TYPE datarecord_periodo_comision IS RECORD (
        id_cia     periodo_comision.id_cia%TYPE,
        id_periodo periodo_comision.id_periodo%TYPE,
        despercom  periodo_comision.despercom%TYPE,
        periodo    periodo_comision.periodo%TYPE,
        mes        periodo_comision.mes%TYPE,
        desmes VARCHAR2(25),
        finicio    periodo_comision.finicio%TYPE,
        ffin       periodo_comision.ffin%TYPE,
        situac     periodo_comision.situac%TYPE,
        ucreac     periodo_comision.ucreac%TYPE,
        uactua     periodo_comision.uactua%TYPE,
        fcreac     periodo_comision.fcreac%TYPE,
        factua     periodo_comision.factua%TYPE
    );
    TYPE datatable_periodo_comision IS
        TABLE OF datarecord_periodo_comision;
    TYPE r_errores IS RECORD (
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_obtener (
        pin_id_cia     NUMBER,
        pin_id_periodo NUMBER
    ) RETURN datatable_periodo_comision
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_periodo_comision
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER
    );

    FUNCTION sp_valida_objeto (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_datos   CLOB
    ) RETURN datatable
        PIPELINED;

END;

/
