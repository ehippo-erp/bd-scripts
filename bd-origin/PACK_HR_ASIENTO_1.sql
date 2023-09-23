--------------------------------------------------------
--  DDL for Package Body PACK_HR_ASIENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_ASIENTO" AS

    FUNCTION sp_reporte_pdf (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT
    ) RETURN datatable_reporte_pdf
        PIPELINED
    AS
        v_table datatable_reporte_pdf;
    BEGIN
        SELECT
            ppp.*
        BULK COLLECT
        INTO v_table
        FROM
            pack_hr_asiento.sp_reporte_pdf_auxiliar(pin_id_cia, pin_tiptra, pin_periodo, pin_mes) ppp
        ORDER BY
            ppp.dh,
            ppp.cuenta,
            ppp.nomper,
            ppp.ctacco;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_pdf;

    FUNCTION sp_reporte_pdf_auxiliar (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT
    ) RETURN datatable_reporte_pdf
        PIPELINED
    AS

        v_rec       datarecord_reporte_pdf;
        v_date      DATE := trunc(current_timestamp);
        v_compra    NUMBER(4, 2) := 0;
        v_venta     NUMBER(4, 2) := 0;
        v_opasiento NUMBER := 0;
        v_aux1      VARCHAR2(2 CHAR);
        v_aux2      VARCHAR2(2 CHAR);
    BEGIN
        v_rec.rotulo := 'POR DEFINIR';
        BEGIN
            SELECT
                round(compra, 2),
                round(venta, 2)
            INTO
                v_compra,
                v_venta
            FROM
                tcambio
            WHERE
                    id_cia = pin_id_cia
                AND fecha = v_date
                AND moneda = 'PEN'
                AND hmoneda = 'USD';

            SELECT
                valfa1
            INTO v_opasiento
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '422';

            FOR i IN (
                SELECT
                    ppp.codper,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre                  AS nomper,
                    ppp.codcon,
                    ppp.nomcon,
                    ppp.cuenta,
                    ppp.codcco,
                    ppp.dh,
                    SUM(round(ppp.totcon, 2))    AS totcon,
                    SUM(round(ppp.importemn, 2)) AS importemn,
                    SUM(round(ppp.importeme, 2)) AS importeme,
                    SUM(round(ppp.debemn, 2))    AS debemn,
                    SUM(round(ppp.debeme, 2))    AS debeme,
                    SUM(round(ppp.habermn, 2))   AS habermn,
                    SUM(round(ppp.haberme, 2))   AS haberme
                FROM
                    pack_hr_asiento.sp_genera(pin_id_cia, pin_tiptra, pin_periodo, pin_mes, v_venta,
                                              0) ppp
                    LEFT OUTER JOIN personal                     p ON p.id_cia = pin_id_cia
                                                  AND p.codper = ppp.codper
                GROUP BY
                    ppp.codper,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre,
                    ppp.codcon,
                    ppp.nomcon,
                    ppp.cuenta,
                    ppp.codcco,
                    ppp.dh
            ) LOOP
                v_rec.id_cia := pin_id_cia;
                v_rec.codper := i.codper;
                v_rec.nomper := i.nomper;
                v_rec.codcon := i.codcon;
                v_rec.nomcon := i.nomcon;
                v_rec.cuenta := i.cuenta;
                v_rec.subcco := i.codper;
                v_rec.codcco := i.codcco;
                v_rec.prcdis := NULL;
                v_rec.dh := i.dh;
                v_rec.totcon := i.totcon;
                v_rec.tipcam := v_venta;
                v_rec.importemn := i.importemn;
                v_rec.importeme := i.importeme;
                v_rec.debemn := i.debemn;
                v_rec.debeme := i.debeme;
                v_rec.habermn := i.habermn;
                v_rec.haberme := i.haberme;
                IF nvl(v_opasiento, 0) = 0 THEN
                    v_aux1 := substr(i.cuenta, 1, 1);
                    v_aux2 := '6';
                ELSIF nvl(v_opasiento, 0) = 1 THEN
                    v_aux1 := substr(i.cuenta, 1, 2);
                    v_aux2 := '34';
                END IF;

                IF v_aux1 = v_aux2 THEN
                    BEGIN
                        SELECT
                            destin
                        INTO v_rec.ctacco
                        FROM
                            tccostos
                        WHERE
                                id_cia = pin_id_cia
                            AND codigo = i.codcco;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_rec.ctacco := NULL;
                    END;
                END IF;

                IF
                    substr(i.cuenta, 1, 2) = '40'
                    AND i.codper IS NULL
                THEN
                    BEGIN
                        SELECT
                            codcta
                        INTO v_rec.subcco
                        FROM
                            afp
                        WHERE
                                id_cia = pin_id_cia
                            AND codcta = i.cuenta;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_rec.subcco := NULL;
                    END;
                END IF;

                PIPE ROW ( v_rec );
            END LOOP;

        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

    END sp_reporte_pdf_auxiliar;

    FUNCTION sp_reporte_excel (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo SMALLINT,
        pin_mes     SMALLINT,
        pin_opc     INTEGER
    ) RETURN datatable_reporte_excel
        PIPELINED
    AS

        v_rec       datarecord_reporte_excel;
        v_date      DATE := trunc(current_timestamp);
        v_compra    NUMBER(4, 2) := 0;
        v_venta     NUMBER(4, 2) := 0;
        v_opasiento NUMBER := 0;
        v_aux1      VARCHAR2(2 CHAR);
        v_aux2      VARCHAR2(2 CHAR);
    BEGIN
        v_rec.rotulo := 'POR DEFINIR';
        BEGIN
            SELECT
                valfa1
            INTO v_opasiento
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '422';

            FOR i IN (
                SELECT
                    ss.codper,
                    ( p.apepat
                      || ' '
                      || p.apemat
                      || ' '
                      || p.nombre )            AS nomper,
                    ss.codcon,
                    ss.nomcon,
                    ss.cuenta,
                    ss.codcco,
                    ss.dh,
                    SUM(round(ss.totcon, 2)) AS totcon
                FROM
                    pack_hr_asiento.sp_genera(pin_id_cia, pin_tiptra, pin_periodo, pin_mes, 3.99,
                                              pin_opc) ss
                    LEFT OUTER JOIN personal                           p ON p.id_cia = pin_id_cia
                                                  AND p.codper = ss.codper
                GROUP BY
                    ss.codper,
                    (
                        p.apepat
                        || ' '
                        || p.apemat
                        || ' '
                        || p.nombre
                    ),
                    ss.codcon,
                    ss.nomcon,
                    ss.cuenta,
                    ss.codcco,
                    ss.dh
            ) LOOP
                v_rec.id_cia := pin_id_cia;
                v_rec.cuenta := i.cuenta;
                v_rec.dh := i.dh;
                v_rec.concepto := i.nomcon;
                v_rec.codmon := 'PEN';
                v_rec.importe := i.totcon;
                IF v_rec.dh = 'D' THEN
                    v_rec.codcco := i.codcco;
                    v_rec.subcco := i.codper; -- SUB CENTRO DE COSTO
                ELSE
                    v_rec.codcco := NULL;
                    v_rec.subcco := NULL;
                END IF;

                v_rec.proyect := NULL;
                v_rec.codcli := i.codper;
                v_rec.razonc := i.nomper;
                v_rec.tident := NULL;
                v_rec.nrodoc := NULL;
                v_rec.tipdoc := NULL;
                v_rec.serie := 'PLA';
                v_rec.numdoc := to_char(pin_periodo * 100 + pin_mes);
                v_rec.femisi := NULL;
                v_rec.ctaalt := NULL;
                v_rec.tiprelcxp := 0;
                v_rec.docrelcxp := 0;
                IF nvl(v_opasiento, 0) = 0 THEN
                    v_aux1 := substr(i.cuenta, 1, 1);
                    v_aux2 := '6';
                ELSIF nvl(v_opasiento, 0) = 1 THEN
                    v_aux1 := substr(i.cuenta, 1, 2);
                    v_aux2 := '34';
                END IF;

