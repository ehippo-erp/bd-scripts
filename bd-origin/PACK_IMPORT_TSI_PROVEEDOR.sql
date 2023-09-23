--------------------------------------------------------
--  DDL for Package PACK_IMPORT_TSI_PROVEEDOR
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_TSI_PROVEEDOR" AS
    TYPE datarecord_buscar IS RECORD (
        codcli    cliente.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        tident    cliente.tident%TYPE,
        dident    cliente.dident%TYPE,
        codtpe    cliente.codtpe%TYPE,
        direc1    cliente.direc1%TYPE,
        direc2    cliente.direc2%TYPE,
        telefono  cliente.telefono%TYPE,
        fax       cliente.fax%TYPE,
        repres    cliente.repres%TYPE,
        codpagcom cliente.codpagcom%TYPE,
        regret    cliente.regret%TYPE,
        clase4    cliente_clase.codigo%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE r_errores IS RECORD (
        fila     NUMBER,
        columna  VARCHAR2(80),
        valor    VARCHAR2(220),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codtpe IN NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION valida_proveedor_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE importa_proveedor_v2 (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    );

END;

/
