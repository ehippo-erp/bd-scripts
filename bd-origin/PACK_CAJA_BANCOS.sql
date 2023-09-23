--------------------------------------------------------
--  DDL for Package PACK_CAJA_BANCOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CAJA_BANCOS" AS
    TYPE datarecord_cuenta_corriente IS RECORD (
        cuenta     VARCHAR(16),
        nombre     VARCHAR(50),
        moneda01   VARCHAR(5),
        entidadfin VARCHAR(65),
        cuentaban  VARCHAR(25),
        codsunban  VARCHAR(10),
        desmon     VARCHAR(50),
        periodo    INTEGER,
        mes        SMALLINT,
        libro      VARCHAR(3),
        asiento    INTEGER,
        item       INTEGER,
        sitem      INTEGER,
        cuentam    VARCHAR(16),
        nombrem    VARCHAR(50),
        topera     VARCHAR(3),
        fecha      DATE,
        dh         CHAR(1),
        fdocum     TIMESTAMP,
        concep     VARCHAR(100),
        serie      VARCHAR(20),
        numero     VARCHAR(30),
        debe01     NUMERIC(16, 2),
        haber01    NUMERIC(16, 2),
        debe02     NUMERIC(16, 2),
        haber02    NUMERIC(16, 2),
        razon      VARCHAR(75),
        codope1    VARCHAR(20),
        codope2    VARCHAR(20),
        cuenta_ref VARCHAR(16),
        nombre_ref VARCHAR(50)
    );
    TYPE datatable_cuenta_corriente IS
        TABLE OF datarecord_cuenta_corriente;
-- SP000_CAJA_BANCOS_DETALLE_CUENTA_CORRIENTE
    FUNCTION sp_detalle_cuenta (
        pin_id_cia    NUMBER,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_swdetalle VARCHAR2
    ) RETURN datatable_cuenta_corriente
        PIPELINED;

END;

/
