--------------------------------------------------------
--  DDL for Package Body PACK_CF_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_COMPANIAS" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_razonc VARCHAR2
    ) RETURN datatable_companias
        PIPELINED
    AS
        v_table datatable_companias;
    BEGIN
        SELECT
            c.cia,
            c.razsoc,
            c.nomcom,
            c.direcc,
            c.dircom,
            c.distri,
            c.ruc,
            c.telefo,
            c.fax,
            c.email,
            c.repres,
            c.codsuc,
            c.anno,
            c.mes,
            c.moneda01,
            c.moneda02,
            c.fcreac,
            c.factua,
            c.usuari,
            CASE
                WHEN c.swacti = 'S' THEN
                    'true'
                ELSE
                    'false'
            END activo,
            c.situac,
            c.swflag,
            c.piepag01,
            c.piepag02,
            c.piepag03,
            c.piepag04,
            c.piepag05,
            c.nomanio,
            cg.grupo,
            c.usuarios
        BULK COLLECT
        INTO v_table
        FROM
            companias       c
            LEFT OUTER JOIN companias_grupo cg ON cg.id_cia = c.cia
        WHERE
            ( pin_id_cia IS NULL
              OR c.cia = pin_id_cia )
            AND ( c.razsoc IS NULL
                  OR upper(c.razsoc) LIKE ( '%'
                                            || upper(pin_razonc)
                                            || '%' ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

END;

/
