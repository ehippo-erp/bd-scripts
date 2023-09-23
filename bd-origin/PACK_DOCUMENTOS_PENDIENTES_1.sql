--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_PENDIENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_PENDIENTES" AS

    FUNCTION sp_detalle_cpe_pendientes_envio_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_detalle_pendientes_envio_sunat
        PIPELINED
    AS
        v_table datatable_detalle_pendientes_envio_sunat;
    BEGIN
        SELECT
            c.id_cia,
            c.numint,
            CASE
                WHEN s.estado = 0
                     OR s.estado IS NULL THEN
                    'NO ENVIADO A SUNAT'
                ELSE
                    CASE
                        WHEN s.estado IN ( 2, 4 ) THEN
                                'CPE PENDIENTES POR ANULACION (RECHAZADOS Y DADOS DE BAJA'
                    END
            END       AS estado,
            c.tipdoc,
            d2.descri AS desdoc,
            c.femisi,
            c.series,
            c.numdoc,
            c.codcli,
            NULL,
            NULL,
            c.tident  AS cab_tident,
            c.ruc,
            c.razonc,
            c.preven
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab             c
            LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                            AND s.numint = c.numint
            LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
                                               AND ( d2.tipdoc = c.tipdoc )
            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
                                              AND doc.codigo = c.tipdoc
                                              AND doc.series = c.series
--            LEFT OUTER JOIN cliente                    cl ON cl.id_cia = c.id_cia
--                                          AND ( cl.codcli = c.codcli )
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.femisi BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND current_date )
--            AND ( ( pin_tipdoc IS NULL
--                    AND c.tipdoc IN ( 1, 3, 7, 8, 102 ) )
--                  OR c.tipdoc = pin_tipdoc )
--            AND c.situac = 'F'
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
            s.estado;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_detalle_cpe_pendientes_envio_sunat;

    FUNCTION sp_resumen_cpe_pendientes_envio_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_resumen_pendientes_envio_sunat
        PIPELINED
    AS
        v_table datatable_resumen_pendientes_envio_sunat;
    BEGIN
