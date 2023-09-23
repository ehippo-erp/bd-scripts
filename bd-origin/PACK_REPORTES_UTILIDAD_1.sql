--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_UTILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_UTILIDAD" AS

    FUNCTION sp_resumen (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_resumen
        PIPELINED
    AS
        v_table    datatable_resumen;
        pin_tipdoc NUMBER;
    BEGIN
        SELECT
            t.id_cia,
            t.tipinv,
            t.dtipinv,
            t.codart,
            t.desart,
            t.codfam,
            t.familia,
            t.desfam,
            t.codlin,
            t.linea,
            t.deslin,
            t.cantid,
--            t.cospro,
            CASE
                WHEN t.cantid = 0 THEN
                    0
                ELSE
                    t.costot / t.cantid
            END     AS cospro,
            t.costot,
            CASE
                WHEN t.cantid = 0 THEN
                    0
                ELSE
                    t.ventot / t.cantid
            END     AS venpro,
--            t.venpro,
            t.ventot,
            (
                CASE
                    WHEN t.ventot = 0 THEN
                        0
                    ELSE
                        ( t.ventot - t.costot ) / t.ventot
                END
            ) * 100 AS margen
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    dr.id_cia,
                    dr.tipinv,
                    t.dtipinv,
                    dr.codart,
                    a.descri      AS desart,
                    ac2.clase     AS codfam,
                    ac2.codigo    AS familia,
                    ac2.descodigo AS desfam,
                    ac3.clase     AS codlin,
                    ac3.codigo    AS linea,
                    ac3.descodigo AS deslin,
                    SUM((
                        CASE
                            WHEN nvl(mt60.valor, 'N') = 'S' THEN
                                0
                            ELSE
                                dr.cantid
                        END
                    ) * dz.signo) AS cantid,
                    SUM(
                        CASE
                            WHEN nvl(k.cantid, 0) = 0
                                 OR nvl(mt60.valor, 'N') = 'S' THEN
                                0
                            ELSE
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                            CAST(k.costot01 / k.cantid AS NUMERIC(16, 5))
                                    ELSE
                                        CAST(k.costot02 / k.cantid AS NUMERIC(16, 5))
                                END
                        END
                        * dz.signo)   AS cospro,
                    SUM(
                        CASE
                            WHEN nvl(k.cantid, 0) = 0
                                 OR nvl(mt60.valor, 'N') = 'S' THEN
                                0
                            ELSE
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                            CAST((k.costot01 / k.cantid) * dr.cantid AS NUMERIC(16, 5))
                                    ELSE
                                        CAST((k.costot02 / k.cantid) * dr.cantid AS NUMERIC(16, 5))
                                END
                        END
                        * dz.signo)   AS costot,
                    SUM(
                        CASE
                            WHEN nvl(dr.cantid, 0) = 0 THEN
                                0
                            ELSE
                                CASE
                                    WHEN dc.tipmon = pin_codmon THEN
                                            CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5))
                                    ELSE
                                        CASE
                                            WHEN dc.tipmon = 'PEN' THEN
                                                        CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5)) / dc.tipcam
                                            ELSE
                                                CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5)) * dc.tipcam
                                        END
                                END
                        END
                        * dz.signo)   AS venpro,
                    SUM(
                        CASE
                            WHEN nvl(dr.cantid, 0) = 0 THEN
                                0
                            ELSE
                                CASE
                                    WHEN dc.tipmon = pin_codmon THEN
                                            CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5))
                                    ELSE
                                        CASE
                                            WHEN dc.tipmon = 'PEN' THEN
                                                        CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5)) / dc.tipcam
                                            ELSE
                                                CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5)) * dc.tipcam
                                        END
                                END
                        END
                        * dz.signo)   AS ventot
                FROM
                    pack_relacion_costo_venta.sp_resumen_utilidad(pin_id_cia, pin_tipinv, pin_fdesde, pin_fhasta) dr
                    LEFT OUTER JOIN kardex_costoventa                                                                             k ON
                    k.id_cia = dr.id_cia
                                                           AND k.numint = dr.numint
                                                           AND k.numite = dr.numite
                    LEFT OUTER JOIN documentos_cab                                                                                dc ON
                    dc.id_cia = dr.id_cia
                                                         AND dc.numint = dr.numint
                    LEFT OUTER JOIN t_inventario                                                                                  t ON
                    t.id_cia = dr.id_cia
                                                      AND t.tipinv = dr.tipinv
                    LEFT OUTER JOIN articulos                                                                                     a ON
                    a.id_cia = dr.id_cia
                                                   AND a.tipinv = dr.tipinv
                                                   AND a.codart = dr.codart
                    LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dr.id_cia, dr.tipinv, dr.codart, 2)                     ac2
                    ON 0 = 0
                    LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dr.id_cia, dr.tipinv, dr.codart, 3)                     ac3
                    ON 0 = 0
                    LEFT OUTER JOIN documentos                                                                                    doc
                    ON doc.id_cia = dr.id_cia
                                                      AND ( doc.codigo = dc.tipdoc )
                                                      AND ( doc.series = dc.series )
                    LEFT OUTER JOIN tdoccobranza                                                                                  dz ON
                    dz.id_cia = dr.id_cia
                                                       AND dz.tipdoc = dc.tipdoc
                    LEFT OUTER JOIN motivos_clase                                                                                 mt44
                    ON mt44.id_cia = dc.id_cia
                                                          AND mt44.tipdoc = dc.tipdoc
                                                          AND mt44.codmot = dc.codmot
                                                          AND mt44.id = dc.id
                                                          AND mt44.codigo = 44 -- TRANFERENCIA GRATUITA, NO SALE EN EL REPORTE
                    LEFT OUTER JOIN motivos_clase                                                                                 mt60
                    ON mt60.id_cia = dc.id_cia
                                                          AND mt60.tipdoc = dc.tipdoc
                                                          AND mt60.codmot = dc.codmot
                                                          AND mt60.id = dc.id
                                                          AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
                    LEFT OUTER JOIN motivos_clase                                                                                 mt3
                    ON mt3.id_cia = dc.id_cia
                                                         AND mt3.tipdoc = dc.tipdoc
                                                         AND mt3.codmot = dc.codmot
                                                         AND mt3.id = dc.id
                                                         AND mt3.codigo = 3 -- IMPRIME EN REPORTE?, SOLO SI ES 'S'
                WHERE
                        dr.id_cia = pin_id_cia
                    AND ( ( nvl(pin_tipo, 0) <= 0
                            AND dc.tipdoc IN ( 1, 3, 7, 8 ) )
                          OR ( pin_tipo = 1
                               AND dc.tipdoc IN ( 1, 3, 8 ) )
                          OR ( pin_tipo = 2
                               AND dc.tipdoc IN ( 7 ) ) )
                    AND nvl(mt44.valor, 'N') <> 'S'
                    AND nvl(mt3.valor, 'S') = 'S'
                GROUP BY
                    dr.id_cia,
                    dr.tipinv,
                    t.dtipinv,
                    dr.codart,
                    a.descri,
                    ac2.clase,
                    ac2.codigo,
                    ac2.descodigo,
                    ac3.clase,
                    ac3.codigo,
                    ac3.descodigo
                ORDER BY
                    dr.tipinv,
                    ac2.codigo,
                    ac3.codigo,
                    dr.codart
            ) t;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen;

    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        SELECT
            dr.id_cia,
            doc.descri                                   AS desdoc,
            dc.series,
            dc.numdoc,
            dc.femisi,
            dc.codcli,
            dc.razonc,
            dc.numint,
            dr.numite                                    AS numite,
            dr.tipinv,
            t.dtipinv,
            dr.codart,
            a.descri                                     AS desart,
            dr.codalm,
            al.descri                                    AS desalm,
            dc.tipmon,
            dc.tipcam,
            ac2.clase                                    AS codfam,
            ac2.codigo                                   AS familia,
            ac2.descodigo                                AS desfam,
            ac3.clase                                    AS codlin,
            ac3.codigo                                   AS linea,
            ac3.descodigo                                AS deslin,
            m.abrevi                                     AS desmot,
            m.desmot,
            dr.monafe + dr.monina + dr.monexo * dz.signo AS ventatotal,
            CASE
                WHEN nvl(k.cantid, 0) = 0 THEN
                    0
                ELSE
                    ( k.costot01 / k.cantid ) * dr.cantid * dz.signo
            END                                          AS costot01,
            CASE
                WHEN nvl(k.cantid, 0) = 0 THEN
                    0
                ELSE
                    ( k.costot02 / k.cantid ) * dr.cantid * dz.signo
            END                                          AS costot02,
            CASE
                WHEN nvl(k.cantid, 0) = 0 THEN
                    0
                ELSE
                    ( k.costot01 / k.cantid ) * dz.signo
            END                                          AS costo01,
            CASE
                WHEN nvl(k.cantid, 0) = 0 THEN
                    0
                ELSE
                    ( k.costot02 / k.cantid ) * dz.signo
            END                                          AS costo02,
            (
                CASE
                    WHEN nvl(mt60.valor, 'N') = 'S' THEN
                        0
                    ELSE
                        dr.cantid
                END
            ) * dz.signo                                 AS cantid,
