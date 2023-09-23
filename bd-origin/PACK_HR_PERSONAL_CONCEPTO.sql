--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_CONCEPTO" AS
    TYPE datarecord_personal_concepto IS RECORD (
        id_cia  personal_concepto.id_cia%TYPE,
        codper  personal_concepto.codper%TYPE,
        codcon  personal_concepto.codcon%TYPE,
        periodo personal_concepto.periodo%TYPE,
        mes     personal_concepto.mes%TYPE,
        nomcon  concepto.nombre%TYPE,
        valcon  personal_concepto.valcon%TYPE,
        ucreac  personal_concepto.ucreac%TYPE,
        uactua  personal_concepto.uactua%TYPE,
        fcreac  personal_concepto.fcreac%TYPE,
        factua  personal_concepto.factua%TYPE
    );
    TYPE datatable_personal_concepto IS
        TABLE OF datarecord_personal_concepto;
    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_codcon  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_personal_concepto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_personal_concepto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_replicar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_generar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_clonar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_asigna_conceptos_fijos (
        pin_id_cia  IN NUMBER,
        pin_codcon  IN VARCHAR2,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/
