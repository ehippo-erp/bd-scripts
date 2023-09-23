--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_LEGAJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_LEGAJO" AS
    TYPE datarecord_personal_legajo IS RECORD (
        id_cia   personal_legajo.id_cia%TYPE,
        codper   personal_legajo.codper%TYPE,
        codleg   personal_legajo.codleg%TYPE,
        desleg   personal_legajo.descri%TYPE,
        codtip   personal_legajo.codtip%TYPE,
        codite   personal_legajo.codite%TYPE,
        desitem  tipoitem.nombre%TYPE,
        finicio  personal_legajo.finicio%TYPE,
        ffin     personal_legajo.ffin%TYPE,
        countadj personal_legajo.countadj%TYPE,
        ucreac   personal_legajo.ucreac%TYPE,
        uactua   personal_legajo.uactua%TYPE,
        fcreac   personal_legajo.factua%TYPE,
        factua   personal_legajo.factua%TYPE
    );
    TYPE datatable_personal_legajo IS
        TABLE OF datarecord_personal_legajo;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codleg VARCHAR2
    ) RETURN datatable_personal_legajo
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_legajo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
