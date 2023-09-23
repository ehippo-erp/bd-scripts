--------------------------------------------------------
--  DDL for Package PACK_HR_CLASE_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CLASE_PERSONAL" AS
    TYPE t_clase_personal IS
        TABLE OF clase_personal%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_personal
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

--    TYPE t_clase_codigo_personal IS
--        TABLE OF clase_codigo_personal%rowtype;
    TYPE datarecord_clase_codigo IS RECORD (
        id_cia    NUMBER,
        clase     NUMBER,
        codigo    VARCHAR2(20 BYTE),
        descri    VARCHAR2(100 CHAR),
        abrevi    VARCHAR2(6 CHAR),
        situac    CHAR(1 BYTE),
        swdefault VARCHAR2(1 CHAR),
        fcreac    TIMESTAMP(6),
        factua    TIMESTAMP(6),
        ucreac    VARCHAR2(10 CHAR),
        uactua    VARCHAR2(10 CHAR),
        tiptra    VARCHAR2(1 BYTE)
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;
    FUNCTION sp_buscar_codigo (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_codigo IN VARCHAR2,
        pin_descri IN VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED;

    PROCEDURE sp_save_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
