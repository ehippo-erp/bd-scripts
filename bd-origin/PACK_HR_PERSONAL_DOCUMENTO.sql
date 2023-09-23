--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_DOCUMENTO" AS
    TYPE datarecord_personal_documento IS RECORD (
        id_cia personal_documento.id_cia%TYPE,
        codper personal_documento.codper%TYPE,
        codtip personal_documento.codtip%TYPE,
        codite personal_documento.codite%TYPE,
        nomtdo tipoitem.nombre%TYPE,
        nrodoc personal_documento.nrodoc%TYPE,
        clase  personal_documento.clase%TYPE,
        codigo personal_documento.codigo%TYPE,
        destipo clase_codigo_personal.descri%TYPE,
        situac personal_documento.situac%TYPE,
        ucreac personal_documento.ucreac%TYPE,
        uactua personal_documento.uactua%TYPE,
        fcreac personal_documento.fcreac%TYPE,
        factua personal_documento.factua%TYPE
    );
    TYPE datatable_personal_documento IS
        TABLE OF datarecord_personal_documento;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codtip VARCHAR2,
        pin_codite NUMBER
    ) RETURN datatable_personal_documento
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_documento
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
