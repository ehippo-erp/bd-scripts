--------------------------------------------------------
--  DDL for Package PACK_HR_TIPOPLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_TIPOPLANILLA" AS
    TYPE datarecord_tipoplanilla IS RECORD (
        id_cia       NUMBER,
        tippla       VARCHAR2(1),
        nombre       VARCHAR2(40),
        diapla       NUMBER(38),
        horpla       NUMBER(38),
        redond       NUMBER(38),
        codcta       VARCHAR2(15),
        descodcta    pcuentas.nombre%TYPE,
        facade       NUMBER(15, 4),
        dh           CHAR(1),
        agrupa       CHAR(1),
        libro        VARCHAR2(3),
        swcuenta     VARCHAR2(1),
        swacti       CHAR(1),
        codctaobr    VARCHAR2(15),
        descodctaobr pcuentas.nombre%TYPE,
        ucreac       VARCHAR2(10),
        uactua       VARCHAR2(10),
        fcreac       TIMESTAMP(6),
        factua       TIMESTAMP(6)
    );
    TYPE datatable_tipoplanila IS
        TABLE OF datarecord_tipoplanilla;
    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tippla IN VARCHAR2
    ) RETURN datatable_tipoplanila
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_tippla IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_tipoplanila
        PIPELINED;

    FUNCTION sp_buscar_config (
        pin_id_cia IN NUMBER
    ) RETURN datatable_tipoplanila
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
