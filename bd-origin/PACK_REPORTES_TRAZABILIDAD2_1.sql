--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TRAZABILIDAD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TRAZABILIDAD2" AS

    FUNCTION sp_ordenpedido (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenpedido
        PIPELINED
    AS
        v_table datatable_ordenpedido;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                            AS numint,
            d.numite                            AS numite,
            c.series                            AS series,
            c.numdoc                            AS numdoc,
            c.femisi                            AS femisi,
            c.codsuc,
            c.opnumdoc                          AS opnumdoc,
            c.razonc                            AS razonc,
            c.direc1                            AS direc1,
            c.ruc                               AS ruc,
            c.tipmon                            AS tipmon,
            c.fentreg                           AS fentreg,
            c.fecter                            AS fecter,
            c.horter                            AS horter,
            c.observ                            AS obscab,
            c.monafe                            AS monafe,
            c.monina                            AS monina,
            c.monafe + c.monina + c.monexo      AS monneto,
            c.monexo                            AS monexo,
            c.monigv                            AS monigv,
            c.monisc                            AS monisc,
            c.monotr                            AS monotr,
            c.preven                            AS preven,
            c.costo,
--            CASE
--                WHEN c.incigv = 'N' THEN
--                    c.costo
--                ELSE
--                    c.costo * ( ( 100 + c.porigv ) / 100 )
--            END                                 AS costo,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                                   AS totpag,
            c.porigv                            AS porigv,
            c.incigv                            AS incigv,
            c.desesp                            AS desesp,
            c1.fax                              AS faxcli,
            c1.telefono                         AS tlfcli,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                                 AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                                 AS glosxdes,
            dca.direc1                          AS desenv01,
            t1.descri                           AS destra,
            t2.descri                           AS destra2,
            dcc.atenci                          AS atenci,
            v1.desven                           AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                                 AS aliassit,
            s2.dessit                           AS dessit,
            mt.desmot                           AS desmot,
            ds.tipimp,
            df.formato                          AS tipimpformato,
            d.tipinv,
            d.codart                            AS codart,
            a.descri                            AS desart,
--            CASE
--                WHEN c33.codigo != 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart != '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart IS NOT NULL
--                                     AND length(lp33.desart) > 0 THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                                 AS desart,
            a.consto                            AS consto,
            d.codalm                            AS codalm,
            d.observ                            AS obsdet,
            d.monafe                            AS monafedet,
            d.monina                            AS moninadet,
            d.monisc                            AS moniscdet,
            d.monigv                            AS monigvdet,
            d.monotr                            AS monotrdet,
            d.codund                            AS codunddet,
            a.coduni                            AS codund,
            d.cantid                            AS cantid,
            d.piezas                            AS piezas,
            d.largo                             AS largo,
            d.ancho                             AS ancho,
            d.preuni                            AS preuni,
            d.cosuni                            AS coduni,
            CASE
                WHEN d.importe = 0 THEN
                    0
                ELSE
                    round(((d.importe -(d.cosuni * d.cantid)) / d.importe) * 100, 2)
            END                                 AS margen,
            d.importe                           AS importe,
            d.importe_bruto                     AS importe_bruto,
            d.pordes1                           AS pordes1,
            d.pordes2                           AS pordes2,
            d.pordes3                           AS pordes3,
            d.pordes4                           AS pordes4,
            d.opronumdoc                        AS opronumdoc,
            d.etiqueta                          AS etiqueta,
            d.nrocarrete                        AS nrocarrete,
            d.acabado                           AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            ( k.ingreso - k.salida )            AS stockk001,
            ( k.ingreso - k.salida ) - d.cantid AS saldok001,
            m1.simbolo                          AS simbolo,
            m1.desmon                           AS desmon,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                             AS porpercep,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    's'
                ELSE
                    'n'
            END                                 AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                                 AS astpercep,
            gar.glosa                           AS glosagar,
            gap.glosa                           AS glosagap,
            gfp.glosa                           AS glosagfp,
            dc2.vstrg                           AS codpiepagforf01,
            dc3.vstrg                           AS codpiepagforf02,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                                   AS valundaltven,
            sv.usuari                           AS c_visadopor,
            uv.nombres                          AS visadopor,
            se.usuari                           AS c_emitidopor,
            ue.nombres                          AS emitidopor,
            dap.uactua                          AS c_aprobadopor,
            ua.nombres                          AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                                   AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )                    AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )                    AS ubigeo_b,
            doc.fecha                           AS fecha_dcorcom,
            doc.numero                          AS numero_dcorcom,
            doc.contacto                        AS contacto_dcorcom,
            un.abrevi                           AS abrunidad,
            d.codadd01,
            cl1.descri                          AS descodadd01,
            d.codadd02,
            cl2.descri                          AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos                  ds ON ds.id_cia = c.id_cia
                                             AND ( ds.codigo = c.tipdoc )
                                             AND ( ds.series = c.series )
            LEFT OUTER JOIN documentos_formatos         df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente                     c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista               t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos                     mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN documentos_cab_ordcom       doc ON doc.id_cia = c.id_cia
                                                         AND doc.numint = c.numint
            LEFT OUTER JOIN documentos_cab_almacen      dca ON dca.id_cia = c.id_cia
                                                          AND ( dca.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON dcc.id_cia = c.id_cia
                                                           AND ( dcc.numint = c.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det              d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN kardex001                   k ON k.id_cia = d.id_cia
                                           AND ( k.tipinv = d.tipinv )
                                           AND ( k.codart = d.codart )
                                           AND ( k.codalm = d.codalm )
                                           AND ( k.etiqueta = d.etiqueta )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN cliente_articulos_clase     cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase     cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN documentos_clase            dc2 ON dc2.id_cia = c.id_cia
                                                    AND dc2.codigo = c.tipdoc
                                                    AND dc2.series = c.series
                                                    AND dc2.clase = 14
            LEFT OUTER JOIN documentos_clase            dc3 ON dc3.id_cia = c.id_cia
                                                    AND dc3.codigo = c.tipdoc
                                                    AND dc3.series = c.series
                                                    AND dc3.clase = 15
            LEFT OUTER JOIN companias_glosa             gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN cliente_clase               c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN listaprecios                lp33 ON lp33.id_cia = c.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa    lpa33 ON lpa33.id_cia = c.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN documentos_situac_max       sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios                    uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max       se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios                    ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion       dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios                    ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordenpedido;

    FUNCTION sp_cotizacion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_cotizacion
        PIPELINED
    AS
        v_table datatable_cotizacion;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc                    AS tipdoc,
            dx.descri                   AS desdoc,
            c.codsuc,
            c.numint                    AS numint,
            d.numite                    AS numite,
            c.series                    AS series,
            c.numdoc                    AS numdoc,
            c.femisi                    AS femisi,
            c.codcli                    AS codcli,
            c.razonc                    AS razonc,
            c.direc1                    AS direc1,
            c.ruc                       AS ruc,
            c.tipcam                    AS tipcam,
            c.tipmon                    AS tipmon,
            c.situac                    AS situac,
            c.observ                    AS obscab,
            c.fentreg                   AS fentreg,
            c.ffacpro                   AS ffacpro,
            c.ordcom                    AS ordcom,
            c.guiarefe                  AS guiarefe,
            c.marcas                    AS marcas,
            d.tipinv,
            d.codart,
            d.positi                    AS positi,
            d.codund                    AS codunddet,
            d.cantid                    AS cantid,
            d.preuni                    AS preuni,
            d.cosuni                    AS coduni,
            CASE
                WHEN d.importe = 0 THEN
                    0
                ELSE
                    round(((d.importe -(d.cosuni * d.cantid)) / d.importe) * 100, 2)
            END                         AS margen,
            d.importe                   AS importe,
            d.pordes1                   AS pordes1,
            d.pordes2                   AS pordes2,
            d.pordes3                   AS pordes3,
            d.pordes4                   AS pordes4,
            d.ubica                     AS ubica,
            d.importe_bruto - d.importe AS descdet,
            d.observ                    AS obsdet,
            d.swacti                    AS swacti,
            c.monafe + c.monina         AS monneto,
            c.monigv                    AS monigv,
            c.preven                    AS preven,
            c.costo,
--            CASE
--                WHEN c.incigv = 'N' THEN
--                    c.costo
--                ELSE
--                    c.costo * ( ( 100 + c.porigv ) / 100 )
--            END                         AS costo,
            c.descue                    AS descue,
            c.totbru                    AS totbru,
            (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS percep,
            ( c.preven ) + (
                CASE
                    WHEN dct.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 2))
                    ELSE
                        dct.vreal
                END
            )                           AS totpag,
            c.porigv                    AS porigv,
            c.incigv                    AS incigv,
            dcc.atenci                  AS atenci,
            dcc.plaent                  AS plaent,
            dcc.valide                  AS valide,
            dcc.email                   AS mailcont,
            CASE
                WHEN ( cc.vstrg IS NULL ) THEN
                    c.numped
                ELSE
                    cc.vstrg
            END                         AS numped,
            a.descri                    AS desart,
--            CASE
--                WHEN c33.codigo != 'S' THEN
--                    a.descri
--                ELSE
--                    CASE
--                        WHEN lpa33.desart != '' THEN
--                                lpa33.desart
--                        ELSE
--                            CASE
--                                WHEN lp33.desart IS NOT NULL
--                                     AND length(lp33.desart) > 0 THEN
--                                            lp33.desart
--                                ELSE
--                                    a.descri
--                            END
--                    END
--            END                         AS desart,
            a.coduni                    AS codund,
            a.codlin                    AS conlin,
            a.faccon                    AS faccon,
            a.conesp                    AS conesp,
            d.cantid * a.faccon         AS pesdet,
            c.codcpag                   AS codcpag,
            cv.despag                   AS despagven,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                         AS glosxdes,
            v1.codven                   AS codven,
            v1.desven                   AS desven,
            v1.cargo                    AS carven,
            v1.email                    AS mailven,
            v1.celular                  AS celuven,
            v1.telefo                   AS tlfven,
            m1.simbolo                  AS simbolo,
            m1.desmon                   AS desmon,
            s2.alias                    AS aliassit,
            vcc.descri                  AS especialidad,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                    CAST('S' AS VARCHAR(20))
                ELSE
                    CAST('N' AS VARCHAR(20))
            END                         AS swdocpercep,
            CASE
                WHEN ( ( fap.vstrg IS NOT NULL )
                       AND ( upper(fap.vstrg) = 'S' )
                       AND ( ddp.vreal IS NOT NULL )
                       AND ( ddp.vreal > 0 ) ) THEN
                    '*'
                ELSE
                    ''
            END                         AS astpercep,
            gar.glosa                   AS glosagar,
            gap.glosa                   AS glosagap,
            gfp.glosa                   AS glosagfp,
            CASE
                WHEN ( ( dcp.codigo IS NOT NULL )
                       AND ( upper(dcp.codigo) = 'S' ) ) THEN
                        ccc.codigo
                ELSE
                    CAST('0.00' AS VARCHAR(20))
            END
            || ' %'                     AS porpercep,
            (
                SELECT
                    glosa
                FROM
                    companias_glosa
                WHERE
                        id_cia = pin_id_cia
                    AND item = 9
            )                           AS gnotas,
            (
                CASE
                    WHEN aca1.vreal IS NULL THEN
                        CAST(0 AS NUMERIC(12, 6))
                    ELSE
                        aca1.vreal
                END
            )                           valundaltven,
            ( cc14.descri
              || ' - '
              || cc15.descri
              || ' - '
              || cc16.descri )            AS ubigeo,
            ( cc16.descri
              || ' -'
              || cc15.descri
              || ' - '
              || cc14.descri )            AS ubigeo_b,
            un.abrevi                   AS abrunidad,
            dca.direc1                  AS desenv01,
            t1.descri                   AS destra,
            cia.ruc                     AS ruccia,
            df.formato                  AS formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT OUTER JOIN documentos_det              d ON ( d.id_cia = c.id_cia
                                                  AND d.numint = c.numint )
            LEFT OUTER JOIN unidad                      un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN cliente                     c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN cliente_clase               c33 ON c33.id_cia = c.id_cia
                                                 AND ( c33.tipcli = 'A' )
                                                 AND ( c33.codcli = c.codcli )
                                                 AND ( c33.clase = 33 )
            LEFT OUTER JOIN cliente_clase               ccc ON ccc.id_cia = c.id_cia
                                                 AND ( ccc.tipcli = 'A' )
                                                 AND ( ccc.codcli = c.codcli )
                                                 AND ( ccc.clase = 23 )
            LEFT OUTER JOIN cliente_clase               c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo        cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase               c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo        cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase               c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo        cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN listaprecios                lp33 ON lp33.id_cia = c1.id_cia
                                                 AND lp33.vencom = 1
                                                 AND lp33.codtit = c1.codtit
                                                 AND lp33.tipinv = d.tipinv
                                                 AND lp33.codart = d.codart
            LEFT OUTER JOIN listaprecios_alternativa    lpa33 ON lpa33.id_cia = c1.id_cia
                                                              AND lpa33.vencom = 1
                                                              AND lpa33.codtit = c1.codtit
                                                              AND lpa33.tipinv = d.tipinv
                                                              AND lpa33.codart = d.codart
                                                              AND lpa33.codadd01 = d.codadd01
                                                              AND lpa33.codadd02 = d.codadd02
            LEFT OUTER JOIN documentos_cab_almacen      dca ON c.id_cia = dca.id_cia
                                                          AND ( c.numint = dca.numint )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON ( c.id_cia = dcc.id_cia
                                                             AND c.numint = dcc.numint )
            LEFT OUTER JOIN documentos_cab_clase        cc ON cc.id_cia = c.id_cia
                                                       AND ( cc.numint = c.numint )
                                                       AND ( cc.clase = 6 )
            LEFT OUTER JOIN documentos_cab_clase        dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase        dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase        ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN factor                      far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                      fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN companias_glosa             gar ON gar.id_cia = far.id_cia
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa             gap ON gap.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa             gfp ON gfp.id_cia = fap.id_cia
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN c_pago                      cv ON cv.id_cia = c.id_cia
                                         AND ( cv.codpag = c.codcpag )
                                         AND ( upper(cv.swacti) = 'S' )
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN vendedor_clase              vc ON vc.id_cia = c.id_cia
                                                 AND ( vc.codven = c.codven )
                                                 AND ( vc.clase = 3 )
            LEFT OUTER JOIN clase_vendedor_codigo       vcc ON vcc.id_cia = vc.id_cia
                                                         AND ( vcc.clase = vc.clase )
                                                         AND ( vcc.codigo = vc.codigo )
            LEFT OUTER JOIN situacion                   s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN articulos_clase_alternativo aca1 ON aca1.id_cia = d.id_cia
                                                                AND aca1.tipinv = d.tipinv
                                                                AND aca1.codart = d.codart
                                                                AND aca1.clase = 1
                                                                AND aca1.codigo = d.codund
            LEFT OUTER JOIN documentos                  dx ON dx.id_cia = c.id_cia
                                             AND ( dx.codigo = c.tipdoc )
                                             AND ( dx.series = c.series )
            LEFT OUTER JOIN documentos_formatos         df ON df.tipdoc = dx.codigo
                                                      AND df.item = nvl(dx.tipimp, 1)
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN companias                   cia ON cia.cia = c.id_cia
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
            AND c.tipdoc = 100
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cotizacion;

    FUNCTION sp_reqcompra (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reqcompra
        PIPELINED
    AS
        v_table datatable_reqcompra;
    BEGIN
        SELECT
            c.tipdoc,
            c.numint,
            c.series,
            c.numdoc,
            c.femisi,
            c.codcli,
            c.razonc,
            c.direc1,
            c.ruc,
            c.tipcam,
            c.descue,
            c.totbru,
            c.monafe,
            c.monina,
            c.monafe + c.monina         AS monneto,
            c.monigv,
            c.preven,
            c.porigv,
            c.incigv,
            c.codsuc,
            c.numped,
            c.codmot,
            c.situac,
            c.observ                    AS obscab,
            c.fentreg,
            c.codarea,
            c.coduso,
            c.totcan,
            c.horing,
            c.fecter,
            c.horter,
            c.codtec,
            c.opnumdoc,
            c.ordcom,
            c.guiarefe,
            c.numvale,
            c.fecvale,
            c.codsec,
            c.destin,
            c.tipmon,
            mt.desmot,
            sit.dessit,
            CASE
                WHEN dap.situac = 'B' THEN
                    'APROBADA'
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                'DESAPROBADO'
                        ELSE
                            sit.alias
                    END
            END                         AS aliassit,
            cv.despag                   AS despagcom,
            m1.simbolo,
            m1.desmon,
            cl.direc1                   AS dircli1,
            cl.direc2                   AS dircli2,
            cl.fax                      AS faxcli,
            cl.telefono                 AS tlfcli,
            dca.codenv,
            dca.direc1                  AS desenv01,
            dca.direc2                  AS desenv02,
            dcc.atenci,
            dcc.email                   AS emailcon,
            dcc.plaent,
            dcc.valide,
            su.sucursal                 AS dessuc,
            su.direcc                   AS direcc,
            su.nomdis                   AS dissuc,
            v1.desven,
            v1.cargo                    AS carven,
            v1.email                    AS mailven,
            v1.celular                  AS celuven,
            v1.telefo                   AS tlfven,
            v1.comisi                   AS comiven,
            v1.codven                   AS codvendedor,
            t1.descri                   AS destra,
            t1.domici                   AS dirtra,
            t1.ruc                      AS ructra,
            t1.punpar                   AS punpartra,
            d.numite                    AS dd_numite,
            d.tipinv                    AS dd_tipinv,
            d.codart                    AS dd_codart,
            d.codalm                    AS dd_codalm,
            d.codund                    AS dd_codund,
            d.diseno                    AS dd_diseno,
            d.acabado                   AS dd_acabado,
            d.cantid                    AS dd_cantid,
            d.piezas                    AS dd_piezas,
            d.largo                     AS dd_largo,
            d.preuni                    AS dd_preuni,
            d.cosuni                    AS dd_cosuni,
            d.ancho                     AS dd_ancho,
            d.importe_bruto             AS dd_importe_bruto,
            d.importe                   AS dd_importe,
            d.importe_bruto - d.importe AS dd_descdet,
            d.observ                    AS dd_obsdet,
            d.pordes1                   AS dd_pordes1,
            d.pordes2                   AS dd_pordes2,
            d.pordes3                   AS dd_pordes3,
            d.pordes4                   AS dd_pordes4,
            a.proart                    AS dd_proart,
            a.descri                    AS dd_desart,
            a.descri
            || '-'
            ||
            CASE
                WHEN dc.codigo IS NULL THEN
                        ' '
                ELSE
                    dc.codigo
            END
            || '-'
            ||
            CASE
                WHEN cdc.descri IS NULL THEN
                        ' '
                ELSE
                    cdc.descri
            END
            AS dd_desartclase,
            a.codlin                    AS dd_codlin,
            a.faccon                    AS dd_faccon,
            a1.desarea                  AS dd_desarea,
            al.descri                   AS dd_desalm,
            u.desuso                    AS dd_desuso,
            d.cantid * a.faccon         AS dd_pesdet,
			-- S5.NOMDIS,
			-- S5.PLAZA,
			-- S5.SUCURSAL,
			-- TI.DTIPINV,
            lp.sku,
            CASE
                WHEN lp.desart <> '' THEN
                    lp.desart
                ELSE
                    a.descri
            END                         AS dd_desart_sku,
			-- (SELECT GLOSA FROM COMPANIAS_GLOSA WHERE CIA=1 AND ITEM=11) AS GPIEPA,
			-- (SELECT SP01_SACA_UNA_CUENTA_CLIENTE(c.id_cia,C.CODCLI,'PEN') FROM dual) AS
			-- CUENTA01PROV,
			-- (SELECT SP01_SACA_UNA_CUENTA_CLIENTE(c.id_cia,C.CODCLI,'USD EUR') FROM dual) AS
			-- CUENTA02PROV,
			-- C2.RAZSOC AS CIARAZONC,
			-- C2.RUC AS CIARUC,
			-- C2.FAX AS CIAFAX,
			-- C2.TELEFO AS CIATELEFO,
            cl1.codigo                  AS dd_codcalid,
            cl1.descri                  AS dd_dcalidad,
            cl2.codigo
            || ' - '
            || cl2.descri               AS dd_dcolor,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    'N'
                ELSE
                    ac5.codigo
            END                         AS dd_glosxdes,
            dx.descri                   AS desdoc,
            dx.nomser,
            dg.observ                   AS glosadoc,
            df.formato                  AS formatoimpresion
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab              c
            LEFT JOIN documentos_det              d ON c.id_cia = d.id_cia
                                          AND c.numint = d.numint
            LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                           AND a.codart = d.codart
                                           AND a.tipinv = d.tipinv
            LEFT JOIN documentos                  dx ON dx.id_cia = c.id_cia
                                       AND dx.codigo = c.tipdoc
                                       AND dx.series = c.series
            LEFT OUTER JOIN documentos_formatos         df ON df.tipdoc = dx.codigo
                                                      AND df.item = dx.tipimp
            LEFT JOIN documentos_glosa            dg ON dg.id_cia = c.id_cia
                                             AND ( dg.codigo = c.tipdoc )
                                             AND ( dg.series = c.series )
            LEFT JOIN documentos_det_imagen       di ON di.id_cia = c.id_cia
                                                  AND ( di.numint = c.numint )
                                                  AND ( di.numite = d.numite )
            LEFT OUTER JOIN documentos_aprobacion       dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
		-- LEFT OUTER JOIN SITUACION OS 				ON OS.id_cia = C.id_cia and OS.TIPDOC = C.TIPDOC AND OS.SITUAC='O'
            LEFT OUTER JOIN c_pago_compras              cv ON cv.id_cia = c.id_cia
                                                 AND ( cv.codpag = c.codcpag )
            LEFT OUTER JOIN sucursal                    su ON su.id_cia = c.id_cia
                                           AND su.codsuc = c.codsuc
            LEFT OUTER JOIN cliente                     cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN vendedor                    v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN tmoneda                     m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
		-- LEFT OUTER JOIN T_INVENTARIO TI 			ON TI.id_cia = D.id_cia and (TI.TIPINV = D.TIPINV)
            LEFT OUTER JOIN situacion                   sit ON sit.id_cia = c.id_cia
                                             AND sit.situac = c.situac
                                             AND sit.tipdoc = c.tipdoc
            LEFT OUTER JOIN transportista               t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN motivos                     mt ON mt.id_cia = c.id_cia
                                          AND mt.codmot = c.codmot
                                          AND mt.id = c.id
                                          AND mt.tipdoc = c.tipdoc
            LEFT OUTER JOIN areas                       a1 ON a1.id_cia = c.id_cia
                                        AND a1.codarea = c.codarea
            LEFT OUTER JOIN usos                        u ON u.id_cia = c.id_cia
                                      AND u.coduso = c.coduso
                                      AND u.codarea = c.codarea 
		-- LEFT OUTER JOIN COMPANIAS C2 				ON C2.cia = C.id_cia and (C.CODSUC = C2.CODSUC)
            LEFT OUTER JOIN almacen                     al ON al.id_cia = d.id_cia
                                          AND ( al.tipinv = d.tipinv )
                                          AND ( al.codalm = d.codalm )
            LEFT OUTER JOIN documentos_cab_contacto     dcc ON c.id_cia = dcc.id_cia
                                                           AND c.numint = dcc.numint
            LEFT OUTER JOIN documentos_cab_almacen      dca ON c.id_cia = dca.id_cia
                                                          AND c.numint = dca.numint
		-- LEFT OUTER JOIN SUCURSAL S5 				ON S5.id_cia = DCA.id_cia and (S5.CODSUC = CASE WHEN DCA.CODENV=0 THEN 1 ELSE DCA.CODENV END )
            LEFT OUTER JOIN documentos_det_clase        dc ON dc.id_cia = c.id_cia
                                                       AND ( dc.numint = c.numint )
                                                       AND ( dc.numite = d.numite )
                                                       AND ( dc.clase = 1 )
            LEFT OUTER JOIN clase_documentos_det_codigo cdc ON cdc.id_cia = d.id_cia
                                                               AND ( cdc.tipdoc = d.tipdoc )
                                                               AND ( cdc.clase = dc.clase )
                                                               AND ( cdc.codigo = dc.codigo )
            LEFT OUTER JOIN cliente_articulos_clase     cl1 ON cl1.id_cia = a.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase     cl2 ON cl2.id_cia = a.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
            LEFT OUTER JOIN listaprecios                lp ON lp.id_cia = c.id_cia
                                               AND ( lp.vencom = 2 )
                                               AND ( lp.codtit = '99999' )
                                               AND ( lp.codpro = c.codcli )
                                               AND ( lp.tipinv = d.tipinv )
                                               AND ( lp.codart = d.codart )
            LEFT OUTER JOIN articulos_clase             ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reqcompra;

    FUNCTION sp_ordenproduccion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenproduccion
        PIPELINED
    AS
        v_table datatable_ordenproduccion;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                       AS numint,
            d.numite                       AS numite,
            c.series                       AS series,
            c.numdoc                       AS numdoc,
            c.femisi                       AS femisi,
            c.codsuc,
            c.opnumdoc                     AS opnumdoc,
            c.razonc                       AS razonc,
            c.direc1                       AS direc1,
            c.ruc                          AS ruc,
            c.tipmon                       AS tipmon,
            c.fentreg                      AS fentreg,
            c.fecter                       AS fecter,
            c.horter                       AS horter,
            c.observ                       AS obscab,
            c.presen                       AS comentario,
            c.monafe                       AS monafe,
            c.monina                       AS monina,
            c.monafe + c.monina + c.monexo AS monneto,
            c.monexo                       AS monexo,
            c.monigv                       AS monigv,
            c.monisc                       AS monisc,
            c.monotr                       AS monotr,
            c.preven                       AS preven,
            0                              AS percep,
            c.preven                       AS totpag,
            c.porigv                       AS porigv,
            c.incigv                       AS incigv,
            c.desesp                       AS desesp,
            c1.fax                         AS faxcli,
            c1.telefono                    AS tlfcli,
            c.numped                       AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                            AS glosxdes,
            NULL                           AS desenv01,
            t1.descri                      AS destra,
            t2.descri                      AS destra2,
            NULL                           AS atenci,
            v1.desven                      AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                            AS aliassit,
            s2.dessit                      AS dessit,
            mt.desmot                      AS desmot,
            ds.tipimp,
            df.formato                     AS tipimpformato,
            d.tipinv,
            d.codart                       AS codart,
            a.descri                       AS desart,
            a.consto                       AS consto,
            d.codalm                       AS codalm,
            d.observ                       AS obsdet,
            d.monafe                       AS monafedet,
            d.monina                       AS moninadet,
            d.monisc                       AS moniscdet,
            d.monigv                       AS monigvdet,
            d.monotr                       AS monotrdet,
            d.codund                       AS codunddet,
            a.coduni                       AS codund,
            d.cantid                       AS cantid,
            d.piezas                       AS piezas,
            d.largo                        AS largo,
            d.ancho                        AS ancho,
            d.preuni                       AS preuni,
            d.importe                      AS importe,
            d.importe_bruto                AS importe_bruto,
            d.pordes1                      AS pordes1,
            d.pordes2                      AS pordes2,
            d.pordes3                      AS pordes3,
            d.pordes4                      AS pordes4,
            d.opronumdoc                   AS opronumdoc,
            d.etiqueta                     AS etiqueta,
            d.nrocarrete                   AS nrocarrete,
            d.acabado                      AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            0                              AS stockk001,
            0                              AS saldok001,
            m1.simbolo                     AS simbolo,
            m1.desmon                      AS desmon,
            NULL                           AS porpercep,
            NULL                           AS swdocpercep,
            NULL                           AS astpercep,
            gar.glosa                      AS glosagar,
            gap.glosa                      AS glosagap,
            gfp.glosa                      AS glosagfp,
            NULL                           AS codpiepagforf01,
            NULL                           AS codpiepagforf02,
            0                              AS valundaltven,
            sv.usuari                      AS c_visadopor,
            uv.nombres                     AS visadopor,
            se.usuari                      AS c_emitidopor,
            ue.nombres                     AS emitidopor,
            dap.uactua                     AS c_aprobadopor,
            ua.nombres                     AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                              AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )               AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )               AS ubigeo_b,
