--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_MOTIVOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_MOTIVOS" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            pin_id_cia,
            cm.codigo,
            cm.descodigo,
            cm.situac,
            cm.ucreac,
            cm.uactua,
            cm.fcreac,
            cm.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_motivos cm
        WHERE
            cm.id_cia = 1;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

END;

/
