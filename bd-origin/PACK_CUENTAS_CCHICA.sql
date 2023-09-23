--------------------------------------------------------
--  DDL for Package PACK_CUENTAS_CCHICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CUENTAS_CCHICA" AS
    TYPE datarecord_movimientos_asignar_costeo IS RECORD (
        cuenta    VARCHAR2(16),
        descuenta VARCHAR2(50),
        codigo    VARCHAR2(20),
        razon     VARCHAR2(100 CHAR),
        periodo   NUMBER,
        mes       NUMBER,
        fecha     DATE,
        libro     VARCHAR2(3),
        asiento   NUMBER,
        item      NUMBER,
        sitem     NUMBER,
        tdocum    VARCHAR2(2),
        numero    VARCHAR2(20),
        moneda01  VARCHAR2(3),
--        debe      NUMERIC(16, 2),
--        haber     NUMERIC(16, 2),
--        saldo     NUMERIC(16, 2),
        concep    VARCHAR2(150 CHAR),
        proyecto  VARCHAR2(50),
        swgasoper NUMBER,
        refere    VARCHAR2(30),
        razonc_cr VARCHAR2(70),
        debe01    NUMERIC(16, 2),
        haber01   NUMERIC(16, 2),
        saldo01   NUMERIC(16, 2),
        debe02    NUMERIC(16, 2),
        haber02   NUMERIC(16, 2),
        saldo02   NUMERIC(16, 2)
    );
    TYPE datatable_movimientos_asignar_costeo IS
        TABLE OF datarecord_movimientos_asignar_costeo;
    FUNCTION sp_movimientos_asignar_costeo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_libro   VARCHAR2
    ) RETURN datatable_movimientos_asignar_costeo
        PIPELINED;

END;

/
