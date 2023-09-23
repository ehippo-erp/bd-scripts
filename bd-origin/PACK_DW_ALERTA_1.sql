--------------------------------------------------------
--  DDL for Package Body PACK_DW_ALERTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW_ALERTA" AS

    FUNCTION sp_pendiente_sunat_reporte (
        pin_id_cia  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codsuc  IN NUMBER,
        pin_lugemi  IN NUMBER,
        pin_codmot  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_codven  IN NUMBER
    ) RETURN datatable_pendiente_sunat_reporte
        PIPELINED
    AS
        v_table datatable_pendiente_sunat_reporte;
    BEGIN
        SELECT
            CASE
                WHEN s.estado = 0
                     OR s.estado IS NULL THEN
                    'NO ENVIADO A SUNAT'
                ELSE
                    CASE
                        WHEN s.estado IN ( 2, 4 ) THEN
                                'CPE PENDIENTES POR ANULACION (RECHAZADOS Y DADOS DE BAJA'
                    END
            END                              AS estado,
            c.tipdoc,
            upper(nvl(d2.descri, dt.descri)) AS desdoc,
            sss.sucursal,
            c.numint,
            c.series,
            c.numdoc,
            c.femisi,
            cl.tident,
            cl.dident,
            c.codcli,
            c.razonc,
            c.preven,
            c.monafe,
            c.monina,
            c.monigv,
            m.desmot,
            ss.dessit
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                            AND s.numint = c.numint
            LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
                                               AND d2.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = c.id_cia
                                                  AND dt.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN sucursal                   sss ON sss.id_cia = c.id_cia
                                            AND sss.codsuc = c.codsuc
            LEFT OUTER JOIN motivos                    m ON m.id_cia = c.id_cia
                                         AND m.tipdoc = c.tipdoc
                                         AND m.id = c.id
                                         AND m.codmot = c.codmot
            LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                            AND ss.tipdoc = c.tipdoc
                                            AND ss.situac = c.situac
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.femisi BETWEEN pin_fdesde AND pin_fhasta )
            AND ( nvl(pin_tipdoc, - 1) = - 1
                  OR c.tipdoc = pin_tipdoc )
            AND ( nvl(pin_codsuc, - 1) = - 1
                  OR c.codsuc = pin_codsuc )
            AND ( pin_codcli IS NULL
                  OR c.codcli = pin_codcli )
            AND ( nvl(pin_lugemi, - 1) = - 1
                  OR c.lugemi = pin_lugemi )
            AND ( nvl(pin_codmot, - 1) = - 1
                  OR c.codmot = pin_codmot )
            AND ( nvl(pin_codven, - 1) = - 1
                  OR c.codven = pin_codven )
            AND ( ( c.tipdoc IN ( 1, 3, 7, 8 )
                    AND c.situac = 'F' )
                  OR ( c.tipdoc = 102
                       AND c.situac IN ( 'F', 'C' ) ) )
            AND doc.docelec = 'S'
            AND ( s.estado IS NULL
                  OR ( s.estado = 0
                       AND s.cres = 0 )
                  OR s.estado = 2 )
        ORDER BY
            s.estado,
            c.series,
            c.numdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_pendiente_sunat_reporte;

    FUNCTION sp_pendiente_sunat_detalle (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_pendiente_sunat_detalle
        PIPELINED
    AS
        v_table datatable_pendiente_sunat_detalle;
    BEGIN
        IF
            pin_fdesde IS NULL
            AND pin_fhasta IS NULL
        THEN
            SELECT
                CASE
                    WHEN s.estado = 0
                         OR s.estado IS NULL THEN
                        'NO ENVIADO A SUNAT'
                    ELSE
                        CASE
                            WHEN s.estado IN ( 2, 4 ) THEN
                                    'CPE PENDIENTES POR ANULACION (RECHAZADOS Y DADOS DE BAJA'
                        END
                END                              AS estado,
                upper(nvl(d2.descri, dt.descri)) AS desdoc,
                sss.sucursal,
                c.numint,
                c.series,
                c.numdoc,
                to_char(c.femisi, 'DD/MM/YY'),
                c.codcli,
                c.razonc,
                m.desmot,
                ss.dessit
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
                LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
                                                   AND d2.tipdoc = c.tipdoc
                LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = c.id_cia
                                                      AND dt.tipdoc = c.tipdoc
                LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                                  AND doc.codigo = c.tipdoc
                                                  AND doc.series = c.series
                LEFT OUTER JOIN sucursal                   sss ON sss.id_cia = c.id_cia
                                                AND sss.codsuc = c.codsuc
                LEFT OUTER JOIN motivos                    m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                                AND ss.tipdoc = c.tipdoc
                                                AND ss.situac = c.situac
            WHERE
                    c.id_cia = pin_id_cia
                AND ( c.femisi BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND current_date )
                AND ( ( c.tipdoc IN ( 1, 3, 7, 8 )
                        AND c.situac = 'F' )
                      OR ( c.tipdoc = 102
                           AND c.situac IN ( 'F', 'C' ) ) )
                AND doc.docelec = 'S'
                AND ( s.estado IS NULL
                      OR ( s.estado = 0
                           AND s.cres = 0 )
                      OR s.estado = 2 )
            ORDER BY
                s.estado,
                c.series,
                c.numdoc;

        ELSE
            SELECT
                CASE
                    WHEN s.estado = 0
                         OR s.estado IS NULL THEN
                        'NO ENVIADO A SUNAT'
                    ELSE
                        CASE
                            WHEN s.estado IN ( 2, 4 ) THEN
                                    'CPE PENDIENTES POR ANULACION (RECHAZADOS Y DADOS DE BAJA'
                        END
                END                              AS estado,
                upper(nvl(d2.descri, dt.descri)) AS desdoc,
                sss.sucursal,
                c.numint,
                c.series,
                c.numdoc,
                to_char(c.femisi, 'DD/MM/YY'),
                c.codcli,
                c.razonc,
                m.desmot,
                ss.dessit
            BULK COLLECT
            INTO v_table
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
                LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
                                                   AND d2.tipdoc = c.tipdoc
                LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = c.id_cia
                                                      AND dt.tipdoc = c.tipdoc
                LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                                  AND doc.codigo = c.tipdoc
                                                  AND doc.series = c.series
                LEFT OUTER JOIN sucursal                   sss ON sss.id_cia = c.id_cia
                                                AND sss.codsuc = c.codsuc
                LEFT OUTER JOIN motivos                    m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                                AND ss.tipdoc = c.tipdoc
                                                AND ss.situac = c.situac
            WHERE
                    c.id_cia = pin_id_cia
                AND ( c.femisi BETWEEN pin_fdesde AND pin_fhasta )
                AND ( pin_tipdoc IS NULL
                      OR c.tipdoc IN ( pin_tipdoc ) )
                AND ( ( c.tipdoc IN ( 1, 3, 7, 8 )
                        AND c.situac = 'F' )
                      OR ( c.tipdoc = 102
                           AND c.situac IN ( 'F', 'C' ) ) )
                AND doc.docelec = 'S'
                AND ( s.estado IS NULL
                      OR ( s.estado = 0
                           AND s.cres = 0 )
                      OR s.estado = 2 )
            ORDER BY
                s.estado,
                c.series,
                c.numdoc;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_pendiente_sunat_detalle;

    -- ESTADISTICAS DEL DASHBOARD
    FUNCTION sp_pendiente_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED
    AS
        v_table datatable_alerta;
    BEGIN
        SELECT
            c.tipdoc,
            (
                CASE
                    WHEN s.estado = 0 THEN
                        upper(nvl(d2.descri, dt.descri))
                        || ' NO ENVIADAS'
                    ELSE
                        upper(nvl(d2.descri, dt.descri))
                        || ' RECHAZADAS'
                END
            )               AS desdoc,
            COUNT(c.numint) AS numpen,
            ref.linkref,
            c.tipdoc,
            'F',
            ss.dessit,
            TO_DATE('01/01/22', 'DD/MM/YY'),
            current_timestamp
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                            AND s.numint = c.numint
            LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
                                               AND d2.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_tipo            dt ON dt.id_cia = c.id_cia
                                                  AND dt.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN situacion                  ss ON ss.id_cia = c.id_cia
                                            AND ss.tipdoc = c.tipdoc
                                            AND ss.situac = 'F' -- FIJO , PARA EVITAR PARTICION POR SITUACION, GREM
            LEFT OUTER JOIN dw_documento_tipo_ref      ref ON ref.tipdoc = c.tipdoc
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.femisi BETWEEN TO_DATE('01/01/22', 'DD/MM/YY') AND current_date )
            AND ( ( c.tipdoc IN ( 1, 3, 7, 8 )
                    AND c.situac = 'F' )
                  OR ( c.tipdoc = 102
                       AND c.situac IN ( 'F', 'C' ) ) )
            AND doc.docelec = 'S'
            AND ( s.estado IS NULL
                  OR ( s.estado = 0
                       AND s.cres = 0 )
                  OR s.estado = 2 )
        GROUP BY
            c.tipdoc,
            s.estado,
            d2.descri,
            dt.descri,
            ref.linkref,
            'F',
            ss.dessit,
            TO_DATE('01/01/22', 'DD/MM/YY'),
            current_timestamp
        ORDER BY
            c.tipdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_pendiente_sunat;

    FUNCTION sp_vencimiento_certificado (
        pin_id_cia NUMBER
    ) RETURN datatable_alerta
        PIPELINED
    AS
        v_table datatable_alerta;
        v_rec   datarecord_alerta;
    BEGIN
        BEGIN
            SELECT
                pfx.item AS tipdoc,
                CASE
                    WHEN pfx.fvenci IS NOT NULL THEN
                            CASE
                                WHEN trunc(pfx.fvenci) - trunc(current_date) > 0 THEN
                                    'Su certificado digital para emitir CPE está por vencer '
                                    || CHR(13)
                                    || 'Le quedan '
                                    || to_char(floor(trunc(pfx.fvenci) - trunc(current_date)))
                                    || ' días'
                                WHEN trunc(pfx.fvenci) - trunc(current_date) = 0 THEN
                                    'Su certificado digital para emitir CPE vence hoy'
                                ELSE
                                    'Su certificado digital para emitir CPE a vencido. '
                                    || CHR(13)
                                    || 'Renovar para poder enviar a SUNAT los CPE'
                            END
                    ELSE
                        'ERROR, EL CERTIFICADO NO TIENE FECHA DE VENCIMIENTO REGISTRADO, CONTACTAR POR SOPORTE'
                END      AS desdoc,
                CASE
                    WHEN pfx.fvenci IS NOT NULL THEN
                            CASE
                                WHEN trunc(pfx.fvenci) - trunc(current_date) > 0 THEN
                                    trunc(pfx.fvenci) - trunc(current_date)
                                WHEN trunc(pfx.fvenci) - trunc(current_date) = 0 THEN
                                    0
                                ELSE
                                    trunc(pfx.fvenci) - trunc(current_date)
                            END
                    ELSE
                        0
                END      AS numped
            INTO
                v_rec.tipdoc,
                v_rec.desdoc,
                v_rec.numpen
            FROM
                certificados_pfx pfx
            WHERE
                    pfx.id_cia = pin_id_cia
                AND ( trunc(pfx.fvenci) - trunc(current_date) <= 30 )
                AND swacti = 'S'
            ORDER BY
                pfx.item DESC
            FETCH NEXT 1 ROWS ONLY;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                v_rec.tipdoc := 0;
                v_rec.desdoc := 'ERROR, LA EMPRESA NO TIENEN NINGUN CERTIFICADO REGISTRADO';
                v_rec.numpen := 0;
        END;

        RETURN;
    END sp_vencimiento_certificado;

    FUNCTION sp_pendiente_documentos (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED
    AS
        v_table datatable_alerta;
    BEGIN
        SELECT
            c.tipdoc,
            upper(
                CASE
                    WHEN c.tipdoc = 103 THEN
                        'GUIAS INTERNAS EMITIDAS'
                    WHEN c.tipdoc = 100 THEN
                            CASE
                                WHEN c.situac = 'A' THEN
                                    'COTIZACION POR VISAR'
                                ELSE
                                    'COTIZACION POR APROBAR CLIENTE'
                            END
                    WHEN c.tipdoc = 101 THEN
                            CASE
                                WHEN c.situac = 'A' THEN
                                    'PEDIDO POR VISAR'
                                ELSE
                                    'PEDIDO POR APROBAR'
                            END
                    WHEN c.tipdoc = 201 THEN
                            CASE
                                WHEN c.situac = 'A' THEN
                                    'DEVOLUCION POR VISAR'
                                ELSE
                                    'DEVOLUCION POR APROBAR'
                            END
                    ELSE
                        CASE
                            WHEN c.situac = 'A' THEN
                                    nvl(d2.descri, dt.descri)
                                    || ' POR VISAR'
                            ELSE
                                nvl(d2.descri, dt.descri)
                                || ' POR APROBAR'
                        END
                END
            )               AS desdoc,
            COUNT(c.numint) AS numpen,
            ref.linkref,
            c.tipdoc,
            c.situac,
            s.dessit,
            TO_DATE('01/01/22', 'DD/MM/YY'),
            current_timestamp
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN tdoccobranza          d2 ON d2.id_cia = c.id_cia
                                               AND d2.tipdoc = c.tipdoc
            LEFT OUTER JOIN documentos_tipo       dt ON dt.id_cia = c.id_cia
                                                  AND dt.tipdoc = c.tipdoc
            LEFT OUTER JOIN situacion             s ON s.id_cia = c.id_cia
                                           AND s.tipdoc = c.tipdoc
                                           AND s.situac = c.situac
            LEFT OUTER JOIN documentos            doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
            LEFT OUTER JOIN dw_documento_tipo_ref ref ON ref.tipdoc = c.tipdoc
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.femisi BETWEEN TO_DATE('01/01/22', 'DD/MM/YY') AND current_date )
            AND ( ( c.tipdoc IN ( 100, 101, 201 )
                    AND c.situac IN ( 'A', 'B' ) )
                  OR ( c.tipdoc IN ( 103 )
                       AND c.situac = 'A' ) )
        GROUP BY
            c.tipdoc,
            c.situac,
            d2.descri,
            dt.descri,
            s.dessit,
            ref.linkref,
            TO_DATE('01/01/22', 'DD/MM/YY'),
            current_timestamp
        ORDER BY
            c.tipdoc,
            c.situac;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_pendiente_documentos;

    FUNCTION sp_pendiente_saldo (
        pin_id_cia NUMBER
    ) RETURN datatable_pendiente_saldo
        PIPELINED
    AS
        v_table datatable_pendiente_saldo;
    BEGIN
        SELECT
            t.modulo,
            t.tipmon,
            t.desdoc,
            t.saldo,
            NULL
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    'CXC'                   AS modulo,
                    d.tipmon                AS tipmon,
                    CASE
                        WHEN d.tipmon = 'PEN' THEN
                            'CUENTAS POR COBRAR S/. '
                        ELSE
                            'CUENTAS POR COBRAR $. '
                    END                     AS desdoc,
                    SUM(d.saldo * td.signo) AS saldo
                FROM
                    dcta100      d
                    LEFT OUTER JOIN tdoccobranza td ON td.id_cia = d.id_cia
                                                       AND td.tipdoc = d.tipdoc
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.saldo <> 0
                GROUP BY
                    'CXC',
                    d.tipmon
                UNION ALL
                SELECT
                    'CXP'                   AS modulo,
                    p.tipmon                AS tipmon,
                    CASE
                        WHEN p.tipmon = 'PEN' THEN
                            'CUENTAS POR PAGAR S/. '
                        ELSE
                            'CUENTAS POR PAGAR $. '
                    END                     AS desdoc,
                    SUM(p.saldo * td.signo) AS saldo
                FROM
                    prov100 p
                    LEFT OUTER JOIN tdocume td ON td.id_cia = p.id_cia
                                                  AND td.codigo = p.tipdoc
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.saldo <> 0
                GROUP BY
                    'CXP',
                    p.tipmon
            ) t
        ORDER BY
            t.modulo ASC,
            t.tipmon ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_pendiente_saldo;

END;

/
