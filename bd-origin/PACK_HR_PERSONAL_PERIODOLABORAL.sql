--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL_PERIODOLABORAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL_PERIODOLABORAL" AS
    TYPE datatable_personal_periodolaboral IS
        TABLE OF personal_periodolaboral%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_id_plab IN NUMBER
    ) RETURN datatable_personal_periodolaboral
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_personal_periodolaboral
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
