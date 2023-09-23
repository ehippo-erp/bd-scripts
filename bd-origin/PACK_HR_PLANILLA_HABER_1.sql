--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_HABER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_HABER" AS

    FUNCTION sp_tipopago (
        pin_id_cia INTEGER
    ) RETURN datatable_tipopago
        PIPELINED
    AS
        v_rec datarecord_tipopago;
        v_aux VARCHAR2(1 CHAR);
    BEGIN
        v_rec.id_cia := pin_id_cia;
        v_rec.tippag := 'M';
        v_rec.despag := 'MENSUAL';
        PIPE ROW ( v_rec );
        v_rec.tippag := 'Q';
        v_rec.despag := 'QUINCENA';
        PIPE ROW ( v_rec );
        v_rec.tippag := 'C';
        v_rec.despag := 'CTS';
        PIPE ROW ( v_rec );
        BEGIN
            SELECT
                'S'
            INTO v_aux
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 702
                AND valfa1 = 1;
            -- LA GRATIFICACION ESTA INCLUIDA COMO PARTE DE LA PLANILLA NORMAL
            v_rec.tippag := 'G';
            v_rec.despag := 'GRATIFICACION';
            PIPE ROW ( v_rec );
        EXCEPTION
            WHEN no_data_found THEN
                NULL; --- OK
        END;

    END sp_tipopago;

    FUNCTION sp_buscar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable_planilla_haber
        PIPELINED
    AS
        v_table datatable_planilla_haber;
    BEGIN
        IF nvl(pin_tippag, 'M') IN ( 'M', 'Q', 'G' ) THEN
            SELECT
                pl.id_cia,
                pl.numpla,
                ( pl.tippla
                  || pl.empobr
                  || '-'
                  || pl.anopla
                  || '/'
                  || TRIM(to_char(pl.mespla, '00'))
                  || '-'
                  || pl.sempla ) AS planilla,
                p.codper,
                p.apepat,
                p.apemat,
                p.nombre,
                p.apepat
                || ' '
                || p.apemat
                || ' '
                || p.nombre    AS nomper,
                pcp14.codigo   AS coddoc,
                pcp14.descri   AS desdoc,
                pd3.nrodoc     AS nrodoc,
                p.codban,
                e.descri       AS desban,
                p.tipcta,
                et.descri      AS descta,
                p.codmon,
                p.codmon,
                p.nrocta,
                p.forpag,
                CASE
                    WHEN p.forpag = 'E' THEN
                        'EFECTIVO'
                    WHEN p.forpag = 'C' THEN
                        'CHEQUE'
                    WHEN p.forpag = 'D' THEN
                        'DEPOSITO'
                    ELSE
                        'ND'
                END            AS despag,
                CASE
                    WHEN nvl(pin_tippag, 'M') = 'M'
                         AND pl.mespla IN ( 7, 12 ) THEN
                        pr.totnet - nvl(pc.valcon, 0)
                    WHEN nvl(pin_tippag, 'M') = 'M'
                         AND pl.mespla NOT IN ( 7, 12 ) THEN
                        pr.totnet
                    ELSE
                        pc.valcon
                END            AS monpag,
                CASE
                    WHEN TRIM(p.nrocta) IS NULL
                         OR p.tipcta NOT IN ( 2, 5 ) THEN
                        'N'
                    ELSE
                        CASE
                                WHEN p.codban = 2
                                     AND p.tipcta = 2
                                     AND length(TRIM(p.nrocta)) = 14 THEN
                                    'S'
                                WHEN p.codban = 2
                                     AND p.tipcta = 5
                                     AND length(TRIM(p.nrocta)) = 20 THEN
                                    'S'
                                WHEN p.codban = 11
                                     AND p.tipcta IN ( 2, 5 )
                                     AND length(TRIM(p.nrocta)) IN ( 18, 20 ) THEN
                                    'S'
                                ELSE
                                    'N'
                        END
                END            AS situac
            BULK COLLECT
            INTO v_table
            FROM
                planilla              pl
                LEFT OUTER JOIN planilla_auxiliar     pa ON pa.id_cia = pl.id_cia
                                                        AND pa.numpla = pl.numpla
                LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pa.id_cia
                                                       AND pr.numpla = pa.numpla
                                                       AND pr.codper = pa.codper
                LEFT OUTER JOIN factor_clase_planilla fp ON fp.id_cia = pl.id_cia
                                                            AND fp.codfac = (
                    CASE
                        WHEN pin_tippag = 'Q' THEN
                            '200'
                        ELSE
                            '703'
                    END
                )
                                                            AND fp.codcla = pin_empobr
                LEFT OUTER JOIN planilla_concepto     pc ON pc.id_cia = pa.id_cia
                                                        AND pc.numpla = pa.numpla
                                                        AND pc.codper = pa.codper
                                                        AND pc.codcon = fp.vstrg
                LEFT OUTER JOIN personal              p ON p.id_cia = pa.id_cia
                                              AND p.codper = pa.codper
                INNER JOIN e_financiera          e ON e.id_cia = p.id_cia
                                             AND e.codigo = p.codban
                LEFT OUTER JOIN e_financiera_tipo     et ON et.id_cia = p.id_cia
                                                        AND et.tipcta = p.tipcta
                LEFT OUTER JOIN personal_documento    pd3 ON pd3.id_cia = p.id_cia
                                                          AND pd3.codper = p.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN clase_codigo_personal pcp14 ON pcp14.id_cia = pd3.id_cia
                                                               AND pcp14.clase = pd3.clase
                                                               AND pcp14.codigo = pd3.codigo
            WHERE
                    pl.id_cia = pin_id_cia
                AND pl.anopla = pin_periodo
                AND pl.mespla = pin_mes
                AND pl.tippla = pin_tippla
                AND pl.empobr = pin_empobr
                AND p.forpag = 'D'
                AND ( ( nvl(pin_tippag, 'M') = 'M'
                        AND pr.totnet <> 0 )
                      OR ( nvl(pin_tippag, 'M') = 'Q'
                           AND pc.valcon <> 0 )
                      OR ( nvl(pin_tippag, 'M') = 'G'
                           AND pc.valcon <> 0 ) )
                AND ( ( pin_inccci = 'S'
                        AND ( p.codban = pin_codban
                              OR ( p.codban <> pin_codban
                                   AND p.tipcta = 5 ) ) )
                      OR ( pin_inccci = 'N'
                           AND p.codban = pin_codban ) )
                AND pa.situac = 'S'
            ORDER BY
                p.apepat,
                p.apemat,
                p.nombre;

        ELSE
            SELECT
                pl.id_cia,
                pl.numpla,
                ( pl.tippla
                  || pl.empobr
                  || '-'
                  || pl.anopla
                  || '/'
                  || TRIM(to_char(pl.mespla, '00'))
                  || '-'
                  || pl.sempla ) AS planilla,
                p.codper,
                p.apepat,
                p.apemat,
                p.nombre,
                p.apepat
                || ' '
                || p.apemat
                || ' '
                || p.nombre    AS nomper,
                pcp14.codigo   AS coddoc,
                pcp14.descri   AS desdoc,
                pd3.nrodoc     AS nrodoc,
                pcts.codban,
                e.descri       AS desban,
                pcts.tipcta,
                et.descri      AS descta,
                pcts.codmon,
                pcts.codmon,
                pcts.cuenta,
                p.forpag,
                CASE
                    WHEN p.forpag = 'E' THEN
                        'EFECTIVO'
                    WHEN p.forpag = 'C' THEN
                        'CHEQUE'
                    WHEN p.forpag = 'D' THEN
                        'DEPOSITO'
                    ELSE
                        'ND'
                END            AS despag,
                pr.totnet      monpag,
                CASE
                    WHEN TRIM(pcts.cuenta) IS NULL
                         OR pcts.tipcta NOT IN ( 2, 5 ) THEN
                        'N'
                    ELSE
                        CASE
                                WHEN pcts.tipcta = 2
                                     AND length(TRIM(pcts.cuenta)) = 14 THEN
                                    'S'
                                WHEN pcts.tipcta = 5
                                     AND length(TRIM(pcts.cuenta)) = 20 THEN
                                    'S'
                                ELSE
                                    'N'
                        END
                END            AS situac
            BULK COLLECT
            INTO v_table
            FROM
                planilla              pl
                LEFT OUTER JOIN planilla_auxiliar     pa ON pa.id_cia = pl.id_cia
                                                        AND pa.numpla = pl.numpla
                LEFT OUTER JOIN planilla_resumen      pr ON pr.id_cia = pa.id_cia
                                                       AND pr.numpla = pa.numpla
                                                       AND pr.codper = pa.codper
                LEFT OUTER JOIN personal              p ON p.id_cia = pa.id_cia
                                              AND p.codper = pa.codper
                LEFT OUTER JOIN personal_cts          pcts ON pcts.id_cia = p.id_cia
                                                     AND pcts.codper = p.codper
                INNER JOIN e_financiera          e ON e.id_cia = pcts.id_cia
                                             AND e.codigo = pcts.codban
                LEFT OUTER JOIN e_financiera_tipo     et ON et.id_cia = pcts.id_cia
                                                        AND et.tipcta = pcts.tipcta
                LEFT OUTER JOIN personal_documento    pd3 ON pd3.id_cia = p.id_cia
                                                          AND pd3.codper = p.codper
                                                          AND pd3.codtip = 'DO'
                                                          AND pd3.codite = 201 /*DOCUMENTO IDENTIDAD*/
                LEFT OUTER JOIN clase_codigo_personal pcp14 ON pcp14.id_cia = pd3.id_cia
                                                               AND pcp14.clase = pd3.clase
                                                               AND pcp14.codigo = pd3.codigo
            WHERE
                    pl.id_cia = pin_id_cia
                AND pl.anopla = pin_periodo
                AND pl.mespla = pin_mes
                AND pl.tippla = 'S' -- CTS
                AND pl.empobr = pin_empobr
                AND p.forpag = 'D'
                AND pr.totnet <> 0
                AND ( ( pin_inccci = 'S'
                        AND ( pcts.codban = pin_codban
                              OR ( pcts.codban <> pin_codban
                                   AND pcts.codban = 5 ) ) )
                      OR ( pin_inccci = 'N'
                           AND pcts.codban = pin_codban ) )
                AND pa.situac = 'S'
            ORDER BY
                p.apepat,
                p.apemat,
                p.nombre;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_detalle (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        SELECT
            t.codper,
            nvl(t.checksum, 0),
            t.nroctaabr,
            t.monpag
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    codper,
                    TO_NUMBER(substr(nrocta, 4, 14)) AS checksum,
                    substr(nrocta, 4, 14)            AS nroctaabr,
                    monpag
                FROM
                    pack_hr_planilla_haber.sp_buscar(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                     pin_tippag, pin_codmon, pin_codban, pin_inccci)
                WHERE
                    TRIM(nrocta) IS NOT NULL
                    AND codban = pin_codban
                    AND tipcta = 2
                UNION ALL
                SELECT
                    codper,
                    TO_NUMBER(substr(nrocta, 11, 20)) AS checksum,
                    substr(nrocta, 11, 20)            AS nroctaabr,
                    monpag
                FROM
                    pack_hr_planilla_haber.sp_buscar(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                     pin_tippag, pin_codmon, pin_codban, pin_inccci)
                WHERE
                    TRIM(nrocta) IS NOT NULL
                    AND codban <> pin_codban
                    AND tipcta = 5
            ) t;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle;

    FUNCTION sp_valida_objeto (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS
        reg_errores r_errores;
        v_nrocta    VARCHAR2(100 CHAR);
    BEGIN
        BEGIN
            SELECT
                TO_NUMBER(TRIM(regexp_replace(ruc, ' [A-Za-z]*'))),
                razsoc
            INTO
                reg_errores.orden,
                reg_errores.concepto
            FROM
                companias
            WHERE
                cia = pin_id_cia;

            SELECT
                nrocta
            INTO v_nrocta
            FROM
                compania_banco
            WHERE
                    id_cia = pin_id_cia
                AND codban = pin_codban
                AND tipcta IN ( 1, 3 )
                AND codmon = pin_codmon
                AND TRIM(nrocta) IS NOT NULL;

            IF
                pin_codban = 2
                AND length(trim(v_nrocta)) <> 13
            THEN
                reg_errores.valor := trim(v_nrocta);
                reg_errores.deserror := 'NUMERO DE CUENTA CORRIENTE O MAESTRA DEBE TENER 13 POSICIONES';
                PIPE ROW ( reg_errores );
            ELSIF
                pin_codban = 11
                AND length(TRIM(v_nrocta)) NOT IN ( 18, 20 )
            THEN
                reg_errores.valor := trim(v_nrocta);
                reg_errores.deserror := 'NUMERO DE CUENTA CORRIENTE O MAESTRA DEBE TENER 18 O 20 POSICIONES';
                PIPE ROW ( reg_errores );
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := 'ND';
                reg_errores.deserror := 'NRO DE CUENTA DE EMPRESA VACIA ( NO DEFINIDA )';
                PIPE ROW ( reg_errores );
            WHEN too_many_rows THEN
                reg_errores.valor := 'ND-ND';
                reg_errores.deserror := 'MULTIPLE NRO DE CUENTA DE EMPRESA, PARA EL BANCO [ '
                                        || pin_codban
                                        || ' ] Y MONEDA [ '
                                        || pin_codmon
                                        || ' ]';

                PIPE ROW ( reg_errores );
        END;

        FOR i IN (
            SELECT
                *
            FROM
                pack_hr_planilla_haber.sp_buscar(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                 pin_tippag, pin_codmon, pin_codban, pin_inccci)
        ) LOOP
            reg_errores.orden := TO_NUMBER ( TRIM(regexp_replace(i.codper, ' [A-Za-z]*')) );

            reg_errores.concepto := i.nomper;
            IF i.tipcta IS NULL THEN
                reg_errores.valor := 'ND';
                reg_errores.deserror := 'TIPO DE CUENTA NO VACIA ( NO DEFINIDA )';
                PIPE ROW ( reg_errores );
            ELSIF i.tipcta NOT IN ( 2, 5 ) THEN
                reg_errores.valor := nvl(i.descta, 'ND');
                reg_errores.deserror := 'TIPO DE CUENTA NO VALIDA PARA ESTA OPERACION, SOLO UTILIZAR CUENTA CORRIENTE O CODIGO INTERBANCARIO (CCI)'
                ;
                PIPE ROW ( reg_errores );
            END IF;

            IF TRIM(i.nrocta) IS NULL THEN
                reg_errores.valor := 'ND';
                reg_errores.deserror := 'NUMERO DE CUENTA VACIA ( NO DEFINIDA )';
                PIPE ROW ( reg_errores );
            ELSE
                IF pin_codban = 2 THEN
                    IF
                        i.tipcta = 2
                        AND length(trim(i.nrocta)) <> 14
                    THEN
                        reg_errores.valor := trim(i.nrocta);
                        reg_errores.deserror := 'NUMERO DE CUENTA DE AHORROS DEBE TENER 14 POSICIONES';
                        PIPE ROW ( reg_errores );
                    ELSIF
                        i.tipcta = 5
                        AND length(trim(i.nrocta)) <> 20
                    THEN
                        reg_errores.valor := trim(i.nrocta);
                        reg_errores.deserror := 'NUMERO DE CUENTA BANCARIA DEBE TENER 20 POSICIONES';
                        PIPE ROW ( reg_errores );
                    END IF;

                ELSIF
                    pin_codban = 11
                    AND length(TRIM(i.nrocta)) NOT IN ( 18, 20 )
                THEN
                    reg_errores.valor := trim(i.nrocta);
                    reg_errores.deserror := 'NUMERO DE CUENTA CORRIENTE O MAESTRA DEBE TENER 18 O 20 POSICIONES';
                END IF;
            END IF;

            IF i.coddoc IS NULL THEN
                reg_errores.valor := 'ND';
                reg_errores.deserror := 'TIPO DE DOCUMENTO IDENTIDAD VACIO ( NO DEFINIDO )';
                PIPE ROW ( reg_errores );
            ELSIF i.coddoc NOT IN ( '01', '03', '04' ) THEN
                reg_errores.valor := i.desdoc;
                reg_errores.deserror := 'TIPO DE DOCUMENTO IDENTIDAD NO VALIDO, PARA ESTA OPERACION';
                PIPE ROW ( reg_errores );
            END IF;

            IF TRIM(i.nrodoc) IS NULL THEN
                reg_errores.valor := 'ND';
                reg_errores.deserror := 'NRO DE DOCUMENTO IDENTIDAD VACIO ( NO DEFINIDO )';
                PIPE ROW ( reg_errores );
            END IF;

        END LOOP;

    END sp_valida_objeto;

--SELECT * FROM pack_hr_planilla_haber.sp_genera_txt
--(25,2023,1,'N','E','M','PEN',3,'S','{"referencia":"HABERES 5TA","tipcam":0,
--    "tipoproceso":"A",
--    "fechaproceso":"2022-01-01",
--    "horaejecucion":"B",
--    "pertenencia":"S"}')

    FUNCTION sp_genera_txt (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tippla  IN VARCHAR2,
        pin_empobr  IN VARCHAR2,
        pin_tippag  IN VARCHAR2,
        pin_codmon  IN VARCHAR2,
        pin_codban  IN NUMBER,
        pin_inccci  IN VARCHAR2,
        pin_datos   IN VARCHAR2
    ) RETURN datatable_genera_txt
        PIPELINED
    AS

        v_rec              datarecord_genera_txt := datarecord_genera_txt(NULL, NULL, NULL, NULL, NULL,
                                                            NULL, NULL, NULL, NULL, NULL,
                                                            NULL);
        o                  json_object_t;
        v_referencia       VARCHAR2(1000 CHAR) := '';
        v_tipcam           NUMBER(16, 2);
        v_subtip           VARCHAR2(1 CHAR) := '';
        v_tipcta           VARCHAR2(1 CHAR) := '';
        v_codmon           VARCHAR2(5 CHAR) := '';
        v_nrocta           VARCHAR2(100 CHAR);
        v_tipoproceso      VARCHAR2(100 CHAR);
        v_fechaproceso     DATE;
        v_fechatextproceso VARCHAR2(100 CHAR);
        v_horaejecucion    VARCHAR2(100 CHAR);
        v_pertenencia      VARCHAR2(100 CHAR);
        v_numper           NUMBER;
        v_checksum         NUMBER;
        v_monpag           NUMBER(16, 2);
    BEGIN
        o := json_object_t.parse(pin_datos);
        v_referencia := o.get_string('referencia');
        v_tipcam := o.get_number('tipcam');
        v_tipoproceso := o.get_string('tipoproceso');
        v_fechaproceso := o.get_date('fechaproceso');
        v_horaejecucion := o.get_string('horaproceso');
        v_pertenencia := o.get_string('pertenencia');
        -- BCP 
        IF pin_codban = 2 THEN
            -- CAB
            SELECT
                'PEMP_'
                ||
                CASE pin_tippag
                        WHEN 'N' THEN
                            'NOR'
                        WHEN 'Q' THEN
                            'QUIN'
                        WHEN 'C' THEN
                            'CTS'
                END
                || pin_periodo
                || TRIM(to_char(pin_mes, '00'))
            INTO v_rec.rotulo
            FROM
                dual;

            v_rec.indcabdet := 'C';
            IF pin_tippla NOT IN ( 'V', 'G' ) THEN
                v_subtip := 'X';
            ELSE
                v_subtip := pin_tippla;
            END IF;

            IF pin_codmon = 'PEN' THEN
                v_codmon := '0001';
            ELSE
                v_codmon := '1001';
            END IF;

            BEGIN
                SELECT
                    nvl(COUNT(codper),
                        0),
                    nvl(SUM(checksum),
                        0),
                    nvl(SUM(monpag),
                        0)
                INTO
                    v_numper,
                    v_checksum,
                    v_monpag
                FROM
                    pack_hr_planilla_haber.sp_detalle(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                      pin_tippag, pin_codmon, pin_codban, pin_inccci);

            END;

            BEGIN
                SELECT
                    nrocta,
                    CASE
                        WHEN tipcta = 1 THEN
                            'C'
                        ELSE
                            'M'
                    END
                INTO
                    v_nrocta,
                    v_tipcta
                FROM
                    compania_banco
                WHERE
                        id_cia = pin_id_cia
                    AND codban = pin_codban
                    AND tipcta IN ( 1, 3 )
                    AND codmon = pin_codmon;

            EXCEPTION
                WHEN no_data_found THEN
                    v_nrocta := '0';
                WHEN too_many_rows THEN
                    v_nrocta := '0';
            END;

            v_checksum := v_checksum + TO_NUMBER ( substr(v_nrocta,
                                                          4,
                                                          length(v_nrocta)) );

            v_rec.column01 := '1'
                              || sp000_ajusta_string(to_char(v_numper), 6, '0', 'R')
                              || to_char(current_timestamp, 'YYYYMMDD')
                              || v_subtip
                              || v_tipcta -- 'C'
                              || v_codmon
                              || v_nrocta;

            v_rec.column02 := sp000_ajusta_string(trim(to_char(v_monpag, '99999999999999.99')), 17, '0', 'R');

            v_rec.column03 := v_referencia;
            v_rec.column04 := sp000_ajusta_string(to_char(v_checksum), 15, '0', 'R'); -- SUMA DE CUENTA
            PIPE ROW ( v_rec );
            -- DET
            FOR i IN (
                SELECT
                    apepat,
                    apemat,
                    nombre,
                    CASE
                        WHEN pin_codmon = 'PEN' THEN
                            '0001'
                        ELSE
                            '1001'
                    END                  AS codmon,
                    round((monpag /
                           CASE
                               WHEN v_tipcam = 0 THEN
                                   1
                               ELSE
                                   v_tipcam
                           END
                    ), 2)                AS monpag,
                    '2'                  AS tipreg,
                    substr(coddoc, 2, 1) AS tipdoc,
                    nrodoc,
                    CASE
                        WHEN tipcta = 2 THEN
                            'A'
                        WHEN tipcta = 5 THEN
                            'B'
                        WHEN tipcta = 3 THEN
                            'M'
                        WHEN tipcta = 1 THEN
                            'C'
                        ELSE
                            ''
                    END                  AS tipcta,
                    nrocta
                FROM
                    pack_hr_planilla_haber.sp_buscar(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                     pin_tippag, pin_codmon, pin_codban, pin_inccci)
                WHERE
                    TRIM(nrocta) IS NOT NULL
                    AND ( ( tipcta = 2
                            AND codban = pin_codban )
                          OR ( tipcta = 5
                               AND codban <> pin_codban ) )
            ) LOOP
                v_rec.indcabdet := 'D';
                v_rec.column01 := i.tipreg
                                  || i.tipcta
                                  || i.nrocta;

                v_rec.column02 := i.tipdoc || i.nrodoc;
                v_rec.column03 := i.apepat
                                  || ' '
                                  || i.apemat
                                  || ' ,'
                                  || i.nombre;

                v_rec.column04 := v_referencia;
                v_rec.column05 := v_referencia;
                v_rec.column06 := i.codmon
                                  || sp000_ajusta_string(trim(to_char(i.monpag, '99999999999999.99')), 17, '0', 'R')
                                  || 'S';

                PIPE ROW ( v_rec );
            END LOOP;

        ELSIF pin_codban = 11 THEN
            -- CAB
            SELECT
                'BBVAHABE'
            INTO v_rec.rotulo
            FROM
                dual;

            v_rec.indcabdet := 'C';
            IF pin_codmon = 'PEN' THEN
                v_codmon := 'PEN';
            ELSE
                v_codmon := 'USD';
            END IF;

            BEGIN
                SELECT
                    CASE
                        WHEN length(nrocta) = 20 THEN
                            nrocta
                        WHEN length(nrocta) = 18 THEN
                            substr(nrocta, 1, 8)
                            || '00'
                            || substr(nrocta, 9, 10)
                        ELSE
                            '00000000000000000000'
                    END AS nrocta
                INTO v_nrocta
                FROM
                    compania_banco
                WHERE
                        id_cia = pin_id_cia
                    AND codban = pin_codban
                    AND tipcta IN ( 1, 3 )
                    AND codmon = pin_codmon;

            EXCEPTION
                WHEN no_data_found THEN
                    v_nrocta := '00000000000000000000';
                WHEN too_many_rows THEN
                    v_nrocta := '00000000000000000000';
            END;

            BEGIN
                SELECT
                    nvl(COUNT(codper),
                        0),
                    nvl(SUM(checksum),
                        0),
                    nvl(SUM(monpag),
                        0)
                INTO
                    v_numper,
                    v_checksum,
                    v_monpag
                FROM
                    pack_hr_planilla_haber.sp_detalle(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                      pin_tippag, pin_codmon, pin_codban, pin_inccci);

            END;

            IF v_referencia IS NULL THEN
                v_referencia := '';
            END IF;
            IF v_tipoproceso = 'A' THEN
                v_fechatextproceso := '         ';
            ELSE
                v_fechatextproceso := to_char(v_fechaproceso, 'YYYYMMDD')
                                      || ' ';
            END IF;

            v_rec.column01 := '700'
                              || v_nrocta
                              || v_codmon
                              || sp000_ajusta_string(to_char(trunc(v_monpag * 100)), 15, '0', 'R') -- TOTAL DE ABONO
                              || v_tipoproceso -- ( A ( INMEDIATO ), B ( FECHA FUTURA ), C ( HORARIO DE EJECUCION ) )
                              || v_fechatextproceso
                              || v_horaejecucion -- ( B ( 11:00 Horas ), C ( 15:00 Horas ), D ( 19:00 Horas ) )
                              || sp000_ajusta_string(substr(v_referencia, 1, 24), 25, ' ', 'L')  -- 25
                              || sp000_ajusta_string(to_char(v_numper), 6, '0', 'R')
                              || v_pertenencia
                              || '0'
                              || '0'
                              || '0000000000000000'
                              || ' ';

            PIPE ROW ( v_rec );
            -- DET
            FOR i IN (
                SELECT
                    apepat,
                    apemat,
                    nombre,
                    round((monpag /
                           CASE
                               WHEN v_tipcam = 0 THEN
                                   1
                               ELSE
                                   v_tipcam
                           END
                    ), 2) AS monpag,
                    CASE substr(coddoc, 2, 1)
                        WHEN '1' THEN
                            'L'
                        WHEN '4' THEN
                            'E'
                        WHEN '7' THEN
                            'P'
                    END   AS tipdoc,
                    nrodoc,
                    CASE
                        WHEN tipcta = 5 THEN
                            'I'
                        ELSE
                            'P'
                    END   AS tipcta,
                    CASE
                        WHEN length(nrocta) = 20 THEN
                            nrocta
                        WHEN length(nrocta) = 18 THEN
                            substr(nrocta, 1, 8)
                            || '00'
                            || substr(nrocta, 9, 10)
                        ELSE
                            '00000000000000000000'
                    END   AS nrocta
                FROM
                    pack_hr_planilla_haber.sp_buscar(pin_id_cia, pin_periodo, pin_mes, pin_tippla, pin_empobr,
                                                     pin_tippag, pin_codmon, pin_codban, pin_inccci)
                WHERE
                    TRIM(nrocta) IS NOT NULL
                    AND ( ( tipcta = 2
                            AND codban = pin_codban )
                          OR ( tipcta = 5
                               AND codban <> pin_codban ) )
            ) LOOP
                v_rec.indcabdet := 'D';
                v_rec.column01 := '002'
                                  || i.tipdoc
                                  || i.nrodoc;
                v_rec.column02 := i.tipcta -- TIPO DE ABONO
                                  || i.nrocta
                                  || upper(i.apepat
                                           || ' '
                                           || i.apemat
                                           || ' '
                                           || i.nombre);

                v_rec.column03 := sp000_ajusta_string(to_char(trunc(i.monpag * 100)), 15, '0', 'R') -- TOTAL DE ABONO
                                  || upper(v_referencia)
                                  || ' '
                                  || ' '
                                  || ' ';

                PIPE ROW ( v_rec );
            END LOOP;

        END IF;

    END sp_genera_txt;

END;

/
