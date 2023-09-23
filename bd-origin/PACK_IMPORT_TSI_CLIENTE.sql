--------------------------------------------------------
--  DDL for Package PACK_IMPORT_TSI_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_TSI_CLIENTE" AS
    TYPE datarecord_buscar IS RECORD (
        codcli    cliente.codcli%TYPE,
        ctacli    cliente.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        tident    cliente.tident%TYPE,
        dident    cliente.dident%TYPE,
        direc1    cliente.direc1%TYPE,
        telefono  cliente.telefono%TYPE,
        fax       cliente.fax%TYPE,
        apepat    cliente_tpersona.apemat%TYPE,
        apemat    cliente_tpersona.apemat%TYPE,
        nombres   cliente_tpersona.nombre%TYPE,
        direc2    cliente.direc2%TYPE,
        codtpe    cliente.codtpe%TYPE,
        email     cliente.email%TYPE,
        codven    cliente.codven%TYPE,
        observ    cliente.observ%TYPE,
        clas_zona clase_cliente_codigo.codigo%TYPE,
        cla_pais  clase_cliente_codigo.codigo%TYPE,
        cla_dep   clase_cliente_codigo.codigo%TYPE,
        cla_pro   clase_cliente_codigo.codigo%TYPE,
        cla_dis   clase_cliente_codigo.codigo%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE r_errores IS RECORD (
        fila     NUMBER,
        columna  VARCHAR2(80),
        valor    VARCHAR2(80),
        deserror VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codtpe NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION valida_cliente_v2 (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE importa_cliente_v2 (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    );

END;

/
