--------------------------------------------------------
--  DDL for Package PACK_INTERLOCUTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_INTERLOCUTOR" AS 
    
     TYPE r_cliente IS RECORD (
        codcli        cliente.codcli%TYPE,
        tident        cliente.tident%TYPE,
        tidentnombre  identidad.abrevi%TYPE,
        dident        cliente.dident%TYPE,
        razonc        cliente.razonc%TYPE,
        codtit        cliente.codtit%TYPE,
        direcc        cliente.direc1%TYPE,
        codpag        cliente.codpag%TYPE,
        valident      cliente.valident%TYPE,
        codtpe        cliente.codtpe%TYPE,
        apellidoPaterno cliente_tpersona.apepat%TYPE,
        apellidoMaterno cliente_tpersona.apemat%TYPE,
        nombres cliente_tpersona.nombre%TYPE,
        nombresCompletos VARCHAR2(120)
    );
    TYPE t_cliente IS
        TABLE OF r_cliente;

     FUNCTION sp_sel_interlocutor (
        pin_id_cia    IN  NUMBER,
        pin_tipcli  IN  VARCHAR2,
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


END PACK_INTERLOCUTOR;

/
