--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_RESUMEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_RESUMEN" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            pr.id_cia,
            pr.numpla,
            pr.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            pr.diatra,
            pr.hortra,
            pr.toting,
            pr.totdsc,
            pr.totapt,
            pr.totape,
            pr.totnet,
            pr.ucreac,
            pr.uactua,
            pr.fcreac,
            pr.factua
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN personal p ON p.id_cia = pr.id_cia
                                     AND p.codper = pr.codper
        WHERE
                pr.id_cia = pin_id_cia
            AND pr.numpla = pin_numpla
            AND pr.situac = 'S'
            AND ( pin_codper IS NULL
                  OR pr.codper = pin_codper )
        ORDER BY
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_reporte_planilla_afp (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_afp
        PIPELINED
    AS
        v_table datatable_reporte_afp;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            pp.tippla,
            tp.nombre,
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            pa.codafp,
            afp.nombre                           AS desafp,
            c.posimp,
            c.nomimp,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre                         AS nomper,
            SUM(nvl(p.valcon, 0))                AS valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla              pp ON pp.id_cia = pr.id_cia
                                      AND pp.numpla = pr.numpla
            INNER JOIN personal              pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            INNER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                          AND pa.numpla = pr.numpla
                                          AND pa.codper = pr.codper
            INNER JOIN afp ON afp.id_cia = pa.id_cia
                              AND afp.codafp = pa.codafp
            INNER JOIN planilla_concepto     p ON p.id_cia = pr.id_cia
                                              AND pr.numpla = p.numpla
                                              AND pr.codper = p.codper
            INNER JOIN concepto              c ON c.id_cia = p.id_cia
                                     AND c.codcon = p.codcon
                                     AND c.indimp = 'S'
            INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = pr.id_cia
                                                   AND tc.codcon = p.codcon
                                                   AND tc.tippla = pp.tippla
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador       ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.tippla = pin_tippla
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
            AND afp.codafp <> '0000'
            -- POSICIONES PARA EL REPORTE DE AFP
            AND c.posimp BETWEEN 1 AND 5
        GROUP BY
            pp.id_cia,
            pp.numpla,
            (
                pp.tippla
                || pp.empobr
                || '-'
                || pp.anopla
                || '/'
                || TRIM(to_char(pp.mespla, '00'))
                || '-'
                || pp.sempla
            ),
            pp.tippla,
            tp.nombre,
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'),
            pp.anopla,
            pa.codafp,
            afp.nombre,
            c.posimp,
            c.nomimp,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre
        ORDER BY
            pa.codafp,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre,
            c.posimp;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_planilla_afp;

    FUNCTION sp_reporte_consolidado_afp (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_afp
        PIPELINED
    AS
        v_table datatable_reporte_afp;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            pa.codafp,
            afp.nombre                           AS desafp,
            c.posimp,
            c.nomimp,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre                         AS nomper,
            SUM(nvl(p.valcon, 0))                AS valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla              pp ON pp.id_cia = pr.id_cia
                                      AND pp.numpla = pr.numpla
            INNER JOIN personal              pe ON pe.id_cia = pr.id_cia
                                      AND pe.codper = pr.codper
            INNER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                          AND pa.numpla = pr.numpla
                                          AND pa.codper = pr.codper
            LEFT OUTER JOIN afp ON afp.id_cia = pa.id_cia
                                   AND afp.codafp = pa.codafp
            INNER JOIN planilla_concepto     p ON p.id_cia = pr.id_cia
                                              AND pr.numpla = p.numpla
                                              AND pr.codper = p.codper
            INNER JOIN concepto              c ON c.id_cia = p.id_cia
                                     AND c.codcon = p.codcon
                                     AND c.indimp = 'S'
            INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = pr.id_cia
                                                   AND tc.codcon = p.codcon
                                                   AND tc.tippla = pp.tippla
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador       ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
            AND afp.codafp <> '0000'
            -- POSICIONES PARA EL REPORTE DE AFP
            AND c.posimp BETWEEN 1 AND 5
        GROUP BY
            pp.id_cia,
            pp.numpla,
            (
                pp.tippla
                || pp.empobr
                || '-'
                || pp.anopla
                || '/'
                || TRIM(to_char(pp.mespla, '00'))
                || '-'
                || pp.sempla
            ),
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'),
            pp.anopla,
            pa.codafp,
            afp.nombre,
            c.posimp,
            c.nomimp,
            pr.codper,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre
        ORDER BY
            pa.codafp,
            pe.apepat
            || ' '
            || pe.apemat
            || ' '
            || pe.nombre,
            c.posimp;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_consolidado_afp;

    FUNCTION sp_reporte_planilla_concepto (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_concepto
        PIPELINED
    AS
        v_table datatable_reporte_concepto;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            pp.tippla,
            tp.nombre,
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            CASE
                WHEN c.ingdes = 'C' THEN
                    'B'
                ELSE
                    c.ingdes
            END                                  AS ingdes,
            CASE
                WHEN c.ingdes = 'C' THEN
                    'DESCUENTO'
                ELSE
                    cc.dingdes
            END                                  AS dingdes,
            c.codcon,
            c.nombre                             AS descon,
            SUM(nvl(p.valcon, 0))                AS valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla                                       pp ON pp.id_cia = pr.id_cia
                                      AND pp.numpla = pr.numpla
            INNER JOIN planilla_concepto                              p ON p.id_cia = pr.id_cia
                                              AND pr.numpla = p.numpla
                                              AND pr.codper = p.codper
            INNER JOIN concepto                                       c ON c.id_cia = pr.id_cia
                                     AND p.codcon = c.codcon
            INNER JOIN tipoplanilla_concepto                          tc ON tc.id_cia = pr.id_cia
                                                   AND tc.codcon = p.codcon
                                                   AND tc.tippla = pp.tippla
            INNER JOIN pack_hr_concepto.sp_buscar_ingdes ( c.id_cia ) cc ON cc.ingdes = c.ingdes
            LEFT OUTER JOIN tipoplanilla                                   tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador                                ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.tippla = pin_tippla
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
            AND instr('A B C D', c.ingdes) > 0
        GROUP BY
            pp.id_cia,
            pp.numpla,
            (
                pp.tippla
                || pp.empobr
                || '-'
                || pp.anopla
                || '/'
                || TRIM(to_char(pp.mespla, '00'))
                || '-'
                || pp.sempla
            ),
            pp.tippla,
            tp.nombre,
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'),
            pp.anopla,
            CASE
                WHEN c.ingdes = 'C' THEN
                        'B'
                ELSE
                    c.ingdes
            END,
            CASE
                WHEN c.ingdes = 'C' THEN
                        'DESCUENTO'
                ELSE
                    cc.dingdes
            END,
            c.codcon,
            c.nombre
        HAVING
            SUM(nvl(p.valcon, 0)) <> 0
        ORDER BY
            CASE
                WHEN c.ingdes = 'C' THEN
                    'B'
                ELSE
                    c.ingdes
            END;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_planilla_concepto;

    FUNCTION sp_reporte_consolidado_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte_concepto
        PIPELINED
    AS
        v_table datatable_reporte_concepto;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            CASE
                WHEN c.ingdes = 'C' THEN
                    'B'
                ELSE
                    c.ingdes
            END                                  AS ingdes,
            CASE
                WHEN c.ingdes = 'C' THEN
                    'DESCUENTO'
                ELSE
                    cc.dingdes
            END                                  AS dingdes,
            c.codcon,
            c.nombre                             AS descon,
            SUM(nvl(p.valcon, 0))                AS valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla                                       pp ON pp.id_cia = pr.id_cia
                                      AND pp.numpla = pr.numpla
            INNER JOIN planilla_concepto                              p ON p.id_cia = pr.id_cia
                                              AND pr.numpla = p.numpla
                                              AND pr.codper = p.codper
            INNER JOIN concepto                                       c ON c.id_cia = pr.id_cia
                                     AND p.codcon = c.codcon
            INNER JOIN tipoplanilla_concepto                          tc ON tc.id_cia = pr.id_cia
                                                   AND tc.codcon = p.codcon
                                                   AND tc.tippla = pp.tippla
            INNER JOIN pack_hr_concepto.sp_buscar_ingdes ( c.id_cia ) cc ON cc.ingdes = c.ingdes
            LEFT OUTER JOIN tipoplanilla                                   tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador                                ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
            AND instr('A B C D', c.ingdes) > 0
        GROUP BY
            pp.id_cia,
            pp.numpla,
            (
                pp.tippla
                || pp.empobr
                || '-'
                || pp.anopla
                || '/'
                || TRIM(to_char(pp.mespla, '00'))
                || '-'
                || pp.sempla
            ),
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'),
            pp.anopla,
            CASE
                WHEN c.ingdes = 'C' THEN
                        'B'
                ELSE
                    c.ingdes
            END,
            CASE
                WHEN c.ingdes = 'C' THEN
                        'DESCUENTO'
                ELSE
                    cc.dingdes
            END,
            c.codcon,
            c.nombre
        HAVING
            SUM(nvl(p.valcon, 0)) <> 0
        ORDER BY
            CASE
                WHEN c.ingdes = 'C' THEN
                    'B'
                ELSE
                    c.ingdes
            END;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_consolidado_concepto;

    FUNCTION sp_reporte_planilla (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            pp.tippla,
            tp.nombre,
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            pr.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre                          AS nomper,
            pr.toting,
            pr.totdsc + pr.totapt                AS totdsc,
            pr.totape,
            pr.totnet
        BULK COLLECT
        INTO v_table
        FROM
                 planilla pp
            INNER JOIN planilla_resumen pr ON pr.id_cia = pp.id_cia
                                              AND pr.numpla = pp.numpla
            INNER JOIN personal         p ON p.id_cia = pr.id_cia
                                     AND p.codper = pr.codper
            LEFT OUTER JOIN tipoplanilla     tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador  ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.tippla = pin_tippla
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
        ORDER BY
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_planilla;

    FUNCTION sp_reporte_consolidado (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            pp.id_cia,
            pp.numpla,
            ( pp.tippla
              || pp.empobr
              || '-'
              || pp.anopla
              || '/'
              || TRIM(to_char(pp.mespla, '00'))
              || '-'
              || pp.sempla )                       AS planilla,
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            pp.anopla,
            pr.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre                          AS nomper,
            SUM(pr.toting),
            SUM(pr.totdsc + pr.totapt)           AS totdsc,
            SUM(pr.totape),
            SUM(pr.totnet)
        BULK COLLECT
        INTO v_table
        FROM
                 planilla pp
            INNER JOIN planilla_resumen pr ON pr.id_cia = pp.id_cia
                                              AND pr.numpla = pp.numpla
            INNER JOIN personal         p ON p.id_cia = pr.id_cia
                                     AND p.codper = pr.codper
            LEFT OUTER JOIN tipoplanilla     tp ON tp.id_cia = pp.id_cia
                                               AND tp.tippla = pp.tippla
            LEFT OUTER JOIN tipo_trabajador  ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND pp.mespla = pin_mespla
            AND pr.situac = 'S'
        GROUP BY
            pp.id_cia,
            pp.numpla,
            (
                pp.tippla
                || pp.empobr
                || '-'
                || pp.anopla
                || '/'
                || TRIM(to_char(pp.mespla, '00'))
                || '-'
                || pp.sempla
            ),
            'C',
            'CONSOLIDADO',
            pp.empobr,
            ttp.nombre,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH'),
            pp.anopla,
            pr.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre
        ORDER BY
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_consolidado;

    PROCEDURE sp_updgen (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_tippla     VARCHAR2(1);
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        SELECT
            tippla
        INTO v_tippla
        FROM
            planilla
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla;
            
        -- REDONDEAMOS TODA LA PLANILLA CONCEPTO
        UPDATE planilla_concepto
        SET
            valcon = round(valcon, 2)
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND situac = 'S';

        IF ( ( v_tippla <> 'X' ) OR ( v_tippla <> 'Y' ) OR ( v_tippla <> 'Z' ) ) THEN
            IF ( v_tippla <> 'L' ) THEN
                FOR i IN (
                    SELECT
                        pr.codper             AS codper,
                        c.ingdes              AS ingdes,
                        SUM(nvl(p.valcon, 0)) AS valcon
                    FROM
                             planilla_resumen pr
                        INNER JOIN planilla_concepto     p ON p.id_cia = pr.id_cia
                                                          AND p.numpla = pr.numpla
                                                          AND p.codper = pr.codper
                        INNER JOIN concepto              c ON c.id_cia = p.id_cia
                                                 AND c.codcon = p.codcon
                        INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = p.id_cia
                                                               AND tc.codcon = p.codcon
                                                               AND tc.tippla = v_tippla
                    WHERE
                            pr.id_cia = pin_id_cia
                        AND pr.numpla = pin_numpla
                        AND instr('A B C D', c.ingdes) > 0
                        AND ( ( pin_codper IS NULL )
                              OR ( pr.codper = pin_codper ) )
                    GROUP BY
                        pr.codper,
                        c.ingdes
                ) LOOP
                    BEGIN
                        IF ( i.ingdes = 'A' ) THEN
                            UPDATE planilla_resumen
                            SET
                                toting = nvl(i.valcon, 0),
                                uactua = pin_coduser,
                                factua = current_date
                            WHERE
                                    id_cia = pin_id_cia
                                AND numpla = pin_numpla
                                AND codper = i.codper;

                        ELSIF ( i.ingdes = 'B' ) THEN
                            UPDATE planilla_resumen
                            SET
                                totdsc = nvl(i.valcon, 0),
                                uactua = pin_coduser,
                                factua = current_date
                            WHERE
                                    id_cia = pin_id_cia
                                AND numpla = pin_numpla
                                AND codper = i.codper;

                        ELSIF ( i.ingdes = 'C' ) THEN
                            UPDATE planilla_resumen
                            SET
                                totapt = nvl(i.valcon, 0),
                                uactua = pin_coduser,
                                factua = current_date
                            WHERE
                                    id_cia = pin_id_cia
                                AND numpla = pin_numpla
                                AND codper = i.codper;

                        ELSIF ( i.ingdes = 'D' ) THEN
                            UPDATE planilla_resumen
                            SET
                                totape = nvl(i.valcon, 0),
                                uactua = pin_coduser,
                                factua = current_date
                            WHERE
                                    id_cia = pin_id_cia
                                AND numpla = pin_numpla
                                AND codper = i.codper;

                        END IF;

                    END;
                END LOOP;

            ELSE
                FOR j IN (
                    SELECT
                        pr.codper             AS codper,
                        c.idliq               AS ingdes,
                        SUM(nvl(p.valcon, 0)) AS valcon
                    FROM
                             planilla_resumen pr
                        INNER JOIN planilla_concepto     p ON p.id_cia = pr.id_cia
                                                          AND p.numpla = pr.numpla
                                                          AND p.codper = pr.codper
                        INNER JOIN concepto              c ON c.id_cia = p.id_cia
                                                 AND c.codcon = p.codcon
                        INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = p.id_cia
                                                               AND tc.codcon = p.codcon
                                                               AND tc.tippla = v_tippla
                    WHERE
                            pr.id_cia = pin_id_cia
                        AND pr.numpla = pin_numpla
                        AND c.idliq IN ( 'B', 'C', 'D', 'E' )
                        AND ( ( pin_codper IS NULL )
                              OR ( pr.codper = pin_codper ) )
                    GROUP BY
                        pr.codper,
                        c.idliq
                ) LOOP
                    IF ( j.ingdes = 'B' ) THEN
                        UPDATE planilla_resumen
                        SET
                            toting = nvl(j.valcon, 0),
                            uactua = pin_coduser,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = j.codper;

                    ELSIF ( j.ingdes = 'C' ) THEN
                        UPDATE planilla_resumen
                        SET
                            totdsc = nvl(j.valcon, 0),
                            uactua = pin_coduser,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = j.codper;

                    ELSIF ( j.ingdes = 'D' ) THEN
                        UPDATE planilla_resumen
                        SET
                            totapt = nvl(j.valcon, 0),
                            uactua = pin_coduser,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = j.codper;

                    ELSIF ( j.ingdes = 'E' ) THEN
                        UPDATE planilla_resumen
                        SET
                            totape = nvl(j.valcon, 0),
                            uactua = pin_coduser,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = j.codper;

                    END IF;
                END LOOP;
            END IF;
        ELSE
            FOR h IN (
                SELECT
                    pr.codper             AS codper,
                    c.ingdes              AS ingdes,
                    SUM(nvl(p.valcon, 0)) AS valcon
                FROM
                         planilla_resumen pr
                    INNER JOIN planilla_concepto     p ON p.id_cia = pr.id_cia
                                                      AND p.numpla = pr.numpla
                                                      AND p.codper = pr.codper
                    INNER JOIN concepto              c ON c.id_cia = p.id_cia
                                             AND c.codcon = p.codcon
                    INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = p.id_cia
                                                           AND tc.codcon = p.codcon
                                                           AND tc.tippla = v_tippla
                WHERE
                        pr.id_cia = pin_id_cia
                    AND pr.numpla = pin_numpla
                    AND c.ingdes = 'E'
                    AND c.idliq = 'H' /*AND ((:ICODPER IS NULL)OR(PR.CODPER =:ICODPER))*/
                GROUP BY
                    pr.codper,
                    c.ingdes
            ) LOOP
                IF ( h.ingdes = 'E' ) THEN
                    UPDATE planilla_resumen
                    SET
                        toting = nvl(h.valcon, 0),
                        uactua = pin_coduser,
                        factua = current_date
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = h.codper;

                END IF;
            END LOOP;
        END IF;

        UPDATE planilla_resumen
        SET
            totnet = toting - ( totdsc + totapt ),
            uactua = pin_coduser,
            factua = current_date
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND situac = 'S'
            AND ( pin_codper IS NULL
                  OR codper = pin_codper );
                  
        -- REDONDEAMOS TODA LA PLANILLA RESUMEN
        UPDATE planilla_resumen
        SET
            toting = round(toting, 2),
            totdsc = round(totdsc, 2),
            totapt = round(totapt, 2),
            totape = round(totape, 2),
            totnet = round(totnet, 2)
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND situac = 'S';

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La Planilla se Calculo correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -20049 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE 'Mes cerrado en el Módulo de Planilla'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
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

            END IF;
    END sp_updgen;

END;

/
