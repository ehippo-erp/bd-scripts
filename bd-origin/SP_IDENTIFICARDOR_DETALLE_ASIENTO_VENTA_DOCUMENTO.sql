--------------------------------------------------------
--  DDL for Function SP_IDENTIFICARDOR_DETALLE_ASIENTO_VENTA_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_IDENTIFICARDOR_DETALLE_ASIENTO_VENTA_DOCUMENTO" (
    pin_id_cia IN NUMBER,
    pin_numint IN NUMBER
) RETURN tbl_identificardor_detalle_asiento_venta_documento
    PIPELINED
AS

    rec          rec_identificardor_detalle_asiento_venta_documento := rec_identificardor_detalle_asiento_venta_documento(0, 0, NULL,
    NULL, NULL,
                                                                                                                NULL, NULL, NULL, NULL
                                                                                                                , NULL,
                                                                                                                NULL, NULL, NULL, NULL
                                                                                                                , NULL,
                                                                                                                NULL);
    v_count      INTEGER := 0;
    CURSOR cur_cuenta_emision_documento (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        CASE
            WHEN m44.valor = 'S' THEN/* Motivo es tranferencia grauita (SUNAT))*/
                nvl(dc31.codigo, dc70.codigo)
            ELSE
                dc.codigo
        END                AS cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam,
        CAST(
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    c.preven
                ELSE
                    c.preven * c.tipcam
            END
        AS NUMERIC(16, 2)) AS importe01,
        CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    c.preven
                ELSE
                    c.preven / c.tipcam
            END
        AS NUMERIC(16, 2)) AS importe02
    FROM
        documentos_cab     c
        LEFT OUTER JOIN motivos_clase      m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44 /* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN cliente_clase      cc4 ON cc4.id_cia = c.id_cia
                                             AND cc4.tipcli = 'A'
                                             AND cc4.codcli = c.codcli
                                             AND cc4.clase = 4 /*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN tdoccobranza       tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN tdoccobranza_clase dc ON dc.id_cia = cc4.id_cia
                                                 AND dc.clase = cc4.codigo
                                                 AND dc.tipdoc = c.tipdoc
                                                 AND dc.moneda = c.tipmon
        LEFT OUTER JOIN tdoccobranza_clase dc31 ON dc31.id_cia = c.id_cia
                                                   AND dc31.clase = 31 /*Cuenta contable transferencia gratuita*/
                                                   AND dc31.tipdoc = c.tipdoc
                                                   AND dc31.moneda = c.tipmon
        LEFT OUTER JOIN tdoccobranza_clase dc70 ON dc70.id_cia = c.id_cia
                                                   AND dc70.clase = 70 -- CUENTA CONTABLE DE RESPALDO
                                                   AND dc70.tipdoc = c.tipdoc
                                                   AND dc70.moneda = c.tipmon
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F',/**/ 'C' /*CON NOTA DE CREDITO*/ )
    ORDER BY
        c.tipdoc,
        c.series,
        c.numdoc;

    CURSOR cur_cuenta_igv (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        fc.cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END                 AS dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam,
        SUM(CAST(
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    c.monigv
                ELSE
                    c.monigv * c.tipcam
            END
        AS NUMERIC(16, 2))) AS importe01,
        SUM(CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    c.monigv
                ELSE
                    c.monigv / c.tipcam
            END
        AS NUMERIC(16, 2))) AS importe02
    FROM
        documentos_cab c
        LEFT OUTER JOIN tdoccobranza   tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN factor         fc ON fc.id_cia = v_id_cia
                                     AND fc.codfac = 1 /*I.G.V Venta*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
    GROUP BY
        c.tipdoc,
        tdc.dh,
        fc.cuenta,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam;

    CURSOR cur_cuenta_emision_anticipo (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        CASE
            WHEN m44.valor = 'S' THEN
                ac31.codigo
            ELSE
                ac.codigo
        END          AS cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END          AS dh,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16,
     2)))         AS importe01,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2)))         importe02,
        tdc.codsunat AS tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab                                             c
        LEFT OUTER JOIN documentos_det                                             d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                               tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN motivos_clase                                              m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44 /* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN cliente_clase                                              cc ON cc.id_cia = c.id_cia
                                            AND ( cc.codcli = c.codcli )
                                            AND ( cc.tipcli = 'A' )
                                            AND ( cc.clase = 4 )/*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN articulos_clase                                            ac ON ac.id_cia = d.id_cia
                                              AND ( ac.tipinv = d.tipinv )
                                              AND ( ac.codart = d.codart )
                                              AND ( ac.clase = cc.codigo )
        LEFT OUTER JOIN articulos_clase                                            ac31 ON ac31.id_cia = d.id_cia
                                                AND ( ac31.tipinv = d.tipinv )
                                                AND ( ac31.codart = d.codart )
                                                AND ( ac31.clase = 31 ) /*Cuenta contable transferencia gratuita*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 32) a32 ON 0 = 0 /*ARTICULO ES BOLSA DE PLASTICO*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 90) a90 ON 0 = 0 /*ARTICULO PARA EMISION DE ANTICIPO*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND coalesce(d.opcargo, 'x') NOT IN ( 'APLI-106', 'APNC-106' )
        AND ( length(a90.codigo) = 3 )
    GROUP BY
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        a32.codigo,
        tdc.dh,
        ac.codigo,
        ac31.codigo,
        m44.valor,
        tdc.codsunat,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monafe + d.monina + coalesce(d.monexo, 0) + nvl(d.monicbper, 0)) <> 0;

    CURSOR cur_cuenta_aplicacion_anticipo (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        ac.codigo   AS ctaartcla,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END         AS dh,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16,
     2)))        AS importe01,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2)))        AS importe02,
        td.codsunat AS tipdoc,
        an.series,
        an.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab                                             c
        LEFT OUTER JOIN documentos_det                                             d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                               tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN cliente_clase                                              cc ON cc.id_cia = c.id_cia
                                            AND ( cc.codcli = c.codcli )
                                            AND ( cc.tipcli = 'A' )
                                            AND ( cc.clase = 4 )/*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN articulos_clase                                            ac ON ac.id_cia = d.id_cia
                                              AND ( ac.tipinv = d.tipinv )
                                              AND ( ac.codart = d.codart )
                                              AND ( ac.clase = cc.codigo )
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 32) a32 ON 0 = 0/*ARTICULO ES BOLSA DE PLASTICO*/
        LEFT OUTER JOIN documentos_cab                                             an ON an.id_cia = d.id_cia
                                             AND an.numint = d.opnumdoc
        LEFT OUTER JOIN tdoccobranza                                               td ON td.id_cia = an.id_cia
                                           AND ( td.tipdoc = an.tipdoc )
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND coalesce(d.opcargo, 'x') IN ( 'APLI-106', 'APNC-106' )
    GROUP BY
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        ac.codigo,
        tdc.dh,
        td.codsunat,
        an.series,
        an.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monafe + d.monina + coalesce(d.monexo, 0) + nvl(d.monicbper, 0)) <> 0;

    CURSOR cur_cuenta_otros_tributos (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        CASE
            WHEN m44.valor = 'S' THEN
                ac31.codigo
            ELSE
                CASE
                    WHEN nvl(c.destin, 0) = 2 THEN
                            nvl(acimp.codigo, ac.codigo)
                    ELSE
                        ac.codigo
                END
        END  AS cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END  AS dh,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16,
     2))) AS importe01,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2))) AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab                                             c
        LEFT OUTER JOIN documentos_det                                             d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                               tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN motivos_clase                                              m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44/* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN cliente_clase                                              cc ON cc.id_cia = c.id_cia
                                            AND ( cc.codcli = c.codcli )
                                            AND ( cc.tipcli = 'A' )
                                            AND ( cc.clase = 4 )/*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN articulos_clase                                            ac ON ac.id_cia = d.id_cia
                                              AND ( ac.tipinv = d.tipinv )
                                              AND ( ac.codart = d.codart )
                                              AND ( ac.clase = cc.codigo )
        LEFT OUTER JOIN articulos_clase                                            acimp ON acimp.id_cia = d.id_cia
                                                 AND acimp.tipinv = d.tipinv
                                                 AND acimp.codart = d.codart
                                                 AND acimp.clase = (
            CASE
                WHEN cc.codigo = '69' THEN
                    '71'
                WHEN cc.codigo = '70' THEN
                    '72'
                ELSE
                    cc.codigo
            END
        )
        LEFT OUTER JOIN articulos_clase                                            ac31 ON ac31.id_cia = d.id_cia
                                                AND ( ac31.tipinv = d.tipinv )
                                                AND ( ac31.codart = d.codart )
                                                AND ( ac31.clase = 31 )/*Cuenta contable transferencia gratuita*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 32) a32 ON 0 = 0/*ARTICULO ES BOLSA DE PLASTICO*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 90) a90 ON 0 = 0/*ARTICULO PARA EMISION DE ANTICIPO*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND coalesce(d.opcargo, 'x') NOT IN ( 'APLI-106', 'APNC-106' )
        AND ( a90.codigo IS NULL
              OR ( length(TRIM(a90.codigo)) <> 3 ) )
    GROUP BY
        a32.codigo,
        tdc.dh,
        c.destin,
        ac.codigo,
        acimp.codigo,
        ac31.codigo,
        m44.valor,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monafe + d.monina + coalesce(d.monexo, 0) + nvl(d.monicbper, 0)) <> 0
    UNION ALL
    SELECT
        CAST(fib.cuenta AS VARCHAR(20)) AS cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END                             AS dh,
        SUM(CAST((nvl(d.monicbper, 0)) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16,
     2)))                            AS importe01,
        SUM(CAST((nvl(d.monicbper, 0)) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2)))                            AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab                                             c
        LEFT OUTER JOIN documentos_det                                             d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                               tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 32) a32 ON 0 = 0/*ARTICULO ES BOLSA DE PLASTICO*/
        LEFT OUTER JOIN factor                                                     fib ON fib.id_cia = c.id_cia
                                      AND fib.codfac = 421 /*Valor de impuesto por bolsa de plastico*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND ( a32.codigo = 'S' )
    GROUP BY
        fib.cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(nvl(d.monicbper, 0)) <> 0
    UNION ALL
    SELECT
        CAST(fib.cuenta AS VARCHAR(20)) AS cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END                             AS dh,
        SUM(CAST((d.monisc) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16, 2)))             AS importe01,
        SUM(CAST((d.monisc) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2)))                            AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab c
        LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza   tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN factor         fib ON fib.id_cia = c.id_cia
                                      AND fib.codfac = 400 /*Calcula articulos con ISC*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
    GROUP BY
        fib.cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monisc) <> 0;

    -- CONFIGURACION ADICIONAL PARA OTROS TRIBUTOS, UTILIZADO EN LUMAD
    -- CONFIGURACION POR EL FACTOR 441 CON EL VSTRG = 'S'
    -- IDENTIFICAR, MONTO AFECTO
    CURSOR cur_cuenta_otros_tributos_personalizado (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        CASE
            WHEN m44.valor = 'S' THEN
                ac31.codigo
            ELSE
                CASE
                    WHEN nvl(c.destin, 0) = 2 THEN
                            nvl(acimp.codigo, ac.codigo)
                    ELSE
                        ac.codigo
                END
        END                                                                                    AS cuenta,
        decode(tdc.dh, 'D', 'H', 'D')                                                          AS dh,
        SUM((d.monafe + d.monina + nvl(d.monexo, 0)) * decode(c.tipmon, 'PEN', 1.0, c.tipcam)) AS importe01,
        SUM((d.monafe + d.monina + nvl(d.monexo, 0)) / decode(c.tipmon, 'USD', 1.0, c.tipcam)) AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab                                                          c
        LEFT OUTER JOIN documentos_det                                                          d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                                            tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN motivos_clase                                                           m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44/* Motivo es tranferencia grauita SUNAT*/
        LEFT OUTER JOIN cliente_clase                                                           cc ON cc.id_cia = c.id_cia
                                            AND cc.codcli = c.codcli
                                            AND cc.tipcli = 'A'
                                            AND cc.clase = 4 /*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN articulos_clase                                                         ac ON ac.id_cia = d.id_cia
                                              AND ac.tipinv = d.tipinv
                                              AND ac.codart = d.codart
                                              AND ac.clase = cc.codigo
        LEFT OUTER JOIN articulos_clase                                                         acimp ON acimp.id_cia = d.id_cia
                                                 AND acimp.tipinv = d.tipinv
                                                 AND acimp.codart = d.codart
                                                 AND acimp.clase = (
            CASE
                WHEN cc.codigo = '69' THEN
                    '71'
                WHEN cc.codigo = '70' THEN
                    '72'
                ELSE
                    cc.codigo
            END
        )
        LEFT OUTER JOIN articulos_clase                                                         ac31 ON ac31.id_cia = d.id_cia
                                                AND ac31.tipinv = d.tipinv
                                                AND ac31.codart = d.codart
                                                AND ac31.clase = 31 /*Cuenta contable transferencia gratuita*/
        LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(d.id_cia, d.tipinv, d.codart, 90) a90 ON 0 = 0/*ARTICULO PARA EMISION DE ANTICIPO*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND coalesce(d.opcargo, 'x') NOT IN ( 'APLI-106', 'APNC-106' )
        AND ( a90.codigo IS NULL
              OR ( length(TRIM(a90.codigo)) <> 3 ) )
    GROUP BY
        tdc.dh,
        c.destin,
        ac.codigo,
        acimp.codigo,
        ac31.codigo,
        m44.valor,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monafe + d.monina + nvl(d.monexo, 0)) <> 0
    UNION ALL
    SELECT
        fib.cuenta                                                       AS cuenta,
        decode(tdc.dh, 'D', 'H', 'D')                                    AS dh,
        SUM((nvl(d.monotr, 0)) * decode(c.tipmon, 'PEN', 1.0, c.tipcam)) AS importe01,
        SUM((nvl(d.monotr, 0)) / decode(c.tipmon, 'USD', 1.0, c.tipcam)) AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab c
        LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza   tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN factor         fib ON fib.id_cia = c.id_cia
                                      AND fib.codfac = 441 -- FACTOR Y VALOR DE CUENTA CONTABLE PARA OTROS TRIBUTOS - PERSONALIZADO
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
    GROUP BY
        fib.cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(nvl(d.monotr, 0)) <> 0
    UNION ALL
    SELECT
        CAST(fib.cuenta AS VARCHAR(20))                                  AS cuenta,
        decode(tdc.dh, 'D', 'H', 'D')                                    AS dh,
        SUM((nvl(d.monisc, 0)) * decode(c.tipmon, 'PEN', 1.0, c.tipcam)) AS importe01,
        SUM((nvl(d.monisc, 0)) / decode(c.tipmon, 'USD', 1.0, c.tipcam)) AS importe02,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    FROM
        documentos_cab c
        LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza   tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN factor         fib ON fib.id_cia = c.id_cia
                                      AND fib.codfac = 400 /*Calcula articulos con ISC*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
    GROUP BY
        fib.cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monisc) <> 0;

    CURSOR cur_cuenta_transferencia_gratuita (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        CASE
            WHEN m44.valor = 'S' THEN
                dc31.codigo
            ELSE
                dc.codigo
        END                AS cuenta,
        CASE
            WHEN tdc.dh = 'D' THEN
                'H'
            ELSE
                'D'
        END                AS dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam,
        CAST(
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    c.preven
                ELSE
                    c.preven * c.tipcam
            END
        AS NUMERIC(16, 2)) AS importe01,
        CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    c.preven
                ELSE
                    c.preven / c.tipcam
            END
        AS NUMERIC(16, 2)) AS importe02
    FROM
        documentos_cab     c
        LEFT OUTER JOIN motivos_clase      m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44/* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN cliente_clase      cc4 ON cc4.id_cia = c.id_cia
                                             AND cc4.tipcli = 'A'
                                             AND cc4.codcli = c.codcli
                                             AND cc4.clase = 4/*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN tdoccobranza       tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN tdoccobranza_clase dc ON dc.id_cia = cc4.id_cia
                                                 AND dc.clase = cc4.codigo
                                                 AND dc.tipdoc = c.tipdoc
                                                 AND dc.moneda = c.tipmon
        LEFT OUTER JOIN tdoccobranza_clase dc31 ON dc31.id_cia = c.id_cia
                                                   AND dc31.clase = 31/*Cuenta contable transferencia gratuita*/
                                                   AND dc31.tipdoc = c.tipdoc
                                                   AND dc31.moneda = c.tipmon
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND m44.valor = 'S'
    ORDER BY
        c.tipdoc,
        c.series,
        c.numdoc,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam;

    CURSOR cur_cuenta_reversion_tranferencia_g (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        fc.cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam,
        SUM(CAST(
            CASE
                WHEN c.tipmon = 'PEN' THEN
                    c.monigv
                ELSE
                    c.monigv * c.tipcam
            END
        AS NUMERIC(16, 2))) AS importe01,
        SUM(CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    c.monigv
                ELSE
                    c.monigv / c.tipcam
            END
        AS NUMERIC(16, 2))) AS importe02
    FROM
        documentos_cab c
        LEFT OUTER JOIN motivos_clase  m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44/* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN tdoccobranza   tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN factor         fc ON fc.id_cia = c.id_cia
                                     AND fc.codfac = 429 /*Agrega reversión de asiento de transferencia gratuita*/
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND m44.valor = 'S'
    GROUP BY
        c.tipdoc,
        tdc.dh,
        fc.cuenta,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam;

    CURSOR cur_cuenta_art_otr_tg (
        v_id_cia IN NUMBER,
        v_numint IN NUMBER
    ) IS
    SELECT
        CASE
            WHEN m44.valor = 'S' THEN
                ac31.codigo
            ELSE
                ac.codigo
        END  AS cuenta,
        tdc.dh,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) *
                 CASE
                     WHEN c.tipmon = 'PEN' THEN
                         1.0
                     ELSE
                         c.tipcam
                 END
        AS NUMERIC(16,
     2))) AS importe01,
        SUM(CAST((d.monafe + d.monina + coalesce(d.monexo, 0) +
                  CASE
                      WHEN a32.codigo = 'S' THEN
                          0
                      ELSE
                          nvl(d.monicbper, 0)
                  END
        ) / CAST(
            CASE
                WHEN c.tipmon <> 'PEN' THEN
                    1.0
                ELSE
                    c.tipcam
            END
        AS DOUBLE PRECISION) AS NUMERIC(16,
     2))) AS importe02
    FROM
        documentos_cab                                             c
        LEFT OUTER JOIN documentos_det                                             d ON d.id_cia = c.id_cia
                                            AND d.numint = c.numint
        LEFT OUTER JOIN tdoccobranza                                               tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tipdoc
        LEFT OUTER JOIN motivos_clase                                              m44 ON m44.id_cia = c.id_cia
                                             AND m44.tipdoc = c.tipdoc
                                             AND m44.codmot = c.codmot
                                             AND m44.id = c.id
                                             AND m44.codigo = 44/* Motivo es tranferencia grauita (SUNAT))*/
        LEFT OUTER JOIN cliente_clase                                              cc ON cc.id_cia = c.id_cia
                                            AND ( cc.codcli = c.codcli )
                                            AND ( cc.tipcli = 'A' )
                                            AND ( cc.clase = 4 )/*CLIENTE RELACIONADO*/
        LEFT OUTER JOIN articulos_clase                                            ac ON ac.id_cia = d.id_cia
                                              AND ( ac.tipinv = d.tipinv )
                                              AND ( ac.codart = d.codart )
                                              AND ( ac.clase = cc.codigo )
        LEFT OUTER JOIN articulos_clase                                            ac31 ON ac31.id_cia = d.id_cia
                                                AND ( ac31.tipinv = d.tipinv )
                                                AND ( ac31.codart = d.codart )
                                                AND ( ac31.clase = 31 )/*Cuenta contable transferencia gratuita*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 32) a32 ON 0 = 0/*ARTICULO ES BOLSA DE PLASTICO*/
        LEFT OUTER JOIN sp_select_articulo_clase(d.id_cia, d.tipinv, d.codart, 90) a90 ON 0 =/*ARTICULO PARA EMISION DE ANTICIPO*/ 0
    WHERE
            c.id_cia = v_id_cia
        AND c.numint = v_numint
        AND c.situac IN ( 'F', 'C' )
        AND ( coalesce(d.opcargo, 'x') NOT IN ( 'APLI-106', 'APNC-106' ) )
        AND ( length(nvl(a90.codigo, ' ')) <> 3 )
        AND m44.valor = 'S'
    GROUP BY
        a32.codigo,
        tdc.dh,
        ac.codigo,
        ac31.codigo,
        m44.valor,
        c.codcli,
        c.razonc,
        c.tident,
        c.ruc,
        c.femisi,
        c.tipdoc,
        c.series,
        c.numdoc,
        c.tipmon,
        c.tipcam
    HAVING
        SUM(d.monafe + d.monina + coalesce(d.monexo, 0) + nvl(d.monicbper, 0)) <> 0;

    factortg     VARCHAR(5);
    factortg_429 VARCHAR(5);
    cuenta_429   VARCHAR(20);
    v_factor441  VARCHAR2(5 CHAR);
