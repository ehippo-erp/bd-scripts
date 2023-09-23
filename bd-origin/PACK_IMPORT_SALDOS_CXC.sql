--------------------------------------------------------
--  DDL for Package PACK_IMPORT_SALDOS_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_IMPORT_SALDOS_CXC" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

     TYPE r_errores IS RECORD (
        valor     VARCHAR2(80),
        deserror  VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;
    FUNCTION valida_objeto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   CLOB
    ) RETURN datatable
        PIPELINED;

    PROCEDURE importa_saldos (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   CLOB
    );

END PACK_IMPORT_SALDOS_CXC;

/
