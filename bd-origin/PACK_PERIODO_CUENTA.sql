--------------------------------------------------------
--  DDL for Package PACK_PERIODO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PERIODO_CUENTA" AS
    TYPE array_tipran IS
        VARRAY(5) OF VARCHAR2(80) NOT NULL;
    ka_tipran array_tipran := array_tipran('Cada 7 Dias', 'Cada 15 Dias', 'Cada 30 dias', 'Cada 45 dias', 'Definido por el Usuario');
    TYPE datarecord_tiporango IS RECORD (
        id_cia    NUMBER,
        tipran    NUMBER,
        destipran VARCHAR2(80)
    );
    TYPE datatable_tiporango IS
        TABLE OF datarecord_tiporango;
    TYPE datarecord_rango IS RECORD (
        id_cia periodo_cuenta.id_cia%TYPE,
        tipran periodo_cuenta.tipran%TYPE,
        tipven periodo_cuenta.tipven%TYPE,
        desven VARCHAR2(80),
        orden periodo_cuenta.orden%TYPE,
        desran periodo_cuenta.desran%TYPE
    );
    TYPE datatable_rango IS
        TABLE OF datarecord_rango;
    FUNCTION sp_buscar_tiporango (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_tiporango
        PIPELINED;

    FUNCTION sp_buscar_rango (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_rango
        PIPELINED;

    TYPE datarecord_buscar IS RECORD (
        id_cia    periodo_cuenta.id_cia%TYPE,
        tipran    periodo_cuenta.tipran%TYPE,
        destipran VARCHAR2(80),
        orden     periodo_cuenta.orden%TYPE,
        desran    periodo_cuenta.desran%TYPE,
        rdesde    periodo_cuenta.rdesde%TYPE,
        rhasta    periodo_cuenta.rhasta%TYPE,
        ucreac    periodo_cuenta.ucreac%TYPE,
        uactua    periodo_cuenta.uactua%TYPE,
        fcreac    periodo_cuenta.fcreac%TYPE,
        factua    periodo_cuenta.factua%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipran NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipran NUMBER,
        pin_orden  NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/
