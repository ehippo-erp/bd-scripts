--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_CLASE" AS
    TYPE datarecord_personal_clase IS RECORD (
        id_cia   personal_clase.id_cia%TYPE,
        codper   personal_clase.codper%TYPE,
        clase    personal_clase.clase%TYPE,
        desclase clase_personal.descri%TYPE,
        codigo   personal_clase.codigo%TYPE,
        descodigo clase_codigo_personal.descri%TYPE,
        situac   personal_clase.situac%TYPE,
        ucreac   personal_clase.ucreac%TYPE,
        uactua   personal_clase.uactua%TYPE,
        fcreac   personal_clase.fcreac%TYPE,
        factua   personal_clase.factua%TYPE
    );
    TYPE datatable_personal_clase IS
        TABLE OF datarecord_personal_clase;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_personal_clase
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_clase
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
