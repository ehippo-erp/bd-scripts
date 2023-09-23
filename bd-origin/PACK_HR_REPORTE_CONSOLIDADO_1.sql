--------------------------------------------------------
--  DDL for Package Body PACK_HR_REPORTE_CONSOLIDADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_REPORTE_CONSOLIDADO" AS

    FUNCTION sp_ingreso_noafecto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_ingreso_noafecto
        PIPELINED
    AS
        v_table datatable_ingreso_noafecto;
    BEGIN
        SELECT
            id_cia,
            codper,
            SUM(nvl(valcon, 0))
        BULK COLLECT
        INTO v_table
        FROM
            planilla_concepto
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codcon IN ( '214', '206' )
            AND situac = 'S'
        GROUP BY
            id_cia,
            codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ingreso_noafecto;

    FUNCTION sp_reporte (
        pin_id_cia   NUMBER,
        pin_codban NUMBER,
        pin_numpla   NUMBER
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            t.codper,
            t.nomper,
            t.ingreso,
            t.descuento,
            t.aportacion,
            t.sueldo_neto,
            t.total_neto,
            t.monto_pagar_haber,
            t.codafp,
            t.ingreso_noafecto,
            t.renta_asegurada,
            CASE
                WHEN sueldo_neto - total_neto = 0 THEN
                    'OK'
                ELSE
                    'DIFERENCIA ( ' || to_char(sueldo_neto - total_neto) || ' ) ' 
            END AS consistencia_importe,
            CASE
                WHEN sueldo_neto - monto_pagar_haber = 0 THEN
                    'OK'
                ELSE
                    'DIFERENCIA ( ' || to_char(sueldo_neto - monto_pagar_haber) || ' ) ' 
            END AS consistencia_haber,
            CASE
                WHEN ingreso - ( renta_asegurada + ingreso_noafecto ) = 0 THEN
                    'OK'
                WHEN codafp = '0000'                                      THEN
                    'NO APLICA'
                ELSE
                    'DIFERENCIA ( ' || to_char(ingreso - ( renta_asegurada + ingreso_noafecto ) ) || ' ) ' 
            END AS consistencia_afp_net
        BULK COLLECT
        INTO
        v_table
        FROM
            (
                SELECT
                    pr.codper,
                    pb.nomper,
                    SUM(
                        CASE
                            WHEN pb.ingdes = 'A' THEN
                                pb.valcon
                            ELSE
                                0
                        END
                    )              AS ingreso,
                    SUM(
                        CASE
                            WHEN pb.ingdes = 'B' THEN
                                pb.valcon
                            ELSE
                                0
                        END
                    )              AS descuento,
                    SUM(
                        CASE
                            WHEN pb.ingdes = 'D' THEN
                                pb.valcon
                            ELSE
                                0
                        END
                    )              AS aportacion,
                    SUM(
                        CASE
                            WHEN pb.ingdes = 'A' THEN
                                pb.valcon
                            WHEN pb.ingdes = 'B' THEN
                                pb.valcon * - 1
                            WHEN pb.ingdes = 'D' THEN
                                0
                            ELSE
                                0
                        END
                    )              AS sueldo_neto,
                    pr.totnet      AS total_neto,
                    ph.monpag      AS monto_pagar_haber,
                    pa.codafp,
                    ian.valcon     AS ingreso_noafecto,
                    afp.sueldoneto AS renta_asegurada
                FROM
                         planilla p
                    INNER JOIN planilla_resumen                                                    pr ON pr.id_cia = p.id_cia
                                                      AND pr.numpla = p.numpla
                    LEFT OUTER JOIN planilla_afp                                                        pa ON pa.id_cia = pr.id_cia
                                                       AND pa.numpla = pr.numpla
                                                       AND pa.codper = pr.codper
                    LEFT OUTER JOIN pack_hr_afp_net.sp_buscar(p.id_cia, p.anopla, p.mespla)             afp ON afp.id_cia = pr.id_cia
                                                                                                   AND afp.codper = pr.codper
                    LEFT OUTER JOIN pack_hr_planilla_haber.sp_buscar(p.id_cia, p.anopla, p.mespla, p.tippla, p.empobr,
                                                                     'M', 'PEN', pin_codban, 'S')                                        ph
                                                                     ON ph.id_cia = pr.id_cia
                                                                                                        AND ph.codper = pr.codper
                    LEFT OUTER JOIN pack_hr_planilla_boleta.sp_buscar(p.id_cia, p.numpla, pr.codper)    pb ON 0 = 0
                    LEFT OUTER JOIN pack_hr_reporte_consolidado.sp_ingreso_noafecto(p.id_cia, p.numpla) ian ON ian.id_cia = pr.id_cia
                                                                                                               AND ian.codper = pr.codper
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.numpla = pin_numpla
                    AND pr.situac = 'S'
                GROUP BY
                    p.id_cia,
                    pr.codper,
                    pb.nomper,
                    ph.monpag,
                    pr.totnet,
                    pa.codafp,
                    ian.valcon,
                    afp.sueldoneto
                ORDER BY
                    pb.nomper ASC
            ) t;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

END;

/
