--------------------------------------------------------
--  DDL for Package Body PACK_DW_PERIODO_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW_PERIODO_CUENTA" AS

    FUNCTION sp_reporte (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        IF pin_cuenta = 1 THEN
            SELECT
                d.id_cia,
                d.codcli,
                c.razonc,
                p.tipven,
                CASE
                    WHEN p.tipven = 1 THEN
                        'VENCIDOS'
                    WHEN p.tipven = 2 THEN
                        'POR VENCER'
                    ELSE
                        'TOTAL'
                END AS desven,
                p.orden,
                p.desran,
                CASE
                    WHEN pin_tipmon = 'PEN' THEN
                        SUM(
                            CASE
                                WHEN d.tipmon = 'PEN' THEN
                                    d.importemn
                                ELSE
                                    d.importeme * d.tipcam
                            END
                        )
                    ELSE
                        SUM(
                            CASE
                                WHEN d.tipmon = 'PEN' THEN
                                    d.importemn / d.tipcam
                                ELSE
                                    d.importeme
                            END
                        )
                END AS importe
            BULK COLLECT
            INTO v_table
            FROM
                     dcta100 d
                INNER JOIN periodo_cuenta p ON p.id_cia = d.id_cia
                                               AND p.tipran = pin_tipran
                                               AND ( current_date - d.fvenci ) BETWEEN p.rdesde AND p.rhasta
                LEFT OUTER JOIN cliente        c ON c.id_cia = d.id_cia
                                             AND c.codcli = d.codcli
            WHERE
                    d.id_cia = pin_id_cia
                AND d.saldo <> 0
                AND ( pin_codcli IS NULL
                      OR d.codcli = pin_codcli )
            GROUP BY
                d.id_cia,
                d.codcli,
                c.razonc,
                p.tipven,
                CASE
                        WHEN p.tipven = 1 THEN
                            'VENCIDOS'
                        WHEN p.tipven = 2 THEN
                            'POR VENCER'
                        ELSE
                            'TOTAL'
                END,
                p.orden,
                p.desran
            ORDER BY
                p.tipven,
                p.orden;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            SELECT
                d.id_cia,
                d.codcli,
                c.razonc,
                p.tipven,
                CASE
                    WHEN p.tipven = 1 THEN
                        'VENCIDOS'
                    WHEN p.tipven = 2 THEN
                        'POR VENCER'
                    ELSE
                        'TOTAL'
                END AS desven,
                p.orden,
                p.desran,
                CASE
                    WHEN pin_tipmon = 'PEN' THEN
                        SUM(
                            CASE
                                WHEN d.tipmon = 'PEN' THEN
                                    d.importemn
                                ELSE
                                    d.importeme * d.tipcam
                            END
                        )
                    ELSE
                        SUM(
                            CASE
                                WHEN d.tipmon = 'PEN' THEN
                                    d.importemn / d.tipcam
                                ELSE
                                    d.importeme
                            END
                        )
                END AS importe
            BULK COLLECT
            INTO v_table
            FROM
                     prov100 d
                INNER JOIN periodo_cuenta p ON p.id_cia = d.id_cia
                                               AND p.tipran = pin_tipran
                                               AND ( current_date - d.fvenci ) BETWEEN p.rdesde AND p.rhasta
                LEFT OUTER JOIN cliente        c ON c.id_cia = d.id_cia
                                             AND c.codcli = d.codcli
            WHERE
                    d.id_cia = pin_id_cia
                AND d.saldo <> 0
                AND ( pin_codcli IS NULL
                      OR d.codcli = pin_codcli )
            GROUP BY
                d.id_cia,
                d.codcli,
                c.razonc,
                p.tipven,
                CASE
                        WHEN p.tipven = 1 THEN
                            'VENCIDOS'
                        WHEN p.tipven = 2 THEN
                            'POR VENCER'
                        ELSE
                            'TOTAL'
                END,
                p.orden,
                p.desran
            ORDER BY
                p.tipven,
                p.orden;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_reporte;

    FUNCTION sp_reportev2 (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2
    ) RETURN datatable_reportev2
        PIPELINED
    AS
        v_table datatable_reportev2;
        v_rec   datarecord_reportev2;
    BEGIN
        FOR i IN (
            SELECT DISTINCT
                codcli,
                orden
            FROM
                pack_dw_periodo_cuenta.sp_reporte(pin_id_cia, pin_cuenta, pin_tipran, 'PEN', NULL)
        ) LOOP
            v_rec := datarecord_reportev2(NULL, NULL, NULL, 0, '',
                                         0, 0);

            FOR j IN (
                SELECT
                    *
                FROM
                    pack_dw_periodo_cuenta.sp_reporte(pin_id_cia, pin_cuenta, pin_tipran, 'PEN', i.codcli)
                WHERE
                    orden = i.orden
            ) LOOP
                v_rec.id_cia := j.id_cia;
                v_rec.codcli := j.codcli;
                v_rec.razonc := j.razonc;
                v_rec.orden := j.orden;
                v_rec.desran := j.desran;
                IF j.tipven = 1 THEN
                    v_rec.venc_importe := j.importe;
                ELSE
                    v_rec.xven_importe := j.importe;
                END IF;

            END LOOP;

            PIPE ROW ( v_rec );
        END LOOP;
    END sp_reportev2;

    FUNCTION sp_general (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2
    ) RETURN datatable_general
        PIPELINED
    AS
        v_table datatable_general;
        v_rec   datarecord_general;
    BEGIN
        FOR i IN (
            SELECT DISTINCT
                codcli
            FROM
                pack_dw_periodo_cuenta.sp_reporte(pin_id_cia, pin_cuenta, pin_tipran, 'PEN', NULL)
        ) LOOP
            v_rec := datarecord_general(NULL, NULL, NULL, 0, 0,
                                       0, 0, 0, 0, 0,
                                       0, 0, 0, 0);

            FOR j IN (
                SELECT
                    *
                FROM
                    pack_dw_periodo_cuenta.sp_reporte(pin_id_cia, pin_cuenta, pin_tipran, 'PEN', i.codcli)
            ) LOOP
                v_rec.id_cia := j.id_cia;
                v_rec.codcli := j.codcli;
                v_rec.razonc := j.razonc;
                IF j.tipven = 1 THEN
                    IF j.orden = 1 THEN
                        v_rec.venci1 := j.importe;
                    ELSIF j.orden = 2 THEN
                        v_rec.venci2 := j.importe;
                    ELSIF j.orden = 3 THEN
                        v_rec.venci3 := j.importe;
                    ELSE
                        v_rec.venci4 := j.importe;
                    END IF;

                    v_rec.ventot := j.importe + v_rec.ventot;
                ELSE
                    IF j.orden = 1 THEN
                        v_rec.pendt1 := j.importe;
                    ELSIF j.orden = 2 THEN
                        v_rec.pendt2 := j.importe;
                    ELSIF j.orden = 3 THEN
                        v_rec.pendt3 := j.importe;
                    ELSIF j.orden = 4 THEN
                        v_rec.pendt4 := j.importe;
                    END IF;

                    v_rec.pentot := j.importe + v_rec.pentot;
                END IF;

                v_rec.sumtot := j.importe + v_rec.sumtot;
            END LOOP;

            PIPE ROW ( v_rec );
        END LOOP;
    END sp_general;

    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_cuenta NUMBER,
        pin_tipran NUMBER,
        pin_tipmon VARCHAR2,
        pin_codcli VARCHAR2,
        pin_tipven NUMBER,
        pin_orden  NUMBER
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        IF pin_cuenta = 1 THEN
            SELECT
                d.id_cia,
                d.codcli,
                c.razonc,
--                p.tipven,
--                CASE
--                    WHEN p.tipven = 1 THEN
--                        'VENCIDOS'
--                    WHEN p.tipven = 2 THEN
--                        'POR VENCER'
--                    ELSE
--                        'TOTAL'
--                END       AS desven,
--                p.orden,
--                p.desran,
                m.desmot,
                upper(td.descri) AS tipdoc,
                d.serie,
                d.numero,
                upper(v.desven),
                d.femisi,
                nvl(d.fvenci, d.femisi),
                trunc((current_date - nvl(d.fvenci, d.femisi)), 0),
                d.tipmon,
                d.tipcam,
                d.importe,
                d.importemn,
                d.importeme,
                d.saldo
            BULK COLLECT
            INTO v_table
            FROM
                     dcta100 d
                INNER JOIN periodo_cuenta p ON p.id_cia = d.id_cia
                                               AND p.tipran = pin_tipran
                                               AND p.orden = pin_orden
                                               AND p.tipven = pin_tipven
                                               AND ( current_date - nvl(d.fvenci, d.femisi) ) BETWEEN p.rdesde AND p.rhasta
                LEFT OUTER JOIN cliente        c ON c.id_cia = d.id_cia
                                             AND c.codcli = d.codcli
                LEFT OUTER JOIN documentos_cab cc ON cc.id_cia = d.id_cia
                                                     AND cc.numint = d.numint
                LEFT OUTER JOIN motivos        m ON m.id_cia = d.id_cia
                                             AND m.codmot = cc.codmot
                                             AND m.id = cc.id
                                             AND m.tipdoc = cc.tipdoc
                LEFT OUTER JOIN tdoccobranza   td ON td.id_cia = d.id_cia
                                                   AND td.tipdoc = cc.tipdoc
                LEFT OUTER JOIN vendedor       v ON v.id_cia = d.id_cia
                                              AND v.codven = cc.codven
            WHERE
                    d.id_cia = pin_id_cia
                AND d.saldo <> 0
                AND d.codcli = pin_codcli
            ORDER BY
                p.tipven,
                p.orden;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            SELECT
                d.id_cia,
                d.codcli,
                c.razonc,
--                p.tipven,
--                CASE
--                    WHEN p.tipven = 1 THEN
--                        'VENCIDOS'
--                    WHEN p.tipven = 2 THEN
--                        'POR VENCER'
--                    ELSE
--                        'TOTAL'
--                END       AS desven,
--                p.orden,
--                p.desran,
                cc.concep,
                upper(td.descri) AS tipdoc,
                d.serie,
                d.numero,
                upper(u.nombres),
                d.femisi,
                nvl(d.fvenci, d.femisi),
                trunc((current_date - nvl(d.fvenci, d.femisi)), 0),
                d.tipmon,
                d.tipcam,
                d.importe,
                d.importemn,
                d.importeme,
                d.saldo
            BULK COLLECT
            INTO v_table
            FROM
                     prov100 d
                INNER JOIN periodo_cuenta p ON p.id_cia = d.id_cia
                                               AND p.tipran = pin_tipran
                                               AND p.orden = pin_orden
                                               AND p.tipven = pin_tipven
                                               AND ( current_date - nvl(d.fvenci, d.femisi) ) BETWEEN p.rdesde AND p.rhasta
                LEFT OUTER JOIN cliente        c ON c.id_cia = d.id_cia
                                             AND c.codcli = d.codcli
                LEFT OUTER JOIN compr010       cc ON cc.id_cia = d.id_cia
                                               AND cc.nserie = d.serie
                                               AND cc.numero = d.numero
                LEFT OUTER JOIN tdocume        td ON td.id_cia = d.id_cia
                                              AND td.codigo = cc.tdocum
                LEFT OUTER JOIN usuarios       u ON u.id_cia = d.id_cia
                                              AND u.coduser = cc.usuari
            WHERE
                    d.id_cia = pin_id_cia
                AND d.saldo <> 0
                AND d.codcli = pin_codcli
            ORDER BY
                p.tipven,
                p.orden;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_detalle;

END;

/
