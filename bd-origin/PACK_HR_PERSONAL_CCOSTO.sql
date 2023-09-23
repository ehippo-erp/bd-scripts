--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_CCOSTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_CCOSTO" AS
    TYPE datarecord_personal_ccosto IS RECORD (
        id_cia personal_ccosto.id_cia%TYPE,
        codper personal_ccosto.codper%TYPE,
        codcco personal_ccosto.codcco%TYPE,
        descco tccostos.descri%TYPE,
        prcdis  personal_ccosto.prcdis%TYPE,
        ucreac personal_ccosto.ucreac%TYPE,
        uactua personal_ccosto.uactua%TYPE,
        fcreac personal_ccosto.fcreac%TYPE,
        factua personal_ccosto.factua%TYPE
    );
    TYPE datatable_personal_ccosto IS
        TABLE OF datarecord_personal_ccosto;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codcco VARCHAR2
    ) RETURN datatable_personal_ccosto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_ccosto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