--                IF v_aux1 = v_aux2 THEN
--                    BEGIN
--                        SELECT
--                            destin
--                        INTO v_rec.codcco
--                        FROM
--                            tccostos
--                        WHERE
--                                id_cia = pin_id_cia
--                            AND codigo = i.codcco;
--
--                    EXCEPTION
--                        WHEN no_data_found THEN
--                            v_rec.codcco := NULL;
--                    END;
--                END IF;

--                IF
--                    substr(i.cuenta, 1, 2) = '40'
--                    AND i.codper IS NULL
--                THEN
--                    BEGIN
--                        SELECT
--                            codcta
--                        INTO v_rec.subcco
--                        FROM
--                            afp
--                        WHERE
--                                id_cia = pin_id_cia
--                            AND codcta = i.cuenta;
--
--                    EXCEPTION
--                        WHEN no_data_found THEN
--                            v_rec.subcco := NULL;
--                    END;
--                END IF;

                PIPE ROW ( v_rec );
            END LOOP;

        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

    END sp_reporte_excel;

    FUNCTION sp_genera (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipcam  NUMBER,
        pin_opc     INTEGER
    ) RETURN datatable_asiento
        PIPELINED
    AS

        v_agrupa    VARCHAR2(1);
        v_ingdes    VARCHAR2(1);
        v_valcon    NUMBER(16, 4);
        v_acumula   NUMBER(16, 4);
        v_sumpor    NUMBER(16, 4);
        v_totcon    NUMBER(16, 4);
        v_nomcon    VARCHAR(40); --q
        v_cuenta    VARCHAR(15);--q
        v_vacxclase NUMERIC(15, 4);
        v_graxclase NUMERIC(15, 4);
        v_numpla    INTEGER;--q
        v_ingre     NUMERIC(15, 4);
        v_descu     NUMERIC(15, 4);
        v_aporte    NUMERIC(15, 4);
        v_monvac    NUMERIC(15, 4);
        v_mongra    NUMERIC(15, 4);
        v_table     datatable_asiento;
        v_rec       datarecord_asiento := datarecord_asiento(NULL, NULL, NULL, NULL, NULL,
                                                      NULL, 0, 0, 0, 0,
                                                      0, 0, 0, 0);
    BEGIN
        -- Vacaciones por clase
        BEGIN
            SELECT
                valfa1
            INTO v_vacxclase
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '701';

        EXCEPTION
            WHEN no_data_found THEN
                v_vacxclase := 0;
        END;
        
        -- Gratificaciones por clase
        BEGIN
            SELECT
                valfa1
            INTO v_graxclase
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '702';

        EXCEPTION
            WHEN no_data_found THEN
                v_graxclase := 0;
        END;

        IF pin_opc = 0 OR pin_opc = 1 THEN
            FOR i IN (
                SELECT
                    pc.codper,
                    pc.codcon,
                    c.nombre   AS nomcon,
                    ccc.codcta AS cuenta,
                    c.dh,
                    c.agrupa,
                    c.ingdes,
                    pc.valcon
                FROM
                         planilla_concepto pc
                    INNER JOIN planilla                                                                    pl ON pl.id_cia = pc.id_cia
                                              AND pl.numpla = pc.numpla
                    INNER JOIN concepto                                                                    c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                                             AND c.empobr = pl.empobr
                    INNER JOIN tipoplanilla_concepto                                                       tc ON tc.id_cia = pc.id_cia
                                                           AND tc.codcon = pc.codcon
                                                           AND tc.tippla = pl.tippla
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, pl.empobr, pl.tippla) ccc ON 0 = 0
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pl.anopla = pin_periodo
                    AND pl.mespla = pin_mes
                    AND pl.empobr = pin_tiptra
                    AND pl.tippla NOT IN ( 'X', 'Y', 'Z', 'L' )
                    AND c.ingdes IN ( 'A', 'B', 'D' )
                    AND pc.valcon <> 0
                    AND pc.situac IN ( 'S' )
                UNION ALL
                SELECT
                    NULL                                           AS codper,
                    decode(c.codpdt, '0605', c.codcon, NULL)       AS codcon,
                    decode(c.codpdt, '0605', c.nombre, a.nombre)   AS nomcon,
                    decode(c.codpdt, '0605', ccc.codcta, a.codcta) AS cuenta,
                    c.dh,
                    c.agrupa,
                    c.ingdes,
                    SUM(nvl(pc.valcon, 0))                         AS valcon
                FROM
                         planilla_concepto pc
                    INNER JOIN planilla                                                                    pl ON pl.id_cia = pc.id_cia
                                              AND pl.numpla = pc.numpla
                    INNER JOIN concepto                                                                    c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                                             AND c.empobr = pl.empobr
                    INNER JOIN tipoplanilla_concepto                                                       tc ON tc.id_cia = pc.id_cia
                                                           AND tc.codcon = pc.codcon
                                                           AND tc.tippla = pl.tippla
                    INNER JOIN personal                                                                    p ON p.id_cia = pc.id_cia
                                             AND p.codper = pc.codper
                    INNER JOIN afp                                                                         a ON a.id_cia = pc.id_cia
                                        AND a.codafp = p.codafp
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, pl.empobr, pl.tippla) ccc ON 0 = 0
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pl.anopla = pin_periodo
                    AND pl.mespla = pin_mes
                    AND pl.empobr = pin_tiptra
                    AND pl.tippla IN ( 'N', 'V', 'P' )
                    AND c.ingdes IN ( 'C' )
                    AND pc.valcon <> 0
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    NULL,
                    decode(c.codpdt, '0605', c.codcon, NULL),
                    decode(c.codpdt, '0605', c.nombre, a.nombre),
                    decode(c.codpdt, '0605', ccc.codcta, a.codcta),
                    c.dh,
                    c.agrupa,
                    c.ingdes
            ) LOOP
                v_rec.codper := i.codper;
                v_rec.codcon := i.codcon;
                v_rec.nomcon := i.nomcon;
                v_rec.cuenta := i.cuenta;
                v_rec.dh := i.dh;
                v_rec.totcon := i.valcon;
                IF i.codcon IS NULL THEN
                    v_sumpor := 0;
                    v_acumula := 0;
                    v_rec.importemn := i.valcon;
                    v_rec.importeme := ( i.valcon / pin_tipcam );
                    IF i.dh = 'D' THEN
                        v_rec.debemn := i.valcon;
                        v_rec.debeme := ( i.valcon / pin_tipcam );
                        v_rec.habermn := 0.00;
                        v_rec.haberme := 0.00;
                    ELSIF i.dh = 'H' THEN
                        v_rec.habermn := i.valcon;
                        v_rec.haberme := ( i.valcon / pin_tipcam );
                        v_rec.debemn := 0.00;
                        v_rec.debeme := 0.00;
                    END IF;

                    PIPE ROW ( v_rec );
                ELSE
                    IF i.agrupa = 'S' THEN
                        v_sumpor := 0;
                        v_acumula := 0;
                        v_rec.importemn := i.valcon;
                        v_rec.importeme := ( i.valcon / pin_tipcam );
                        IF i.dh = 'D' THEN
                            v_rec.debemn := i.valcon;
                            v_rec.debeme := ( i.valcon / pin_tipcam );
                            v_rec.habermn := 0.00;
                            v_rec.haberme := 0.00;
                        ELSIF i.dh = 'H' THEN
                            v_rec.habermn := i.valcon;
                            v_rec.haberme := ( i.valcon / pin_tipcam );
                            v_rec.debemn := 0.00;
                            v_rec.debeme := 0.00;
                        END IF;

                        PIPE ROW ( v_rec );
                    ELSIF i.agrupa = 'N' THEN
                        IF
                            i.ingdes <> 'A'
                            AND i.ingdes <> 'D'
                        THEN
                            v_sumpor := 0;
                            v_acumula := 0;
                            v_rec.importemn := i.valcon;
                            v_rec.importeme := ( i.valcon / pin_tipcam );
                            IF i.dh = 'D' THEN
                                v_rec.debemn := i.valcon;
                                v_rec.debeme := ( i.valcon / pin_tipcam );
                                v_rec.habermn := 0.00;
                                v_rec.haberme := 0.00;
                            ELSIF i.dh = 'H' THEN
                                v_rec.habermn := i.valcon;
                                v_rec.haberme := ( i.valcon / pin_tipcam );
                                v_rec.debemn := 0.00;
                                v_rec.debeme := 0.00;
                            END IF;

                            PIPE ROW ( v_rec );
                        ELSE
                            v_sumpor := 0;
                            v_acumula := 0;
                            v_rec.totcon := 0;
                            FOR j IN (
                                SELECT
                                    codcco,
                                    nvl(prcdis, 100) / 100 AS prcdis
                                FROM
                                    personal_ccosto
                                WHERE
                                        id_cia = pin_id_cia
                                    AND codper = i.codper
                            ) LOOP
                                v_rec.codcco := j.codcco;
                                v_rec.prcdis := j.prcdis;
                                IF j.prcdis = 1 THEN
                                    v_rec.totcon := i.valcon;
                                ELSE
                                    v_sumpor := v_sumpor + j.prcdis;
                                    IF v_sumpor < 1 THEN
                                        v_rec.totcon := ROUND(i.valcon * j.prcdis,2);
                                        v_acumula := v_acumula + v_rec.totcon;
                                    ELSIF v_sumpor >= 1 THEN
                                        v_rec.totcon := i.valcon - v_acumula;
                                    END IF;

                                END IF;

                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                IF i.dh = 'D' THEN
                                    v_rec.debemn := v_rec.totcon;
                                    v_rec.debeme := ( v_rec.totcon / pin_tipcam );
                                    v_rec.habermn := 0.00;
                                    v_rec.haberme := 0.00;
                                ELSIF i.dh = 'H' THEN
                                    v_rec.habermn := v_rec.totcon;
                                    v_rec.haberme := ( v_rec.totcon / pin_tipcam );
                                    v_rec.debemn := 0.00;
                                    v_rec.debeme := 0.00;
                                END IF;

                                PIPE ROW ( v_rec );
                            END LOOP;

                        END IF;
                    END IF;
                END IF;

            END LOOP;
        END IF;
