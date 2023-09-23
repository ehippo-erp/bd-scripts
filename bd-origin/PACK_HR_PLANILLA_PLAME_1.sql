--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_PLAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_PLAME" AS

    FUNCTION sp_concepto_tiptra (
        pin_id_cia NUMBER,
        pin_codfac VARCHAR2,
        pin_tiptra VARCHAR2
    ) RETURN VARCHAR2 AS
        v_concepto VARCHAR2(20 CHAR);
    BEGIN
        BEGIN
            SELECT
                TRIM(vstrg)
            INTO v_concepto
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = pin_codfac
                AND codcla = pin_tiptra
                AND tipcla = 1 -- TIPO DE TRABAJADOR
                AND tipvar = 'S'; -- STRING

        EXCEPTION
            WHEN no_data_found THEN
                v_concepto := NULL;
        END;

        RETURN v_concepto;
    END sp_concepto_tiptra;

    FUNCTION sp_ingtrides_txt (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_ingtrides
        PIPELINED
    AS
        v_table datatable_ingtrides;
    BEGIN
        SELECT
            p.id_cia,
            p.titulo,
            p.coddid,
            p.coddidsunat,
            p.desdid,
            p.codper,
            p.nomper,
            NULL,
            p.codconsunat,
            p.descon,
            SUM(p.mondev),
            SUM(p.monpag)
        BULK COLLECT
        INTO v_table
        FROM
            pack_hr_planilla_plame.sp_ingtrides(pin_id_cia, pin_empobr, pin_periodo, pin_mes) p
        GROUP BY
            p.id_cia,
            p.titulo,
            p.coddid,
            p.coddidsunat,
            p.desdid,
            p.codper,
            p.nomper,
            NULL,
            p.codconsunat,
            p.descon
        ORDER BY
            p.nomper,
            p.codconsunat;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ingtrides_txt;

    FUNCTION sp_ingtrides (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_ingtrides
        PIPELINED
    AS
        v_table datatable_ingtrides;
    BEGIN
        SELECT
            p.id_cia,
            replace('0601'
                    || to_char(pin_periodo, '0000')
                    || to_char(pin_mes, '00')
                    || to_char(c.ruc),
                    ' ',
                    '') AS titulo,
            p.coddid,
            p.coddidsunat,
            p.desdid,
            p.codper,
            p.nomper,
            p.codcon,
            p.codconsunat,
            pdt.descri  AS descon,
            SUM(p.mondev),
            SUM(p.monpag)
        BULK COLLECT
        INTO v_table
        FROM
            pack_hr_planilla_plame.sp_ingtrides_detalle(pin_id_cia, pin_empobr, pin_periodo, pin_mes, NULL,
                                                        0) p
            LEFT OUTER JOIN companias                                      c ON c.cia = p.id_cia
            LEFT OUTER JOIN conceptos_pdt                                  pdt ON pdt.id_cia = p.id_cia
                                                 AND pdt.codpdt = p.codconsunat
        GROUP BY
            p.id_cia,
            replace('0601'
                    || to_char(pin_periodo, '0000')
                    || to_char(pin_mes, '00')
                    || to_char(c.ruc),
                    ' ',
                    ''),
            p.coddid,
            p.coddidsunat,
            p.desdid,
            p.codper,
            p.nomper,
            p.codcon,
            p.codconsunat,
            pdt.descri
        ORDER BY
            p.nomper,
            p.codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ingtrides;

    FUNCTION sp_ingtrides_detalle (
        pin_id_cia    NUMBER,
        pin_empobr    VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_numpla    NUMBER,
        pin_provicion NUMBER
    ) RETURN datatable_ingtrides_detalle
        PIPELINED
    AS
        v_table datatable_ingtrides_detalle;
    BEGIN
        SELECT
            pl.id_cia,
            ccp.abrevi     AS coddid,
            ccp.codigo     AS coddidsunat,
            pd.nrodoc      AS desdid,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre )  AS nomper,
            CASE
                WHEN co.ingdes = 'C' THEN
                    'B'
                ELSE
                    co.ingdes
            END            AS ingdes,
            co.codcon,
            co.codpdt      AS codconsunat,
            co.nombre      AS descon,
            SUM(pc.valcon) AS mondev,
            SUM(pc.valcon) AS monpag
        BULK COLLECT
        INTO v_table
        FROM
            planilla              pl
            LEFT OUTER JOIN tipoplanilla          tpl ON tpl.id_cia = pl.id_cia
                                                AND tpl.tippla = pl.tippla
            LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pl.id_cia
                                                   AND pr.numpla = pl.numpla
            LEFT OUTER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                               AND pa.numpla = pr.numpla
                                               AND pa.codper = pr.codper
            LEFT OUTER JOIN personal              p ON p.id_cia = pr.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN personal_documento    pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN tipoplanilla_concepto tc ON tc.id_cia = pl.id_cia
                                                        AND tc.tippla = pl.tippla
            LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = pr.id_cia
                                                    AND pc.numpla = pr.numpla
                                                    AND pc.codper = pr.codper
                                                    AND pc.codcon = tc.codcon
            LEFT OUTER JOIN concepto              co ON co.id_cia = pc.id_cia
                                           AND pc.codcon = co.codcon
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_empobr IS NULL
                  OR pl.empobr = pin_empobr )
            AND pl.anopla = pin_periodo
            AND pl.mespla = pin_mes
            AND ( nvl(pin_numpla, - 1) = - 1
                  OR pl.numpla = pin_numpla )
            AND co.ingdes IN ( 'A', 'B', 'C', 'D' )/*A = ingreso B=descuento C y D = aportacion*/
            AND nvl(co.codpdt, '0') <> '0'
            AND ( pc.valcon <> 0
                  OR co.codcon = pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '002', pl.empobr)
                  OR ( pa.codafp <> '0000'
                       AND co.codcon IN ( pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '008', pl.empobr), pack_hr_planilla_plame.sp_concepto_tiptra
                       (pl.id_cia, '009', pl.empobr), pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '010', pl.empobr) ) ) )