--        SELECT
--            c.tipdoc,
--            (
--                CASE
--                    WHEN s.estado = 0 THEN
--                        d2.descri || ' NO ENVIADAS'
--                    ELSE
--                        d2.descri || ' RECHAZADAS'
--                END
--            )               AS desdoc,
--            COUNT(c.numint) AS numpen
--        BULK COLLECT
--        INTO v_table
--        FROM
--            documentos_cab             c
--            LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
--                                                            AND s.numint = c.numint
--            LEFT OUTER JOIN tdoccobranza               d2 ON d2.id_cia = c.id_cia
--                                               AND ( d2.tipdoc = c.tipdoc )
--            LEFT OUTER JOIN documentos                 doc ON doc.id_cia = c.id_cia
--                                              AND doc.codigo = c.tipdoc
--                                              AND doc.series = c.series
--        WHERE
--                c.id_cia = pin_id_cia
--            AND ( c.femisi BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND current_date )
----            AND ( ( pin_tipdoc IS NULL
----                    AND c.tipdoc IN ( 1, 3, 7, 8, 102 ) )
----                  OR c.tipdoc = pin_tipdoc )
----            AND c.situac = 'F'
--            AND ( ( c.tipdoc IN ( 1, 3, 7, 8 )
--                    AND c.situac = 'F' )
--                  OR ( c.tipdoc = 102
--                       AND c.situac IN ( 'F', 'C' ) ) )
--            AND doc.docelec = 'S'
--            AND ( s.estado IS NULL
--                  OR ( s.estado = 0
--                       AND s.cres = 0 )
--                  OR s.estado = 2 )
--        GROUP BY
--            c.tipdoc,
--            s.estado,
--            d2.descri
--        ORDER BY
--            c.tipdoc;

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
            COUNT(c.numint) AS numpen
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
        GROUP BY
            c.tipdoc,
            s.estado,
            d2.descri,
            dt.descri
        ORDER BY
            c.tipdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_resumen_cpe_pendientes_envio_sunat;

    FUNCTION sp_detalle_planilla (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codcli   VARCHAR2,
        pin_solodesc VARCHAR2,
        pin_fhasta   DATE
    ) RETURN datatable_detalle_planilla
        PIPELINED
    AS
        v_table datatable_detalle_planilla;
    BEGIN
        SELECT
            d.id_cia,
            d.numint,
            d.tipdoc,
            d.docume,
            d.serie,
            d.numero,
            d.femisi,
            d.fvenci,
            d.codban,
            d.numbco,
            d.refere01,
            d.refere02,
            d.tipmon,
            d.importe,
            d.importemn,
            d.importeme,
            d.saldo,
            d.saldomn,
            d.saldome,
            d.dh,
            d.cuenta,
            d.tipcam,
            d.protes,
            c.codcli,
            c.razonc,
            c.regret,
            c.tident,
            c.dident,
            td.codsunat,
            td.abrevi,
            nvl(cr.tasa, 0),
            nvl(cr.tope, 0),
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldo > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldo * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoret,
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldomn > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldomn * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoretmn,
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldome > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldome * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoretme
        BULK COLLECT
        INTO v_table
        FROM
            dcta100                                                                       d
            LEFT OUTER JOIN tdoccobranza                                                                  td ON td.id_cia = d.id_cia
                                               AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN cliente                                                                       c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN pack_retencion.sp_regimen_retencion(d.id_cia, c.regret, d.codcli, pin_fhasta) cr ON 0 = 0
            LEFT OUTER JOIN factor                                                                        f331 ON f331.id_cia = d.id_cia
                                           AND f331.codfac = 331
            LEFT OUTER JOIN factor                                                                        f332 ON f332.id_cia = d.id_cia
                                           AND f332.codfac = 332
        WHERE
                d.id_cia = pin_id_cia
            AND d.codcli = pin_codcli
            AND d.saldo <> 0
            AND ( pin_tipdoc IS NULL
                  OR pin_tipdoc = - 1
                  OR d.tipdoc = pin_tipdoc )
            AND ( pin_fhasta IS NULL
                  OR d.femisi <= pin_fhasta )
            AND ( ( nvl(pin_solodesc, 'N') = 'N'
                    AND d.operac IN ( 0, 1 ) )
                  OR ( pin_solodesc = 'S'
                       AND d.operac IN ( 1, 2 ) ) )
        ORDER BY
            d.femisi;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_planilla;

    FUNCTION sp_detalle_planilla_docume (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_docume   VARCHAR2,
        pin_solodesc VARCHAR2,
        pin_fhasta   DATE
    ) RETURN datatable_detalle_planilla
        PIPELINED
    AS
        v_table datatable_detalle_planilla;
    BEGIN
        SELECT
            d.id_cia,
            d.numint,
            d.tipdoc,
            d.docume,
            d.serie,
            d.numero,
            d.femisi,
            d.fvenci,
            d.codban,
            d.numbco,
            d.refere01,
            d.refere02,
            d.tipmon,
            d.importe,
            d.importemn,
            d.importeme,
            d.saldo,
            d.saldomn,
            d.saldome,
            d.dh,
            d.cuenta,
            d.tipcam,
            d.protes,
            c.codcli,
            c.razonc,
            c.regret,
            c.tident,
            c.dident,
            td.codsunat,
            td.abrevi,
            nvl(cr.tasa, 0),
            nvl(cr.tope, 0),
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldo > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldo * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoret,
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldomn > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldomn * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoretmn,
            CASE
                WHEN f331.vstrg = 'N'
                     AND f332.vstrg = 'N'
                     AND c.regret = 1
                     AND d.saldo = d.importe
                     AND decode(d.tipmon, 'PEN', d.importe, d.importe * d.tipcam) > nvl(cr.tope, 0)
                     AND d.saldome > 0
                     AND nvl(cr.tasa, 0) > 0 THEN
                    ( d.saldome * ( 100 - cr.tasa ) ) / 100
                ELSE
                    0
            END AS saldoretme
        BULK COLLECT
        INTO v_table
        FROM
            dcta100                                                                       d
            LEFT OUTER JOIN tdoccobranza                                                                  td ON td.id_cia = d.id_cia
                                               AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN cliente                                                                       c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN pack_retencion.sp_regimen_retencion(d.id_cia, c.regret, d.codcli, pin_fhasta) cr ON 0 = 0
            LEFT OUTER JOIN factor                                                                        f331 ON f331.id_cia = d.id_cia
                                           AND f331.codfac = 331
            LEFT OUTER JOIN factor                                                                        f332 ON f332.id_cia = d.id_cia
                                           AND f332.codfac = 332
        WHERE
                d.id_cia = pin_id_cia
            AND d.docume = pin_docume
            AND d.saldo <> 0
            AND ( pin_tipdoc IS NULL
                  OR pin_tipdoc = - 1
                  OR d.tipdoc = pin_tipdoc )
            AND ( pin_fhasta IS NULL
                  OR d.femisi <= pin_fhasta )
            AND ( ( nvl(pin_solodesc, 'N') = 'N'
                    AND d.operac IN ( 0, 1 ) )
                  OR ( pin_solodesc = 'S'
                       AND d.operac <= 2 ) )
        ORDER BY
            d.femisi;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_planilla_docume;

    FUNCTION sp_planilla_ingban (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2
    ) RETURN datatable_planilla_ingban
        PIPELINED
    AS
        v_table datatable_planilla_ingban;
    BEGIN
        SELECT DISTINCT
            d3.id_cia,
            d3.libro,
            d3.periodo,
            d3.mes,
            d3.secuencia,
            d2.concep,
            d2.dia,
            d2.situac,
            d2.femisi,
            d2.referencia,
            CASE
                WHEN d2.conpag = 1 THEN
                    'Cobranza'
                ELSE
                    CASE
                        WHEN d2.conpag = 2 THEN
                                'Descuento'
                        ELSE
                            CASE
                                WHEN d2.conpag = 3 THEN
                                            'Garantia'
                                ELSE
                                    'No definido'
                            END
                    END
            END AS tipenvio
        BULK COLLECT
        INTO v_table
        FROM
            dcta102            d2
            LEFT OUTER JOIN dcta103            d3 ON d3.id_cia = d2.id_cia
                                          AND d3.libro = d2.libro
                                          AND d3.periodo = d2.periodo
                                          AND d3.mes = d2.mes
                                          AND d3.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta103_rel        dr ON dr.id_cia = d2.id_cia
                                              AND dr.r_libro = d3.libro
                                              AND dr.r_periodo = d3.periodo
                                              AND dr.r_mes = d3.mes
                                              AND dr.r_secuencia = d3.secuencia
                                              AND dr.r_item = d3.item
            LEFT OUTER JOIN dcta102_aprobacion da ON da.id_cia = d2.id_cia
                                                     AND da.libro = d2.libro
                                                     AND da.periodo = d2.periodo
                                                     AND da.mes = d2.mes
                                                     AND da.secuencia = d2.secuencia
                                                     AND da.tipo = 1
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.tippla = 118
            AND d2.situac = 'B'
            AND ( dr.libro IS NULL )
            AND ( da.vdate IS NOT NULL )
            AND d2.conpag = 2
            AND d2.codcob = pin_codban;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_planilla_ingban;

    FUNCTION sp_planilla_ingban_detalle (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_planilla_ingban_detalle
        PIPELINED
    AS
        v_table datatable_planilla_ingban_detalle;
    BEGIN
        SELECT
            d3.*
        BULK COLLECT
        INTO v_table
        FROM
            dcta103     d3
            LEFT OUTER JOIN dcta103_rel dr ON dr.id_cia = d3.id_cia
                                              AND dr.r_libro = d3.libro
                                              AND dr.r_periodo = d3.periodo
                                              AND dr.r_mes = d3.mes
                                              AND dr.r_secuencia = d3.secuencia
                                              AND dr.r_item = d3.item
        WHERE
                d3.id_cia = pin_id_cia
            AND d3.libro = pin_libro
            AND d3.periodo = pin_periodo
            AND d3.mes = pin_mes
            AND d3.secuencia = pin_secuencia
            AND ( dr.libro IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_planilla_ingban_detalle;

    FUNCTION sp_consulta (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codcli   VARCHAR2,
        pin_docume   VARCHAR2,
        pin_chksaldo VARCHAR2,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_limit    INTEGER,
        pin_offset   INTEGER
    ) RETURN datatable_consulta
        PIPELINED
    AS
        v_table datatable_consulta;
    BEGIN
        SELECT
            d1.*,
            c.razonc,
            ca.razonc    AS razonc_acep,
            CASE
                WHEN d1.tipdoc = 6 THEN
                    ef.descri
                ELSE
                    b.descri
            END          AS desban,
            do.desoperac AS operac_desc,
            CASE
                WHEN d1.protes = 1 THEN
                    'SI'
                ELSE
                    'NO'
            END          AS protesto_des
        BULK COLLECT
        INTO v_table
        FROM
            dcta100        d1
            LEFT OUTER JOIN dcta100_operac do ON do.id_cia = 1
                                                 AND do.operac = d1.operac
            LEFT OUTER JOIN cliente        c ON c.id_cia = d1.id_cia
                                         AND c.codcli = d1.codcli
            LEFT OUTER JOIN cliente        ca ON ca.id_cia = d1.id_cia
                                          AND ca.codcli = d1.codacep
            LEFT OUTER JOIN tbancos        b ON b.id_cia = d1.id_cia
                                         AND b.codban = d1.codban
            LEFT OUTER JOIN e_financiera   ef ON ef.id_cia = d1.id_cia
                                               AND ef.codigo = d1.codban
        WHERE
                d1.id_cia = pin_id_cia
            AND d1.tipdoc = pin_tipdoc
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( d1.femisi BETWEEN pin_fdesde AND pin_fhasta ) )
            AND ( pin_codcli IS NULL
                  OR d1.codcli = pin_codcli )
            AND ( d1.codubi = '1'
                  OR d1.codubi IS NULL )
            AND ( ( pin_chksaldo = 'S'
                    AND d1.saldo <> 0 )
                  OR nvl(pin_chksaldo, 'N') = 'N' )
            AND ( pin_docume IS NULL
                  OR d1.docume LIKE pin_docume )
        ORDER BY
            d1.femisi DESC
        OFFSET
            CASE
                WHEN nvl(pin_offset, - 1) = - 1 THEN
                    0
                ELSE
                    pin_offset
            END
        ROWS FETCH NEXT
            CASE
                WHEN nvl(pin_limit, - 1) = - 1 THEN
                    999999
                ELSE
                    pin_limit
            END
        ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_consulta;

END;

/
