--------------------------------------------------------
--  DDL for Package PACK_HR_TCCOSTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_TCCOSTOS" AS
    TYPE datarecord_tccostos IS RECORD (
        id_cia    NUMBER(38),
        codigo    VARCHAR2(16),
        descodigo pcuentas.nombre%TYPE,
        descri    VARCHAR2(50),
        succcosto CHAR(1),
        destino   CHAR(1),
        destin    VARCHAR2(16),
        desdestin pcuentas.nombre%TYPE,
        swacti    VARCHAR2(1),
        usuari    VARCHAR2(10),
        fcreac    TIMESTAMP(6),
        factua    TIMESTAMP(6)
    );
    TYPE datatable_tccostos IS
        TABLE OF datarecord_tccostos;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER
    ) RETURN datatable_tccostos
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
