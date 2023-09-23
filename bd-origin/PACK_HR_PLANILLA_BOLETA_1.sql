--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_BOLETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_BOLETA" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table  datatable_buscar;
        v_iopc   NUMBER := 0;
        pin_iopc NUMBER := 0;
    BEGIN
        IF ( v_iopc IS NULL OR ( v_iopc <= 0 ) ) THEN
            v_iopc := 1;
        ELSE
            v_iopc := pin_iopc;
        END IF;

        FOR i IN 1..v_iopc LOOP
            SELECT
                p.id_cia,
                1,
                emp.nomcom,
                emp.ruc,
                'FALTA'                                           AS nomder,
                'FALTA'                                           AS nompro,
                emp.distri                                        AS nomdis,
                nvl(emp.direcc, emp.dircom),
                pl.anopla,
                pl.mespla,
                to_char(pl.fecini, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
                pl.tippla,
                tpl.nombre                                        AS destippla,
                pl.empobr,
--                ttp.nombre        AS desempobr,
                pcp8.descri                                       AS desempobr,
                pl.fecini,
                pl.fecfin,
                p.codper,
                ( p.apepat
                  || ' '
                  || p.apemat
                  || ', '
                  || p.nombre )                                     AS nomper,
                pd3.nrodoc                                        AS numdni,
                tcc.descco                                        AS nomcco,
                ca.nombre                                         AS nomcar,
                prl.finicio                                       AS fecing,
                prl.ffinal                                        AS fecces,
                pd1.nrodoc                                        AS carips,
                a.nombre                                          AS nomafp,
                pd2.nrodoc                                        AS carafp,
                CASE
                    WHEN co.ingdes = 'C' THEN
                        'B'
                    ELSE
                        co.ingdes
                END                                               AS ingdes,
                decode(co.ingdes, 'D', 'APORTACION', ccc.dingdes) AS dingdes,
                pc.codcon,
                co.abrevi,
                ccc.rotulo                                        AS descon,
                pc.valcon,
                nvl(psp.saldo, 0)                                 AS salpre,
                co.conrel,
                dd.rotdiaslab,
                dd.diaslab,
                dd.rotdiasnolab,
                dd.diasnolab,
                dd.rotdiassub,
                dd.diassub,
                dd.rothordinarias,
                dd.hordinarias,
                dd.rottardanzas,
                dd.tardanzas,
                plc.valcon,
                p.codafp,
                0                                                 AS porfac,
                0                                                 AS porafp,
                con.nombre                                        AS nomsba,
                pcp14.descri                                      AS nomeps,
                pd4.nrodoc                                        AS perconf
            BULK COLLECT
            INTO v_table
            FROM
                planilla                                                                                pl
                LEFT OUTER JOIN tipoplanilla                                                                            tpl ON tpl.id_cia = pl.id_cia
                                                    AND tpl.tippla = pl.tippla
                LEFT OUTER JOIN tipo_trabajador                                                                         ttp ON ttp.id_cia = pl.id_cia
                                                       AND ttp.tiptra = pl.empobr
                LEFT OUTER JOIN companias                                                                               emp ON emp.cia = pl.id_cia
                LEFT OUTER JOIN planilla_resumen                                                                        pr ON pr.id_cia = pl.id_cia
                                                       AND pr.numpla = pl.numpla
                LEFT OUTER JOIN planilla_auxiliar                                                                       prl ON prl.id_cia = pr.id_cia
                                                         AND prl.numpla = pr.numpla
                                                         AND prl.codper = pr.codper
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_dias(pr.id_cia, pr.numpla, pr.codper)                dd ON 0 = 0
                LEFT OUTER JOIN planilla_saldoprestamo                                                                  psp ON psp.id_cia = pr.id_cia
                                                              AND psp.numpla = pr.numpla
                                                              AND psp.codper = pr.codper
                LEFT OUTER JOIN tipoplanilla_concepto                                                                   tc ON tc.id_cia = pl.id_cia
                                                            AND tc.tippla = pl.tippla
                LEFT OUTER JOIN planilla_concepto                                                                       pc ON pc.id_cia = pr.id_cia
                                                        AND pc.numpla = pr.numpla
                                                        AND pc.codper = pr.codper
                                                        AND pc.codcon = tc.codcon
                LEFT OUTER JOIN personal                                                                                p ON p.id_cia = pc.id_cia
                                              AND pc.codper = p.codper
                LEFT OUTER JOIN concepto                                                                                co ON co.id_cia = pc.id_cia
                                               AND pc.codcon = co.codcon
                LEFT OUTER JOIN pack_hr_concepto.sp_buscar_ingdes ( pl.id_cia )                                         ccc ON ccc.ingdes = CASE
                                                                                                        WHEN co.ingdes = 'C' THEN
                                                                                                            'B'
                                                                                                        ELSE
                                                                                                            co.ingdes
                                                                                                    END
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_tcc(p.id_cia, p.codper)                              tcc ON 0 = 0
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_concepto(pc.id_cia, pc.numpla, pc.codper, pc.codcon) ccc ON 0 = 0
                LEFT OUTER JOIN personal_documento                                                                      pd1 ON pd1.id_cia = p.id_cia
                                                          AND p.codper = pd1.codper
                                                          AND pd1.codtip = 'DO'
                                                          AND pd1.codite = 204 /*CARNE DE SEGURO*/
                LEFT OUTER JOIN personal_documento                                                                      pd2 ON pd2.id_cia = p.id_cia
                                                          AND p.codper = pd2.codper
                                                          AND pd2.codtip = 'DO'
                                                          AND pd2.codite = 205 /*CUSS AFP*/
                LEFT OUTER JOIN personal_documento                                                                      pd3 ON pd3.id_cia = p.id_cia
                                                          AND p.codper = pd3.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN personal_documento                                                                      pd4 ON pd4.id_cia = p.id_cia
                                                          AND p.codper = pd4.codper
                                                          AND pd4.codtip = 'DO'
                                                          AND pd4.codite = 206 /*PERSONAL DE CONFIANZA*/
                LEFT OUTER JOIN afp                                                                                     a ON a.id_cia = pc.id_cia
                                         AND p.codafp = a.codafp
                LEFT OUTER JOIN cargo                                                                                   ca ON ca.id_cia = pc.id_cia
                                            AND ca.codcar = p.codcar
                LEFT OUTER JOIN planilla_concepto                                                                       plc ON plc.id_cia = pc.id_cia
                                                         AND p.codper = plc.codper
                                                         AND plc.codcon IN ( '001', '501' )
                                                         AND plc.numpla = pc.numpla
                LEFT OUTER JOIN concepto                                                                                con ON con.id_cia = pc.id_cia
                                                AND con.codcon IN ( '001', '501' )
                                                AND con.empobr = co.empobr  /*001 INGRESO MENSUAL ; 501 NGRESO SEMANAL*/
                LEFT OUTER JOIN personal_clase                                                                          pc8 ON pc8.id_cia = p.id_cia
                                                      AND pc8.codper = p.codper
                                                      AND pc8.clase = 8
                LEFT OUTER JOIN clase_codigo_personal                                                                   pcp8 ON pcp8.id_cia = p.id_cia
                                                              AND pcp8.clase = 8
                                                              AND pcp8.codigo = pc8.codigo
                LEFT OUTER JOIN personal_clase                                                                          pc14 ON pc14.id_cia = p.id_cia
                                                       AND pc14.codper = p.codper
                                                       AND pc14.clase = 14
                LEFT OUTER JOIN clase_codigo_personal                                                                   pcp14 ON pcp14.id_cia = p.id_cia
                                                               AND pcp14.clase = 14
                                                               AND pcp14.codigo = pc14.codigo
            WHERE
                    p.id_cia = pin_id_cia
                AND co.ingdes IN ( 'A', 'B', 'C', 'D' )/*A = ingreso B=descuento C y D = aportacion*/
                AND pc.valcon <> 0
                AND pc.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pr.codper = pin_codper )
                AND pr.situac = 'S'
            ORDER BY
                pc.numpla,
                p.apepat,
                p.apemat,
                p.nombre,
                co.ingdes,
                co.codcon;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_detalle_concepto_resultado (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2,
        pin_vstrg  VARCHAR2
    ) RETURN datatable_detalle_concepto_resultado
        PIPELINED
    AS

        v_rec          datarecord_detalle_concepto_resultado;
        v_char         VARCHAR2(100 CHAR);
        v_aux          NUMBER := 0;
        pout_mensaje   VARCHAR2(1000) := '';
        v_formula      VARCHAR2(1000) := '';
        v_aux_formula  VARCHAR2(1000) := '';
        v_pout_formula VARCHAR2(1000) := '';
        v_mensaje      VARCHAR2(1000) := '';
    BEGIN
        IF pin_codigo = '01' THEN
            SELECT
                rtrim(to_char(nvl(valcon, '0'),
                              'FM999999999999990.999999'),
                      ',')
            INTO v_char
            FROM
                planilla_concepto
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla
                AND codper = pin_codper
                AND codcon = pin_vstrg;

        ELSIF pin_codigo = '02' THEN
            pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, pin_vstrg, 'N',
                                                           NULL, NULL, v_formula, v_aux_formula, v_char,
                                                           v_mensaje);
        ELSIF pin_codigo = '03' THEN
            pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, pin_vstrg, 'N',
                                                           NULL, NULL, v_formula, v_aux_formula, v_char,
                                                           v_mensaje);
        END IF;

        v_char := rtrim(to_char(nvl(v_char, '0'), 'FM999999999999990'), ',');

        v_rec.id_cia := pin_id_cia;
        v_rec.codcon := pin_codcon;
        v_rec.clase := pin_clase;
        v_rec.codigo := pin_codigo;
        v_rec.vstrg := pin_vstrg;
        v_rec.valcon := v_char;
        PIPE ROW ( v_rec );
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            v_rec.id_cia := pin_id_cia;
            v_rec.codcon := pin_codcon;
            v_rec.clase := pin_clase;
            v_rec.codigo := pin_codigo;
            v_rec.vstrg := pin_vstrg;
            v_rec.valcon := '0';
            PIPE ROW ( v_rec );
            RETURN;
    END sp_detalle_concepto_resultado;

    FUNCTION sp_convert_format (
        pin_input  VARCHAR2,
        pin_codfor NUMBER
    ) RETURN VARCHAR2 AS
        v_char   VARCHAR2(100 CHAR);
        v_number NUMBER(24, 6);
    BEGIN
        IF pin_codfor = 1 THEN
            v_char := rtrim(to_char(nvl(pin_input, '0'), 'FM999999999999990'), ',');
        ELSIF pin_codfor = 2 THEN
            v_char := rtrim(to_char(nvl(pin_input, '0'), '999999999999990.99'), ',');
        ELSIF pin_codfor = 3 THEN
            v_char := rtrim(to_char(nvl(pin_input, '0'), '999999999999990.9999'), ',');
        ELSIF pin_codfor = 4 THEN
            v_char := rtrim(to_char(nvl(pin_input, '0'), '999999999999990.999999'), ',');
        ELSIF pin_codfor = 5 THEN
            SELECT
                CAST(nvl(pin_input, '0') AS NUMBER(24,
                     6)) * 100
            INTO v_number
            FROM
                dual;

            v_char := rtrim(to_char(v_number, '999999999999990.99'), ',');
        ELSIF pin_codfor = 6 THEN
            SELECT
                CAST(nvl(pin_input, '0') AS NUMBER(24,
                     6)) * - 100
            INTO v_number
            FROM
                dual;

            v_char := rtrim(to_char(v_number, '999999999999990.99'), ',');
        ELSIF pin_codfor = 7 THEN
            v_char := nvl(pin_input, '0');
        ELSE
            v_char := nvl(pin_input, '0');
        END IF;

        RETURN v_char;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '0';
    END sp_convert_format;

    FUNCTION sp_detalle_concepto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_detalle_concepto
        PIPELINED
    AS

        v_rec              datarecord_detalle_concepto;
        v_char             VARCHAR2(100 CHAR) := '';
        v_number           NUMBER(24, 6) := 0.0;
        v_rec_planilla_afp planilla_afp%rowtype;
        v_rec_planilla     planilla%rowtype;
        v_aux              NUMBER := 0;
        pout_mensaje       VARCHAR2(1000) := '';
        v_formula          VARCHAR2(1000) := '';
        v_aux_formula      VARCHAR2(1000) := '';
        v_pout_formula     VARCHAR2(1000) := '';
        v_mensaje          VARCHAR2(1000) := '';
        v_prefijo          VARCHAR2(100 CHAR);
        v_sufijo           VARCHAR2(100 CHAR);
        v_operador_prefijo VARCHAR2(10 CHAR);
        v_operador_sufijo  VARCHAR2(10 CHAR);
    BEGIN
        BEGIN
            SELECT
                c.codcon,
                c.nombre
            INTO
                v_rec.codcon,
                v_rec.descon
            FROM
                concepto c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.codcon = pin_codcon
                AND EXISTS (
                    SELECT
                        cc.*
                    FROM
                        concepto_clase cc
                    WHERE
                            cc.id_cia = c.id_cia
                        AND cc.codcon = c.codcon
                );

        -- VERIFICAMOS LA EXISTENCIA DE UN CONCEPTO INTERRUPTOR
            BEGIN
                FOR i IN (
                    SELECT
                        cch.*,
                        CASE
                            WHEN cch.clase = 20 THEN
                                '+'
                            WHEN cch.clase = 21 THEN
                                '-'
                            WHEN cch.clase = 22 THEN
                                '*'
                            WHEN cch.clase = 23 THEN
                                '/'
                            ELSE
                                NULL
                        END AS operador
                    FROM
                        concepto_clase       cc
                        LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_concepto_resultado(pin_id_cia, pin_numpla, pin_codper, pin_codcon
                        , cc.clase,
                                                                                              cc.codigo, cc.vstrg) ppp ON 0 = 0
                        LEFT OUTER JOIN concepto_clase       cch ON cch.id_cia = cc.id_cia
                                                              AND cch.codcon = cc.codcon
                                                              AND cch.vresult = ppp.valcon
                    WHERE
                            cc.id_cia = pin_id_cia
                        AND cc.codcon = pin_codcon
                        AND cc.clase = 17
                        AND cch.clase IN ( 15, 16, 20, 21, 22,
                                           23 ) -- CONCEPTO REFERENCIALES Y/O OPERADORES
                    ORDER BY
                        cch.clase DESC
                )-- CONCEPTO INTERRUPTOR
                 LOOP
                    v_aux := 1;
                    IF i.clase IN ( 20, 21, 22, 23 ) THEN
                        dbms_output.put_line('CONCEPTO OPERADOR');
                        CASE i.codigo
                            WHEN '01' THEN
                                SELECT
                                    rtrim(to_char(nvl(valcon, '0'),
                                                  'FM999999999999990.999999'),
                                          ',')
                                INTO v_char
                                FROM
                                    planilla_concepto
                                WHERE
                                        id_cia = pin_id_cia
                                    AND numpla = pin_numpla
                                    AND codper = pin_codper
                                    AND codcon = i.vstrg;

                            WHEN '02' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            WHEN '03' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            ELSE
                                v_rec.prefijo := 'ERROR ';
                                v_rec.sufijo := ' ERROR';
                                v_rec.rotulo := v_rec.prefijo
                                                || v_rec.descon
                                                || v_rec.sufijo;

                                PIPE ROW ( v_rec );
                                RETURN;
                        END CASE;

                        IF i.vposition = 'P' THEN
                            v_prefijo := trim(v_char);
                            v_operador_prefijo := to_char(i.operador);
                        ELSIF i.vposition = 'S' THEN
                            v_sufijo := trim(v_char);
                            v_operador_sufijo := to_char(i.operador);
                        END IF;

                        dbms_output.put_line('O|'
                                             || v_operador_prefijo
                                             || '|'
                                             || v_prefijo
                                             || '|'
                                             || v_sufijo
                                             || '|'
                                             || i.vposition
                                             || '|'
                                             || i.operador);

                    ELSE
                        dbms_output.put_line('CONCEPTO');
                        CASE i.codigo
                            WHEN '01' THEN
                                SELECT
                                    rtrim(to_char(nvl(valcon, '0'),
                                                  'FM999999999999990.999999'),
                                          ',')
                                INTO v_char
                                FROM
                                    planilla_concepto
                                WHERE
                                        id_cia = pin_id_cia
                                    AND numpla = pin_numpla
                                    AND codper = pin_codper
                                    AND codcon = i.vstrg;

                            WHEN '02' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            WHEN '03' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            ELSE
                                v_rec.prefijo := 'ERROR ';
                                v_rec.sufijo := ' ERROR';
                                v_rec.rotulo := v_rec.prefijo
                                                || v_rec.descon
                                                || v_rec.sufijo;

                                PIPE ROW ( v_rec );
                                RETURN;
                        END CASE;

                        dbms_output.put_line('C.O. '
                                             || v_operador_prefijo
                                             || '|'
                                             || v_prefijo
                                             || '|'
                                             || v_sufijo);

                        IF
                            ( v_operador_prefijo IS NOT NULL OR v_operador_sufijo IS NOT NULL )
                            AND ( v_prefijo IS NOT NULL OR v_sufijo IS NOT NULL )
                        THEN
                            IF i.vposition = 'P' THEN
                                v_pout_formula := v_char
                                                  || ' '
                                                  || v_operador_prefijo
                                                  || ' '
                                                  || v_prefijo;
                            ELSIF i.vposition = 'S' THEN
                                v_pout_formula := v_char
                                                  || ' '
                                                  || v_operador_sufijo
                                                  || ' '
                                                  || v_sufijo;
                            END IF;

                            EXECUTE IMMEDIATE 'SELECT '
                                              || v_pout_formula
                                              || ' FROM DUAL '
                            INTO v_char;
                            v_char := rtrim(to_char(v_char, 'FM999999999999990.999999'), ',');
                        END IF;

                        v_char := pack_hr_planilla_boleta.sp_convert_format(v_char, i.codfor);
                        IF i.vposition = 'P' THEN
                            v_rec.prefijo := i.vprefijo
                                             || trim(v_char)
                                             || i.vsufijo
                                             || ' ';
                        ELSIF i.vposition = 'S' THEN
                            v_rec.sufijo := ' '
                                            || i.vprefijo
                                            || trim(v_char)
                                            || i.vsufijo;
                        ELSE
                            v_rec.prefijo := 'ERROR ';
                            v_rec.sufijo := ' ERROR';
                        END IF;

                    END IF;

                END LOOP;

                IF v_aux = 0 THEN -- NO EXISTE CONCEPTO INTERRUPTOR

                    FOR i IN (
                        SELECT
                            cc.*,
                            cch.clase  AS rel_clase,
                            cch.codigo AS rel_codigo,
                            cch.vstrg  AS rel_vstrg,
                            CASE
                                WHEN cch.clase = 20 THEN
                                    '+'
                                WHEN cch.clase = 21 THEN
                                    '-'
                                WHEN cch.clase = 21 THEN
                                    '*'
                                WHEN cch.clase = 21 THEN
                                    '/'
                                ELSE
                                    NULL
                            END        AS rel_operador
                        FROM
                            concepto_clase cc
                            LEFT OUTER JOIN concepto_clase cch ON cch.id_cia = cc.id_cia
                                                                  AND cch.codcon = cc.codcon
                                                                  AND cch.vresult = TRIM(to_char(cc.vresult))
                        WHERE
                                cc.id_cia = pin_id_cia
                            AND cc.codcon = pin_codcon
                            AND cc.clase IN ( 15, 16 )
                            AND nvl(cch.clase, 99) IN ( 20, 21, 22, 23, 99 ) -- CONCEPTO REFERENCIALES Y/O OPERADORES
                        ORDER BY
                            cc.clase ASC
                    )-- CONCEPTO INTERRUPTOR
                     LOOP
                        v_aux := 1;
                        IF i.rel_clase IN ( 20, 21, 22, 23 ) THEN
                            CASE i.rel_codigo
                                WHEN '01' THEN
                                    SELECT
                                        rtrim(to_char(nvl(valcon, '0'),
                                                      'FM999999999999990.999999'),
                                              ',')
                                    INTO v_char
                                    FROM
                                        planilla_concepto
                                    WHERE
                                            id_cia = pin_id_cia
                                        AND numpla = pin_numpla
                                        AND codper = pin_codper
                                        AND codcon = i.rel_vstrg;

                                WHEN '02' THEN
                                    pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.rel_vstrg, 'N'
                                    ,
                                                                                   NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                                   v_mensaje);
                                WHEN '03' THEN
                                    pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.rel_vstrg, 'N'
                                    ,
                                                                                   NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                                   v_mensaje);
                                ELSE
                                    v_rec.prefijo := 'ERROR ';
                                    v_rec.sufijo := ' ERROR';
                                    v_rec.rotulo := v_rec.prefijo
                                                    || v_rec.descon
                                                    || v_rec.sufijo;

                                    PIPE ROW ( v_rec );
                                    RETURN;
                            END CASE;

                            IF i.vposition = 'P' THEN
                                v_prefijo := trim(v_char);
                                v_operador_prefijo := i.rel_operador;
                            ELSIF i.vposition = 'S' THEN
                                v_sufijo := trim(v_char);
                                v_operador_sufijo := i.rel_operador;
                            END IF;

                        END IF;

                        CASE i.codigo
                            WHEN '01' THEN
                                SELECT
                                    rtrim(to_char(nvl(valcon, '0'),
                                                  'FM999999999999990.999999'),
                                          ',')
                                INTO v_char
                                FROM
                                    planilla_concepto
                                WHERE
                                        id_cia = pin_id_cia
                                    AND numpla = pin_numpla
                                    AND codper = pin_codper
                                    AND codcon = i.vstrg;

                            WHEN '02' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            WHEN '03' THEN
                                pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, i.vstrg, 'N',
                                                                               NULL, NULL, v_formula, v_aux_formula, v_char,
                                                                               v_mensaje);
                            ELSE
                                v_rec.prefijo := 'ERROR ';
                                v_rec.sufijo := ' ERROR';
                                v_rec.rotulo := v_rec.prefijo
                                                || v_rec.descon
                                                || v_rec.sufijo;

                                PIPE ROW ( v_rec );
                                RETURN;
                        END CASE;

                        IF
                            v_operador_prefijo IS NOT NULL
                            AND ( v_prefijo IS NOT NULL OR v_sufijo IS NOT NULL )
                        THEN
                            IF i.vposition = 'P' THEN
                                v_pout_formula := v_char
                                                  || ' '
                                                  || v_operador_prefijo
                                                  || ' '
                                                  || v_prefijo;
                            ELSIF i.vposition = 'S' THEN
                                v_pout_formula := v_char
                                                  || ' '
                                                  || v_operador_sufijo
                                                  || ' '
                                                  || v_sufijo;
                            END IF;

                            EXECUTE IMMEDIATE 'SELECT '
                                              || v_pout_formula
                                              || ' FROM DUAL '
                            INTO v_char;
                            v_char := rtrim(to_char(v_char, 'FM999999999999990.999999'), ',');
                        END IF;

                        v_char := pack_hr_planilla_boleta.sp_convert_format(v_char, i.codfor);
                        IF i.vposition = 'P' THEN
                            v_rec.prefijo := i.vprefijo
                                             || trim(v_char)
                                             || i.vsufijo
                                             || ' ';
                        ELSIF i.vposition = 'S' THEN
                            v_rec.sufijo := ' '
                                            || i.vprefijo
                                            || trim(v_char)
                                            || i.vsufijo;
                        ELSE
                            v_rec.prefijo := 'ERROR ';
                            v_rec.sufijo := ' ERROR';
                        END IF;

                    END LOOP;

                END IF;

                v_rec.rotulo := v_rec.prefijo
                                || v_rec.descon
                                || v_rec.sufijo;

                PIPE ROW ( v_rec );
            EXCEPTION
                WHEN no_data_found THEN
                    v_rec.prefijo := 'ERROR ';
                    v_rec.sufijo := ' ERROR';
                    v_rec.rotulo := v_rec.prefijo
                                    || v_rec.descon
                                    || v_rec.sufijo;

                    PIPE ROW ( v_rec );
                    RETURN;
            END;

        EXCEPTION
            WHEN no_data_found THEN
                SELECT
                    c.codcon,
                    c.nombre
                INTO
                    v_rec.codcon,
                    v_rec.descon
                FROM
                    concepto c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.codcon = pin_codcon;

                v_rec.prefijo := NULL;
                v_rec.sufijo := NULL;
                v_rec.rotulo := v_rec.prefijo
                                || v_rec.descon
                                || v_rec.sufijo;

                PIPE ROW ( v_rec );
                RETURN;
        END;
    END sp_detalle_concepto;

    FUNCTION sp_detalle_firma (
        pin_id_cia NUMBER
    ) RETURN datatable_detalle_firma
        PIPELINED
    AS
        v_table datatable_detalle_firma;
    BEGIN
        SELECT
            c.cia,
            c.logocab,
            c.formcab,
            c.logodet,
            c.formdet
        BULK COLLECT
        INTO v_table
        FROM
            companias       c
            LEFT OUTER JOIN factor_planilla fp ON fp.id_cia = c.cia
                                                  AND fp.codfac = '310'
        WHERE
                c.cia = pin_id_cia
            AND fp.valfa1 = 0;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_firma;

    FUNCTION sp_detalle_envio_correo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_envio_correo
        PIPELINED
    AS
        v_table datatable_detalle_envio_correo;
    BEGIN
        SELECT
            pa.id_cia,
            pa.numpla,
            pa.codper
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pa
            INNER JOIN personal       p ON p.id_cia = pa.id_cia
                                     AND p.codper = pa.codper
            INNER JOIN personal_clase pc ON pc.id_cia = p.id_cia
                                            AND pc.codper = p.codper
                                            AND pc.clase = 1100
                                            AND pc.codigo = 'S'
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.numpla = pin_numpla
            AND pa.situac = 'S'
            AND ( pin_codper IS NULL
                  OR pa.codper = pin_codper );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_envio_correo;

    FUNCTION sp_detalle_rango (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_rango
        PIPELINED
    AS
        v_table    datatable_detalle_rango;
        v_planilla planilla%rowtype;
        v_aux      VARCHAR2(1 CHAR);
    BEGIN
        BEGIN
            SELECT
                'S' -- SI HAY REGISTROS DE DESCANSO VACIONAL EN LA PLANILLA ACTUAL
            INTO v_aux
            FROM
                planilla_rango pr
            WHERE
                    pr.id_cia = pin_id_cia
                AND pr.numpla = pin_numpla
                AND pr.codper = pin_codper
                AND pr.codigo = 23; -- DESCANDO VACACIONAL
        EXCEPTION
            WHEN no_data_found THEN
                v_aux := 'N'; -- NO HAY REGISTROS DE DESCANSO VACIONAL EN LA PLANILLA ACTUAL
            WHEN too_many_rows THEN
                v_aux := 'S'; -- SI HAY REGISTROS DE DESCANSO VACIONAL EN LA PLANILLA ACTUAL
        END;

        BEGIN
            SELECT
                p.anopla,
                p.mespla,
                p.tippla
            INTO
                v_planilla.anopla,
                v_planilla.mespla,
                v_planilla.tippla
            FROM
                planilla p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.numpla = pin_numpla;

        EXCEPTION
            WHEN no_data_found THEN
                v_planilla.tippla := 'N';
        END;

        IF
            v_planilla.tippla = 'V'
            AND v_aux = 'N'
        THEN
            SELECT
                p.codper,
                p.codigo,
                mo.descri AS desmot,
                p.finicio,
                p.ffinal,
                p.dias
            BULK COLLECT
            INTO v_table
            FROM
                planilla_rango  p
                LEFT OUTER JOIN motivo_planilla mo ON mo.id_cia = p.id_cia
                                                      AND mo.codrel = p.codigo
                INNER JOIN planilla        pl ON pl.id_cia = p.id_cia
                                          AND pl.numpla = p.numpla
                                          AND pl.tippla = 'N'
                                          AND pl.anopla = v_planilla.anopla
                                          AND pl.mespla = v_planilla.mespla
            WHERE
                    p.id_cia = pin_id_cia
                AND p.codigo = 23
                AND ( ( pin_codper IS NULL )
                      OR ( p.codper = pin_codper ) )
            ORDER BY
                p.numpla,
                p.codper,
                p.codcon,
                p.item;

        ELSE
            SELECT
                p.codper,
                p.codigo,
                mo.descri AS desmot,
                p.finicio,
                p.ffinal,
                p.dias
            BULK COLLECT
            INTO v_table
            FROM
                planilla_rango  p
                LEFT OUTER JOIN motivo_planilla mo ON mo.id_cia = p.id_cia
                                                      AND mo.codrel = p.codigo
            WHERE
                    p.id_cia = pin_id_cia
                AND p.numpla = pin_numpla
                AND ( ( pin_codper IS NULL )
                      OR ( p.codper = pin_codper ) )
            ORDER BY
                p.numpla,
                p.codper,
                p.codcon,
                p.item;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_detalle_rango;

    FUNCTION sp_detalle_dias (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_dias
        PIPELINED
    AS

        v_rec        datarecord_detalle_dias;
        rec_planilla planilla%rowtype;
        v_diaslab    NUMBER := 0;
        v_diasnolab  NUMBER := 0;
        v_diassub    NUMBER := 0;
        v_diastar    NUMBER := 0;
        v_horempobr  NUMBER := 0;
        v_days       NUMBER := 0;
        v_day        DATE;
        v_thor       NUMBER := 0;
        v_tmin       NUMBER := 0;
    BEGIN

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
                nvl(SUM(nvl(pr.dias, 0)),
                    0)
            INTO v_diasnolab
            FROM
                     planilla_rango pr
                INNER JOIN motivo_planilla mp ON mp.id_cia = pr.id_cia
                                                 AND mp.codrel = pr.codigo
                                                 AND mp.tipo = 'B'
            WHERE
                    pr.id_cia = pin_id_cia
                AND pr.numpla = pin_numpla
                AND pr.codper = pin_codper;

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
            INTO v_diastar
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
                v_diastar := 0;
        END;

        -- DIAS LABORADOS
        BEGIN
            SELECT
                to_char(nvl(pc.valcon, 0))
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
--                FOR i IN 1..v_days LOOP
--                    v_day := rec_planilla.fecini + 1;
--                    IF to_char(v_day, 'DY') NOT IN ( 'SUN' )
--                AND v_day NOT IN (
--                    SELECT
--                        fecha
--                    FROM
--                        asistencia_planilla_feriados
--                    WHERE
--                            id_cia = pin_id_cia
--                        AND periodo = rec_planilla.anopla
--                        AND situac = 'S'
--                )
--                     THEN
--                        v_diaslab := v_diaslab + 1;
--                    END IF;
--                END LOOP;
                v_diaslab := 30;
                v_rec.diaslab := to_char(v_diaslab - v_diasnolab - v_diassub);
        END;

        -- FINALEMNTE
        v_rec.diasnolab := to_char(v_diasnolab);
        v_rec.diassub := to_char(v_diassub);
        v_rec.hordinarias := to_char(floor(v_rec.diaslab * v_horempobr) - nvl(floor(to_char(v_diastar) / 60), 0));

        v_thor := floor(to_char(v_diastar) / 60);
        v_tmin := v_diastar - ( floor(to_char(v_diastar) / 60) * 60 );

        SELECT
            decode(v_thor,
                   0,
                   '00',
                   to_char(v_thor))
            || ':'
            || decode(v_tmin,
                      0,
                      '00',
                      to_char(v_tmin))
        INTO v_rec.tardanzas
        FROM
            dual;

        IF rec_planilla.tippla = 'V' THEN
            v_rec.rotdiasnolab := 'DIAS NO LABORADOS:';
            v_rec.diasnolab := v_rec.diaslab;
            v_rec.rotdiaslab := NULL;
            v_rec.diaslab := NULL;
            v_rec.rotdiassub := NULL;
            v_rec.diassub := NULL;
            v_rec.rothordinarias := NULL;
            v_rec.hordinarias := NULL;
            v_rec.rottardanzas := NULL;
            v_rec.tardanzas := NULL;
            PIPE ROW ( v_rec );
        ELSE
            v_rec.rotdiaslab := 'DIAS EFECTIVOS:';
            v_rec.diaslab := v_rec.diaslab;
            v_rec.rotdiasnolab := 'DIAS NO LABORADOS:';
            v_rec.diasnolab := v_rec.diasnolab;
            v_rec.rotdiassub := 'DIAS SUBSIDIO:';
            v_rec.diassub := v_rec.diassub;
            v_rec.rothordinarias := 'HORAS:';
            v_rec.hordinarias := v_rec.hordinarias;
            v_rec.rottardanzas := 'TARZANDA:';
            v_rec.tardanzas := v_rec.tardanzas;
            PIPE ROW ( v_rec );
        END IF;

    END sp_detalle_dias;

    FUNCTION sp_detalle_cts (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_cts
        PIPELINED
    AS
        v_rec        datarecord_detalle_cts;
        v_mensaje    VARCHAR2(1000 CHAR);
        pout_formula VARCHAR2(1000 CHAR);
    BEGIN
        FOR i IN (
            SELECT
                pa.id_cia,
                pa.numpla,
                pa.codper,
                pa.finicio,
                pa.ffinal,
                p.anopla,
                p.mespla,
                ef.codigo AS codban,
                ef.descri AS desban,
                m.codmon,
                m.simbolo AS simmon,
                cts.cuenta,
                pc.valcon AS deposito
            FROM
                planilla_auxiliar pa
                LEFT OUTER JOIN planilla          p ON p.id_cia = pa.id_cia
                                              AND p.numpla = pa.numpla
                LEFT OUTER JOIN planilla_concepto pc ON pc.id_cia = pa.id_cia
                                                        AND pc.numpla = pa.numpla
                                                        AND pc.codper = pa.codper
                                                        AND pc.codcon = '193'
                LEFT OUTER JOIN personal_cts      cts ON cts.id_cia = pa.id_cia
                                                    AND cts.codper = pa.codper
                LEFT OUTER JOIN e_financiera      ef ON ef.id_cia = cts.id_cia
                                                   AND ef.codigo = cts.codban
                LEFT OUTER JOIN personal          p ON p.id_cia = pa.id_cia
                                              AND p.codper = pa.codper
                LEFT OUTER JOIN tmoneda           m ON m.id_cia = p.id_cia
                                             AND m.codmon = p.codmon
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pa.codper = pin_codper )
        ) LOOP
            IF i.mespla < 7 THEN
                pack_hr_procedure_general.sp_diafactor_proyecciongrati(i.id_cia, i.numpla, i.codper, 12, i.anopla - 1,
                                                                      i.finicio, i.ffinal, pout_formula, v_rec.diacts, v_mensaje);

                pack_hr_procedure_general.sp_mesfactor_proyecciongrati(i.id_cia, i.numpla, i.codper, 12, i.anopla - 1,
                                                                      i.finicio, i.ffinal, pout_formula, v_rec.mescts, v_mensaje);

            ELSE
                pack_hr_procedure_general.sp_diafactor_proyecciongrati(i.id_cia, i.numpla, i.codper, 7, i.anopla,
                                                                      i.finicio, i.ffinal, pout_formula, v_rec.diacts, v_mensaje);

                pack_hr_procedure_general.sp_mesfactor_proyecciongrati(i.id_cia, i.numpla, i.codper, 7, i.anopla,
                                                                      i.finicio, i.ffinal, pout_formula, v_rec.mescts, v_mensaje);

            END IF;

            v_rec.codper := i.codper;
            v_rec.finicio := i.finicio;
            v_rec.ffinal := i.ffinal;
            v_rec.totcts := 0;
            v_rec.codban := i.codban;
            v_rec.desban := i.desban;
            v_rec.codmon := i.codmon;
            v_rec.simmon := i.simmon;
            v_rec.cuenta := i.cuenta;
            v_rec.deposito := i.deposito;
            PIPE ROW ( v_rec );
        END LOOP;
    END sp_detalle_cts;

    FUNCTION sp_buscar_cts (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar_cts
        PIPELINED
    AS
        v_table  datatable_buscar_cts;
        v_iopc   NUMBER := 0;
        pin_iopc NUMBER := 0;
    BEGIN
        IF ( v_iopc IS NULL OR ( v_iopc <= 0 ) ) THEN
            v_iopc := 1;
        ELSE
            v_iopc := pin_iopc;
        END IF;

        FOR i IN 1..v_iopc LOOP
            SELECT
                p.id_cia,
                1,
                emp.nomcom,
                emp.ruc,
                'FALTA'                                      AS nomder,
                'FALTA'                                      AS nompro,
                emp.distri                                   AS nomdis,
                nvl(emp.direcc, emp.dircom),
                pl.anopla,
                pl.mespla,
                to_char(pl.fecini, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
                pl.tippla,
                tpl.nombre                                   AS destippla,
                pl.empobr,
                ttp.nombre                                   AS desempobr,
                pl.fecini,
                pl.fecfin,
                p.codper,
                ( p.apepat
                  || ' '
                  || p.apemat
                  || ', '
                  || p.nombre )                                AS nomper,
                pd3.nrodoc                                   AS numdni,
                tcc.descco                                   AS nomcco,
                ca.nombre                                    AS nomcar,
                prl.finicio                                  AS fecing,
                prl.ffinal                                   AS fecces,
                pd1.nrodoc                                   AS carips,
                a.nombre                                     AS nomafp,
                pd2.nrodoc                                   AS carafp,
                CASE
                    WHEN co.idliq = 'G' THEN
                        'A'
                    WHEN co.idliq = 'A' THEN
                        'B'
                    WHEN co.idliq = 'C' THEN
                        'C'
                    WHEN co.idliq = 'B' THEN
                        'D'
                    WHEN co.idliq = 'H' THEN
                        'E'
                    ELSE
                        co.idliq
                END                                          AS idliq,
                decode(co.idliq, 'B', 'CALCULO', ccc.didliq) AS didliq,
                pc.codcon,
                co.abrevi,
                co.nombre                                    AS descon,
                pc.valcon,
                nvl(psp.saldo, 0)                            AS salpre,
                co.conrel,
                dd.mescts,
                dd.diacts,
                dd.totcts,
                dd.codban,
                dd.desban,
                dd.codmon,
                round(venta, 2)                              AS tipcam,
                dd.simmon,
                dd.cuenta,
                dd.deposito,
                plc.valcon,
                p.codafp,
                0                                            AS porfac,
                0                                            AS porafp,
                con.nombre                                   AS nomsba,
                pcp14.descri                                 AS nomeps,
                pd4.nrodoc                                   AS perconf
            BULK COLLECT
            INTO v_table
            FROM
                planilla                                                                pl
                LEFT OUTER JOIN tipoplanilla                                                            tpl ON tpl.id_cia = pl.id_cia
                                                    AND tpl.tippla = pl.tippla
                LEFT OUTER JOIN tipo_trabajador                                                         ttp ON ttp.id_cia = pl.id_cia
                                                       AND ttp.tiptra = pl.empobr
                LEFT OUTER JOIN companias                                                               emp ON emp.cia = pl.id_cia
                LEFT OUTER JOIN planilla_resumen                                                        pr ON pr.id_cia = pl.id_cia
                                                       AND pr.numpla = pl.numpla
                LEFT OUTER JOIN planilla_auxiliar                                                       prl ON prl.id_cia = pr.id_cia
                                                         AND prl.numpla = pr.numpla
                                                         AND prl.codper = pr.codper
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_cts(pr.id_cia, pr.numpla, pr.codper) dd ON 0 = 0
                LEFT OUTER JOIN planilla_saldoprestamo                                                  psp ON psp.id_cia = pr.id_cia
                                                              AND psp.numpla = pr.numpla
                                                              AND psp.codper = pr.codper
                LEFT OUTER JOIN tipoplanilla_concepto                                                   tc ON tc.id_cia = pl.id_cia
                                                            AND tc.tippla = pl.tippla
                LEFT OUTER JOIN planilla_concepto                                                       pc ON pc.id_cia = pr.id_cia
                                                        AND pc.numpla = pr.numpla
                                                        AND pc.codper = pr.codper
                                                        AND pc.codcon = tc.codcon
                LEFT OUTER JOIN personal                                                                p ON p.id_cia = pc.id_cia
                                              AND pc.codper = p.codper
                LEFT OUTER JOIN concepto                                                                co ON co.id_cia = pc.id_cia
                                               AND pc.codcon = co.codcon
--                LEFT OUTER JOIN pack_hr_concepto.sp_buscar_idliq ( pl.id_cia )                          ccc ON ccc.idliq = CASE
--                    WHEN co.idliq = 'G' THEN
--                        'A'
--                    WHEN co.idliq = 'A' THEN
--                        'B'
--                    WHEN co.idliq = 'C' THEN
--                        'C'
--                    WHEN co.idliq = 'B' THEN
--                        'D'
--                    WHEN co.idliq = 'H' THEN
--                        'E'
--                    ELSE
--                        co.idliq
                LEFT OUTER JOIN pack_hr_concepto.sp_buscar_idliq ( pl.id_cia )                          ccc ON ccc.idliq = co.idliq
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_tcc(p.id_cia, p.codper)              tcc ON 0 = 0
                LEFT OUTER JOIN personal_documento                                                      pd1 ON pd1.id_cia = p.id_cia
                                                          AND p.codper = pd1.codper
                                                          AND pd1.codtip = 'DO'
                                                          AND pd1.codite = 204 /*CARNE DE SEGURO*/
                LEFT OUTER JOIN personal_documento                                                      pd2 ON pd2.id_cia = p.id_cia
                                                          AND p.codper = pd2.codper
                                                          AND pd2.codtip = 'DO'
                                                          AND pd2.codite = 205 /*CUSS AFP*/
                LEFT OUTER JOIN personal_documento                                                      pd3 ON pd3.id_cia = p.id_cia
                                                          AND p.codper = pd3.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN personal_documento                                                      pd4 ON pd4.id_cia = p.id_cia
                                                          AND p.codper = pd4.codper
                                                          AND pd4.codtip = 'DO'
                                                          AND pd4.codite = 206 /*PERSONAL DE CONFIANZA*/
                LEFT OUTER JOIN afp                                                                     a ON a.id_cia = pc.id_cia
                                         AND p.codafp = a.codafp
                LEFT OUTER JOIN cargo                                                                   ca ON ca.id_cia = pc.id_cia
                                            AND ca.codcar = p.codcar
                LEFT OUTER JOIN planilla_concepto                                                       plc ON plc.id_cia = pc.id_cia
                                                         AND p.codper = plc.codper
                                                         AND plc.codcon IN ( '001', '501' )
                                                         AND plc.numpla = pc.numpla
                LEFT OUTER JOIN concepto                                                                con ON con.id_cia = pc.id_cia
                                                AND con.codcon IN ( '001', '501' )
                                                AND con.empobr = co.empobr  /*001 INGRESO MENSUAL ; 501 NGRESO SEMANAL*/
                LEFT OUTER JOIN personal_clase                                                          pc14 ON pc14.id_cia = p.id_cia
                                                       AND pc14.codper = p.codper
                                                       AND pc14.clase = 14
                LEFT OUTER JOIN clase_codigo_personal                                                   pcp14 ON pcp14.id_cia = p.id_cia
                                                               AND pcp14.clase = 14
                                                               AND pcp14.codigo = pc14.codigo
                LEFT OUTER JOIN tcambio                                                                 tc ON tc.id_cia = pl.id_cia
                                              AND fecha = trunc(current_timestamp)
                                              AND hmoneda = 'PEN'
                                              AND moneda = 'USD'
            WHERE
                    p.id_cia = pin_id_cia
                AND co.idliq IN ( 'A', 'B', 'C', 'G', 'H' )/*A = ingreso B=descuento C y D = aportacion*/
                AND pc.valcon <> 0
                AND pc.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pr.codper = pin_codper )
                AND pr.situac = 'S'
            ORDER BY
                pc.numpla,
                p.apepat,
                p.apemat,
                p.nombre,
                CASE
                        WHEN co.idliq = 'G' THEN
                            'A'
                        WHEN co.idliq = 'A' THEN
                            'B'
                        WHEN co.idliq = 'C' THEN
                            'C'
                        WHEN co.idliq = 'B' THEN
                            'D'
                        WHEN co.idliq = 'H' THEN
                            'E'
                        ELSE
                            co.idliq
                END,
                co.codcon;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_buscar_cts;

    FUNCTION sp_buscar_qui (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table  datatable_buscar;
        v_iopc   NUMBER := 0;
        pin_iopc NUMBER := 0;
    BEGIN
        IF ( v_iopc IS NULL OR ( v_iopc <= 0 ) ) THEN
            v_iopc := 1;
        ELSE
            v_iopc := pin_iopc;
        END IF;

        FOR i IN 1..v_iopc LOOP
            SELECT
                p.id_cia,
                1,
                emp.nomcom,
                emp.ruc,
                'FALTA'           AS nomder,
                'FALTA'           AS nompro,
                emp.distri        AS nomdis,
                nvl(emp.direcc, emp.dircom),
                pl.anopla,
                pl.mespla,
                to_char(pl.fecini, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
                pl.tippla,
                tpl.nombre        AS destippla,
                pl.empobr,
                ttp.nombre        AS desempobr,
                pl.fecini,
                pl.fecfin,
                p.codper,
                ( p.apepat
                  || ' '
                  || p.apemat
                  || ', '
                  || p.nombre )     AS nomper,
                pd3.nrodoc        AS numdni,
                tcc.descco        AS nomcco,
                ca.nombre         AS nomcar,
                prl.finicio       AS fecing,
                prl.ffinal        AS fecces,
                pd1.nrodoc        AS carips,
                a.nombre          AS nomafp,
                pd2.nrodoc        AS carafp,
                CASE
                    WHEN co.ingdes = 'C' THEN
                        'B'
                    ELSE
                        co.ingdes
                END               AS ingdes,
                ccc.dingdes       AS dingdes,
                pc.codcon,
                co.abrevi,
                co.nombre         AS descon,
                pc.valcon,
                nvl(psp.saldo, 0) AS salpre,
                co.conrel,
                dd.rotdiaslab,
                dd.diaslab,
                dd.rotdiasnolab,
                dd.diasnolab,
                dd.rotdiassub,
                dd.diassub,
                dd.rothordinarias,
                dd.hordinarias,
                dd.rottardanzas,
                dd.tardanzas,
                plc.valcon,
                p.codafp,
                0                 AS porfac,
                0                 AS porafp,
                con.nombre        AS nomsba,
                pcp14.descri      AS nomeps,
                pd4.nrodoc        AS perconf
            BULK COLLECT
            INTO v_table
            FROM
                planilla                                                                 pl
                LEFT OUTER JOIN tipoplanilla                                                             tpl ON tpl.id_cia = pl.id_cia
                                                    AND tpl.tippla = pl.tippla
                LEFT OUTER JOIN tipo_trabajador                                                          ttp ON ttp.id_cia = pl.id_cia
                                                       AND ttp.tiptra = pl.empobr
                LEFT OUTER JOIN companias                                                                emp ON emp.cia = pl.id_cia
                LEFT OUTER JOIN planilla_resumen                                                         pr ON pr.id_cia = pl.id_cia
                                                       AND pr.numpla = pl.numpla
                LEFT OUTER JOIN planilla_auxiliar                                                        prl ON prl.id_cia = pr.id_cia
                                                         AND prl.numpla = pr.numpla
                                                         AND prl.codper = pr.codper
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_dias(pr.id_cia, pr.numpla, pr.codper) dd ON 0 = 0
                LEFT OUTER JOIN planilla_saldoprestamo                                                   psp ON psp.id_cia = pr.id_cia
                                                              AND psp.numpla = pr.numpla
                                                              AND psp.codper = pr.codper
                LEFT OUTER JOIN tipoplanilla_concepto                                                    tc ON tc.id_cia = pl.id_cia
                                                            AND tc.tippla = pl.tippla
                LEFT OUTER JOIN planilla_concepto                                                        pc ON pc.id_cia = pr.id_cia
                                                        AND pc.numpla = pr.numpla
                                                        AND pc.codper = pr.codper
                                                        AND pc.codcon = tc.codcon
                LEFT OUTER JOIN personal                                                                 p ON p.id_cia = pc.id_cia
                                              AND pc.codper = p.codper
                LEFT OUTER JOIN concepto                                                                 co ON co.id_cia = pc.id_cia
                                               AND pc.codcon = co.codcon
                LEFT OUTER JOIN pack_hr_concepto.sp_buscar_ingdes ( pl.id_cia )                          ccc ON ccc.ingdes = CASE
                                                                                                        WHEN co.ingdes = 'C' THEN
                                                                                                            'B'
                                                                                                        ELSE
                                                                                                            co.ingdes
                                                                                                    END
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_tcc(p.id_cia, p.codper)               tcc ON 0 = 0
                LEFT OUTER JOIN personal_documento                                                       pd1 ON pd1.id_cia = p.id_cia
                                                          AND p.codper = pd1.codper
                                                          AND pd1.codtip = 'DO'
                                                          AND pd1.codite = 204 /*CARNE DE SEGURO*/
                LEFT OUTER JOIN personal_documento                                                       pd2 ON pd2.id_cia = p.id_cia
                                                          AND p.codper = pd2.codper
                                                          AND pd2.codtip = 'DO'
                                                          AND pd2.codite = 205 /*CUSS AFP*/
                LEFT OUTER JOIN personal_documento                                                       pd3 ON pd3.id_cia = p.id_cia
                                                          AND p.codper = pd3.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN personal_documento                                                       pd4 ON pd4.id_cia = p.id_cia
                                                          AND p.codper = pd4.codper
                                                          AND pd4.codtip = 'DO'
                                                          AND pd4.codite = 206 /*PERSONAL DE CONFIANZA*/
                LEFT OUTER JOIN afp                                                                      a ON a.id_cia = pc.id_cia
                                         AND p.codafp = a.codafp
                LEFT OUTER JOIN cargo                                                                    ca ON ca.id_cia = pc.id_cia
                                            AND ca.codcar = p.codcar
                LEFT OUTER JOIN planilla_concepto                                                        plc ON plc.id_cia = pc.id_cia
                                                         AND p.codper = plc.codper
                                                         AND plc.codcon IN ( '001', '501' )
                                                         AND plc.numpla = pc.numpla
                LEFT OUTER JOIN concepto                                                                 con ON con.id_cia = pc.id_cia
                                                AND con.codcon IN ( '001', '501' )
                                                AND con.empobr = co.empobr  /*001 INGRESO MENSUAL ; 501 NGRESO SEMANAL*/
                LEFT OUTER JOIN personal_clase                                                           pc14 ON pc14.id_cia = p.id_cia
                                                       AND pc14.codper = p.codper
                                                       AND pc14.clase = 14
                LEFT OUTER JOIN clase_codigo_personal                                                    pcp14 ON pcp14.id_cia = p.id_cia
                                                               AND pcp14.clase = 14
                                                               AND pcp14.codigo = pc14.codigo
            WHERE
                    p.id_cia = pin_id_cia
                AND co.ingdes IN ( 'B' )
                AND co.codcon = '201'
                AND pc.valcon <> 0
                AND pc.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pr.codper = pin_codper )
                AND pr.situac = 'S'
            ORDER BY
                pc.numpla,
                p.apepat,
                p.apemat,
                p.nombre,
                co.ingdes,
                co.codcon;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_buscar_qui;

    FUNCTION sp_detalle_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_liq
        PIPELINED
    AS
        v_table datatable_detalle_liq;
    BEGIN
        SELECT
            pa.codper,
            pa.finicio,
            pa.ffinal,
--            floor(months_between(pa.ffinal, pa.finicio) / 12)                                                      AS perliq,
--            floor(months_between(pa.ffinal, pa.finicio) -(floor(months_between(pa.ffinal, pa.finicio) / 12) * 12)) AS mesliq,
--            floor((months_between(pa.ffinal, pa.finicio) - floor(months_between(pa.ffinal, pa.finicio))) * 30) + 1 AS dialiq,
            CASE
                WHEN ddd.anio = 0 THEN
                    NULL
                ELSE
                    ddd.anio
            END,
            CASE
                WHEN ddd.mes = 0 THEN
                    NULL
                ELSE
                    ddd.mes
            END,
            CASE
                WHEN ddd.dia = 0 THEN
                    NULL
                ELSE
                    ddd.dia
            END,
            0          AS totliq,
            ccp.codigo AS codmod,
            ccp.descri AS desmod,
            0          AS deposito
        BULK COLLECT
        INTO v_table
        FROM
            planilla_auxiliar                                                 pa
            LEFT OUTER JOIN pack_hr_function_general.sp_fun_ymd_fechas(pa.finicio, pa.ffinal) ddd ON 0 = 0
            LEFT OUTER JOIN personal_clase                                                    pc17 ON pc17.id_cia = pa.id_cia
                                                   AND pc17.codper = pa.codper
                                                   AND pc17.clase = 17
            LEFT OUTER JOIN clase_codigo_personal                                             ccp ON ccp.id_cia = pc17.id_cia
                                                         AND ccp.clase = pc17.clase
                                                         AND ccp.codigo = pc17.codigo
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.numpla = pin_numpla
            AND ( pin_codper IS NULL
                  OR pa.codper = pin_codper );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_liq;

    FUNCTION sp_observ_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_observ_liq
        PIPELINED
    AS

        v_rec    datarecord_observ_liq;
        v_razsoc VARCHAR2(500 CHAR);
        v_nomper VARCHAR2(500 CHAR);
        v_nrodoc VARCHAR2(100 CHAR);
        v_desdoc VARCHAR2(100 CHAR);
        v_totnet NUMBER(15, 4);
    BEGIN
        SELECT
            c.razsoc,
            ( p.apepat
              || ' '
              || p.apemat
              || ' '
              || p.nombre )                   AS nomper,
            nvl(pcp14.abrevi, pcp14.descri) AS desdoc,
            pd3.nrodoc,
            pr.totnet
        INTO
            v_razsoc,
            v_nomper,
            v_desdoc,
            v_nrodoc,
            v_totnet
        FROM
            companias             c
            LEFT OUTER JOIN personal              p ON p.id_cia = c.cia
                                          AND p.codper = pin_codper
            LEFT OUTER JOIN personal_documento    pd3 ON pd3.id_cia = p.id_cia
                                                      AND pd3.codper = p.codper
                                                      AND pd3.codtip = 'DO'
                                                      AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
            LEFT OUTER JOIN clase_codigo_personal pcp14 ON pcp14.id_cia = p.id_cia
                                                           AND pcp14.clase = pd3.clase
                                                           AND pcp14.codigo = pd3.codigo
            LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = p.id_cia
                                                   AND pr.numpla = pin_numpla
                                                   AND pr.codper = p.codper
                                                   AND pr.situac = 'S'
        WHERE
                c.cia = pin_id_cia
            AND p.codper = pin_codper;

        v_rec.observ := 'Yo, '
                        || v_nomper
                        || ' identificado con '
                        || upper(v_desdoc)
                        || ' '
                        || v_nrodoc
                        || ' he recibido de '
                        || v_razsoc
                        || ', la cantidad de '
                        || to_char(round(v_totnet, 2))
                        || ' ('
                        || pack_ayuda_general.sp_number_text(trunc(v_totnet))
                        || '- '
                        || pack_ayuda_general.sp_decimal2_text(v_totnet)
                        || ' SOLES'
                        || ') por concepto de : BENEFICIOS SOCIALES no adeudando la empresa importe alguno.'
                        || chr(13)
                        || 'Firmo la presente en señal de conformidad.';

        PIPE ROW ( v_rec );
    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    FUNCTION sp_buscar_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar_liq
        PIPELINED
    AS
        v_table  datatable_buscar_liq;
        v_iopc   NUMBER := 0;
        pin_iopc NUMBER := 0;
    BEGIN
        IF ( v_iopc IS NULL OR ( v_iopc <= 0 ) ) THEN
            v_iopc := 1;
        ELSE
            v_iopc := pin_iopc;
        END IF;

        FOR i IN 1..v_iopc LOOP
            SELECT
                p.id_cia,
                1,
                emp.nomcom,
                emp.ruc,
                'FALTA'           AS nomder,
                'FALTA'           AS nompro,
                emp.distri        AS nomdis,
                nvl(emp.direcc, emp.dircom),
                pl.anopla,
                pl.mespla,
                to_char(pl.fecini, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
                pl.tippla,
                tpl.nombre        AS destippla,
                pl.empobr,
                ttp.nombre        AS desempobr,
                pl.fecini,
                pl.fecfin,
                p.codper,
                ( p.apepat
                  || ' '
                  || p.apemat
                  || ', '
                  || p.nombre )     AS nomper,
                p.apepat,
                p.apemat,
                p.nombre,
                pd3.nrodoc        AS numdni,
                tcc.descco        AS nomcco,
                ca.nombre         AS nomcar,
                prl.finicio       AS fecing,
                prl.ffinal        AS fecces,
                pd1.nrodoc        AS carips,
                a.nombre          AS nomafp,
                pd2.nrodoc        AS carafp,
                CASE
                    WHEN co.idliq = 'D' THEN
                        'C'
                    ELSE
                        co.idliq
                END               AS idliq,
                ccc.didliq        AS didliq,
                pc.codcon,
                co.abrevi,
                ccc.rotulo        AS descon,
                pc.valcon,
                nvl(psp.saldo, 0) AS salpre,
                co.conrel,
                dd.perliq,
                dd.mesliq,
                dd.dialiq,
                dd.totliq,
                dd.codmot,
                dd.desmot,
                dd.deposito,
                plc.valcon,
                p.codafp,
                0                 AS porfac,
                0                 AS porafp,
                con.nombre        AS nomsba,
                pcp14.descri      AS nomeps,
                pd4.nrodoc        AS perconf
            BULK COLLECT
            INTO v_table
            FROM
                planilla                                                                                pl
                LEFT OUTER JOIN tipoplanilla                                                                            tpl ON tpl.id_cia = pl.id_cia
                                                    AND tpl.tippla = pl.tippla
                LEFT OUTER JOIN tipo_trabajador                                                                         ttp ON ttp.id_cia = pl.id_cia
                                                       AND ttp.tiptra = pl.empobr
                LEFT OUTER JOIN companias                                                                               emp ON emp.cia = pl.id_cia
                LEFT OUTER JOIN planilla_resumen                                                                        pr ON pr.id_cia = pl.id_cia
                                                       AND pr.numpla = pl.numpla
                LEFT OUTER JOIN planilla_auxiliar                                                                       prl ON prl.id_cia = pr.id_cia
                                                         AND prl.numpla = pr.numpla
                                                         AND prl.codper = pr.codper
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_liq(pr.id_cia, pr.numpla, pr.codper)                 dd ON 0 = 0
                LEFT OUTER JOIN planilla_saldoprestamo                                                                  psp ON psp.id_cia = pr.id_cia
                                                              AND psp.numpla = pr.numpla
                                                              AND psp.codper = pr.codper
                LEFT OUTER JOIN tipoplanilla_concepto                                                                   tc ON tc.id_cia = pl.id_cia
                                                            AND tc.tippla = pl.tippla
                LEFT OUTER JOIN planilla_concepto                                                                       pc ON pc.id_cia = pr.id_cia
                                                        AND pc.numpla = pr.numpla
                                                        AND pc.codper = pr.codper
                                                        AND pc.codcon = tc.codcon
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_concepto(pc.id_cia, pc.numpla, pc.codper, pc.codcon) ccc ON 0 = 0
                LEFT OUTER JOIN personal                                                                                p ON p.id_cia = pc.id_cia
                                              AND pc.codper = p.codper
                LEFT OUTER JOIN concepto                                                                                co ON co.id_cia = pc.id_cia
                                               AND pc.codcon = co.codcon
                LEFT OUTER JOIN pack_hr_concepto.sp_buscar_idliq ( pl.id_cia )                                          ccc ON ccc.idliq = CASE
                                                                                                      WHEN co.idliq = 'D' THEN
                                                                                                          'C'
                                                                                                      ELSE
                                                                                                          co.idliq
                                                                                                  END
                LEFT OUTER JOIN pack_hr_planilla_boleta.sp_detalle_tcc(p.id_cia, p.codper)                              tcc ON 0 = 0
                LEFT OUTER JOIN personal_documento                                                                      pd1 ON pd1.id_cia = p.id_cia
                                                          AND p.codper = pd1.codper
                                                          AND pd1.codtip = 'DO'
                                                          AND pd1.codite = 204 /*CARNE DE SEGURO*/
                LEFT OUTER JOIN personal_documento                                                                      pd2 ON pd2.id_cia = p.id_cia
                                                          AND p.codper = pd2.codper
                                                          AND pd2.codtip = 'DO'
                                                          AND pd2.codite = 205 /*CUSS AFP*/
                LEFT OUTER JOIN personal_documento                                                                      pd3 ON pd3.id_cia = p.id_cia
                                                          AND p.codper = pd3.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN personal_documento                                                                      pd4 ON pd4.id_cia = p.id_cia
                                                          AND p.codper = pd4.codper
                                                          AND pd4.codtip = 'DO'
                                                          AND pd4.codite = 206 /*PERSONAL DE CONFIANZA*/
                LEFT OUTER JOIN afp                                                                                     a ON a.id_cia = pc.id_cia
                                         AND p.codafp = a.codafp
                LEFT OUTER JOIN cargo                                                                                   ca ON ca.id_cia = pc.id_cia
                                            AND ca.codcar = p.codcar
                LEFT OUTER JOIN planilla_concepto                                                                       plc ON plc.id_cia = pc.id_cia
                                                         AND p.codper = plc.codper
                                                         AND plc.codcon IN ( '001', '501' )
                                                         AND plc.numpla = pc.numpla
                LEFT OUTER JOIN concepto                                                                                con ON con.id_cia = pc.id_cia
                                                AND con.codcon IN ( '001', '501' )
                                                AND con.empobr = co.empobr  /*001 INGRESO MENSUAL ; 501 NGRESO SEMANAL*/
                LEFT OUTER JOIN personal_clase                                                                          pc14 ON pc14.id_cia = p.id_cia
                                                       AND pc14.codper = p.codper
                                                       AND pc14.clase = 14
                LEFT OUTER JOIN clase_codigo_personal                                                                   pcp14 ON pcp14.id_cia = p.id_cia
                                                               AND pcp14.clase = 14
                                                               AND pcp14.codigo = pc14.codigo
            WHERE
                    p.id_cia = pin_id_cia
                AND co.idliq IN ( 'A', 'B', 'C', 'D', 'E' )
                AND pc.valcon <> 0
                AND pc.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pr.codper = pin_codper )
                AND pr.situac = 'S'
            ORDER BY
                pc.numpla,
                p.apepat,
                p.apemat,
                p.nombre,
                co.idliq,
                co.codcon;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_buscar_liq;

    FUNCTION sp_detalle_tcc (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_tcc
        PIPELINED
    AS
        v_table datatable_detalle_tcc;
--    v_prcdis personal_ccosto.prcdis%TYPE;
    BEGIN
        SELECT
            tc.codigo,
            tc.descri AS descco,
            nvl(pc.prcdis, 0)
        BULK COLLECT
        INTO v_table
        FROM
            personal_ccosto pc
            LEFT OUTER JOIN tccostos        tc ON tc.id_cia = pc.id_cia
                                           AND tc.codigo = pc.codcco
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
            AND pc.prcdis IS NOT NULL
        ORDER BY
            pc.prcdis DESC
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_tcc;

END;

/
