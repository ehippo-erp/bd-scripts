--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_REPORTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_REPORTE" AS

    FUNCTION sp_leyenda_constancia (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_leyenda
        PIPELINED
    AS
        v_rec           datarecord_leyenda;
        pin_codperfirma VARCHAR2(20 CHAR);
    BEGIN
        BEGIN
            SELECT
                codper
            INTO pin_codperfirma
            FROM
                personal_clase
            WHERE
                    id_cia = pin_id_cia
                AND clase = 1101
                AND codigo = 'S' -- BUSCANDO AL TRABAJADOR CON AL CLASE 1101 ACTIVA
            ORDER BY
                fcreac DESC
            FETCH NEXT 1 ROWS ONLY;

            BEGIN
                SELECT
                    id_cia,
                    pin_codper,
                    'FNOMPER',
                    apepat
                    || ' '
                    || apemat
                    || ' '
                    || nombre
                INTO v_rec
                FROM
                    personal
                WHERE
                        id_cia = pin_id_cia
                    AND codper = pin_codperfirma;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            BEGIN
                SELECT
                    id_cia,
                    pin_codper,
                    'FNRODNI',
                    nrodoc
                INTO v_rec
                FROM
                    personal_documento
                WHERE
                        id_cia = pin_id_cia
                    AND codper = pin_codperfirma
                    AND codtip = 'DO'
                    AND codite = 201;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            BEGIN
                SELECT
                    dp.id_cia,
                    pin_codper,
                    'FTIPDOC',
                    ccp.descri
                INTO v_rec
                FROM
                    personal_documento    dp
                    LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = dp.id_cia
                                                                 AND ccp.clase = dp.clase
                                                                 AND ccp.codigo = dp.codigo
                WHERE
                        dp.id_cia = pin_id_cia
                    AND dp.codper = pin_codperfirma
                    AND dp.codtip = 'DO'
                    AND dp.codite = 201;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            BEGIN
                SELECT
                    id_cia,
                    pin_codper,
                    'FTRATAMIENTO',
                    nrodoc
                INTO v_rec
                FROM
                    personal_documento
                WHERE
                        id_cia = pin_id_cia
                    AND codper = pin_codperfirma
                    AND codtip = 'DO'
                    AND codite = 209;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            BEGIN
                SELECT
                    p.id_cia,
                    pin_codper,
                    'FCARGO',
                    c.nombre
                INTO v_rec
                FROM
                    personal p
                    LEFT OUTER JOIN cargo    c ON c.id_cia = p.id_cia
                                               AND c.codcar = p.codcar
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.codper = pin_codperfirma;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                id_cia,
                codper,
                'NOMPER',
                apepat
                || ' '
                || apemat
                || ' '
                || nombre
            INTO v_rec
            FROM
                personal
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                id_cia,
                codper,
                'NRODNI',
                nrodoc
            INTO v_rec
            FROM
                personal_documento
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
                AND codtip = 'DO'
                AND codite = 201;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                dp.id_cia,
                dp.codper,
                'TIPDOC',
                ccp.descri
            INTO v_rec
            FROM
                personal_documento    dp
                LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = dp.id_cia
                                                             AND ccp.clase = dp.clase
                                                             AND ccp.codigo = dp.codigo
            WHERE
                    dp.id_cia = pin_id_cia
                AND dp.codper = pin_codper
                AND dp.codtip = 'DO'
                AND dp.codite = 201;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                id_cia,
                codper,
                'TRATAMIENTO',
                nrodoc
            INTO v_rec
            FROM
                personal_documento
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
                AND codtip = 'DO'
                AND codite = 209;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                p.id_cia,
                p.codper,
                'CARGO',
                c.nombre
            INTO v_rec
            FROM
                personal p
                LEFT OUTER JOIN cargo    c ON c.id_cia = p.id_cia
                                           AND c.codcar = p.codcar
            WHERE
                    p.id_cia = pin_id_cia
                AND p.codper = pin_codper;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                pa.id_cia,
                pa.codper,
                'FECHAINGRESO',
                to_char(pa.finicio, 'DD/MM/YYYY')
            INTO v_rec
            FROM
                     planilla_auxiliar pa
                INNER JOIN planilla p ON p.id_cia = pa.id_cia
                                         AND p.numpla = pa.numpla
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.codper = pin_codper
                AND p.tippla = 'L'
            ORDER BY
                pa.numpla DESC
            FETCH NEXT 1 ROWS ONLY;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                pa.id_cia,
                pa.codper,
                'FECHACESE',
                to_char(pa.ffinal, 'DD/MM/YYYY')
            INTO v_rec
            FROM
                     planilla_auxiliar pa
                INNER JOIN planilla p ON p.id_cia = pa.id_cia
                                         AND p.numpla = pa.numpla
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.codper = pin_codper
                AND p.tippla = 'L'
            ORDER BY
                pa.numpla DESC
            FETCH NEXT 1 ROWS ONLY;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        BEGIN
            SELECT
                pin_id_cia,
                pin_codper,
                'FECHAEMISION',
                to_char(current_timestamp, 'DD/MM/YYYY')
            INTO v_rec
            FROM
                dual;

            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

    END sp_leyenda_constancia;

    FUNCTION sp_personal_concepto (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mdesde NUMBER,
        pin_mhasta NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_personal_concepto
        PIPELINED
    AS
        v_table datatable_personal_concepto;
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
            ttp.nombre                           AS destiptra,
            pp.anopla,
            pp.mespla,
            to_char(TO_DATE('01/'
                            || TRIM(to_char(pp.mespla, '00'))
                            || '/00',
        'DD/MM/YY'),
                    'MONTH',
                    'NLS_DATE_LANGUAGE=SPANISH') AS desmes,
            ppp.codper,
            ppp.apepat
            || ' '
            || ppp.apemat
            || ' '
            || ppp.nombre,
            c.codcon,
            c.nombre                             AS descon,
            nvl(pc.valcon, 0)                    AS valcon
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla              pp ON pp.id_cia = pr.id_cia
                                      AND pp.numpla = pr.numpla
            INNER JOIN planilla_concepto     pc ON pc.id_cia = pr.id_cia
                                               AND pc.numpla = pr.numpla
                                               AND pc.codper = pr.codper
            INNER JOIN concepto              c ON c.id_cia = pc.id_cia
                                     AND c.codcon = pc.codcon
            INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = pc.id_cia
                                                   AND tc.codcon = pc.codcon
                                                   AND tc.tippla = pp.tippla
            LEFT OUTER JOIN personal              ppp ON ppp.id_cia = pr.id_cia
                                            AND ppp.codper = pr.codper
            LEFT OUTER JOIN tipo_trabajador       ttp ON ttp.id_cia = pp.id_cia
                                                   AND ttp.tiptra = pp.empobr
        WHERE
                pp.id_cia = pin_id_cia
            AND pp.empobr = pin_empobr
            AND pp.anopla = pin_anopla
            AND ( pp.mespla BETWEEN pin_mdesde AND pin_mhasta )
            AND ( pin_codper IS NULL
                  OR pr.codper = pin_codper )
            AND pc.codcon = pin_codcon
            AND pc.valcon > 0
            AND pr.situac = 'S'
        ORDER BY
            ppp.apepat
            || ' '
            || ppp.apemat
            || ' '
            || ppp.nombre ASC,
            nvl(pc.valcon, 0) DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_personal_concepto;

    FUNCTION sp_descuento_proyectado (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_codper  VARCHAR2,
        pin_situacs VARCHAR2
    ) RETURN datatable_descuento_proyectado
        PIPELINED
    AS
        v_table datatable_descuento_proyectado;
        v_rec   datarecord_descuento_proyectado;
    BEGIN
        FOR i IN (
            SELECT
                p.id_cia,
                p.tiptra,
                ttp.nombre    AS destiptra,
                p.codper,
                ( p.apepat
                  || p.apemat
                  || ' '
                  || p.nombre ) AS nomper,
                p.situac,
                sp.nombre     AS dessituac,
                r.id_pre,
                r.fecpre,
                r.monpre,
                r.salpre,
                r.cancuo,
                r.valcuo,
                r.observ
            FROM
                personal           p
                LEFT OUTER JOIN situacion_personal sp ON sp.id_cia = p.id_cia
                                                         AND sp.codsit = p.situac
                LEFT OUTER JOIN tipo_trabajador    ttp ON ttp.id_cia = p.id_cia
                                                       AND ttp.tiptra = p.tiptra
                INNER JOIN prestamo           r ON p.codper = r.codper
            WHERE
                    p.id_cia = pin_id_cia
                AND ( pin_empobr IS NULL
                      OR p.tiptra = pin_empobr )
                AND ( pin_codper IS NULL
                      OR p.codper = pin_codper )
                AND p.situac IN (
                    SELECT
                        regexp_substr(pin_situacs, '[^,]+', 1, level)
                    FROM
                        dual
                    CONNECT BY
                        regexp_substr(pin_situacs, '[^,]+', 1, level) IS NOT NULL
                )
                AND r.salpre > 0
        ) LOOP
            v_rec.id_cia := i.id_cia;--OK
            v_rec.tiptra := i.tiptra;--OK
            v_rec.destiptra := i.destiptra;--OK
            v_rec.codper := i.codper;--OK
            v_rec.nomper := i.nomper;--OK
            v_rec.situac := i.situac;--OK
            v_rec.dessituac := i.dessituac;--OK
            v_rec.id_pre := i.id_pre;--OK
            v_rec.fecpre := i.fecpre;--OK
            v_rec.monpre := i.monpre;--OK
            v_rec.dscpre := i.monpre - nvl(i.salpre, 0);
            v_rec.salpre := nvl(i.salpre, 0);--OK
            v_rec.valcuo := i.valcuo;--OK (CUOTA PACTADA )
            v_rec.observ := i.observ;--OK
            v_rec.cancuo := i.cancuo;-- OK ( NUMERO DE CUOTAS PACTADAS )
            -- VALORES POR CALCULAR
            BEGIN
                SELECT
                    COUNT(dsc.valcuo),
                    SUM(dsc.valcuo)
                INTO
                    v_rec.nrocuo,
                    v_rec.impdes
                FROM
                    dsctoprestamo dsc
                WHERE
                        dsc.id_cia = i.id_cia
                    AND dsc.id_pre = i.id_pre;

            EXCEPTION
                WHEN no_data_found THEN
                    v_rec.nrocuo := 0;
                    v_rec.impdes := 0;
            END;

            v_rec.nrocuo := nvl(v_rec.nrocuo, 0); -- CUOTA ACTUAL
            v_rec.nrocuofal := v_rec.cancuo - v_rec.nrocuo;
            IF v_rec.nrocuo + 1 >= v_rec.cancuo THEN -- ULTIMA CUOTA
                v_rec.candes := v_rec.salpre;
                v_rec.impdes := v_rec.salpre;
            ELSE
                IF v_rec.salpre > v_rec.valcuo THEN
                    v_rec.candes := v_rec.valcuo;
                    v_rec.impdes := v_rec.valcuo;
                ELSE
                    v_rec.candes := v_rec.salpre;
                    v_rec.impdes := v_rec.salpre;
                END IF;
            END IF;

            PIPE ROW ( v_rec );
        END LOOP;

        RETURN;
    END sp_descuento_proyectado;

END;

/
