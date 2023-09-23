--------------------------------------------------------
--  DDL for Package Body PACK_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ALMACEN" AS

    FUNCTION sp_ayuda (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER
    ) RETURN datatable_ayuda
        PIPELINED
    AS
        v_table datatable_ayuda;
    BEGIN
        SELECT
            a.id_cia,
            pin_tipinv,
            a.codalm,
            a.codsuc,
            s.sucursal,
            a.descri,
            a.abrevi,
            a.fcreac,
            a.factua,
            a.usuari,
            CASE
                WHEN a.swacti = 'S' THEN
                    'true'
                ELSE
                    'false'
            END activo,
            CASE
                WHEN a.swterc = 'S' THEN
                    'true'
                ELSE
                    'false'
            END swterc,
            a.ubigeo,
            a.direcc,
            CASE
                WHEN a.consigna = 'S' THEN
                    'true'
                ELSE
                    'false'
            END consigna
        BULK COLLECT
        INTO v_table
        FROM
            almacen  a
            LEFT OUTER JOIN sucursal s ON s.id_cia = a.id_cia
                                          AND s.codsuc = a.codsuc
        WHERE
                a.id_cia = pin_id_cia
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR a.tipinv = pin_tipinv )
        ORDER BY
            a.tipinv,
            a.codalm ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ayuda;

END;

/