--------------------------------------
/* CUENTA 41 */
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            pack_hr_asiento.sp_genera_cuenta41(pin_id_cia, pin_tiptra, pin_periodo, pin_mes, pin_tipcam,
                                               pin_opc);

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;
--------------------------------------
/*LINEAS ABAJO SE OBTINE LA CUENTA 40 CORRESPONDIENTE A ESSALUD SIEMPRE DEBE IR AL HABER Y EN LA
    CONFIGURACION DEL CONCEPTO DEBE IR AL DEBE ,LA CUEENTA GASTO DEBE TERNER LA 40 Y CTA CONTABLE 62*/ -- ESALUD
        FOR k IN (
            SELECT
                codcon,
                nomcon,
                cuenta,
                SUM(nvl(totcon, 0)) AS totcon
            FROM
                pack_hr_funcion_contable.sp_concepto_gasto(pin_id_cia, pin_periodo, pin_mes, pin_tiptra, pin_opc)
            GROUP BY
                codcon,
                nomcon,
                cuenta
        ) LOOP
            v_rec.codper := NULL;
            v_rec.codcon := k.codcon;
            v_rec.nomcon := k.nomcon;
            v_rec.cuenta := k.cuenta;
            v_rec.dh := 'H';
            v_rec.totcon := k.totcon;
            v_rec.importemn := v_rec.totcon;
            v_rec.importeme := ( v_rec.totcon / pin_tipcam );
            v_rec.debemn := 0.00;
            v_rec.debeme := 0.00;
            v_rec.habermn := v_rec.totcon;
            v_rec.haberme := ( v_rec.totcon / pin_tipcam );
            PIPE ROW ( v_rec );
        END LOOP;

        IF pin_opc = 0 OR pin_opc = 2 THEN
        -- PLANILLA DE LIQUIDACION
            FOR i IN (
                SELECT
                    NULL           AS codper,
                    ccc.codcta     AS cuenta,
                    c.agrupa,
                    pc.codcon,
                    c.nombre       AS nomcon,
                    c.dh,
                    SUM(pc.valcon) AS valcon
                FROM
                         planilla p
                    INNER JOIN planilla_concepto                                                         pc ON pc.id_cia = p.id_cia
                                                       AND pc.numpla = p.numpla
                    INNER JOIN concepto                                                                  c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                    INNER JOIN tipoplanilla_concepto                                                     tc ON tc.id_cia = pin_id_cia
                                                           AND tc.codcon = pc.codcon
                                                           AND tc.tippla = 'L'
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, p.empobr, p.tippla) ccc ON 0 = 0
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.anopla = pin_periodo
                    AND p.mespla = pin_mes
                    AND p.empobr = pin_tiptra
                    AND p.tippla = 'L'
                    AND c.idliq IN ( 'B', 'C', 'D', 'E' )
                    AND c.indprc = '6'
                    AND pc.valcon <> 0
                    AND c.agrupa = 'S'
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    pc.codper,
                    ccc.codcta,
                    c.agrupa,
                    pc.codcon,
                    c.nombre,
                    c.dh
                UNION ALL
                SELECT
                    pc.codper,
                    ccc.codcta     AS cuenta,
                    c.agrupa,
                    pc.codcon,
                    c.nombre       AS nomcon,
                    c.dh,
                    SUM(pc.valcon) AS valcon
                FROM
                         planilla p
                    INNER JOIN planilla_concepto                                                         pc ON pc.id_cia = p.id_cia
                                                       AND pc.numpla = p.numpla
                    INNER JOIN concepto                                                                  c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                    INNER JOIN tipoplanilla_concepto                                                     tc ON tc.id_cia = pin_id_cia
                                                           AND tc.codcon = pc.codcon
                                                           AND tc.tippla = 'L'
                    INNER JOIN pack_hr_concepto_formula.sp_ayuda(c.id_cia, c.codcon, p.empobr, p.tippla) ccc ON 0 = 0
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.anopla = pin_periodo
                    AND p.mespla = pin_mes
                    AND p.empobr = pin_tiptra
                    AND p.tippla = 'L'
                    AND c.idliq IN ( 'B', 'C', 'D', 'E' )
                    AND c.indprc = '6'
                    AND pc.valcon <> 0
                    AND c.agrupa = 'N'
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    pc.codper,
                    ccc.codcta,
                    c.agrupa,
                    pc.codcon,
                    c.nombre,
                    c.dh
                UNION ALL
                SELECT
                    NULL           AS codper,
                    a.codcta       AS cuenta,
                    NULL           AS agrupa,
                    NULL           AS codcon,
                    a.nombre       AS nomcon,
                    c.dh,
                    SUM(pc.valcon) AS valcon
                FROM
                         planilla p
                    INNER JOIN planilla_afp          pa ON pa.id_cia = p.id_cia
                                                  AND pa.numpla = p.numpla
                    INNER JOIN planilla_concepto     pc ON pc.id_cia = pa.id_cia
                                                       AND pc.numpla = pa.numpla
                                                       AND pc.codper = pa.codper
                    INNER JOIN concepto              c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                    INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = pc.id_cia
                                                           AND tc.codcon = pc.codcon
                                                           AND tc.tippla = 'L'
                    INNER JOIN afp                   a ON a.id_cia = pa.id_cia
                                        AND a.codafp = pa.codafp
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.anopla = pin_periodo
                    AND p.mespla = pin_mes
                    AND p.empobr = pin_tiptra
                    AND p.tippla = 'L'
                    AND c.idliq IN ( 'B', 'C', 'D', 'E' )
                    AND c.indprc = '2'
                    AND pc.valcon <> 0
                    AND pc.situac IN ( 'S' )
                GROUP BY
                    NULL,
                    a.codcta,
                    a.nombre,
                    c.dh
            ) LOOP
                v_rec.codper := i.codper;
                v_rec.codcon := i.codcon;
                v_rec.nomcon := i.nomcon;
                v_rec.cuenta := i.cuenta;
                v_rec.dh := i.dh;
                v_rec.totcon := i.valcon;
                IF i.codcon IS NULL THEN
                    v_sumpor := 0;
                    v_acumula := 0;
                    v_rec.importemn := i.valcon;
                    v_rec.importeme := ( i.valcon / pin_tipcam );
                    IF i.dh = 'D' THEN
                        v_rec.debemn := i.valcon;
                        v_rec.debeme := ( i.valcon / pin_tipcam );
                        v_rec.habermn := 0.00;
                        v_rec.haberme := 0.00;
                    ELSIF i.dh = 'H' THEN
                        v_rec.habermn := i.valcon;
                        v_rec.haberme := ( i.valcon / pin_tipcam );
                        v_rec.debemn := 0.00;
                        v_rec.debeme := 0.00;
                    END IF;

                    PIPE ROW ( v_rec );
                ELSE
                    IF i.agrupa = 'S' THEN
                        v_sumpor := 0;
                        v_acumula := 0;
                        v_rec.importemn := i.valcon;
                        v_rec.importeme := ( i.valcon / pin_tipcam );
                        IF i.dh = 'D' THEN
                            v_rec.debemn := i.valcon;
                            v_rec.debeme := ( i.valcon / pin_tipcam );
                            v_rec.habermn := 0.00;
                            v_rec.haberme := 0.00;
                        ELSIF i.dh = 'H' THEN
                            v_rec.habermn := i.valcon;
                            v_rec.haberme := ( i.valcon / pin_tipcam );
                            v_rec.debemn := 0.00;
                            v_rec.debeme := 0.00;
                        END IF;

                        PIPE ROW ( v_rec );
                    ELSIF i.agrupa = 'N' THEN
                        v_sumpor := 0;
                        v_acumula := 0;
                        v_rec.totcon := 0;
                        FOR j IN (
                            SELECT
                                codcco,
                                nvl(prcdis, 100) / 100 AS prcdis
                            FROM
                                personal_ccosto
                            WHERE
                                    id_cia = pin_id_cia
                                AND codper = i.codper
                        ) LOOP
                            v_rec.codcco := j.codcco;
                            v_rec.prcdis := j.prcdis;
                            IF j.prcdis = 1 THEN
                                v_rec.totcon := i.valcon;
                            ELSE
                                v_sumpor := v_sumpor + j.prcdis;
                                IF v_sumpor < 1 THEN
                                    v_rec.totcon := i.valcon * j.prcdis;
                                    v_acumula := v_acumula + v_rec.totcon;
                                ELSIF v_sumpor >= 1 THEN
                                    v_rec.totcon := i.valcon - v_acumula;
                                END IF;

                            END IF;

                            v_rec.importemn := v_rec.totcon;
                            v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                            IF i.dh = 'D' THEN
                                v_rec.debemn := v_rec.totcon;
                                v_rec.debeme := ( v_rec.totcon / pin_tipcam );
                                v_rec.habermn := 0.00;
                                v_rec.haberme := 0.00;
                            ELSIF i.dh = 'H' THEN
                                v_rec.habermn := v_rec.totcon;
                                v_rec.haberme := ( v_rec.totcon / pin_tipcam );
                                v_rec.debemn := 0.00;
                                v_rec.debeme := 0.00;
                            END IF;

                            PIPE ROW ( v_rec );
                        END LOOP;

                    END IF;
                END IF;

            END LOOP;
        END IF;

    END sp_genera;

    FUNCTION sp_genera_cuenta41 (
        pin_id_cia  NUMBER,
        pin_tiptra  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipcam  NUMBER,
        pin_opc     INTEGER
    ) RETURN datatable_asiento
        PIPELINED
    AS

        v_rec       datarecord_asiento;
        v_vacxclase NUMERIC(15, 4);
        v_graxclase NUMERIC(15, 4);
        v_ingre     NUMERIC(15, 4);
        v_descu     NUMERIC(15, 4);
        v_total     NUMERIC(15, 4);
        v_monvac    NUMERIC(15, 4);
        v_mongra    NUMERIC(15, 4);
    BEGIN
    
            -- Vacaciones por clase
        BEGIN
            SELECT
                valfa1
            INTO v_vacxclase
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '701';

        EXCEPTION
            WHEN no_data_found THEN
                v_vacxclase := 0;
        END;
        
        -- Gratificaciones por clase
        BEGIN
            SELECT
                valfa1
            INTO v_graxclase
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = '702';

        EXCEPTION
            WHEN no_data_found THEN
                v_graxclase := 0;
        END;

        IF pin_opc = 0 OR pin_opc = 1 THEN
            FOR i IN (
                SELECT
                    p.tippla,
                    p.numpla,
                    t.codcta AS cuenta,
                    t.dh     AS dh,
                    t.nombre AS nomcon,
                    t.agrupa
                FROM
                         planilla p
                    INNER JOIN tipoplanilla t ON t.id_cia = p.id_cia
                                                 AND t.tippla = p.tippla
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.anopla = pin_periodo
                    AND p.mespla = pin_mes
                    AND p.empobr = pin_tiptra
                    AND p.tippla NOT IN ( 'X', 'Y', 'Z', 'L', 'S' )
            ) LOOP
                v_rec.nomcon := i.nomcon;
                v_rec.cuenta := i.cuenta;
                v_rec.dh := i.dh;
                dbms_output.put_line(v_rec.cuenta);
            -- CONCEPTOS AGRUPADOS!
                IF i.agrupa = 'S' THEN
                    IF
                        i.tippla = 'N'
                        AND v_vacxclase = 1
                    THEN
                        v_monvac := 0;
                        BEGIN
                            SELECT
                                cuenta,
                                nomcta,
                                SUM(nvl(valcon, 0))
                            INTO
                                v_rec.cuenta,
                                v_rec.nomcon,
                                v_monvac
                            FROM
                                pack_hr_funcion_contable.sp_buscar_vacaxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                            WHERE
                                valing <> 0
                            GROUP BY
                                cuenta,
                                nomcta;

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_monvac := 0;
                        END;

                        IF v_monvac <> 0 THEN
                            v_rec.totcon := v_monvac;
                            v_rec.habermn := v_monvac;
                            v_rec.haberme := ( v_monvac / pin_tipcam );
                            v_rec.debemn := 0.00;
                            v_rec.debeme := 0.00;
                            v_rec.importemn := v_rec.totcon;
                            v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                            PIPE ROW ( v_rec );
                        END IF;

                        IF
                            i.tippla = 'N'
                            AND v_graxclase = 1
                        THEN
                            v_mongra := 0;
                            BEGIN
                                SELECT
                                    cuenta,
                                    nomcta,
                                    SUM(nvl(valcon, 0))
                                INTO
                                    v_rec.cuenta,
                                    v_rec.nomcon,
                                    v_mongra
                                FROM
                                    pack_hr_funcion_contable.sp_buscar_gratxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                                WHERE
                                    valing <> 0
                                GROUP BY
                                    cuenta,
                                    nomcta;

                            EXCEPTION
                                WHEN no_data_found THEN
                                    v_mongra := 0;
                            END;

                            IF ( v_mongra <> 0 ) THEN
                                v_rec.codcon := NULL;
                                v_rec.totcon := v_mongra;
                                v_rec.habermn := v_mongra;
                                v_rec.haberme := ( v_monvac / pin_tipcam );
                                v_rec.debemn := 0.00;
                                v_rec.debeme := 0.00;
                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                PIPE ROW ( v_rec );
                            END IF;

                        END IF;

                    END IF;
            -- TOTAL DEL ASIENTO, 
            -- RECUPERAMOS VALORS, INGS, Y DESTINO
                    v_mongra := 0;
                    v_monvac := 0;
                    BEGIN
                        SELECT
                            SUM(decode(c.ingdes, 'A', pc.valcon, 0)) AS ingreso,
                            SUM(decode(c.ingdes, 'A', 0, pc.valcon)) AS descuento
                        INTO
                            v_ingre,
                            v_descu
                        FROM
                                 planilla_concepto pc
                            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                     AND c.codcon = pc.codcon
                        WHERE
                                pc.id_cia = pin_id_cia
                            AND pc.numpla = i.numpla
                            AND c.ingdes IN ( 'A', 'B', 'C' )
                            AND pc.situac IN ( 'S' );

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_ingre := 0;
                            v_descu := 0;
                    END;

            -- TOTAL POR VACACION, GRATIFICACION, SI ESTAM EN LA MISMA PLANILLA
                    IF
                        i.tippla = 'N'
                        AND v_vacxclase = 1
                    THEN
                        BEGIN
                            SELECT
                                SUM(nvl(valcon, 0))
                            INTO v_monvac
                            FROM
                                pack_hr_funcion_contable.sp_buscar_vacaxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                            WHERE
                                valing <> 0
                            HAVING
                                SUM(nvl(valcon, 0)) <> 0;

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_monvac := 0;
                        END;
                    END IF;

                    IF
                        i.tippla = 'N'
                        AND v_graxclase = 1
                    THEN
                        BEGIN
                            SELECT
                                SUM(nvl(valcon, 0))
                            INTO v_mongra
                            FROM
                                pack_hr_funcion_contable.sp_buscar_gratxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                            WHERE
                                valing <> 0
                            HAVING
                                SUM(nvl(valcon, 0)) <> 0;

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_mongra := 0;
                        END;
                    END IF;

                    v_rec.codcon := NULL;
                    v_rec.totcon := v_ingre - ( v_descu + nvl(v_monvac, 0) + nvl(v_mongra, 0) );

                    v_rec.habermn := v_rec.totcon;
                    v_rec.haberme := ( v_rec.habermn / pin_tipcam );
                    v_rec.debemn := 0.00;
                    v_rec.debeme := 0.00;
                    v_rec.importemn := v_rec.habermn;
                    v_rec.importeme := ( v_rec.habermn / pin_tipcam );
                    PIPE ROW ( v_rec );
                ELSIF i.agrupa = 'N' THEN
                    FOR k IN (
                        SELECT
                            'V'                 AS tippla,
                            codper,
                            cuenta              AS cuenta,
                            nomcta,
                            SUM(nvl(valcon, 0)) AS mon
                        FROM
                            pack_hr_funcion_contable.sp_buscar_vacaxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                        WHERE
                            valing <> 0
                        GROUP BY
                            'V',
                            codper,
                            cuenta,
                            nomcta
                        HAVING
                            SUM(nvl(valcon, 0)) <> 0
                        UNION ALL
                        SELECT
                            'G'                 AS tippla,
                            codper,
                            cuenta              AS cuenta,
                            nomcta,
                            SUM(nvl(valcon, 0)) AS mon
                        FROM
                            pack_hr_funcion_contable.sp_buscar_gratxclase(pin_id_cia, pin_periodo, pin_mes, pin_tiptra)
                        WHERE
                            valing <> 0
                        GROUP BY
                            'G',
                            codper,
                            cuenta,
                            nomcta
                        HAVING
                            SUM(nvl(valcon, 0)) <> 0
                        UNION ALL
                        SELECT
                            'Z'                                                                                 AS tippla,
                            pc.codper,
                            v_rec.cuenta                                                                        AS cuenta,
                            v_rec.nomcon                                                                        AS nomcta,
                            SUM(decode(c.ingdes, 'A', pc.valcon, 0)) - SUM(decode(c.ingdes, 'A', 0, pc.valcon)) AS mon
                        FROM
                                 planilla_concepto pc
                            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                     AND c.codcon = pc.codcon
                        WHERE
                                pc.id_cia = pin_id_cia
                            AND pc.numpla = i.numpla
                            AND c.ingdes IN ( 'A', 'B', 'C' )
                            AND pc.situac IN ( 'S' )
                        GROUP BY
                            'Z',
                            pc.codper,
                            v_rec.cuenta,
                            v_rec.nomcon
                        ORDER BY
                            codper,
                            tippla
                    ) LOOP
                        IF
                            i.tippla = 'N'
                            AND v_vacxclase = 1
                            AND k.tippla = 'V'
                        THEN
                            v_rec.codper := k.codper;
                            v_rec.nomcon := k.nomcta;
                            v_rec.cuenta := k.cuenta;
                            v_monvac := nvl(k.mon, 0);
                            IF i.dh = 'D' THEN
                                v_rec.codcon := NULL;
                                v_rec.totcon := k.mon;
                                v_rec.habermn := 0.00;
                                v_rec.haberme := 0.00;
                                v_rec.debemn := k.mon;
                                v_rec.debeme := ( k.mon / pin_tipcam );
                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                PIPE ROW ( v_rec );
                            ELSIF i.dh = 'H' THEN
                                v_rec.codcon := NULL;
                                v_rec.totcon := k.mon;
                                v_rec.habermn := k.mon;
                                v_rec.haberme := ( k.mon / pin_tipcam );
                                v_rec.debemn := 0.00;
                                v_rec.debeme := 0.00;
                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                PIPE ROW ( v_rec );
                            END IF;

                        ELSIF
                            i.tippla = 'N'
                            AND v_graxclase = 1
                            AND k.tippla = 'G'
                        THEN
                            v_rec.codper := k.codper;
                            v_rec.nomcon := k.nomcta;
                            v_rec.cuenta := k.cuenta;
                            v_mongra := nvl(k.mon, 0);
                            IF i.dh = 'D' THEN
                                v_rec.codcon := NULL;
                                v_rec.totcon := k.mon;
                                v_rec.habermn := 0.00;
                                v_rec.haberme := 0.00;
                                v_rec.debemn := k.mon;
                                v_rec.debeme := ( k.mon / pin_tipcam );
                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                PIPE ROW ( v_rec );
                            ELSIF i.dh = 'H' THEN
                                v_rec.codcon := NULL;
                                v_rec.totcon := k.mon;
                                v_rec.habermn := k.mon;
                                v_rec.haberme := ( k.mon / pin_tipcam );
                                v_rec.debemn := 0.00;
                                v_rec.debeme := 0.00;
                                v_rec.importemn := v_rec.totcon;
                                v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                                PIPE ROW ( v_rec );
                            END IF;

                        ELSIF k.tippla = 'Z' THEN
                            v_rec.codper := k.codper;
                            v_rec.nomcon := k.nomcta;
                            v_rec.cuenta := k.cuenta;
                            v_rec.codcon := NULL;
                            v_rec.totcon := nvl(k.mon, 0) - ( nvl(v_monvac, 0) + nvl(v_mongra, 0) );

                            v_rec.habermn := v_rec.totcon;
                            v_rec.haberme := ( v_rec.habermn / pin_tipcam );
                            v_rec.debemn := 0.00;
                            v_rec.debeme := 0.00;
                            v_rec.importemn := v_rec.habermn;
                            v_rec.importeme := ( v_rec.habermn / pin_tipcam );
                        -- REINICIANDO IMPORTE
                            v_monvac := 0;
                            v_mongra := 0;
                            PIPE ROW ( v_rec );
                        END IF;
                    END LOOP;
                END IF;

            END LOOP;
        END IF;

        IF pin_opc = 0 OR pin_opc = 2 THEN
            FOR i IN (
                SELECT
                    pl.tippla,
                    pl.numpla,
                    tp.codcta AS cuenta,
                    tp.dh     AS dh,
                    tp.nombre AS nomcon,
                    tp.agrupa
                FROM
                         planilla pl
                    INNER JOIN tipoplanilla tp ON tp.id_cia = pl.id_cia
                                                  AND tp.tippla = pl.tippla
                WHERE
                        pl.id_cia = pin_id_cia
                    AND pl.anopla = pin_periodo
                    AND pl.mespla = pin_mes
                    AND pl.empobr = pin_tiptra
                    AND pl.tippla = 'L'
            ) LOOP
                v_rec.nomcon := i.nomcon;
                v_rec.cuenta := i.cuenta;
                v_rec.dh := i.dh;
                IF i.agrupa = 'S' THEN
                    BEGIN
                        SELECT
                            SUM(decode(c.idliq, 'B', pc.valcon, 0)) AS ingreso,
                            SUM(decode(c.idliq, 'B', 0, pc.valcon)) AS descuento
                        INTO
                            v_ingre,
                            v_descu
                        FROM
                                 planilla_concepto pc
                            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                     AND c.codcon = pc.codcon
                        WHERE
                                pc.id_cia = pin_id_cia
                            AND pc.numpla = i.numpla
                            AND c.idliq IN ( 'B', 'C', 'D' )
                            AND pc.situac IN ( 'S' );

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_ingre := 0;
                            v_descu := 0;
                    END;

                    v_total := v_ingre - v_descu;
                    IF i.dh = 'D' THEN
                        v_rec.codcon := NULL;
                        v_rec.totcon := v_total;
                        v_rec.habermn := 0.00;
                        v_rec.haberme := 0.00;
                        v_rec.debemn := v_rec.totcon;
                        v_rec.debeme := ( v_rec.totcon / pin_tipcam );
                        v_rec.importemn := v_rec.totcon;
                        v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                        PIPE ROW ( v_rec );
                    ELSIF i.dh = 'H' THEN
                        v_rec.codcon := NULL;
                        v_rec.totcon := v_total;
                        v_rec.habermn := v_rec.totcon;
                        v_rec.haberme := ( v_rec.totcon / pin_tipcam );
                        v_rec.debemn := 0.00;
                        v_rec.debeme := 0.00;
                        v_rec.importemn := v_rec.totcon;
                        v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                        PIPE ROW ( v_rec );
                    END IF;

                ELSIF i.agrupa = 'N' THEN
                    FOR k IN (
                        SELECT
                            pc.codper,
                            SUM(decode(c.idliq, 'B', pc.valcon, 0)) AS ingreso,
                            SUM(decode(c.idliq, 'B', 0, pc.valcon)) AS descuento
                        FROM
                                 planilla_concepto pc
                            INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                     AND c.codcon = pc.codcon
                        WHERE
                                pc.id_cia = pin_id_cia
                            AND pc.numpla = i.numpla
                            AND c.idliq IN ( 'B', 'C', 'D' )
                            AND pc.situac IN ( 'S' )
                        GROUP BY
                            pc.codper
                    ) LOOP
                        v_total := k.ingreso - k.descuento;
                        IF i.dh = 'D' THEN
                            v_rec.codcon := NULL;
                            v_rec.totcon := v_total;
                            v_rec.habermn := 0.00;
                            v_rec.haberme := 0.00;
                            v_rec.debemn := v_rec.totcon;
                            v_rec.debeme := ( v_rec.totcon / pin_tipcam );
                            v_rec.importemn := v_rec.totcon;
                            v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                            PIPE ROW ( v_rec );
                        ELSIF i.dh = 'H' THEN
                            v_rec.codcon := NULL;
                            v_rec.totcon := v_total;
                            v_rec.habermn := v_rec.totcon;
                            v_rec.haberme := ( v_rec.totcon / pin_tipcam );
                            v_rec.debemn := 0.00;
                            v_rec.debeme := 0.00;
                            v_rec.importemn := v_rec.totcon;
                            v_rec.importeme := ( v_rec.totcon / pin_tipcam );
                            PIPE ROW ( v_rec );
                        END IF;

                    END LOOP;
                END IF;

            END LOOP;
        END IF;

    END sp_genera_cuenta41;

END;

/
