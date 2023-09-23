--------------------------------------------------------
--  DDL for Package PACK_CLASE_MOTIVOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLASE_MOTIVOS" AS
    TYPE datatable_buscar IS
        TABLE OF clase_motivos%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

END;

/
