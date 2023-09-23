--------------------------------------------------------
--  DDL for Package PACK_GASTOS_GENERALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_GASTOS_GENERALES" AS
    TYPE datarecord_subcentro_costo_cab IS RECORD (
        codcli cliente.codcli%TYPE,
        razonc cliente.razonc%TYPE,
        abrevi clase_cliente_codigo.abrevi%TYPE
    );
    TYPE datatable_subcentro_costo_cab IS
        TABLE OF datarecord_subcentro_costo_cab;
    FUNCTION sp_buscar_subcentro_costo_cab (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_ccosto VARCHAR2
    ) RETURN datatable_subcentro_costo_cab
        PIPELINED;

    TYPE datarecord_subcentro_costo_det IS RECORD (
        tipgas    pcuentas.tipgas%TYPE,
        destipgas tgastos.descri%TYPE,
        cuenta    movimientos.cuenta%TYPE,
        descuenta pcuentas.nombre%TYPE,
        saldo     movimientos.saldo%TYPE,
        codcli    cliente.codcli%TYPE,
        abrevi    clase_cliente_codigo.abrevi%TYPE
    );
    TYPE datatable_subcentro_costo_det IS
        TABLE OF datarecord_subcentro_costo_det;
    FUNCTION sp_buscar_subcentro_costo_det (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_ccosto VARCHAR2,
        pin_moneda VARCHAR2
    ) RETURN datatable_subcentro_costo_det
        PIPELINED;

END;

/
