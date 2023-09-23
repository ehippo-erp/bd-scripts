--------------------------------------------------------
--  DDL for Package Body PACK_DCTA105
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DCTA105" AS

    FUNCTION sp_imprime_letra (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_numdoc NUMBER
    ) RETURN datatable_imprime_letra
        PIPELINED
    AS
        v_table datatable_imprime_letra;
    BEGIN
        SELECT
            p.id_cia,
            p.series,
            p.numdoc,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.femisi,
            p.fvenci,
            p.tipmon,
            p.importe,
            p.refere,
            m.simbolo,
            s.nomdis,
            p.codcli,
            c.razonc,
            CASE
                WHEN ( upper(b.vchar) = 'S' )
                     AND ( c.codtpe = 1 )
                     AND ( tp.nrodni IS NOT NULL ) THEN
                    tp.nrodni
                ELSE
                    c.dident
            END             AS dident,
            c.codtpe,
            c.direc1,
            c.direc2,
            c.telefono,
            c2.codcli       AS codaval,
            c2.telefono     AS telefonoaval,
            c2.razonc       AS razoncaval,
            CASE
                WHEN ( c2.codtpe = 1 )
                     AND ( cp2.nrodni IS NOT NULL ) THEN
                    cp2.nrodni
                ELSE
                    c2.dident
            END             AS didentaval,
            c2.direc1       AS direc1aval,
            c2.direc2       AS direc2aval,
            c3.codcli       AS codaval2,
            c3.telefono     AS telefonoaval2,
            c14.descodigo   AS dir_depart,
            c15.descodigo   AS dir_provin,
            c16.descodigo   AS dir_distri,
            CASE
                WHEN c14.abrcodigo = '' THEN
                    c14.descodigo
                ELSE
                    c14.abrcodigo
            END             AS distrito,
            c3.razonc       AS razoncaval2,
            c3.dident       AS didentaval2,
            c3.direc1       AS direc1aval2,
            c3.direc2       AS direc2aval2,
            ca116.descodigo AS distriaval1,
            ca216.descodigo AS distriaval2,
            s.codsuc,
            s.sucursal
        BULK COLLECT
        INTO v_table
        FROM
            dcta105                                                 p
            LEFT OUTER JOIN cliente                                                 c ON c.id_cia = p.id_cia
                                         AND c.codcli = p.codacep
            LEFT OUTER JOIN cliente_tpersona                                        tp ON tp.id_cia = p.id_cia
                                                   AND tp.codcli = p.codacep
            LEFT OUTER JOIN tbancos_clase                                           b ON b.id_cia = p.id_cia
                                               AND b.codban = p.codban
                                               AND b.clase = 7
            LEFT OUTER JOIN tmoneda                                                 m ON m.id_cia = p.id_cia
                                         AND m.codmon = p.tipmon
            LEFT OUTER JOIN sucursal                                                s ON s.id_cia = p.id_cia
                                          AND s.codsuc = p.codsuc
            LEFT OUTER JOIN cliente                                                 c2 ON c2.id_cia = p.id_cia
                                          AND c2.codcli = p.codaval01
            LEFT OUTER JOIN cliente_tpersona                                        cp2 ON cp2.id_cia = p.id_cia
                                                    AND cp2.codcli = c2.codcli
            LEFT OUTER JOIN cliente                                                 c3 ON c3.id_cia = p.id_cia
                                          AND c3.codcli = p.codaval02
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'D', p.codaval01, 16) ca116 ON ca116.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'D', p.codaval02, 16) ca216 ON ca216.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 14)    c14 ON c14.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 15)    c15 ON c15.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 16)    c16 ON c16.codigo <> 'ND'
        WHERE
                p.id_cia = pin_id_cia
            AND p.tipdoc = pin_tipdoc
            AND p.numdoc = pin_numdoc
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_imprime_letra;

    FUNCTION sp_imprime_letra_planilla (
        pin_id_cia NUMBER,
        pin_libro VARCHAR2,
        pin_periodo NUMBER,
        pin_mes NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_imprime_letra
        PIPELINED
    AS
        v_table datatable_imprime_letra;
    BEGIN
        SELECT
            p.id_cia,
            p.series,
            p.numdoc,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.femisi,
            p.fvenci,
            p.tipmon,
            p.importe,
            p.refere,
            m.simbolo,
            s.nomdis,
            p.codcli,
            c.razonc,
            CASE
                WHEN ( upper(b.vchar) = 'S' )
                     AND ( c.codtpe = 1 )
                     AND ( tp.nrodni IS NOT NULL ) THEN
                    tp.nrodni
                ELSE
                    c.dident
            END             AS dident,
            c.codtpe,
            c.direc1,
            c.direc2,
            c.telefono,
            c2.codcli       AS codaval,
            c2.telefono     AS telefonoaval,
            c2.razonc       AS razoncaval,
            CASE
                WHEN ( c2.codtpe = 1 )
                     AND ( cp2.nrodni IS NOT NULL ) THEN
                    cp2.nrodni
                ELSE
                    c2.dident
            END             AS didentaval,
            c2.direc1       AS direc1aval,
            c2.direc2       AS direc2aval,
            c3.codcli       AS codaval2,
            c3.telefono     AS telefonoaval2,
            c14.descodigo   AS dir_depart,
            c15.descodigo   AS dir_provin,
            c16.descodigo   AS dir_distri,
            CASE
                WHEN c14.abrcodigo = '' THEN
                    c14.descodigo
                ELSE
                    c14.abrcodigo
            END             AS distrito,
            c3.razonc       AS razoncaval2,
            c3.dident       AS didentaval2,
            c3.direc1       AS direc1aval2,
            c3.direc2       AS direc2aval2,
            ca116.descodigo AS distriaval1,
            ca216.descodigo AS distriaval2,
            s.codsuc,
            s.sucursal
        BULK COLLECT
        INTO v_table
        FROM
            dcta105                                                 p
            LEFT OUTER JOIN cliente                                                 c ON c.id_cia = p.id_cia
                                         AND c.codcli = p.codacep
            LEFT OUTER JOIN cliente_tpersona                                        tp ON tp.id_cia = p.id_cia
                                                   AND tp.codcli = p.codacep
            LEFT OUTER JOIN tbancos_clase                                           b ON b.id_cia = p.id_cia
                                               AND b.codban = p.codban
                                               AND b.clase = 7
            LEFT OUTER JOIN tmoneda                                                 m ON m.id_cia = p.id_cia
                                         AND m.codmon = p.tipmon
            LEFT OUTER JOIN sucursal                                                s ON s.id_cia = p.id_cia
                                          AND s.codsuc = p.codsuc
            LEFT OUTER JOIN cliente                                                 c2 ON c2.id_cia = p.id_cia
                                          AND c2.codcli = p.codaval01
            LEFT OUTER JOIN cliente_tpersona                                        cp2 ON cp2.id_cia = p.id_cia
                                                    AND cp2.codcli = c2.codcli
            LEFT OUTER JOIN cliente                                                 c3 ON c3.id_cia = p.id_cia
                                          AND c3.codcli = p.codaval02
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'D', p.codaval01, 16) ca116 ON ca116.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'D', p.codaval02, 16) ca216 ON ca216.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 14)    c14 ON c14.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 15)    c15 ON c15.codigo <> 'ND'
            LEFT OUTER JOIN sp_select_cliente_clase(p.id_cia, 'A', c.codcli, 16)    c16 ON c16.codigo <> 'ND'
        WHERE
                p.id_cia = pin_id_cia
            AND p.libro = pin_libro
            AND p.periodo  = pin_periodo
            AND ( pin_mes = -1 OR p.mes = pin_mes )
            AND ( pin_secuencia = -1  OR p.secuencia  = pin_secuencia );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_imprime_letra_planilla;

END;

/