--            AND ( pc.valcon <> 0
--                  OR co.codcon IN ( '306', '806' )
--                  OR ( pa.codafp <> '0000'
--                       AND co.codcon IN ( '303', '803', 'C06', '304', '804',
--                                          'C08', '305', '805', 'C09' ) ) )
            AND pl.tippla IN ( 'N', 'V', 'P' )
            AND pr.situac = 'S'
        GROUP BY
            pl.id_cia,
            ccp.codigo,
            ccp.abrevi,
            pd.nrodoc,
            pr.codper,
            (
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            ),
            CASE
                WHEN co.ingdes = 'C' THEN
                        'B'
                ELSE
                    co.ingdes
            END,
            co.codcon,
            co.nombre,
            co.codpdt
        ORDER BY
            pr.codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            pl.id_cia,
            ccp.abrevi     AS coddid,
            ccp.codigo     AS coddidsunat,
            pd.nrodoc      AS desdid,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre )  AS nomper,
            CASE
                WHEN co.ingdes = 'C' THEN
                    'B'
                ELSE
                    co.ingdes
            END            AS ingdes,
            co.codcon,
            co.codpdt      AS codconsunat,
            co.nombre      AS descon,
            SUM(pc.valcon) AS mondev,
            SUM(pc.valcon) AS monpag
        BULK COLLECT
        INTO v_table
        FROM
            planilla              pl
            LEFT OUTER JOIN tipoplanilla          tpl ON tpl.id_cia = pl.id_cia
                                                AND tpl.tippla = pl.tippla
            LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pl.id_cia
                                                   AND pr.numpla = pl.numpla
            LEFT OUTER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                               AND pa.numpla = pr.numpla
                                               AND pa.codper = pr.codper
            LEFT OUTER JOIN personal              p ON p.id_cia = pr.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN personal_documento    pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN tipoplanilla_concepto tc ON tc.id_cia = pl.id_cia
                                                        AND tc.tippla = pl.tippla
            LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = pr.id_cia
                                                    AND pc.numpla = pr.numpla
                                                    AND pc.codper = pr.codper
                                                    AND pc.codcon = tc.codcon
            LEFT OUTER JOIN concepto              co ON co.id_cia = pc.id_cia
                                           AND pc.codcon = co.codcon
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_empobr IS NULL
                  OR pl.empobr = pin_empobr )
            AND pl.anopla = pin_periodo
            AND pl.mespla = ( pin_mes - pin_provicion )
            AND ( nvl(pin_numpla, - 1) = - 1
                  OR pl.numpla = pin_numpla )
            AND co.ingdes IN ( 'A', 'B', 'C', 'D' )/*A = ingreso B=descuento C y D = aportacion*/
            AND nvl(co.codpdt, '0') <> '0'
            AND ( pc.valcon <> 0
                  OR co.codcon = pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '002', pl.empobr) )
