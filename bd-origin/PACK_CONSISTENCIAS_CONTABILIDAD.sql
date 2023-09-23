--------------------------------------------------------
--  DDL for Package PACK_CONSISTENCIAS_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CONSISTENCIAS_CONTABILIDAD" AS
    TYPE datarecord_clase_6_9 IS RECORD (
        libro       movimientos.libro%TYPE,
        periodo     movimientos.periodo%TYPE,
        mes         movimientos.mes%TYPE,
        asiento     movimientos.asiento%TYPE,
        sumatoria_6 NUMBER,
        sumatoria_9 NUMBER,
        diferencia  NUMBER
    );
    TYPE datatable_clase_6_9 IS
        TABLE OF datarecord_clase_6_9;

    TYPE datarecord_clase_67_9 IS RECORD (
        libro       movimientos.libro%TYPE,
        periodo     movimientos.periodo%TYPE,
        mes         movimientos.mes%TYPE,
        asiento     movimientos.asiento%TYPE,
        sumatoria_67 NUMBER,
        sumatoria_9 NUMBER,
        diferencia  NUMBER
    );
    TYPE datatable_clase_67_9 IS
        TABLE OF datarecord_clase_67_9;

    TYPE datarecord_centros_costos IS RECORD (
        centro_costo tccostos.codigo%type,
        destino tccostos.destin%type,
        ccosto_pcuentas VARCHAR2(1),
        destino_pcuentas VARCHAR2(1)
    );
    TYPE datatable_centros_costos IS
        TABLE OF datarecord_centros_costos;

    TYPE datarecord_centros_costos_movimientos IS RECORD (
        periodo movimientos.periodo%type,
        mes movimientos.mes%type,
        libro movimientos.libro%type,
        asiento movimientos.asiento%type,
        item movimientos.item%type,
        cuenta_movimiento movimientos.cuenta%type,
        ccosto_movimiento movimientos.ccosto%type,
        ccosto_pcuentas VARCHAR2(1),
        ccosto_tccostos VARCHAR2(1)
    );
    TYPE datatable_centros_costos_movimientos IS
        TABLE OF datarecord_centros_costos_movimientos;  

    FUNCTION sp_clase_6_9 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_clase_6_9
        PIPELINED;

    FUNCTION sp_centro_costos (
        pin_id_cia NUMBER
    ) RETURN datatable_centros_costos
        PIPELINED;

    FUNCTION sp_centro_costos_movimientos (
        pin_id_cia NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_centros_costos_movimientos
        PIPELINED;

     FUNCTION sp_clase_67_9 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_clase_67_9
        PIPELINED;

END;

/
