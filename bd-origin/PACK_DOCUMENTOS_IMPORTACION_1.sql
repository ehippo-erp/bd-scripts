--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_IMPORTACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_IMPORTACION" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_obtener
        PIPELINED
    AS
        v_table datatable_obtener;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                  AS numint,
            c.tipdoc,
            c.series                  AS series,
            c.numdoc                  AS numdoc,
            c.femisi                  AS femisi,
            c.razonc                  AS razonc,
            c.direc1                  AS direc1,
            c.ruc                     AS ruc,
            c.observ                  AS obscab,
            c.tipcam                  AS tipcam,
            c.ordcom                  AS ordcom,
            c.fordcom                 AS fordcom,
            c.facpro                  AS facpro,
            c.ffacpro                 AS ffacpro,
            c.numped                  AS numped,
            c.id                      AS id,
            c.porigv                  AS porigv,
            c.tipmon,
            m1.simbolo                AS simbolo,
            m1.desmon                 AS desmon,
            c1.direc1                 AS dircli1,
            s2.alias                  AS aliassit,
            mt.codmot,
            mt.desmot                 AS desmot,
            c.opnumdoc                AS opnumdoc,
            d.numite                  AS dd_numite,
            d.tipinv                  AS dd_tipinv,
            ti.dtipinv,
            d.codart                  AS dd_codart,
            a.descri                  AS dd_desart,
            d.cantid                  AS dd_cantid,
            d.canref                  AS dd_canref,
            d.ancho                   AS dd_ancho,
            d.tara                    AS dd_tara,
            a.coduni                  AS dd_codund,
            d.preuni                  AS dd_preuni,
            d.importe                 AS dd_importe,
            d.observ                  AS dd_obsdet,
            d.codadd01                AS dd_codcalid,
            d.codadd02                AS dd_codcolor,
            ca1.descri                AS dd_dcalidad,
            d.codadd02
            || ' - '
            || ca2.descri             AS dd_dcolor,
            CAST(1 AS NUMERIC(10, 1)) AS dd_canitem,
            un.abrevi                 AS dd_abrunidad
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab          c
            LEFT OUTER JOIN cliente                 c1 ON ( c1.id_cia = c.id_cia
                                            AND c1.codcli = c.codcli )
            LEFT OUTER JOIN situacion               s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN tmoneda                 m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN motivos                 mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( c.tipdoc = mt.tipdoc )
            LEFT OUTER JOIN documentos_det          d ON ( d.id_cia = c.id_cia
                                                  AND d.numint = c.numint )
            LEFT OUTER JOIN unidad                  un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN t_inventario            ti ON ti.id_cia = d.id_cia
                                               AND ti.tipinv = d.tipinv
            LEFT OUTER JOIN articulos               a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = d.codadd01
            LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = d.codadd02
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            c.tipdoc,
            c.numint,
            d.positi,
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    PROCEDURE sp_valida (
        pin_id_cia   IN NUMBER,
        pin_opnumdoc IN NUMBER,
        pin_opnumite IN NUMBER,
        pin_tipinv   IN NUMBER,
        pin_codart   IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS
        v_aux        VARCHAR2(1 CHAR) := '';
        pout_mensaje VARCHAR2(1000 CHAR) := '';
    BEGIN
        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                documentos_det
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_opnumdoc
                AND numite = pin_opnumite
                AND tipinv = pin_tipinv
                AND codart = pin_codart;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'No se puede procesar, porque la ORDEN DE COMPRA DE IMPORTACIÓN con el NUMERO INTERNO [ '
                                || pin_opnumdoc
                                || ' ], con el ITEM [ '
                                || pin_opnumite
                                || ' ] no esta relacionado al ARTICULO [ '
                                || pin_tipinv
                                || ' ] - [ '
                                || pin_codart
                                || ' ]';

                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_valida;

END;

/