--            doc.fecha                      AS fecha_dcorcom,
            NULL                           AS fecha_dcorcom,
--            doc.numero                     AS numero_dcorcom,
            NULL                           AS numero_dcorcom,
--            doc.contacto                   AS contacto_dcorcom,
            NULL                           AS contacto_dcorcom,
            un.abrevi                      AS abrunidad,
            d.codadd01,
--            cl1.descri                          AS descodadd01,
            NULL                           AS descodadd01,
            d.codadd02,
--            cl2.descri                          AS descodadd02
            NULL                           AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos            ds ON ds.id_cia = c.id_cia
                                             AND ds.codigo = c.tipdoc
                                             AND ds.series = c.series
            LEFT OUTER JOIN documentos_formatos   df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente               c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor              v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion             s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista         t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista         t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos               mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase         c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo  cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase         c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo  cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase         c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo  cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN factor                far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN documentos_cab_clase  dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase  dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase  ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda               m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN companias_glosa       gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa       gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa       gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase       ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN documentos_situac_max sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios              uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios              ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios              ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordenproduccion;

    FUNCTION sp_ordentrabajo (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_ordenproduccion
        PIPELINED
    AS
        v_table datatable_ordenproduccion;
    BEGIN
        SELECT
            c.id_cia,
            c.numint                       AS numint,
            d.numite                       AS numite,
            c.series                       AS series,
            c.numdoc                       AS numdoc,
            c.femisi                       AS femisi,
            c.codsuc,
            c.opnumdoc                     AS opnumdoc,
            c.razonc                       AS razonc,
            c.direc1                       AS direc1,
            c.ruc                          AS ruc,
            c.tipmon                       AS tipmon,
            c.fentreg                      AS fentreg,
            c.fecter                       AS fecter,
            c.horter                       AS horter,
            c.observ                       AS obscab,
            c.presen                       AS comentario,
            c.monafe                       AS monafe,
            c.monina                       AS monina,
            c.monafe + c.monina + c.monexo AS monneto,
            c.monexo                       AS monexo,
            c.monigv                       AS monigv,
            c.monisc                       AS monisc,
            c.monotr                       AS monotr,
            c.preven                       AS preven,
            0                              AS percep,
            c.preven                       AS totpag,
            c.porigv                       AS porigv,
            c.incigv                       AS incigv,
            c.desesp                       AS desesp,
            c1.fax                         AS faxcli,
            c1.telefono                    AS tlfcli,
            c.numped                       AS numped,
            CASE
                WHEN ac5.codigo IS NULL THEN
                    CAST('N' AS VARCHAR(20))
                ELSE
                    ac5.codigo
            END                            AS glosxdes,
            NULL                           AS desenv01,
            t1.descri                      AS destra,
            t2.descri                      AS destra2,
            NULL                           AS atenci,
            v1.desven                      AS desven,
            CASE
                WHEN dap.situac = 'B' THEN
                    CAST('Aprobado' AS VARCHAR(50))
                ELSE
                    CASE
                        WHEN dap.situac = 'J' THEN
                                CAST('Desaprobado' AS VARCHAR(50))
                        ELSE
                            s2.alias
                    END
            END                            AS aliassit,
            s2.dessit                      AS dessit,
            mt.desmot                      AS desmot,
            ds.tipimp,
            df.formato                     AS tipimpformato,
            d.tipinv,
            d.codart                       AS codart,
            a.descri                       AS desart,
            a.consto                       AS consto,
            d.codalm                       AS codalm,
            d.observ                       AS obsdet,
            d.monafe                       AS monafedet,
            d.monina                       AS moninadet,
            d.monisc                       AS moniscdet,
            d.monigv                       AS monigvdet,
            d.monotr                       AS monotrdet,
            d.codund                       AS codunddet,
            a.coduni                       AS codund,
            d.cantid                       AS cantid,
            d.piezas                       AS piezas,
            d.largo                        AS largo,
            d.ancho                        AS ancho,
            d.preuni                       AS preuni,
            d.importe                      AS importe,
            d.importe_bruto                AS importe_bruto,
            d.pordes1                      AS pordes1,
            d.pordes2                      AS pordes2,
            d.pordes3                      AS pordes3,
            d.pordes4                      AS pordes4,
            d.opronumdoc                   AS opronumdoc,
            d.etiqueta                     AS etiqueta,
            d.nrocarrete                   AS nrocarrete,
            d.acabado                      AS acabado,
            d.chasis,
            d.motor,
            d.lote,
            d.fvenci,
            0                              AS stockk001,
            0                              AS saldok001,
            m1.simbolo                     AS simbolo,
            m1.desmon                      AS desmon,
            NULL                           AS porpercep,
            NULL                           AS swdocpercep,
            NULL                           AS astpercep,
            gar.glosa                      AS glosagar,
            gap.glosa                      AS glosagap,
            gfp.glosa                      AS glosagfp,
            NULL                           AS codpiepagforf01,
            NULL                           AS codpiepagforf02,
            0                              AS valundaltven,
            sv.usuari                      AS c_visadopor,
            uv.nombres                     AS visadopor,
            se.usuari                      AS c_emitidopor,
            ue.nombres                     AS emitidopor,
            dap.uactua                     AS c_aprobadopor,
            ua.nombres                     AS aprobadopor,
            (
                CASE
                    WHEN dap.situac IS NULL THEN
                        CAST('E' AS CHAR(1))
                    ELSE
                        dap.situac
                END
            )                              AS situac_aprob,
            ( cc14.descri
              || ','
              || cc15.descri
              || ','
              || cc16.descri )               AS ubigeo,
            ( cc16.descri
              || ' - '
              || cc15.descri
              || '- '
              || cc14.descri )               AS ubigeo_b,
--            doc.fecha                      AS fecha_dcorcom,
            NULL                           AS fecha_dcorcom,
--            doc.numero                     AS numero_dcorcom,
            NULL                           AS numero_dcorcom,
--            doc.contacto                   AS contacto_dcorcom,
            NULL                           AS contacto_dcorcom,
            un.abrevi                      AS abrunidad,
            d.codadd01,
--            cl1.descri                          AS descodadd01,
            NULL                           AS descodadd01,
            d.codadd02,
--            cl2.descri                          AS descodadd02
            NULL                           AS descodadd02,
            df.formato
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos            ds ON ds.id_cia = c.id_cia
                                             AND ds.codigo = c.tipdoc
                                             AND ds.series = c.series
            LEFT OUTER JOIN documentos_formatos   df ON df.tipdoc = ds.codigo
                                                      AND df.item = nvl(ds.tipimp, 1)
            LEFT OUTER JOIN cliente               c1 ON c1.id_cia = c.id_cia
                                          AND ( c1.codcli = c.codcli )
            LEFT OUTER JOIN vendedor              v1 ON v1.id_cia = c.id_cia
                                           AND ( v1.codven = c.codven )
            LEFT OUTER JOIN situacion             s2 ON s2.id_cia = c.id_cia
                                            AND ( s2.situac = c.situac )
                                            AND ( s2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN transportista         t1 ON t1.id_cia = c.id_cia
                                                AND ( t1.codtra = c.codtra )
            LEFT OUTER JOIN transportista         t2 ON t2.id_cia = c.id_cia
                                                AND ( t2.codtra = c.codtec )
            LEFT OUTER JOIN motivos               mt ON mt.id_cia = c.id_cia
                                          AND ( mt.codmot = c.codmot )
                                          AND ( mt.id = c.id )
                                          AND ( mt.tipdoc = c.tipdoc )
            LEFT OUTER JOIN cliente_clase         c14 ON c14.id_cia = c.id_cia
                                                 AND ( c14.tipcli = 'A' )
                                                 AND ( c14.codcli = c.codcli )
                                                 AND ( c14.clase = 14 )
            LEFT OUTER JOIN clase_cliente_codigo  cc14 ON cc14.id_cia = c14.id_cia
                                                         AND cc14.clase = c14.clase
                                                         AND cc14.codigo = c14.codigo
                                                         AND cc14.tipcli = c14.tipcli
            LEFT OUTER JOIN cliente_clase         c15 ON c15.id_cia = c.id_cia
                                                 AND ( c15.tipcli = 'A' )
                                                 AND ( c15.codcli = c.codcli )
                                                 AND ( c15.clase = 15 )
            LEFT OUTER JOIN clase_cliente_codigo  cc15 ON cc15.id_cia = c15.id_cia
                                                         AND cc15.clase = c15.clase
                                                         AND cc15.codigo = c15.codigo
                                                         AND cc15.tipcli = c15.tipcli
            LEFT OUTER JOIN cliente_clase         c16 ON c16.id_cia = c.id_cia
                                                 AND ( c16.tipcli = 'A' )
                                                 AND ( c16.codcli = c.codcli )
                                                 AND ( c16.clase = 16 )
            LEFT OUTER JOIN clase_cliente_codigo  cc16 ON cc16.id_cia = c16.id_cia
                                                         AND cc16.clase = c16.clase
                                                         AND cc16.codigo = c16.codigo
                                                         AND cc16.tipcli = c16.tipcli
            LEFT OUTER JOIN factor                far ON far.id_cia = c.id_cia
                                          AND ( far.codfac = 331 )
            LEFT OUTER JOIN factor                fap ON fap.id_cia = c.id_cia
                                          AND ( fap.codfac = 332 )
            LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
                                                AND ( d.numint = c.numint )
            LEFT OUTER JOIN unidad                un ON un.id_cia = d.id_cia
                                         AND un.coduni = d.codund
            LEFT OUTER JOIN documentos_cab_clase  dcp ON dcp.id_cia = c.id_cia
                                                        AND ( dcp.numint = c.numint )
                                                        AND ( dcp.clase = 3 )
            LEFT OUTER JOIN documentos_cab_clase  dct ON dct.id_cia = c.id_cia
                                                        AND ( dct.numint = c.numint )
                                                        AND ( dct.clase = 4 )
            LEFT OUTER JOIN documentos_det_clase  ddp ON ddp.id_cia = d.id_cia
                                                        AND ( ddp.numint = d.numint )
                                                        AND ( ddp.numite = d.numite )
                                                        AND ( ddp.clase = 50 )
            LEFT OUTER JOIN articulos             a ON a.id_cia = d.id_cia
                                           AND ( a.codart = d.codart )
                                           AND ( a.tipinv = d.tipinv )
            LEFT OUTER JOIN tmoneda               m1 ON m1.id_cia = c.id_cia
                                          AND ( m1.codmon = c.tipmon )
            LEFT OUTER JOIN companias_glosa       gar ON ( gar.id_cia = c.id_cia )
                                                   AND ( far.vstrg IS NOT NULL )
                                                   AND ( upper(far.vstrg) = 'S' )
                                                   AND ( gar.item = 15 )
            LEFT OUTER JOIN companias_glosa       gap ON ( gap.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( gap.item = 13 )
            LEFT OUTER JOIN companias_glosa       gfp ON ( gfp.id_cia = c.id_cia )
                                                   AND ( fap.vstrg IS NOT NULL )
                                                   AND ( upper(fap.vstrg) = 'S' )
                                                   AND ( dcp.codigo IS NOT NULL )
                                                   AND ( upper(dcp.codigo) = 'S' )
                                                   AND ( gfp.item = 14 )
            LEFT OUTER JOIN articulos_clase       ac5 ON ac5.id_cia = d.id_cia
                                                   AND ( ac5.tipinv = d.tipinv )
                                                   AND ( ac5.codart = d.codart )
                                                   AND ( ac5.clase = 87 )
            LEFT OUTER JOIN documentos_situac_max sv ON sv.id_cia = c.id_cia
                                                        AND sv.numint = c.numint
                                                        AND sv.situac = 'B'
            LEFT OUTER JOIN usuarios              uv ON uv.id_cia = sv.id_cia
                                           AND uv.coduser = sv.usuari
            LEFT OUTER JOIN documentos_situac_max se ON se.id_cia = c.id_cia
                                                        AND se.numint = c.numint
                                                        AND se.situac = 'A'
            LEFT OUTER JOIN usuarios              ue ON ue.id_cia = se.id_cia
                                           AND ue.coduser = se.usuari
            LEFT OUTER JOIN documentos_aprobacion dap ON dap.id_cia = c.id_cia
                                                         AND dap.numint = c.numint
            LEFT OUTER JOIN usuarios              ua ON ua.id_cia = dap.id_cia
                                           AND ua.coduser = dap.uactua
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
        ORDER BY
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ordentrabajo;

END;

/
