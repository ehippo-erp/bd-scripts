--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_CONTRATO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_CONTRATO" AS
    TYPE datarecord_personal_contrato IS RECORD (
        id_cia   personal_contrato.id_cia%TYPE,
        codper   personal_contrato.codper%TYPE,
        nrocon   personal_contrato.nrocon%TYPE,
        finicio  personal_contrato.finicio%TYPE,
        ffin     personal_contrato.ffin%TYPE,
        ftermino personal_contrato.ftermino%TYPE,
        duracion personal_contrato.duracion%TYPE,
        countadj personal_contrato.countadj%TYPE,
        observ   personal_contrato.observ%TYPE,
        ucreac   personal_contrato.ucreac%TYPE,
        uactua   personal_contrato.uactua%TYPE,
        fcreac   personal_contrato.fcreac%TYPE,
        factua   personal_contrato.factua%TYPE
    );
    TYPE datatable_personal_contrato IS
        TABLE OF datarecord_personal_contrato;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_nrocon VARCHAR2
    ) RETURN datatable_personal_contrato
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_contrato
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
