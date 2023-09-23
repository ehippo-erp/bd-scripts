--------------------------------------------------------
--  DDL for Package PACK_HELPCLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HELPCLIENTE" AS
    TYPE r_cliente IS RECORD (
        codcli        cliente.codcli%TYPE,
        tident        cliente.tident%TYPE,
        tidentnombre  identidad.abrevi%TYPE,
        dident        cliente.dident%TYPE,
        razonc        cliente.razonc%TYPE,
        codtit        cliente.codtit%TYPE,
        direcc        cliente.direc1%TYPE,
        codpag        cliente.codpag%TYPE,
        clase01       VARCHAR2(1),
        valident      cliente.valident%TYPE,
        codtpe        cliente.codtpe%TYPE,
        apellidoPaterno cliente_tpersona.apepat%TYPE,
        apellidoMaterno cliente_tpersona.apemat%TYPE,
        nombres cliente_tpersona.nombre%TYPE,
        nombresCompletos VARCHAR2(120)
    );
    TYPE t_cliente IS
        TABLE OF r_cliente;
    FUNCTION sp_sel_cliente (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codtpe    IN  NUMBER,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_nombres    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_cliente
        PIPELINED;

    TYPE r_proveedor IS RECORD (
        codpro        cliente.codcli%TYPE,
        tident        cliente.tident%TYPE,
        tidentnombre  identidad.abrevi%TYPE,
        dident        cliente.dident%TYPE,
        razonc        cliente.razonc%TYPE,
        direcc        cliente.direc1%TYPE,
        valident      cliente.valident%TYPE,
        codtpe        cliente.codtpe%TYPE
    );
    TYPE t_proveedor IS
        TABLE OF r_proveedor;
    FUNCTION sp_sel_proveedor (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codtpe    IN  NUMBER,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_proveedor
        PIPELINED;

    TYPE r_subcentrocosto IS RECORD (
        id_cia    cliente.id_cia%TYPE,
        tipcli    cliente.tipcli%TYPE,
        codcli    cliente.codcli%TYPE,
        descri    cliente.razonc%TYPE,
        tident    cliente.tident%TYPE,
        dident    cliente.dident%TYPE,
        valident  cliente.valident%TYPE,
        codtpe    cliente.codtpe%TYPE
    );
    TYPE t_subcentrocosto IS
        TABLE OF r_subcentrocosto;
    FUNCTION sp_sel_subcentrocosto (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_subcentrocosto
        PIPELINED;

END;

/
