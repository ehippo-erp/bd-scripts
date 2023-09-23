--------------------------------------------------------
--  DDL for Package PACK_TIPO_TRABAJADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TIPO_TRABAJADOR" AS
    TYPE t_tipo_trabajador IS
        TABLE OF tipo_trabajador%rowtype;
    FUNCTION sp_sel_tipo_trabajador (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_tipo_trabajador
        PIPELINED;

    PROCEDURE sp_save_tipo_trabajador (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
