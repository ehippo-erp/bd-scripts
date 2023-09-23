--------------------------------------------------------
--  DDL for Package PACK_ASIENTO_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ASIENTO_CIERRE" AS
    TYPE datarecord_buscar IS RECORD (
        cuenta  pcuentas.cuenta%TYPE,
        nombre  pcuentas.nombre%TYPE,
        saldo01 movimientos.debe01%TYPE,
        saldo02 movimientos.debe02%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_buscar (
        pin_id_cia     NUMBER,
        pin_periodo    NUMBER,
        pin_tipocierre NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_genera (
        pin_id_cia     IN NUMBER,
        pin_libro      IN VARCHAR2,
        pin_femisi     IN DATE,
        pin_coduser    IN VARCHAR2,
        pin_tccompra   IN NUMBER,
        pin_tcventa    IN NUMBER,
        pin_tipocierre IN NUMBER,
        pout_message   OUT VARCHAR2
    );

END;

/