--            dr.cantid * dz.signo                         AS cantid,
            CASE
                WHEN nvl(k.cantid, 0) = 0
                     OR nvl(mt60.valor, 'N') = 'S' THEN
                        0
                ELSE
                    CASE
                        WHEN pin_codmon = 'PEN' THEN
                                    CAST(k.costot01 / k.cantid AS NUMERIC(16, 5))
                        ELSE
                            CAST(k.costot02 / k.cantid AS NUMERIC(16, 5))
                    END
            END
            * dz.signo                                   AS cospro,
            CASE
                WHEN nvl(k.cantid, 0) = 0
                     OR nvl(mt60.valor, 'N') = 'S' THEN
                        0
                ELSE
                    CASE
                        WHEN pin_codmon = 'PEN' THEN
                                    CAST((k.costot01 / k.cantid) * dr.cantid AS NUMERIC(16, 5))
                        ELSE
                            CAST((k.costot02 / k.cantid) * dr.cantid AS NUMERIC(16, 5))
                    END
            END
            * dz.signo                                   AS costot,
            CASE
                WHEN nvl(dr.cantid, 0) = 0 THEN
                        0
                ELSE
                    CASE
                        WHEN dc.tipmon = pin_codmon THEN
                                    CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5))
                        ELSE
                            CASE
                                WHEN dc.tipmon = 'PEN' THEN
                                                CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5)) / dc.tipcam
                                ELSE
                                    CAST((dr.monafe + dr.monina + dr.monexo) / dr.cantid AS NUMERIC(16, 5)) * dc.tipcam
                            END
                    END
            END
            * dz.signo                                   AS venpro,
            CASE
                WHEN nvl(dr.cantid, 0) = 0 THEN
                        0
                ELSE
                    CASE
                        WHEN dc.tipmon = pin_codmon THEN
                                    CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5))
                        ELSE
                            CASE
                                WHEN dc.tipmon = 'PEN' THEN
                                                CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5)) / dc.tipcam
                                ELSE
                                    CAST(dr.monafe + dr.monina + dr.monexo AS NUMERIC(16, 5)) * dc.tipcam
                            END
                    END
            END
            * dz.signo                                   AS ventot,
            0
        BULK COLLECT
        INTO v_table
        FROM
            pack_relacion_costo_venta.sp_resumen(pin_id_cia, pin_tipinv, pin_fdesde, pin_fhasta) dr
            LEFT OUTER JOIN kardex_costoventa                                                                    k ON k.id_cia = dr.id_cia
                                                   AND k.numint = dr.numint
                                                   AND k.numite = dr.numite
            LEFT OUTER JOIN documentos_cab                                                                       dc ON dc.id_cia = dr.id_cia
                                                 AND dc.numint = dr.numint
            LEFT OUTER JOIN t_inventario                                                                         t ON t.id_cia = dr.id_cia
                                              AND t.tipinv = dr.tipinv
            LEFT OUTER JOIN articulos                                                                            a ON a.id_cia = dr.id_cia
                                           AND a.tipinv = dr.tipinv
                                           AND a.codart = dr.codart
            LEFT OUTER JOIN almacen                                                                              al ON al.id_cia = dr.id_cia
                                          AND al.codalm = dr.codalm
                                          AND al.tipinv = dr.tipinv
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dr.id_cia, dr.tipinv, dr.codart, 2)            ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(dr.id_cia, dr.tipinv, dr.codart, 3)            ac3 ON 0 = 0
            LEFT OUTER JOIN documentos                                                                           doc ON doc.id_cia = dr.id_cia
                                              AND ( doc.codigo = dc.tipdoc )
                                              AND ( doc.series = dc.series )
            LEFT OUTER JOIN tdoccobranza                                                                         dz ON dz.id_cia = dr.id_cia
                                               AND dz.tipdoc = dc.tipdoc
            LEFT OUTER JOIN motivos                                                                              m ON m.id_cia = dc.id_cia
                                         AND m.tipdoc = dc.tipdoc
                                         AND m.codmot = dc.codmot
                                         AND m.id = dc.id
            LEFT OUTER JOIN motivos_clase                                                                        mt44 ON mt44.id_cia = dc.id_cia
                                                  AND mt44.tipdoc = dc.tipdoc
                                                  AND mt44.codmot = dc.codmot
                                                  AND mt44.id = dc.id
                                                  AND mt44.codigo = 44 -- TRANFERENCIA GRATUITA, NO SALE EN EL REPORTE
            LEFT OUTER JOIN motivos_clase                                                                        mt60 ON mt60.id_cia = dc.id_cia
                                                  AND mt60.tipdoc = dc.tipdoc
                                                  AND mt60.codmot = dc.codmot
                                                  AND mt60.id = dc.id
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
            LEFT OUTER JOIN motivos_clase                                                                        mt3 ON mt3.id_cia = dc.id_cia
                                                 AND mt3.tipdoc = dc.tipdoc
                                                 AND mt3.codmot = dc.codmot
                                                 AND mt3.id = dc.id
                                                 AND mt3.codigo = 3 -- IMPRIME EN REPORTE?, SOLO SI ES 'S'
        WHERE
                dr.id_cia = pin_id_cia
            AND ( ( nvl(pin_tipo, 0) <= 0
                    AND dc.tipdoc IN ( 1, 3, 7, 8 ) )
                  OR ( pin_tipo = 1
                       AND dc.tipdoc IN ( 1, 3, 8 ) )
                  OR ( pin_tipo = 2
                       AND dc.tipdoc IN ( 7 ) ) )
            AND nvl(mt44.valor, 'N') <> 'S'
            AND nvl(mt3.valor, 'S') = 'S'
        ORDER BY
            dr.tipinv,
            ac2.codigo,
            ac3.codigo,
            dr.codart,
            dc.femisi;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_leyenda
        PIPELINED
    AS
        v_table datatable_leyenda;
    BEGIN
        SELECT
            documento,
            motivo,
            SUM(cantidad),
            SUM(costototsol),
            SUM(costototdol),
            SUM(ventatotsol),
            SUM(ventatotdol)
        BULK COLLECT
        INTO v_table
        FROM
            pack_cubo_ventas.sp_cuboventas008(pin_id_cia, pin_fdesde, pin_fhasta)
        WHERE
                id_cia = pin_id_cia
            AND ( ( nvl(pin_tipo, 0) <= 0
                    AND tipdoc IN ( 1, 3, 7, 8 ) )
                  OR ( pin_tipo = 1
                       AND tipdoc IN ( 1, 3, 8 ) )
                  OR ( pin_tipo = 2
                       AND tipdoc IN ( 7 ) ) )
            AND ( NVL(pin_tipinv,-1) = -1 OR tipinv = pin_tipinv )
            AND transferencia_gratuita = 'N'
            AND imprime_utilidad = 'S'
        GROUP BY
            documento,
            motivo
        ORDER BY
            documento;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_leyenda;

END;

/
