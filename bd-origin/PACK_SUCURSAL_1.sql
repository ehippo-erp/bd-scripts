--------------------------------------------------------
--  DDL for Package Body PACK_SUCURSAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_SUCURSAL" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_sucursal
        PIPELINED
    AS
        v_table datatable_sucursal;
    BEGIN

--    SELECT
--        *
--    FROM
--        pack_sucursal.sp_buscar ( 66 );

        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            sucursal
        WHERE
            id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

END;

/