--            AND ( pc.valcon <> 0
--                  OR co.codcon IN ( '306', '806' ) )
            AND pl.tippla IN ( 'G' )
            AND pr.situac = 'S'
        GROUP BY
            pl.id_cia,
            ccp.codigo,
            ccp.abrevi,
            pd.nrodoc,
            pr.codper,
            (
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            ),
            CASE
                WHEN co.ingdes = 'C' THEN
                        'B'
                ELSE
                    co.ingdes
            END,
            co.codcon,
            co.nombre,
            co.codpdt
        ORDER BY
            pr.codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            pl.id_cia,
            ccp.abrevi     AS coddid,
            ccp.codigo     AS coddidsunat,
            pd.nrodoc      AS desdid,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre )  AS nomper,
            CASE
                WHEN co.idliq = 'B' THEN
                    'A'
                WHEN co.idliq = 'C' THEN
                    'B'
                WHEN co.idliq = 'D' THEN
                    'B'
                WHEN co.idliq = 'E' THEN
                    'D'
                ELSE
                    co.idliq
            END            AS ingdes,
            co.codcon,
            co.codpdt      AS codconsunat,
            co.nombre      AS descon,
            SUM(pc.valcon) AS mondev,
            SUM(pc.valcon) AS monpag
        BULK COLLECT
        INTO v_table
        FROM
            planilla              pl
            LEFT OUTER JOIN tipoplanilla          tpl ON tpl.id_cia = pl.id_cia
                                                AND tpl.tippla = pl.tippla
            LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pl.id_cia
                                                   AND pr.numpla = pl.numpla
            LEFT OUTER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                               AND pa.numpla = pr.numpla
                                               AND pa.codper = pr.codper
            LEFT OUTER JOIN personal              p ON p.id_cia = pr.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN personal_documento    pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN tipoplanilla_concepto tc ON tc.id_cia = pl.id_cia
                                                        AND tc.tippla = pl.tippla
            LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = pr.id_cia
                                                    AND pc.numpla = pr.numpla
                                                    AND pc.codper = pr.codper
                                                    AND pc.codcon = tc.codcon
            LEFT OUTER JOIN concepto              co ON co.id_cia = pc.id_cia
                                           AND pc.codcon = co.codcon
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_empobr IS NULL
                  OR pl.empobr = pin_empobr )
            AND pl.anopla = pin_periodo
            AND pl.mespla = pin_mes
            AND ( nvl(pin_numpla, - 1) = - 1
                  OR pl.numpla = pin_numpla )
            AND co.idliq IN ( 'B', 'C', 'D', 'E' )/*A = ingreso B=descuento C y D = aportacion*/
            AND nvl(co.codpdt, '0') <> '0'
            AND ( pc.valcon <> 0
                  OR co.codcon = pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '002', pl.empobr)
                  OR ( pa.codafp <> '0000'
                       AND co.codcon IN ( pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '008', pl.empobr), pack_hr_planilla_plame.sp_concepto_tiptra
                       (pl.id_cia, '009', pl.empobr), pack_hr_planilla_plame.sp_concepto_tiptra(pl.id_cia, '010', pl.empobr) ) ) )
