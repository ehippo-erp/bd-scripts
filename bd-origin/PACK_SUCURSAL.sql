--------------------------------------------------------
--  DDL for Package PACK_SUCURSAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_SUCURSAL" AS
    TYPE datatable_sucursal IS
        TABLE OF sucursal%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_sucursal
        PIPELINED;

END;

/
