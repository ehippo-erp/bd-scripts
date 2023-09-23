--------------------------------------------------------
--  DDL for Package PACK_DW_CVENTAS_MENSUAL_META
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW_CVENTAS_MENSUAL_META" AS
    TYPE datarecord_dw_cventas_mensual_meta IS RECORD (
        id_cia   dw_cventas_mensual_meta.id_cia%TYPE,
        codsuc   dw_cventas_mensual_meta.codsuc%TYPE,
        sucursal VARCHAR2(120),
        periodo  dw_cventas_mensual_meta.periodo%TYPE,
        idmes    dw_cventas_mensual_meta.idmes%TYPE,
        mes      dw_cventas_mensual_meta.mes%TYPE,
        mesid    dw_cventas_mensual_meta.mesid%TYPE,
        meta01   dw_cventas_mensual_meta.meta01%TYPE,
        meta02   dw_cventas_mensual_meta.meta02%TYPE,
        ucreac   dw_cventas_mensual_meta.ucreac%TYPE,
        uactua   dw_cventas_mensual_meta.uactua%TYPE,
        fcreac   dw_cventas_mensual_meta.fcreac%TYPE,
        factua   dw_cventas_mensual_meta.factua%TYPE
    );
    TYPE datatable_dw_cventas_mensual_meta IS
        TABLE OF datarecord_dw_cventas_mensual_meta;
    TYPE r_errores IS RECORD (
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_periodo NUMBER,
        pin_idmes   NUMBER
    ) RETURN datatable_dw_cventas_mensual_meta
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_dw_cventas_mensual_meta
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_codsuc  IN NUMBER,
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