--            AND ( pc.valcon <> 0
--                  OR co.codcon IN ( '306', '806' )
--                  OR ( pa.codafp <> '0000'
--                       AND co.codcon IN ( '303', '803', 'C06', '304', '804',
--                                          'C08', '305', '805', 'C09' ) ) )
            AND pl.tippla IN ( 'L' )
            AND pr.situac = 'S'
        GROUP BY
            pl.id_cia,
            ccp.codigo,
            ccp.abrevi,
            pd.nrodoc,
            pr.codper,
            (
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            ),
            CASE
                    WHEN co.idliq = 'B' THEN
                        'A'
                    WHEN co.idliq = 'C' THEN
                        'B'
                    WHEN co.idliq = 'D' THEN
                        'B'
                    WHEN co.idliq = 'E' THEN
                        'D'
                    ELSE
                        co.idliq
            END,
            co.codcon,
            co.nombre,
            co.codpdt
        ORDER BY
            pr.codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            pl.id_cia,
            ccp.abrevi     AS coddid,
            ccp.codigo     AS coddidsunat,
            pd.nrodoc      AS desdid,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre )  AS nomper,
            CASE
                WHEN co.idliq = 'B' THEN
                    'A'
                ELSE
                    'B'
            END            AS ingdes,
            co.codcon,
            co.codpdt      AS codconsunat,
            co.nombre      AS descon,
            SUM(pc.valcon) AS mondev,
            SUM(pc.valcon) AS monpag
        BULK COLLECT
        INTO v_table
        FROM
            planilla              pl
            LEFT OUTER JOIN tipoplanilla          tpl ON tpl.id_cia = pl.id_cia
                                                AND tpl.tippla = pl.tippla
            LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pl.id_cia
                                                   AND pr.numpla = pl.numpla
            LEFT OUTER JOIN planilla_afp          pa ON pa.id_cia = pr.id_cia
                                               AND pa.numpla = pr.numpla
                                               AND pa.codper = pr.codper
            LEFT OUTER JOIN personal              p ON p.id_cia = pr.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN personal_documento    pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN tipoplanilla_concepto tc ON tc.id_cia = pl.id_cia
                                                        AND tc.tippla = pl.tippla
            LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = pr.id_cia
                                                    AND pc.numpla = pr.numpla
                                                    AND pc.codper = pr.codper
                                                    AND pc.codcon = tc.codcon
            LEFT OUTER JOIN concepto              co ON co.id_cia = pc.id_cia
                                           AND pc.codcon = co.codcon
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_empobr IS NULL
                  OR pl.empobr = pin_empobr )
            AND pl.anopla = pin_periodo
            AND pl.mespla = ( pin_mes - pin_provicion )
            AND ( nvl(pin_numpla, - 1) = - 1
                  OR pl.numpla = pin_numpla )
            AND co.idliq IN ( 'B', 'C' )/*A = ingreso B=descuento C y D = aportacion*/
            AND nvl(co.codpdt, '0') <> '0'
            AND pc.valcon <> 0
            AND pl.tippla IN ( 'S' )
            AND pr.situac = 'S'
        GROUP BY
            pl.id_cia,
            ccp.codigo,
            ccp.abrevi,
            pd.nrodoc,
            pr.codper,
            (
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            ),
            CASE
                WHEN co.idliq = 'B' THEN
                        'A'
                ELSE
                    'B'
            END,
            co.codcon,
            co.nombre,
            co.codpdt
        ORDER BY
            pr.codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ingtrides_detalle;

    FUNCTION sp_detalle_dias (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_dias
        PIPELINED
    AS

        v_rec          datarecord_detalle_dias;
        rec_planilla   planilla%rowtype;
        v_diaslab      NUMBER := 0;
        v_diasnolab    NUMBER := 0;
        v_hrsext       NUMBER := 0;
        v_diassub      NUMBER := 0;
        v_diastar      NUMBER := 0;
        v_horempobr    NUMBER := 0;
        v_days         NUMBER := 0;
        v_day          DATE;
        v_hrsordmanual NUMBER := 0;
        v_mintar       NUMBER := 0;
        v_hrstar       NUMBER := 0;
    BEGIN

        -- HORAS ORDINARIAS MANUAL
        BEGIN
            SELECT
                nvl(pc.valcon, 0)
            INTO v_hrsordmanual
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac = '400'
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_hrsordmanual := 0;
        END;    


        -- HORAS EXTRAS (MINUTOS)
        BEGIN
            SELECT
                nvl(pc.valcon, 0)
            INTO v_hrsext
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac = '403'
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_hrsext := 0;
        END;

        -- INFORMACION DE LA PLANILLA
        BEGIN
            SELECT
                *
            INTO rec_planilla
            FROM
                planilla
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

        END;

        -- TOTAL DE DIAS NO LABORADOS
        BEGIN
            SELECT
                nvl(pc.valcon, 0)
            INTO v_diasnolab
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac = '023'
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_diasnolab := 0;
        END;

        -- TOTAL DE DIAS SUBSIDIADOS
        BEGIN
            SELECT
                nvl(SUM(nvl(pc.valcon, 0)),
                    0)
            INTO v_diassub
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac IN ( '080', '081' )
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_diassub := 0;
        END;

        -- HORAS ORDINARIAS TURNO X TIPO TRABAJADOR
        BEGIN
            SELECT
                nvl(vreal, 0)
            INTO v_horempobr
            FROM
                factor_clase_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '413'
                AND codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_horempobr := 0;
        END;

        -- TARDANZAS ( MINUTOS )
        BEGIN
            SELECT
                nvl(pc.valcon, 0)
            INTO v_mintar
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac IN ( '022' )
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                v_mintar := 0;
        END;        

        -- DIAS EFECTIVAMENTE LABORADOS
        BEGIN
            SELECT
                nvl(pc.valcon, 0)
            INTO v_rec.diaslab
            FROM
                factor_clase_planilla fcp
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = fcp.id_cia
                                                        AND pc.numpla = pin_numpla
                                                        AND pc.codper = pin_codper
                                                        AND pc.codcon = fcp.vstrg
                                                        AND pc.valcon <> 0 -- TIENE QUE ESTAR DEFINIDO
            WHERE
                    fcp.id_cia = pin_id_cia
                AND fcp.codfac = '403'
                AND fcp.codcla = rec_planilla.empobr;

        EXCEPTION
            WHEN no_data_found THEN
                -- DE NO ESTAR DEFINIDO
                -- TOTAL DE DIAS ( PLANILLA )
                v_days := rec_planilla.fecfin - rec_planilla.fecini;
                v_diaslab := 30;
                v_rec.diaslab := v_diaslab - v_diasnolab - v_diassub;
        END;

        -- FINALEMNTE
        v_rec.diasnolab := v_diasnolab;
        IF v_hrsordmanual > 0 THEN -- SI TIENE VALOR REGISTRO MANUALMENTE EL CONCEPTO, CONSIDERA DECIRMALES
            v_rec.hrosord := TRUNC(v_hrsordmanual); -- HOR
--            v_rec.minsord := TO_NUMBER ( regexp_substr(to_char(v_hrsordmanual),
--                                                       '\d+$') );
            v_rec.minsord := MOD(v_hrsordmanual, 1) * 60; -- MIN
        ELSE
            IF v_mintar > 0 THEN -- REGISTRO DE TRADANZA, ENCONTRADO
                v_hrstar := TRUNC(v_mintar / 60); -- HOR
                v_mintar := v_mintar - v_hrstar * 60;  -- MIN
            END IF;

            v_rec.hrosord := v_rec.diaslab * v_horempobr - v_hrstar;
            v_rec.minsord := NVL(MOD(v_rec.hrosord, 1)*60,0); -- SI HAY PARTE DECIMAL EN EL CALCULO
            v_rec.hrosord := TRUNC(v_rec.hrosord); -- HAY PARTE ENTERA
            v_rec.minsord := v_rec.minsord + v_mintar; -- ADICIONAMOS MINUTOS EXTRA
        END IF;

        v_rec.hrosext := v_hrsext;
        v_rec.minsext := NVL(MOD(v_hrsext, 1)*60,0);
        PIPE ROW ( v_rec );
    END sp_detalle_dias;

    FUNCTION sp_diajorlab (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_diajorlab
        PIPELINED
    AS
        v_table datatable_diajorlab;
    BEGIN
        SELECT
            pl.id_cia,
            replace('0601'
                    || to_char(pin_periodo, '0000')
                    || to_char(pin_mes, '00')
                    || to_char(c.ruc),
                    ' ',
                    '')   AS titulo,
            ccp.abrevi    AS coddid,
            ccp.codigo    AS coddidsunat,
            pd.nrodoc     AS desdid,
            pr.codper,
            p.apepat,
            p.apemat,
            p.nombre,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre ) AS nomper,
            SUM(dd.diaslab),
            SUM(dd.hrosord),
            SUM(dd.minsord),
            SUM(dd.hrosext),
            SUM(dd.minsext)
        BULK COLLECT
        INTO v_table
        FROM
            planilla                                                                pl
            LEFT OUTER JOIN companias                                                               c ON c.cia = pl.id_cia
            LEFT OUTER JOIN planilla_resumen                                                        pr ON pr.id_cia = pl.id_cia
                                                   AND pr.numpla = pl.numpla
            LEFT OUTER JOIN personal                                                                p ON p.id_cia = pl.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN personal_documento                                                      pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal                                                   ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN pack_hr_planilla_plame.sp_detalle_dias(pr.id_cia, pr.numpla, pr.codper) dd ON 0 = 0
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.empobr = pin_empobr
            AND pl.anopla = pin_periodo
            AND pl.mespla = pin_mes
            AND pr.situac = 'S'
        GROUP BY
            pl.id_cia,
            replace('0601'
                    || to_char(pin_periodo, '0000')
                    || to_char(pin_mes, '00')
                    || to_char(c.ruc),
                    ' ',
                    ''),
            ccp.abrevi,
            ccp.codigo,
            pd.nrodoc,
            pr.codper,
            p.apepat,
            p.apemat,
            p.nombre,
            (
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_diajorlab;

    FUNCTION sp_diasubnolab (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_diasubnolab
        PIPELINED
    AS
        v_table datatable_diasubnolab;
    BEGIN
        SELECT
            pl.id_cia,
            replace('0601'
                    || to_char(pin_periodo, '0000')
                    || to_char(pin_mes, '00')
                    || to_char(c.ruc),
                    ' ',
                    '')   AS titulo,
            ccp.abrevi    AS coddid,
            ccp.codigo    AS coddidsunat,
            pd.nrodoc     AS desdid,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre ) AS nomper,
            pr.finicio,
            pr.ffinal,
            pr.dias,
            pr.codigo,
            ccc.descri    AS descodigo
        BULK COLLECT
        INTO v_table
        FROM
            planilla              pl
            LEFT OUTER JOIN companias             c ON c.cia = pl.id_cia
            LEFT OUTER JOIN planilla_resumen      ps ON ps.id_cia = pl.id_cia
                                                   AND ps.numpla = pl.numpla
            INNER JOIN planilla_rango        pr ON pr.id_cia = ps.id_cia
                                            AND pr.numpla = ps.numpla
                                            AND pr.codper = ps.codper
            LEFT OUTER JOIN personal              p ON p.id_cia = pl.id_cia
                                          AND p.codper = pr.codper
            LEFT OUTER JOIN motivo_planilla       ccc ON ccc.id_cia = pr.id_cia
                                                   AND ccc.codrel = pr.codigo
            LEFT OUTER JOIN personal_documento    pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.empobr = pin_empobr
            AND pl.anopla = pin_periodo
            AND pl.mespla = pin_mes
            AND ps.situac = 'S';

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_diasubnolab;

END;

/
