--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_CTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_CTS" AS
    TYPE datarecord_personal_cts IS RECORD (
        id_cia    personal_cts.id_cia%TYPE,
        codper    personal_cts.codper%TYPE,
        codban    personal_cts.codban%TYPE,
        desban    e_financiera.descri%TYPE,
        tipcta    personal_cts.tipcta%TYPE,
        destipcta e_financiera_tipo.descri%TYPE,
        codmon    personal_cts.codmon%TYPE,
        cuenta    personal_cts.cuenta%TYPE,
        ucreac    personal_cts.ucreac%TYPE,
        uactua    personal_cts.uactua%TYPE,
        fcreac    personal_cts.fcreac%TYPE,
        factua    personal_cts.factua%TYPE
    );
    TYPE datatable_personal_cts IS
        TABLE OF datarecord_personal_cts;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codban NUMBER
    ) RETURN datatable_personal_cts
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_cts
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
