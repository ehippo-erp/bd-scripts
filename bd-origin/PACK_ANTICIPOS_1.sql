--------------------------------------------------------
--  DDL for Package Body PACK_ANTICIPOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ANTICIPOS" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_situac NUMBER,
        pin_detapl NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_anticipo
        PIPELINED
    AS
        v_table datatable_reporte_anticipo;
    BEGIN
        IF pin_detapl = 0 THEN
            IF pin_codcli IS NULL THEN
                SELECT
                    c.id_cia,
                    c.tipdoc,
                    t.descri                     AS desdoc,
                    c.numint,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    c.codcli,
                    c.razonc,
                    cl.dident                    AS ruc,
                    c.direc1                     AS direccion,
                    c.codven,
                    c.incigv,
                    c.destin,
                    c.totbru,
                    c.descue,
                    c.desesp,
                    c.monafe,
                    c.monina,
                    c.porigv,
                    c.monigv,
                    c.costo,
                    c.tipmon,
                    m.simbolo                    AS simmon,
                    c.tipcam,
                    c.seguro,
                    c.flete,
                    c.desexp,
                    c.gasadu,
                    c.pesbru,
                    c.pesnet,
                    c.bultos,
                    c.valfob,
                    c.ffacpro,
                    c.cargo,
                    c.codsuc,
                    c.desseg,
                    c.desgasa,
                    c.desnetx,
                    c.despreven,
                    c.codcob,
                    d1.importe                   AS preven,
                    ( d1.importe - ds106.saldo ) AS facturado,
                    ds106.saldo,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL
                BULK COLLECT
                INTO v_table
                FROM
                    sp000_saca_saldo_dcta106(pin_id_cia, 0) ds106
                    LEFT OUTER JOIN dcta106                                 d1 ON d1.id_cia = pin_id_cia
                                                  AND d1.numint = ds106.numint
                                                  AND d1.item = 0
                                                  AND d1.id = 'I'
                    INNER JOIN documentos_cab                          c ON c.id_cia = pin_id_cia
                                                   AND c.numint = ds106.numint
                    LEFT OUTER JOIN cliente                                 cl ON cl.id_cia = pin_id_cia
                                                  AND cl.codcli = c.codcli
                    LEFT OUTER JOIN documentos_tipo                         t ON t.id_cia = pin_id_cia
                                                         AND t.tipdoc = c.tipdoc
                    LEFT OUTER JOIN tmoneda                                 m ON m.id_cia = pin_id_cia
                                                 AND m.codmon = c.tipmon
                WHERE
                        c.id_cia = pin_id_cia
                    AND ( ( pin_situac = 0
                            AND ds106.saldo IS NOT NULL ) -- TODOS
                          OR ( pin_situac = 1
                               AND ds106.saldo <> 0 ) -- PENDIENTES
                          OR ( pin_situac = 2
                               AND ds106.saldo = 0 ) ) -- CANCELADOS
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                    AND c.situac IN ( 'C', 'F' )
                ORDER BY
                    c.tipdoc,
                    c.series,
                    c.numdoc,
                    c.femisi;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                SELECT
                    c.id_cia,
                    c.tipdoc,
                    t.descri                     AS desdoc,
                    c.numint,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    c.codcli,
                    c.razonc,
                    cl.dident                    AS ruc,
                    c.direc1                     AS direccion,
                    c.codven,
                    c.incigv,
                    c.destin,
                    c.totbru,
                    c.descue,
                    c.desesp,
                    c.monafe,
                    c.monina,
                    c.porigv,
                    c.monigv,
                    c.costo,
                    c.tipmon,
                    m.simbolo                    AS simmon,
                    c.tipcam,
                    c.seguro,
                    c.flete,
                    c.desexp,
                    c.gasadu,
                    c.pesbru,
                    c.pesnet,
                    c.bultos,
                    c.valfob,
                    c.ffacpro,
                    c.cargo,
                    c.codsuc,
                    c.desseg,
                    c.desgasa,
                    c.desnetx,
                    c.despreven,
                    c.codcob,
                    d1.importe                   AS preven,
                    ( d1.importe - ds106.saldo ) AS facturado,
                    ds106.saldo,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL
                BULK COLLECT
                INTO v_table
                FROM
                    sp000_saca_saldo_dcta106_codcli(pin_id_cia, pin_codcli) ds106
                    LEFT OUTER JOIN dcta106                                                 d1 ON d1.id_cia = pin_id_cia
                                                  AND d1.numint = ds106.numint
                                                  AND d1.item = 0
                                                  AND d1.id = 'I'
                    INNER JOIN documentos_cab                                          c ON c.id_cia = pin_id_cia
                                                   AND c.numint = ds106.numint
                    LEFT OUTER JOIN cliente                                                 cl ON cl.id_cia = pin_id_cia
                                                  AND cl.codcli = c.codcli
                    LEFT OUTER JOIN documentos_tipo                                         t ON t.id_cia = pin_id_cia
                                                         AND t.tipdoc = c.tipdoc
                    LEFT OUTER JOIN tmoneda                                                 m ON m.id_cia = pin_id_cia
                                                 AND m.codmon = c.tipmon
                WHERE
                        c.id_cia = pin_id_cia
                    AND ( ( pin_situac = 0
                            AND ds106.saldo IS NOT NULL ) -- TODOS
                          OR ( pin_situac = 1
                               AND ds106.saldo <> 0 ) -- PENDIENTES
                          OR ( pin_situac = 2
                               AND ds106.saldo = 0 ) ) -- CANCELADOS
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                    AND c.situac IN ( 'C', 'F' )
                ORDER BY
                    c.tipdoc,
                    c.series,
                    c.numdoc,
                    c.femisi;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            END IF;

        ELSE
            IF pin_codcli IS NULL THEN
                SELECT
                    c.id_cia,
                    c.tipdoc,
                    t.descri                     AS desdoc,
                    c.numint,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    c.codcli,
                    c.razonc,
                    cl.dident                    AS ruc,
                    c.direc1                     AS direccion,
                    c.codven,
                    c.incigv,
                    c.destin,
                    c.totbru,
                    c.descue,
                    c.desesp,
                    c.monafe,
                    c.monina,
                    c.porigv,
                    c.monigv,
                    c.costo,
                    c.tipmon,
                    m.simbolo                    AS simmon,
                    c.tipcam,
                    c.seguro,
                    c.flete,
                    c.desexp,
                    c.gasadu,
                    c.pesbru,
                    c.pesnet,
                    c.bultos,
                    c.valfob,
                    c.ffacpro,
                    c.cargo,
                    c.codsuc,
                    c.desseg,
                    c.desgasa,
                    c.desnetx,
                    c.despreven,
                    c.codcob,
                    d1.importe                   AS preven,
                    ( d1.importe - ds106.saldo ) AS facturado,
                    ds106.saldo,
                    dap.numint                   AS numintap,
                    dap.femisi                   AS femisiap,
                    dap.tipdoc                   AS tipdocap,
                    dap.series                   AS seriesap,
                    dap.numdoc                   AS numdocap,
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                            dd.importemn
                        ELSE
                            dd.importeme
                    END                          AS importeap
                BULK COLLECT
                INTO v_table
                FROM
                    sp000_saca_saldo_dcta106(pin_id_cia, 0) ds106
                    LEFT OUTER JOIN dcta106                                 d1 ON d1.id_cia = pin_id_cia
                                                  AND d1.numint = ds106.numint
                                                  AND d1.item = 0
                                                  AND d1.id = 'I'
                    INNER JOIN documentos_cab                          c ON c.id_cia = pin_id_cia
                                                   AND c.numint = ds106.numint
                    LEFT OUTER JOIN cliente                                 cl ON cl.id_cia = pin_id_cia
                                                  AND cl.codcli = c.codcli
                    LEFT OUTER JOIN documentos_tipo                         t ON t.id_cia = pin_id_cia
                                                         AND t.tipdoc = c.tipdoc
                    LEFT OUTER JOIN tmoneda                                 m ON m.id_cia = pin_id_cia
                                                 AND m.codmon = c.tipmon
                    LEFT OUTER JOIN dcta106                                 dd ON dd.id_cia = pin_id_cia
                                                  AND dd.numint = ds106.numint
                                                  AND dd.numintap > 0
                    LEFT OUTER JOIN documentos_cab                          dap ON dap.id_cia = pin_id_cia
                                                          AND dap.numint = dd.numintap
                WHERE   