BEGIN
    BEGIN
        SELECT
            nvl(vstrg, 'N')
        INTO factortg
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 403;

    EXCEPTION
        WHEN no_data_found THEN
            factortg := 'N';
    END;

    -- FACTOR DE CUENTA DE OTROS TRIBUTOS PERSONALIZADO - ACTIVADO?
    BEGIN
        SELECT
            nvl(vstrg, 'N')
        INTO v_factor441
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 441;

    EXCEPTION
        WHEN no_data_found THEN
            v_factor441 := 'N';
    END;


     /* CUENTSA POR EMISION DE DOCUMENTO 12 */
    FOR r_cta12 IN cur_cuenta_emision_documento(pin_id_cia, pin_numint) LOOP
        rec.cuenta := r_cta12.cuenta;
        rec.dh := r_cta12.dh;
        rec.codcli := r_cta12.codcli;
        rec.razonc := r_cta12.razonc;
        rec.tident := r_cta12.tident;
        rec.ruc := r_cta12.ruc;
        rec.femisi := r_cta12.femisi;
        rec.tipdoc := r_cta12.tipdoc;
        rec.series := r_cta12.series;
        rec.numdoc := r_cta12.numdoc;
        rec.tipmon := r_cta12.tipmon;
        rec.tipcam := r_cta12.tipcam;
        rec.importe01 := r_cta12.importe01;
        rec.importe02 := r_cta12.importe02;
        dbms_output.put_line('IMPRIME N1');
        v_count := v_count + 1;
        rec.id_reg := v_count;
        PIPE ROW ( rec );
    END LOOP;

    rec.cuenta := NULL;
    rec.dh := NULL;
    rec.codcli := NULL;
    rec.razonc := NULL;
    rec.tident := NULL;
    rec.ruc := NULL;
    rec.femisi := NULL;
    rec.tipdoc := NULL;
    rec.series := NULL;
    rec.numdoc := NULL;
    rec.tipmon := NULL;
    rec.tipcam := NULL;
    rec.importe01 := NULL;
    rec.importe02 := NULL;


    /* CUENTA POR IGV */
    FOR r_ctaigv IN cur_cuenta_igv(pin_id_cia, pin_numint) LOOP
        rec.cuenta := r_ctaigv.cuenta;
        rec.dh := r_ctaigv.dh;
        rec.codcli := r_ctaigv.codcli;
        rec.razonc := r_ctaigv.razonc;
        rec.tident := r_ctaigv.tident;
        rec.ruc := r_ctaigv.ruc;
        rec.femisi := r_ctaigv.femisi;
        rec.tipdoc := r_ctaigv.tipdoc;
        rec.series := r_ctaigv.series;
        rec.numdoc := r_ctaigv.numdoc;
        rec.tipmon := r_ctaigv.tipmon;
        rec.tipcam := r_ctaigv.tipcam;
        rec.importe01 := r_ctaigv.importe01;
        rec.importe02 := r_ctaigv.importe02;
        IF ( ( rec.importe01 <> 0.0 ) OR ( rec.importe02 <> 0.0 ) ) THEN
            dbms_output.put_line('IMPRIME N2');
            v_count := v_count + 1;
            rec.id_reg := v_count;
            PIPE ROW ( rec );
        END IF;

    END LOOP;

    rec.cuenta := NULL;
    rec.dh := NULL;
    rec.codcli := NULL;
    rec.razonc := NULL;
    rec.tident := NULL;
    rec.ruc := NULL;
    rec.femisi := NULL;
    rec.tipdoc := NULL;
    rec.series := NULL;
    rec.numdoc := NULL;
    rec.tipmon := 'PEN';
    rec.tipcam := 0.0;
    rec.importe01 := NULL;
    rec.importe02 := NULL;

       /* CUENTAS POR EMISION DE ANTICIPOS*/
    FOR r_cta_emianti IN cur_cuenta_emision_anticipo(pin_id_cia, pin_numint) LOOP
        IF ( r_cta_emianti.importe01 < 0 ) THEN
            IF ( r_cta_emianti.dh = 'H' ) THEN
                r_cta_emianti.dh := 'D';
            ELSE
                r_cta_emianti.dh := 'H';
            END IF;
        END IF;

        rec.cuenta := r_cta_emianti.cuenta;
        rec.dh := r_cta_emianti.dh;
        rec.codcli := r_cta_emianti.codcli;
        rec.razonc := r_cta_emianti.razonc;
        rec.tident := r_cta_emianti.tident;
        rec.ruc := r_cta_emianti.ruc;
        rec.femisi := r_cta_emianti.femisi;
        rec.tipdoc := r_cta_emianti.tipdoc;
        rec.series := r_cta_emianti.series;
        rec.numdoc := r_cta_emianti.numdoc;
        rec.tipmon := r_cta_emianti.tipmon;
        rec.tipcam := r_cta_emianti.tipcam;
        rec.importe01 := r_cta_emianti.importe01;
        rec.importe02 := r_cta_emianti.importe02;
        dbms_output.put_line('IMPRIME N3');
        v_count := v_count + 1;
        rec.id_reg := v_count;
        PIPE ROW ( rec );
    END LOOP;

    rec.cuenta := NULL;
    rec.dh := NULL;
    rec.codcli := NULL;
    rec.razonc := NULL;
    rec.tident := NULL;
    rec.ruc := NULL;
    rec.femisi := NULL;
    rec.tipdoc := NULL;
    rec.series := NULL;
    rec.numdoc := NULL;
    rec.tipmon := 'PEN';
    rec.tipcam := 0.0;
    rec.importe01 := NULL;
    rec.importe02 := NULL;

    /* CUENTA POR APLICACION DE ANTICIPO */
    FOR r_cta_aplianti IN cur_cuenta_aplicacion_anticipo(pin_id_cia, pin_numint) LOOP
        IF ( r_cta_aplianti.importe01 < 0 ) THEN
            IF ( r_cta_aplianti.dh = 'H' ) THEN
                r_cta_aplianti.dh := 'D';
            ELSE
                r_cta_aplianti.dh := 'H';
            END IF;
        END IF;

        rec.cuenta := r_cta_aplianti.ctaartcla;
        rec.dh := r_cta_aplianti.dh;
        rec.codcli := r_cta_aplianti.codcli;
        rec.razonc := r_cta_aplianti.razonc;
        rec.tident := r_cta_aplianti.tident;
        rec.ruc := r_cta_aplianti.ruc;
        rec.femisi := r_cta_aplianti.femisi;
        rec.tipdoc := r_cta_aplianti.tipdoc;
        rec.series := r_cta_aplianti.series;
        rec.numdoc := r_cta_aplianti.numdoc;
        rec.tipmon := r_cta_aplianti.tipmon;
        rec.tipcam := r_cta_aplianti.tipcam;
        rec.importe01 := abs(r_cta_aplianti.importe01);
        rec.importe02 := abs(r_cta_aplianti.importe02);
        dbms_output.put_line('IMPRIME N4');
        v_count := v_count + 1;
        rec.id_reg := v_count;
        PIPE ROW ( rec );
    END LOOP;

    rec.cuenta := NULL;
    rec.dh := NULL;
    rec.codcli := NULL;
    rec.razonc := NULL;
    rec.tident := NULL;
    rec.ruc := NULL;
    rec.femisi := NULL;
    rec.tipdoc := NULL;
    rec.series := NULL;
    rec.numdoc := NULL;
    rec.tipmon := 'PEN';
    rec.tipcam := 0.0;
    rec.importe01 := NULL;
    rec.importe02 := NULL;


    -- CUENTA POR ARTICULO Y OTROS TRIBUTOS
    -- CONFIGURACION SEGUN FACTOR 441
    IF v_factor441 = 'S' THEN
        FOR r_cta_otrostri IN cur_cuenta_otros_tributos_personalizado(pin_id_cia, pin_numint) LOOP
            IF ( r_cta_otrostri.importe01 < 0 ) THEN
                IF ( r_cta_otrostri.dh = 'H' ) THEN
                    r_cta_otrostri.dh := 'D';
                ELSE
                    r_cta_otrostri.dh := 'H';
                END IF;
            END IF;

            rec.id_ide := 1;
            rec.cuenta := r_cta_otrostri.cuenta;
            rec.dh := r_cta_otrostri.dh;
            rec.codcli := r_cta_otrostri.codcli;
            rec.razonc := r_cta_otrostri.razonc;
            rec.tident := r_cta_otrostri.tident;
            rec.ruc := r_cta_otrostri.ruc;
            rec.femisi := r_cta_otrostri.femisi;
            rec.tipdoc := r_cta_otrostri.tipdoc;
            rec.series := r_cta_otrostri.series;
            rec.numdoc := r_cta_otrostri.numdoc;
            rec.tipmon := r_cta_otrostri.tipmon;
            rec.tipcam := r_cta_otrostri.tipcam;
            rec.importe01 := abs(r_cta_otrostri.importe01);
            rec.importe02 := abs(r_cta_otrostri.importe02);
            dbms_output.put_line('CUENTA POR ARTICULO Y OTROS TRIBUTOS PERSONALIZADO - IMPRIME N5 - FACTOR441 - S');
            v_count := v_count + 1;
            rec.id_reg := v_count;
            PIPE ROW ( rec );
        END LOOP;
    ELSE
        FOR r_cta_otrostri IN cur_cuenta_otros_tributos(pin_id_cia, pin_numint) LOOP
            IF ( r_cta_otrostri.importe01 < 0 ) THEN
                IF ( r_cta_otrostri.dh = 'H' ) THEN
                    r_cta_otrostri.dh := 'D';
                ELSE
                    r_cta_otrostri.dh := 'H';
                END IF;
            END IF;

            rec.id_ide := 1;
            rec.cuenta := r_cta_otrostri.cuenta;
            rec.dh := r_cta_otrostri.dh;
            rec.codcli := r_cta_otrostri.codcli;
            rec.razonc := r_cta_otrostri.razonc;
            rec.tident := r_cta_otrostri.tident;
            rec.ruc := r_cta_otrostri.ruc;
            rec.femisi := r_cta_otrostri.femisi;
            rec.tipdoc := r_cta_otrostri.tipdoc;
            rec.series := r_cta_otrostri.series;
            rec.numdoc := r_cta_otrostri.numdoc;
            rec.tipmon := r_cta_otrostri.tipmon;
            rec.tipcam := r_cta_otrostri.tipcam;
            rec.importe01 := abs(r_cta_otrostri.importe01);
            rec.importe02 := abs(r_cta_otrostri.importe02);
            dbms_output.put_line('CUENTA POR ARTICULO Y OTROS TRIBUTOS - IMPRIME N5 - FACTOR441 - N');
            v_count := v_count + 1;
            rec.id_reg := v_count;
            PIPE ROW ( rec );
        END LOOP;
    END IF;

    DECLARE BEGIN
        SELECT
            vstrg,
            cuenta
        INTO
            factortg_429,
            cuenta_429
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 429;/*Agrega reversión de asiento de transferencia gratuita*/

    EXCEPTION
        WHEN no_data_found THEN
            factortg_429 := NULL;
            cuenta_429 := NULL;
    END;

    IF ( factortg_429 = 'S' ) THEN
        rec.cuenta := NULL;
        rec.dh := NULL;
        rec.codcli := NULL;
        rec.razonc := NULL;
        rec.tident := NULL;
        rec.ruc := NULL;
        rec.femisi := NULL;
        rec.tipdoc := NULL;
        rec.series := NULL;
        rec.numdoc := NULL;
        rec.tipmon := 'PEN';
        rec.tipcam := 0.0;
        rec.importe01 := NULL;
        rec.importe02 := NULL;
        FOR r_cta_tg IN cur_cuenta_transferencia_gratuita(pin_id_cia, pin_numint) LOOP
            rec.cuenta := r_cta_tg.cuenta;
            rec.dh := r_cta_tg.dh;
            rec.codcli := r_cta_tg.codcli;
            rec.razonc := r_cta_tg.razonc;
            rec.tident := r_cta_tg.tident;
            rec.ruc := r_cta_tg.ruc;
            rec.femisi := r_cta_tg.femisi;
            rec.tipdoc := r_cta_tg.tipdoc;
            rec.series := r_cta_tg.series;
            rec.numdoc := r_cta_tg.numdoc;
            rec.tipmon := r_cta_tg.tipmon;
            rec.tipcam := r_cta_tg.tipcam;
            rec.importe01 := r_cta_tg.importe01;
            rec.importe02 := r_cta_tg.importe02;
            dbms_output.put_line('IMPRIME N6');
            v_count := v_count + 1;
            rec.id_reg := v_count;
            PIPE ROW ( rec );
        END LOOP;

        rec.cuenta := NULL;
        rec.dh := NULL;
        rec.codcli := NULL;
        rec.razonc := NULL;
        rec.tident := NULL;
        rec.ruc := NULL;
        rec.femisi := NULL;
        rec.tipdoc := NULL;
        rec.series := NULL;
        rec.numdoc := NULL;
        rec.tipmon := 'PEN';
        rec.tipcam := 0.0;
        rec.importe01 := NULL;
        rec.importe02 := NULL;
        FOR r_ctar_rtg IN cur_cuenta_reversion_tranferencia_g(pin_id_cia, pin_numint) LOOP
            rec.cuenta := r_ctar_rtg.cuenta;
            rec.dh := r_ctar_rtg.dh;
            rec.codcli := r_ctar_rtg.codcli;
            rec.razonc := r_ctar_rtg.razonc;
            rec.tident := r_ctar_rtg.tident;
            rec.ruc := r_ctar_rtg.ruc;
            rec.femisi := r_ctar_rtg.femisi;
            rec.tipdoc := r_ctar_rtg.tipdoc;
            rec.series := r_ctar_rtg.series;
            rec.numdoc := r_ctar_rtg.numdoc;
            rec.tipmon := r_ctar_rtg.tipmon;
            rec.tipcam := r_ctar_rtg.tipcam;
            rec.importe01 := r_ctar_rtg.importe01;
            rec.importe02 := r_ctar_rtg.importe02;
            IF ( r_ctar_rtg.importe01 > 0 ) THEN
                dbms_output.put_line('IMPRIME N7');
                v_count := v_count + 1;
                rec.id_reg := v_count;
                PIPE ROW ( rec );
            END IF;

        END LOOP;

        rec.cuenta := NULL;
        rec.dh := NULL;
        rec.codcli := NULL;
        rec.razonc := NULL;
        rec.tident := NULL;
        rec.ruc := NULL;
        rec.femisi := NULL;
        rec.tipdoc := NULL;
        rec.series := NULL;
        rec.numdoc := NULL;
        rec.tipmon := 'PEN';
        rec.tipcam := 0.0;
        rec.importe01 := NULL;
        rec.importe02 := NULL;


     /* CUENTA POR ARTICULO Y OTROS TRIBUTOS - SOLO TRANSFERENCIA GRATUITA */
        FOR r_cta_tg IN cur_cuenta_art_otr_tg(pin_id_cia, pin_numint) LOOP
            IF ( r_cta_tg.importe01 < 0 ) THEN
                IF ( r_cta_tg.dh = 'H' ) THEN
                    r_cta_tg.dh := 'D';
                ELSE
                    r_cta_tg.dh := 'H';
                END IF;
            END IF;

            rec.cuenta := r_cta_tg.cuenta;
            rec.dh := r_cta_tg.dh;
            rec.codcli := r_cta_tg.codcli;
            rec.razonc := r_cta_tg.razonc;
            rec.tident := r_cta_tg.tident;
            rec.ruc := r_cta_tg.ruc;
            rec.femisi := r_cta_tg.femisi;
            rec.tipdoc := r_cta_tg.tipdoc;
            rec.series := r_cta_tg.series;
            rec.numdoc := r_cta_tg.numdoc;
            rec.tipmon := r_cta_tg.tipmon;
            rec.tipcam := r_cta_tg.tipcam;
            rec.importe01 := r_cta_tg.importe01;
            rec.importe02 := r_cta_tg.importe02;
            dbms_output.put_line('IMPRIME N8');
            v_count := v_count + 1;
            rec.id_reg := v_count;
            PIPE ROW ( rec );
        END LOOP;

    END IF;

END;

/
