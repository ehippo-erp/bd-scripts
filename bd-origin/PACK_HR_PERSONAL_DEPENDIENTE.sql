--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_DEPENDIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_DEPENDIENTE" AS
    TYPE datarecord_personal_dependiente IS RECORD (
        id_cia    personal_dependiente.id_cia%TYPE,
        codper    personal_dependiente.codper%TYPE,
        item      personal_dependiente.item%TYPE,
        clas03    personal_dependiente.clas03%TYPE,
        codi03    personal_dependiente.codi03%TYPE,
        desclas03 clase_codigo_personal.descri%TYPE,
        numdoc    personal_dependiente.numdoc%TYPE,
        apepat    personal_dependiente.apepat%TYPE,
        apemat    personal_dependiente.apemat%TYPE,
        nombre    personal_dependiente.nombre%TYPE,
        fecnac    personal_dependiente.fecnac%TYPE,
        sexo      personal_dependiente.sexo%TYPE,
        clas19    personal_dependiente.clas19%TYPE,
        codi19    personal_dependiente.codi19%TYPE,
        desclas19 clase_codigo_personal.descri%TYPE,
        fecalt    personal_dependiente.fecalt%TYPE,
        clas20    personal_dependiente.clas20%TYPE,
        codi20    personal_dependiente.codi20%TYPE,
        desclas20 clase_codigo_personal.descri%TYPE,
        misdom    personal_dependiente.misdom%TYPE,
        ucreac    personal_dependiente.ucreac%TYPE,
        uactua    personal_dependiente.uactua%TYPE,
        fcreac    personal_dependiente.fcreac%TYPE,
        factua    personal_dependiente.factua%TYPE
    );
    TYPE datatable_personal_dependiente IS
        TABLE OF datarecord_personal_dependiente;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_item   VARCHAR2
    ) RETURN datatable_personal_dependiente
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_dependiente
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
