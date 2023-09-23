--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_NOAFECTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_NOAFECTO" AS
    TYPE datarecord_personal_noafecto IS RECORD (
        id_cia personal_noafecto.id_cia%TYPE,
        codcon personal_noafecto.codcon%TYPE,
        codper personal_noafecto.codper%TYPE,
        nomper VARCHAR2(500),
        ucreac personal_noafecto.ucreac%TYPE,
        uactua personal_noafecto.uactua%TYPE,
        fcreac personal_noafecto.fcreac%TYPE,
        factua personal_noafecto.factua%TYPE
    );
    TYPE datatable_personal_noafecto IS
        TABLE OF datarecord_personal_noafecto;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_noafecto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_personal_noafecto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
