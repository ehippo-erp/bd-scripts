--------------------------------------------------------
--  DDL for Package Body PACK_HR_FUNCION_CONTABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_FUNCION_CONTABLE" AS

    FUNCTION sp_buscar_gratxclase (
        pin_id_cia NUMBER,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN dt_gratxclase
        PIPELINED
    AS

        rec    record_gratxclase := record_gratxclase(NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL);
        v_f341 NUMERIC(15, 4);
    BEGIN
        BEGIN
            SELECT
                valfa1
            INTO v_f341
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '341';

        EXCEPTION
            WHEN no_data_found THEN
                v_f341 := 'N';
        END;

        FOR cur_numpla IN (
            SELECT
                pl.empobr AS tiptra,
                pl.tippla,
                pr.numpla,
                pr.codper
            FROM
                     planilla_resumen pr
                INNER JOIN planilla          pl ON pl.id_cia = pr.id_cia
                                          AND pl.numpla = pr.numpla
                INNER JOIN planilla_auxiliar pa ON pa.id_cia = pr.id_cia
                                                   AND pa.numpla = pr.numpla
                                                   AND pa.codper = pr.codper
            WHERE
                    pr.id_cia = pin_id_cia
                AND pl.anopla = pin_anopla
                AND pl.mespla = pin_mespla
                AND pl.empobr = pin_tiptra
                AND pl.tippla = 'N'
                AND pa.situac IN ( 'S' )
        ) LOOP
            rec.id_cia := pin_id_cia;
            rec.numpla := cur_numpla.numpla;
            rec.codper := cur_numpla.codper;

     /*DESCUENTOS*/
            BEGIN
                SELECT
                    nvl(SUM(nvl(valcon, 0)),
                        0)
                INTO rec.valdes
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto_clase cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 19  /*CUENTA GASTO GRATIFICACION*/
                                                    AND cc.codigo = '02' /*DESCUENTO GRATIFICACION*/
                    LEFT OUTER JOIN concepto       co ON co.id_cia = pc.id_cia
                                                   AND co.empobr = 'E'
                                                   AND co.codcon = cc.codcon
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = cur_numpla.numpla
                    AND pc.codper = cur_numpla.codper
                    AND pc.situac IN ( 'S' );

            EXCEPTION
                WHEN no_data_found THEN
                    rec.valdes := 0;
            END;

            rec.valbon := 0;
            IF (
                ( pin_anopla >= 2009 )
                AND ( pin_anopla <= v_f341 )
            ) THEN
                BEGIN
                    SELECT
                        nvl(SUM(nvl(valcon, 0)),
                            0)
                    INTO rec.valbon
                    FROM
                             planilla_concepto pc
                        INNER JOIN concepto_clase cc ON cc.id_cia = pc.id_cia
                                                        AND cc.codcon = pc.codcon
                                                        AND cc.clase = 19  /*CUENTA GASTO GRATIFICACION*/
                                                        AND cc.codigo = '03' /*APORTE DEL EMPLEADOR A FAVOR DEL TRABAJADOR*/
                        LEFT OUTER JOIN concepto       co ON co.id_cia = pc.id_cia
                                                       AND co.empobr = 'E'
                                                       AND co.codcon = cc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = cur_numpla.numpla
                        AND pc.codper = cur_numpla.codper
                        AND pc.situac IN ( 'S' );

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.valbon := 0;
                END;
            END IF;

            BEGIN
                SELECT
                    tp.nombre,
                    ccc.ctagasto,
                    nvl(SUM(nvl(valcon, 0)),
                        0)
                INTO
                    rec.nomcta,
                    rec.cuenta,
                    rec.valing
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto_clase                                                                                cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 19  /*CUENTA GASTO GRATIFICACION*/
                                                    AND cc.codigo = '01' /*INGRESO GRATIFICACIONES*/
                    LEFT OUTER JOIN concepto                                                                                      co ON
                    co.id_cia = pc.id_cia
                                                   AND co.empobr = pin_tiptra
                                                   AND co.codcon = cc.codcon
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(co.id_cia, co.codcon, cur_numpla.tiptra, cur_numpla.tippla) ccc ON 0 = 0
                    LEFT OUTER JOIN tipoplanilla                                                                                  tp ON
                    tp.id_cia = pc.id_cia
                                                       AND tp.tippla = 'G'
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = cur_numpla.numpla
                    AND pc.codper = cur_numpla.codper
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    tp.nombre,
                    ccc.ctagasto;

            EXCEPTION
                WHEN no_data_found THEN
                    rec.nomcta := '';
                    rec.cuenta := '';
                    rec.valing := 0;
            END;

            rec.valcon := ( rec.valing + rec.valbon ) - rec.valdes;

            PIPE ROW ( rec );
        END LOOP;

    END sp_buscar_gratxclase;

    FUNCTION sp_buscar_vacaxclase (
        pin_id_cia NUMBER,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN dt_vacaxclase
        PIPELINED
    AS

        rec record_vacaxclase := record_vacaxclase(NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL);
    BEGIN
        FOR cur_numpla IN (
            SELECT
                pl.empobr AS tiptra,
                pl.tippla,
                pl.numpla,
                pr.codper,
                nvl(SUM(nvl(dias, 0)),
                    0)    AS dias
            FROM
                     planilla_rango pr
                INNER JOIN planilla          pl ON pl.id_cia = pr.id_cia
                                          AND pl.numpla = pr.numpla
                INNER JOIN planilla_auxiliar pa ON pa.id_cia = pr.id_cia
                                                   AND pa.numpla = pr.numpla
                                                   AND pa.codper = pr.codper
            WHERE
                    pr.id_cia = pin_id_cia
                AND pr.codigo = '23'
                AND pl.anopla = pin_anopla
                AND pl.mespla = pin_mespla
                AND pl.empobr = pin_tiptra
                AND pl.tippla = 'N'
                AND pa.situac IN ( 'S' )
            GROUP BY
                pl.empobr,
                pl.tippla,
                pl.numpla,
                pr.codper
        ) LOOP
            rec.id_cia := pin_id_cia;
            rec.numpla := cur_numpla.numpla;
            rec.codper := cur_numpla.codper;
            rec.dias := cur_numpla.dias;

     /*DESCUENTOS PRORATEADOS*/
            BEGIN
                SELECT
                    nvl(SUM(nvl(valcon, 0)),
                        0)
                INTO rec.valren
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto_clase cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 18  /*CUENTA GASTO VACACIONES*/
                                                    AND cc.codigo = '03' /*DESCUENTOS PRORATEADOS*/
                    LEFT OUTER JOIN concepto       co ON co.id_cia = pc.id_cia
                                                   AND co.empobr = 'E'
                                                   AND co.codcon = cc.codcon
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = cur_numpla.numpla
                    AND pc.codper = cur_numpla.codper
                    AND pc.situac IN ( 'S' );

            EXCEPTION
                WHEN no_data_found THEN
                    rec.valren := 0;
            END;

            IF rec.valren > 0 THEN
                rec.valren := ( rec.valren / 30 ) * cur_numpla.dias;
            END IF;


     /*DESCUENTOS*/

            BEGIN
                SELECT
                    nvl(SUM(nvl(valcon, 0)),
                        0)
                INTO rec.valdes
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto_clase cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 18  /*CUENTA GASTO VACACIONES*/
                                                    AND cc.codigo = '02' /*DESCUENTOS DIRECTOS*/
                    LEFT OUTER JOIN concepto       co ON co.id_cia = pc.id_cia
                                                   AND co.empobr = 'E'
                                                   AND co.codcon = cc.codcon
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = cur_numpla.numpla
                    AND pc.codper = cur_numpla.codper
                    AND pc.situac IN ( 'S' );

            EXCEPTION
                WHEN no_data_found THEN
                    rec.valdes := 0;
            END;

            BEGIN
                SELECT
                    tp.nombre,
                    ccc.ctagasto,
                    nvl(SUM(nvl(valcon, 0)),
                        0)
                INTO
                    rec.nomcta,
                    rec.cuenta,
                    rec.valing
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto_clase                                                                                cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 18  /*CUENTA GASTO VACACIONES*/
                                                    AND cc.codigo = '01' /*INGRESO VACACIONES*/
                    LEFT OUTER JOIN concepto                                                                                      co ON
                    co.id_cia = pc.id_cia
                                                   AND co.empobr = pin_tiptra
                                                   AND co.codcon = cc.codcon
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(co.id_cia, co.codcon, cur_numpla.tiptra, cur_numpla.tippla) ccc ON 0 = 0
                    LEFT OUTER JOIN tipoplanilla                                                                                  tp ON
                    tp.id_cia = pc.id_cia
                                                       AND tp.tippla = 'V'
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = cur_numpla.numpla
                    AND pc.codper = cur_numpla.codper
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    tp.nombre,
                    ccc.ctagasto;

            EXCEPTION
                WHEN no_data_found THEN
                    rec.nomcta := '';
                    rec.cuenta := '';
                    rec.valing := 0;
            END;

            BEGIN
                SELECT
                    totalpor
                INTO rec.porafp
                FROM
                    pack_hr_factor_afp.sp_factor_afp_periodo(pin_id_cia, cur_numpla.numpla, cur_numpla.codper);

            EXCEPTION
                WHEN no_data_found THEN
                    rec.porafp := 0;
            END;

            rec.valafp := rec.valing * rec.porafp;
            rec.valcon := rec.valing - ( rec.valren + rec.valdes ) - rec.valafp;

            PIPE ROW ( rec );
        END LOOP;
    END sp_buscar_vacaxclase;

    FUNCTION sp_concepto_gasto (
        pin_id_cia NUMBER,
        pin_anopla INTEGER,
        pin_mespla INTEGER,
        pin_tiptra VARCHAR2,
        pin_opc    INTEGER
    ) RETURN datatable_concepto_gasto
        PIPELINED
    AS
        v_rec datarecord_concepto_gasto;
    BEGIN
/*
  OPC 0 = TODAS LAS PLANILLA NO INCLUYE LIQUIDACIONES
  OPC 1 = TODAS LAS PLANILLA INCLUYE LIQUIDACIONES
  OPC 2 = SOLO LIQUIDACIONES                           */
        IF pin_opc = 0 OR pin_opc = 1 THEN
            FOR i IN (
                SELECT
                    empobr AS tiptra,
                    tippla,
                    numpla
                FROM
                    planilla
                WHERE
                        id_cia = pin_id_cia
                    AND anopla = pin_anopla
                    AND mespla = pin_mespla
                    AND empobr = pin_tiptra
                    AND NOT tippla IN ( 'L', 'X', 'Y', 'Z' )
            ) LOOP
                FOR j IN (
                    SELECT
                        pc.codper,
                        ccc.ctagasto AS cuenta,
                        pc.codcon,
                        c.nombre     AS nomcon,
                        c.dh,
                        c.agrupa,
                        pc.valcon    AS totcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN concepto                                                                  c ON c.id_cia = pc.id_cia
                                                 AND pc.codcon = c.codcon
                        INNER JOIN tipoplanilla_concepto                                                     tc ON tc.id_cia = pc.id_cia
                                                               AND tc.codcon = pc.codcon
                                                               AND tc.tippla = i.tippla
                        INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, i.tiptra, i.tippla) ccc ON 0 = 0
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = i.numpla
                        AND ( c.ingdes IN ( 'D' )
                              OR ( tc.tippla = 'S'
                                   AND c.idliq = 'B' ) )
                        AND pc.valcon <> 0
                        AND pc.situac IN ( 'S' )
                        AND c.ctagasto IS NOT NULL
                ) LOOP
                    v_rec.codper := j.codper;
                    v_rec.codcon := j.codcon;
                    v_rec.nomcon := j.nomcon;
                    v_rec.totcon := j.totcon;
                    v_rec.cuenta := j.cuenta;
                    v_rec.dh := j.dh;
                    IF j.agrupa = 'S' THEN
                        v_rec.codper := NULL;
                    END IF;
                    PIPE ROW ( v_rec );
                END LOOP;
            END LOOP;
        END IF;

        IF pin_opc = 0 OR pin_opc = 2 THEN
            FOR i IN (
                SELECT
                    empobr AS tiptra,
                    tippla,
                    numpla
                FROM
                    planilla
                WHERE
                        id_cia = pin_id_cia
                    AND anopla = pin_anopla
                    AND mespla = pin_mespla
                    AND empobr = pin_tiptra
                    AND tippla = 'L'
            ) LOOP
                FOR j IN (
                    SELECT
                        pc.codper,
                        ccc.ctagasto AS cuenta,
                        pc.codcon,
                        c.nombre     AS nomcon,
                        c.dh,
                        c.agrupa,
                        pc.valcon    AS totcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN concepto                                                                  c ON c.id_cia = pc.id_cia
                                                 AND pc.codcon = c.codcon
                        INNER JOIN tipoplanilla_concepto                                                     tc ON tc.id_cia = pc.id_cia
                                                               AND tc.codcon = pc.codcon
                                                               AND tc.tippla = i.tippla
                        INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, i.tiptra, i.tippla) ccc ON 0 = 0
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = i.numpla
                        AND c.idliq IN ( 'E' )
                        AND pc.valcon <> 0
                        AND pc.situac IN ( 'S' )
                        AND c.ctagasto IS NOT NULL
                ) LOOP
                    v_rec.codper := j.codper;
                    v_rec.codcon := j.codcon;
                    v_rec.nomcon := j.nomcon;
                    v_rec.totcon := j.totcon;
                    v_rec.cuenta := j.cuenta;
                    v_rec.dh := j.dh;
                    IF j.agrupa = 'S' THEN
                        v_rec.codper := NULL;
                    END IF;
                    PIPE ROW ( v_rec );
                END LOOP;
            END LOOP;

        END IF;

    END sp_concepto_gasto;

END pack_hr_funcion_contable;

/