--       WStrWHere
                        c.id_cia = pin_id_cia
                    AND ( ( pin_situac = 0
                            AND ds106.saldo IS NOT NULL ) -- TODOS
                          OR ( pin_situac = 1
                               AND ds106.saldo <> 0 ) -- PENDIENTES
                          OR ( pin_situac = 2
                               AND ds106.saldo = 0 ) ) -- CANCELADOS
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                    AND c.situac IN ( 'C', 'F' )
                ORDER BY
                    c.tipdoc,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    dap.femisi,
                    dap.tipdoc,
                    dap.series,
                    dap.numdoc;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            ELSE
                SELECT
                    c.id_cia,
                    c.tipdoc,
                    t.descri                     AS desdoc,
                    c.numint,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    c.codcli,
                    c.razonc,
                    cl.dident                    AS ruc,
                    c.direc1                     AS direccion,
                    c.codven,
                    c.incigv,
                    c.destin,
                    c.totbru,
                    c.descue,
                    c.desesp,
                    c.monafe,
                    c.monina,
                    c.porigv,
                    c.monigv,
                    c.costo,
                    c.tipmon,
                    m.simbolo                    AS simmon,
                    c.tipcam,
                    c.seguro,
                    c.flete,
                    c.desexp,
                    c.gasadu,
                    c.pesbru,
                    c.pesnet,
                    c.bultos,
                    c.valfob,
                    c.ffacpro,
                    c.cargo,
                    c.codsuc,
                    c.desseg,
                    c.desgasa,
                    c.desnetx,
                    c.despreven,
                    c.codcob,
                    d1.importe                   AS preven,
                    ( d1.importe - ds106.saldo ) AS facturado,
                    ds106.saldo,
                    dap.numint                   AS numintap,
                    dap.femisi                   AS femisiap,
                    dap.tipdoc                   AS tipdocap,
                    dap.series                   AS seriesap,
                    dap.numdoc                   AS numdocap,
                    CASE
                        WHEN c.tipmon = 'PEN' THEN
                            dd.importemn
                        ELSE
                            dd.importeme
                    END                          AS importeap
                BULK COLLECT
                INTO v_table
                FROM
                    sp000_saca_saldo_dcta106_codcli(pin_id_cia, pin_codcli) ds106
                    LEFT OUTER JOIN dcta106                                                 d1 ON d1.id_cia = pin_id_cia
                                                  AND d1.numint = ds106.numint
                                                  AND d1.item = 0
                                                  AND d1.id = 'I'
                    INNER JOIN documentos_cab                                          c ON c.id_cia = pin_id_cia
                                                   AND c.numint = ds106.numint
                    LEFT OUTER JOIN cliente                                                 cl ON cl.id_cia = pin_id_cia
                                                  AND cl.codcli = c.codcli
                    LEFT OUTER JOIN documentos_tipo                                         t ON t.id_cia = pin_id_cia
                                                         AND t.tipdoc = c.tipdoc
                    LEFT OUTER JOIN tmoneda                                                 m ON m.id_cia = pin_id_cia
                                                 AND m.codmon = c.tipmon
                    LEFT OUTER JOIN dcta106                                                 dd ON dd.id_cia = pin_id_cia
                                                  AND dd.numint = ds106.numint
                                                  AND dd.numintap > 0
                    LEFT OUTER JOIN documentos_cab                                          dap ON dap.id_cia = pin_id_cia
                                                          AND dap.numint = dd.numintap
                WHERE   
--       WStrWHere
                        c.id_cia = pin_id_cia
                    AND ( ( pin_situac = 0
                            AND ds106.saldo IS NOT NULL ) -- TODOS
                          OR ( pin_situac = 1
                               AND ds106.saldo <> 0 ) -- PENDIENTES
                          OR ( pin_situac = 2
                               AND ds106.saldo = 0 ) ) -- CANCELADOS
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                    AND c.situac IN ( 'C', 'F' )
                ORDER BY
                    c.tipdoc,
                    c.series,
                    c.numdoc,
                    c.femisi,
                    dap.femisi,
                    dap.tipdoc,
                    dap.series,
                    dap.numdoc;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            END IF;
        END IF;
    END sp_buscar;

END;

/
