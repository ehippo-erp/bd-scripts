--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_planilla
        PIPELINED
    AS
        v_table datatable_planilla;
    BEGIN
        SELECT
            p.id_cia,
            p.numpla,
            ( p.tippla
              || p.empobr
              || '-'
              || p.anopla
              || '/'
              || TRIM(to_char(p.mespla, '00'))
              || '-'
              || p.sempla ) AS planilla,
            p.tippla,
            tp.nombre,
            p.empobr,
            ttp.nombre,
            p.anopla,
            p.mespla,
            p.sempla,
            p.fecini,
            p.fecfin,
            p.dianor,
            p.hornor,
            p.tcambio,
            p.situac,
            CASE
                WHEN p.situac = 'S' THEN
                    'ABIERTA'
                WHEN p.situac = 'N' THEN
                    'CERRADA'
                ELSE
                    'ND'
            END           AS dessituac,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            planilla        p
            LEFT OUTER JOIN tipoplanilla    tp ON tp.id_cia = p.id_cia
                                               AND tp.tippla = p.tippla
            LEFT OUTER JOIN tipo_trabajador ttp ON ttp.id_cia = p.id_cia
                                                   AND ttp.tiptra = p.empobr
        WHERE
                p.id_cia = pin_id_cia
            AND p.numpla = pin_numpla;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_empobr VARCHAR2,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_situac VARCHAR2
    ) RETURN datatable_planilla
        PIPELINED
    AS
        v_table datatable_planilla;
    BEGIN
        SELECT
            p.id_cia,
            p.numpla,
            p.tippla
            || p.empobr
            || '-'
            || p.anopla
            || '/'
            || TRIM(to_char(p.mespla, '00'))
            || '-'
            || p.sempla AS planilla,
            p.tippla,
            tp.nombre,
            p.empobr,
            ttp.nombre,
            p.anopla,
            p.mespla,
            p.sempla,
            p.fecini,
            p.fecfin,
            p.dianor,
            p.hornor,
            p.tcambio,
            p.situac,
            CASE
                WHEN p.situac = 'S' THEN
                    'ABIERTA'
                WHEN p.situac = 'N' THEN
                    'CERRADA'
                ELSE
                    'ND'
            END         AS dessituac,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            planilla        p
            LEFT OUTER JOIN tipoplanilla    tp ON tp.id_cia = p.id_cia
                                               AND tp.tippla = p.tippla
            LEFT OUTER JOIN tipo_trabajador ttp ON ttp.id_cia = p.id_cia
                                                   AND ttp.tiptra = p.empobr
        WHERE
                p.id_cia = pin_id_cia
            AND ( pin_tippla IS NULL
                  OR p.tippla = pin_tippla )
            AND ( pin_empobr IS NULL
                  OR p.empobr = pin_empobr )
            AND ( pin_anopla IS NULL
                  OR p.anopla = pin_anopla )
            AND ( pin_mespla IS NULL
                  OR p.mespla = pin_mespla )
            AND ( pin_situac IS NULL
                  OR p.situac = pin_situac )
        ORDER BY
            p.numpla DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_autocompletar (
        pin_id_cia  NUMBER,
        pin_empobr  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_autocompletar
        PIPELINED
    AS
        v_rec datarecord_autocompletar;
    BEGIN
        v_rec.fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                       || '/'
                                                       || pin_mes
                                                       || '/'
                                                       || pin_periodo), 'DD/MM/YYYY')));

        v_rec.fdesde := TO_DATE ( to_char('01'
                                          || '/'
                                          || pin_mes
                                          || '/'
                                          || pin_periodo), 'DD/MM/YYYY' );

        v_rec.semana := TO_NUMBER ( to_char(TO_TIMESTAMP(v_rec.fhasta),
                                            'WW') );

        v_rec.dias := ( v_rec.fhasta - v_rec.fdesde );
        BEGIN
            SELECT
                fcp.vreal
            INTO v_rec.horas
            FROM
                     factor_planilla fp
                INNER JOIN factor_clase_planilla fcp ON fcp.id_cia = fp.id_cia
                                                        AND fcp.codfac = fp.codfac
            WHERE
                    fp.id_cia = pin_id_cia
                AND fp.codfac = '413'
                AND fcp.codcla = pin_empobr
                AND nvl(fcp.vreal, 0) <> 0;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.mensaje := 'ERROR, LA EMPRESA NO TIENE DEFINIDO EL FACTOR [ 413 ] CON LA CLASE [ '
                                 || pin_empobr
                                 || ' ]';
        END;

        PIPE ROW ( v_rec );
    END sp_autocompletar;

    FUNCTION sp_periodolaboral (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_periodolaboral
        PIPELINED
    AS
        v_table datatable_periodolaboral;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            p.tiptra,
            p.situac,
            fs.id_plab,
            trunc(fs.finicio),
            trunc(fs.ffinal),
            trunc(pin_fhasta) - trunc(fs.finicio),
            nvl(fs.ffinal,(fs.finicio + 1000000)) - trunc(pin_fdesde)
        BULK COLLECT
        INTO v_table
        FROM
            personal                p
            LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                          AND fs.codper = p.codper
        WHERE
                p.id_cia = pin_id_cia
            AND p.tiptra = pin_tiptra
            AND ( trunc(pin_fhasta) - trunc(fs.finicio) ) >= 0
            AND ( trunc(nvl(fs.ffinal,(fs.finicio + 1000000))) - trunc(pin_fdesde) >= 0 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_periodolaboral;

    FUNCTION sp_personal_incluido (
        pin_id_cia NUMBER,
        pin_datos  CLOB
    ) RETURN datatable_personal_incluido
        PIPELINED
    AS
        v_rec        datarecord_personal_incluido;
        o            json_object_t;
        rec_planilla planilla%rowtype;
        v_situac     VARCHAR2(5 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_planilla.id_cia := pin_id_cia;
        rec_planilla.tippla := o.get_string('tippla');
        rec_planilla.empobr := o.get_string('empobr');
        rec_planilla.anopla := o.get_number('anopla');
        rec_planilla.mespla := o.get_number('mespla');
        rec_planilla.sempla := o.get_number('sempla');
        rec_planilla.fecini := o.get_date('fecini');
        rec_planilla.fecfin := o.get_date('fecfin');
        rec_planilla.dianor := o.get_number('dianor');
        rec_planilla.hornor := o.get_number('hornor');
        rec_planilla.situac := o.get_string('situac');
        rec_planilla.tcambio := o.get_number('tcambio');
        IF ( ( rec_planilla.tippla = 'G' ) OR ( rec_planilla.tippla = 'N' ) OR ( rec_planilla.tippla = 'S' ) OR ( rec_planilla.tippla = 'P'
        ) OR ( rec_planilla.tippla = 'X' ) OR ( rec_planilla.tippla = 'Y' ) OR ( rec_planilla.tippla = 'Z' ) ) THEN
            v_situac := '01';
        ELSIF ( rec_planilla.tippla = 'C' ) THEN
            v_situac := '03';
        ELSIF ( rec_planilla.tippla = 'V' ) THEN
            v_situac := '02';
        ELSIF ( rec_planilla.tippla = 'L' ) THEN
            v_situac := '05';
        END IF;

        v_rec.id_planilla := rec_planilla.tippla
                             || rec_planilla.empobr
                             || '-'
                             || rec_planilla.anopla
                             || '/'
                             || trim(to_char(rec_planilla.mespla, '00'))
                             || '-'
                             || rec_planilla.sempla;

        IF rec_planilla.tippla <> 'L' THEN
            FOR i IN (
                SELECT
                    p.id_cia,
                    p.codper,
                    p.nomper,
                    p.situac,
                    sp.nombre,
                    p.finicio,
                    p.ffinal
                FROM
                    pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin) p
                    LEFT OUTER JOIN situacion_personal                                                                                            sp
                    ON sp.id_cia = p.id_cia
                                                             AND sp.codsit = p.situac
                WHERE
                        p.id_cia = pin_id_cia
                    AND ( p.situac = v_situac
                          OR ( p.situac = CASE
                                              WHEN ( ( rec_planilla.tippla = 'X' )
                                                     OR ( rec_planilla.tippla = 'Y' )
                                                     OR ( rec_planilla.tippla = 'Z' )
                                                     OR ( rec_planilla.tippla = 'S' ) ) THEN
                                                  '02'
                                          END )
                          OR ( p.situac = CASE
                                              WHEN ( ( ( rec_planilla.tippla = 'X' )
                                                       OR ( rec_planilla.tippla = 'Y' )
                                                       OR ( rec_planilla.tippla = 'Z' )
                                                       OR ( rec_planilla.tippla = 'S' ) ) ) THEN
                                                  '05'
                                          END ) )
                ORDER BY
                    p.nomper
            ) LOOP
                v_rec.id_cia := i.id_cia;
                v_rec.codper := i.codper;
                v_rec.nomper := i.nomper;
                v_rec.situac := i.situac;
                v_rec.desituac := i.nombre;
                v_rec.finicio := i.finicio;
                v_rec.ffinal := i.ffinal;
                PIPE ROW ( v_rec );
            END LOOP;
        ELSE
            FOR i IN (
                SELECT
                    p.id_cia,
                    p.codper,
                    p.nomper,
                    p.situac,
                    sp.nombre,
                    p.finicio,
                    p.ffinal
                FROM
                    pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin) p
                    LEFT OUTER JOIN situacion_personal                                                                                            sp
                    ON sp.id_cia = p.id_cia
                                                             AND sp.codsit = p.situac
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.situac = v_situac
                    AND EXTRACT(YEAR FROM p.ffinal) = rec_planilla.anopla
                    AND EXTRACT(MONTH FROM p.ffinal) = rec_planilla.mespla
                ORDER BY
                    p.nomper
            ) LOOP
                v_rec.id_cia := i.id_cia;
                v_rec.codper := i.codper;
                v_rec.nomper := i.nomper;
                v_rec.situac := i.situac;
                v_rec.desituac := i.nombre;
                v_rec.finicio := i.finicio;
                v_rec.ffinal := i.ffinal;
                PIPE ROW ( v_rec );
            END LOOP;
        END IF;

    END sp_personal_incluido;

    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_datos  CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores       r_errores := r_errores(NULL, NULL);
        o                 json_object_t;
        rec_planilla      planilla%rowtype;
        v_count           NUMBER(38);
        v_sum             NUMBER(16, 4);
        v_mes             NUMBER;
        v_anio            NUMBER;
        v_aux             VARCHAR2(10) := '';
        v_situac          VARCHAR2(10) := '';
        v_mensaje         VARCHAR2(1000) := '';
        v_existe_personal VARCHAR2(1 CHAR) := 'N';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_planilla.id_cia := pin_id_cia;
        rec_planilla.tippla := o.get_string('tippla');
        rec_planilla.empobr := o.get_string('empobr');
        rec_planilla.anopla := o.get_number('anopla');
        rec_planilla.mespla := o.get_number('mespla');
        rec_planilla.sempla := o.get_number('sempla');
        rec_planilla.fecini := o.get_date('fecini');
        rec_planilla.fecfin := o.get_date('fecfin');
        rec_planilla.dianor := o.get_number('dianor');
        rec_planilla.hornor := o.get_number('hornor');
        rec_planilla.situac := o.get_string('situac');
        rec_planilla.tcambio := o.get_number('tcambio');
        rec_planilla.ucreac := o.get_string('ucreac');
        rec_planilla.uactua := o.get_string('uactua');
        
        -- SITUACION, SEGUN TIPO DE PLANILLA
        IF ( ( rec_planilla.tippla = 'G' ) OR ( rec_planilla.tippla = 'N' ) OR ( rec_planilla.tippla = 'S' ) OR ( rec_planilla.tippla = 'P'
        ) OR ( rec_planilla.tippla = 'X' ) OR ( rec_planilla.tippla = 'Y' ) OR ( rec_planilla.tippla = 'Z' ) ) THEN
            v_situac := '01';
        ELSIF ( rec_planilla.tippla = 'C' ) THEN
            v_situac := '03';
        ELSIF ( rec_planilla.tippla = 'V' ) THEN
            v_situac := '02';
        ELSIF ( rec_planilla.tippla = 'L' ) THEN
            v_situac := '05';
        END IF;

        IF rec_planilla.mespla = 1 THEN
            v_mes := 12;
            v_anio := rec_planilla.anopla - 1;
        ELSE
            v_mes := rec_planilla.mespla - 1;
            v_anio := rec_planilla.anopla;
        END IF;

        FOR a IN (
            SELECT
                p.id_cia,
                p.codper,
                p.nomper
            FROM
                pack_hr_planilla.sp_personal_incluido(pin_id_cia, pin_datos) p
        ) LOOP
            -- EXISTE ALMENOS UN PERSONAL, PARA LA PLANILLA
            v_existe_personal := 'S';
            BEGIN
                SELECT
                    1 AS count
                INTO v_count
                FROM
                    personal_concepto pc
                WHERE
                        pc.id_cia = a.id_cia
                    AND pc.codper = a.codper
                    AND ( ( pc.periodo = v_anio
                            AND pc.mes = v_mes )
                          OR ( pc.periodo = rec_planilla.anopla
                               AND pc.mes = rec_planilla.mespla ) )
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.orden := TO_NUMBER ( TRIM(regexp_replace(a.codper, ' [A-Za-z]*')) );

                    reg_errores.concepto := a.codper
                                            || ' - '
                                            || a.nomper;
                    reg_errores.valor := 'Concepto Fijo';
                    reg_errores.deserror := 'No tiene asginado Conceptos Fijos en el periodo anterior a esta planilla';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1 AS count
                INTO v_count
                FROM
                    pack_hr_personal_periodo_rpension.sp_regimenpension(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin
                    ) p
                WHERE
                    p.codper = a.codper;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.orden := TO_NUMBER ( TRIM(regexp_replace(a.codper, ' [A-Za-z]*')) );

                    reg_errores.concepto := a.codper
                                            || ' - '
                                            || a.nomper;
                    reg_errores.valor := 'Regimen de Pesiones';
                    reg_errores.deserror := 'No tiene asginado un periodo valido de Regimen Pensionario para esta planilla';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1 AS count
                INTO v_count
                FROM
                    factor_afp pc
                WHERE
                        pc.id_cia = a.id_cia
                    AND ( ( pc.anio = v_anio
                            AND pc.mes = v_mes )
                          OR ( pc.anio = rec_planilla.anopla
                               AND pc.mes = rec_planilla.mespla ) )
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.orden := TO_NUMBER ( TRIM(regexp_replace(a.codper, ' [A-Za-z]*')) );

                    reg_errores.concepto := a.codper
                                            || ' - '
                                            || a.nomper;
                    reg_errores.valor := 'Factor AFP';
                    reg_errores.deserror := 'No tiene asginado el Factor de AFP en el periodo anterior a esta planilla';
                    PIPE ROW ( reg_errores );
            END;

        END LOOP;

        IF v_existe_personal = 'N' THEN
            reg_errores.orden := 0;
            reg_errores.concepto := 'PLANILLA SIN PERSONAL ASIGNADO';
            reg_errores.valor := 'ND';
            reg_errores.deserror := 'No hay ningun personal asignado para la generacion de la planilla '
                                    || rec_planilla.tippla
                                    || rec_planilla.empobr
                                    || '-'
                                    || rec_planilla.anopla
                                    || '/'
                                    || trim(to_char(rec_planilla.mespla, '00'))
                                    || '-'
                                    || rec_planilla.sempla
                                    || ' , considerando el rango de fechas establecido [ '
                                    || to_char(rec_planilla.fecini, 'DD/MM/YY')
                                    || ' - '
                                    || to_char(rec_planilla.fecfin, 'DD/MM/YY')
                                    || ' ], revisar las fechas de inicio - cese y la situacion laboral de los trabajadores';

            PIPE ROW ( reg_errores );
        END IF;

        FOR j IN (
            SELECT
                p.codper,
                pr.apepat
                || ' '
                || pr.apemat
                || ' '
                || pr.nombre AS nomper
            FROM
                     pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin) p
                INNER JOIN personal pr ON pr.id_cia = p.id_cia
                                          AND pr.codper = p.codper
            WHERE
                    p.id_cia = pin_id_cia
                AND ( p.situac = v_situac
                      OR ( p.situac = CASE
                                          WHEN ( ( rec_planilla.tippla = 'X' )
                                                 OR ( rec_planilla.tippla = 'Y' )
                                                 OR ( rec_planilla.tippla = 'Z' )
                                                 OR ( rec_planilla.tippla = 'S' ) ) THEN
                                              '02'
                                      END )
                      OR ( p.situac = CASE
                                          WHEN ( ( ( rec_planilla.tippla = 'X' )
                                                   OR ( rec_planilla.tippla = 'Y' )
                                                   OR ( rec_planilla.tippla = 'Z' )
                                                   OR ( rec_planilla.tippla = 'S' ) ) ) THEN
                                              '05'
                                      END ) )
        ) LOOP
            reg_errores.orden := TO_NUMBER ( TRIM(regexp_replace(j.codper, ' [A-Za-z]*')) );

            reg_errores.concepto := j.nomper;
            BEGIN
                SELECT
                    1 AS count
                INTO v_count
                FROM
                    personal_periodo_rpension
                WHERE
                        id_cia = pin_id_cia
                    AND codper = j.codper
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := 'Regimen de Pensiones';
                    reg_errores.deserror := 'No tiene asginado un Regimen de Pensiones';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN
                SELECT
                    1 AS count
                INTO v_count
                FROM
                    personal_periodolaboral
                WHERE
                        id_cia = pin_id_cia
                    AND codper = j.codper
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := 'Periodo Laboral';
                    reg_errores.deserror := 'No tiene asginado un Periodo Laboral';
                    PIPE ROW ( reg_errores );
            END;

            BEGIN ---- TIENE QUE TENER TODAS DOCUMENTOS OBLIGATORIOS ACTIVADOS
                SELECT
                    COUNT(*)
                INTO v_count
                FROM
                    personal_documento
                WHERE
                        id_cia = pin_id_cia
                    AND codper = j.codper
                    AND situac = 'N';

                IF v_count > 0 THEN
                    reg_errores.valor := 'Documentos Obligatorios';
                    reg_errores.deserror := 'Tiene '
                                            || v_count
                                            || ' documentos obligatorios sin definir';
                    PIPE ROW ( reg_errores );
                END IF;

            END;

            BEGIN -- TIENE QUE TENER TODAS CLASES OBLIGATORIAS ACTIVADAS
                SELECT
                    COUNT(*)
                INTO v_count
                FROM
                    personal_clase
                WHERE
                        id_cia = pin_id_cia
                    AND codper = j.codper
                    AND situac = 'N';

                IF v_count > 0 THEN
                    reg_errores.valor := 'Clases Obligatorias';
                    reg_errores.deserror := 'Tiene '
                                            || v_count
                                            || ' clases obligatorios sin definir';
                    PIPE ROW ( reg_errores );
                END IF;

            END;

            BEGIN -- DISTRIBUCION DE COSTO DEBE SER IGUAL A 100%
                SELECT
                    SUM(nvl(prcdis, 0))
                INTO v_sum
                FROM
                    personal_ccosto
                WHERE
                        id_cia = pin_id_cia
                    AND codper = j.codper;

                IF nvl(v_sum, 0) < 100 THEN
                    reg_errores.valor := 'Centro de Costo';
                    reg_errores.deserror := ' Tiene [ '
                                            || nvl(v_sum, 0)
                                            || '% distribuido '
                                            || '] debe ser igual al 100%';

                    PIPE ROW ( reg_errores );
                END IF;

            END;

            -- VALIDACION POR CONCEPTO OBLIGATORIO DIFERENTE DE CERO
            v_mensaje := NULL;
            FOR k IN (
                SELECT
                    pc.codcon AS codcon,
                    c.nombre
                FROM
                         personal_concepto pc
                    INNER JOIN concepto       c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                    INNER JOIN concepto_clase cc ON cc.id_cia = pc.id_cia
                                                    AND cc.codcon = pc.codcon
                                                    AND cc.clase = 30
                                                    AND cc.codigo = 'S'
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.codper = j.codper
                    AND pc.periodo = rec_planilla.anopla
                    AND pc.mes = rec_planilla.mespla
                    AND nvl(pc.valcon, 0) = 0
            ) LOOP
                IF length(v_mensaje) >= 3 THEN
                    reg_errores.valor := 'Concepto Fijo Obligatorio';
                    reg_errores.deserror := 'CONCEPTO [ '
                                            || to_char(k.codcon)
                                            || ' - '
                                            || to_char(k.nombre)
                                            || ' ]';

                    PIPE ROW ( reg_errores );
                END IF;
            END LOOP;

        END LOOP;

        RETURN;
    END sp_valida_objeto;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "tippla":"N",
--                "empobr":"I",
--                "anopla":2022,
--                "mespla":05,
--                "sempla":45,
--                "fecini":"2022-05-01",
--                "fecfin":"2022-06-01",
--                "dianor":15,
--                "hornor":15,
--                "tcambio":3.89,
--                "situac":"P",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_planilla.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_planilla.sp_obtener(66,1);
--
--SELECT * FROM pack_hr_planilla.sp_buscar(66,NULL,NULL,NULL,NULL,NULL);
--
--SELECT * FROM pack_hr_planilla.sp_autocompletar(66,2022,08);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        m            json_object_t;
        rec_planilla planilla%rowtype;
        v_accion     VARCHAR2(50) := '';
        pout_mensaje VARCHAR2(1000) := '';
        v_mensaje    VARCHAR2(1000) := '';
        v_prcdis     NUMBER := 0;
        v_aux        VARCHAR2(100) := '';
        v_indgen     VARCHAR2(1) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_planilla.id_cia := pin_id_cia;
        rec_planilla.numpla := o.get_string('numpla');
        rec_planilla.tippla := o.get_string('tippla');
        rec_planilla.empobr := o.get_string('empobr');
        rec_planilla.anopla := o.get_number('anopla');
        rec_planilla.mespla := o.get_number('mespla');
        rec_planilla.sempla := o.get_number('sempla');
        rec_planilla.fecini := o.get_date('fecini');
        rec_planilla.fecfin := o.get_date('fecfin');
        rec_planilla.dianor := o.get_number('dianor');
        rec_planilla.hornor := o.get_number('hornor');
        rec_planilla.situac := o.get_string('situac');
        rec_planilla.tcambio := o.get_number('tcambio');
        rec_planilla.ucreac := o.get_string('ucreac');
        rec_planilla.uactua := o.get_string('uactua');
        v_accion := '';
        IF rec_planilla.numpla IS NOT NULL THEN
            IF rec_planilla.situac = 'S' THEN
                -- 6 : MODULO PLANILLA 
                sp_chequea_mes_proceso(pin_id_cia, rec_planilla.anopla, rec_planilla.mespla, 6, v_mensaje);
                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            ELSE
                dbms_output.put_line('VERIFICANDO LA EXISTENCIA DE LA PLANILLA');
                BEGIN
                    SELECT
                        situac
                    INTO v_aux
                    FROM
                        pack_hr_planilla.sp_obtener(pin_id_cia, rec_planilla.numpla)
                    WHERE
                        situac = 'S';

                    dbms_output.put_line(v_aux);
                EXCEPTION
                    WHEN no_data_found THEN
                        dbms_output.put_line('LA PLANILLA ESTA CERRADA');
                        pout_mensaje := 'No se puede MODIFICAR O ELIMINAR UNA PLANILLA [ '
                                        || rec_planilla.tippla
                                        || rec_planilla.empobr
                                        || '-'
                                        || rec_planilla.anopla
                                        || '/'
                                        || trim(to_char(rec_planilla.mespla, '00'))
                                        || '-'
                                        || rec_planilla.sempla
                                        || ' ] CERRADA';

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

            END IF;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        MAX(numpla)
                    INTO rec_planilla.numpla
                    FROM
                        planilla
                    WHERE
                        id_cia = pin_id_cia;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_planilla.numpla := 0;
                END;

                rec_planilla.situac := 'S';
                rec_planilla.numpla := nvl(rec_planilla.numpla, 0) + 1;
                v_accion := 'La inserción';
                INSERT INTO planilla (
                    id_cia,
                    numpla,
                    tippla,
                    empobr,
                    anopla,
                    mespla,
                    sempla,
                    fecini,
                    fecfin,
                    dianor,
                    hornor,
                    tcambio,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_planilla.id_cia,
                    rec_planilla.numpla,
                    rec_planilla.tippla,
                    rec_planilla.empobr,
                    rec_planilla.anopla,
                    rec_planilla.mespla,
                    rec_planilla.sempla,
                    rec_planilla.fecini,
                    rec_planilla.fecfin,
                    rec_planilla.dianor,
                    rec_planilla.hornor,
                    rec_planilla.tcambio,
                    rec_planilla.situac,
                    rec_planilla.ucreac,
                    rec_planilla.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                -- CLONANDO AFP - PERIODO ANTERIOR

                pack_hr_factor_afp.sp_clonar(pin_id_cia, rec_planilla.anopla, rec_planilla.mespla, NULL, v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                -- GENERANDO PLANILLA
                pack_hr_planilla.sp_generar(pin_id_cia, rec_planilla.numpla, pin_datos, pin_opcdml, rec_planilla.ucreac,
                                           v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE planilla
                SET
                    tippla =
                        CASE
                            WHEN rec_planilla.tippla IS NULL THEN
                                tippla
                            ELSE
                                rec_planilla.tippla
                        END,
                    empobr =
                        CASE
                            WHEN rec_planilla.empobr IS NULL THEN
                                empobr
                            ELSE
                                rec_planilla.empobr
                        END,
                    anopla =
                        CASE
                            WHEN rec_planilla.anopla IS NULL THEN
                                anopla
                            ELSE
                                rec_planilla.anopla
                        END,
                    mespla =
                        CASE
                            WHEN rec_planilla.mespla IS NULL THEN
                                mespla
                            ELSE
                                rec_planilla.mespla
                        END,
                    sempla =
                        CASE
                            WHEN rec_planilla.sempla IS NULL THEN
                                sempla
                            ELSE
                                rec_planilla.sempla
                        END,
                    fecini =
                        CASE
                            WHEN rec_planilla.fecini IS NULL THEN
                                fecini
                            ELSE
                                rec_planilla.fecini
                        END,
                    fecfin =
                        CASE
                            WHEN rec_planilla.fecfin IS NULL THEN
                                fecfin
                            ELSE
                                rec_planilla.fecfin
                        END,
                    dianor =
                        CASE
                            WHEN rec_planilla.dianor IS NULL THEN
                                dianor
                            ELSE
                                rec_planilla.dianor
                        END,
                    hornor =
                        CASE
                            WHEN rec_planilla.hornor IS NULL THEN
                                hornor
                            ELSE
                                rec_planilla.hornor
                        END,
                    situac =
                        CASE
                            WHEN rec_planilla.situac IS NULL THEN
                                situac
                            ELSE
                                rec_planilla.situac
                        END,
                    tcambio =
                        CASE
                            WHEN rec_planilla.tcambio IS NULL THEN
                                tcambio
                            ELSE
                                rec_planilla.tcambio
                        END,
                    uactua =
                        CASE
                            WHEN rec_planilla.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_planilla.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM dsctoprestamo
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_saldoprestamo
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_rango
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_concepto_respaldo
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_concepto
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_afp
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_auxiliar
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla_resumen
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

                DELETE FROM planilla
                WHERE
                        id_cia = rec_planilla.id_cia
                    AND numpla = rec_planilla.numpla;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                            'message' VALUE 'La Planilla [ '
                                            || rec_planilla.tippla
                                            || rec_planilla.empobr
                                            || '-'
                                            || rec_planilla.anopla
                                            || '/'
                                            || TRIM(to_char(rec_planilla.mespla, '00'))
                                            || '-'
                                            || rec_planilla.sempla
                                            || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incor reg_erroresto'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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

            ELSIF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'Mes cerrado en el Módulo de Planilla'
                    )
                INTO pin_mensaje
                FROM
                    dual;

                ROLLBACK;
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

                ROLLBACK;
            END IF;
    END sp_save;

    PROCEDURE sp_generar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_situac      VARCHAR2(2) := '';
        o             json_object_t;
        m             json_object_t;
        rec_planilla  planilla%rowtype;
        pout_mensaje  VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_conpre      VARCHAR2(3) := '';
        v_indgen      VARCHAR2(1) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_valor       VARCHAR2(1000) := '';
    BEGIN
        -- SEGUNDO VALIDACION SEGUN EL TIPO DE PLANILLA
        o := json_object_t.parse(pin_datos);
        rec_planilla.tippla := o.get_string('tippla');
        rec_planilla.empobr := o.get_string('empobr');
        rec_planilla.situac := o.get_string('situac');
        rec_planilla.anopla := o.get_number('anopla');
        rec_planilla.mespla := o.get_number('mespla');
        rec_planilla.fecini := o.get_date('fecini');
        rec_planilla.fecfin := o.get_date('fecfin');
        rec_planilla.hornor := o.get_number('hornor');
        rec_planilla.dianor := o.get_number('dianor');
        rec_planilla.ucreac := o.get_string('ucreac');
        rec_planilla.uactua := o.get_string('uactua');
        IF ( ( rec_planilla.tippla = 'G' ) OR ( rec_planilla.tippla = 'N' ) OR ( rec_planilla.tippla = 'S' ) OR ( rec_planilla.tippla = 'P'
        ) OR ( rec_planilla.tippla = 'X' ) OR ( rec_planilla.tippla = 'Y' ) OR ( rec_planilla.tippla = 'Z' ) ) THEN
            v_situac := '01';
        ELSIF ( rec_planilla.tippla = 'C' ) THEN
            v_situac := '03';
        ELSIF ( rec_planilla.tippla = 'V' ) THEN
            v_situac := '02';
        ELSIF ( rec_planilla.tippla = 'L' ) THEN
            v_situac := '05';
        END IF;

        -- GENERAMOS LA PLANILLA SEGUN EL PERSONAL - INICIALIZAMOS EN 0 LOS TOTALES
        IF v_situac <> '05' THEN
            -- GENERANDO LA PLANILLA AUXILIAR
            INSERT INTO planilla_auxiliar
                (
                    SELECT
                        p.id_cia,
                        pin_numpla,
                        p.codper,
                        rec_planilla.fecini,
                        rec_planilla.fecfin,
                        p.id_plab,
                        p.finicio,
                        p.ffinal,
                        p.situac,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin)
                        p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND ( p.situac = v_situac
                              OR ( p.situac = CASE
                                                  WHEN ( ( rec_planilla.tippla = 'X' )
                                                         OR ( rec_planilla.tippla = 'Y' )
                                                         OR ( rec_planilla.tippla = 'Z' )
                                                         OR ( rec_planilla.tippla = 'S' ) ) THEN
                                                      '02'
                                              END )
                              OR ( p.situac = CASE
                                                  WHEN ( ( ( rec_planilla.tippla = 'X' )
                                                           OR ( rec_planilla.tippla = 'Y' )
                                                           OR ( rec_planilla.tippla = 'Z' )
                                                           OR ( rec_planilla.tippla = 'S' ) ) ) THEN
                                                      '05'
                                              END ) )
                );

            -- CLONANDO CONCEPTOS FIJOS - PERIODO ANTERIOR
            pack_hr_personal_concepto.sp_clonar(pin_id_cia, pin_numpla, rec_planilla.anopla, rec_planilla.mespla, rec_planilla.ucreac
            ,
                                               v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            -- GENERANDO LA PLANILLA RESUMEN
            INSERT INTO planilla_resumen
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        rec_planilla.hornor,
                        rec_planilla.dianor,
                        0,
                        0,
                        0,
                        0,
                        0,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        planilla_auxiliar pa
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );
            -- GENERANDO LA PLANILLA AFP
            INSERT INTO planilla_afp
                (
                    SELECT
                        p.id_cia,
                        pa.numpla,
                        p.codper,
                        p.codafp,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             planilla_auxiliar pa
                        INNER JOIN pack_hr_personal_periodo_rpension.sp_regimenpension(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini
                        , rec_planilla.fecfin) p ON p.id_cia = pa.id_cia
                                                                                                                                    AND
                                                                                                                                    pa.numpla = pin_numpla
                                                                                                                                    AND
                                                                                                                                    p.codper = pa.codper
                    WHERE
                        p.id_cia = pin_id_cia
                );

            -- GENERAMOS LA PLANILLA_CONCEPTO ( CONCETOS NO FIJOS )
            INSERT INTO planilla_concepto (
                id_cia,
                numpla,
                codper,
                codcon,
                valcon,
                situac,
                proceso,
                ucreac,
                uactua,
                fcreac,
                factua
            )
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        c.codcon,
                        0,
                        'S',
                        0,
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             planilla_auxiliar pa
                        INNER JOIN concepto              c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                                                 AND c.fijvar <> 'F'
                        INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = c.id_cia
                                                               AND c.codcon = tc.codcon
                                                               AND tc.tippla = rec_planilla.tippla
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );


            -- GENERAMOS LA PLANILLA_CONCEPTO ( CONCETOS FIJOS )
            INSERT INTO planilla_concepto (
                id_cia,
                numpla,
                codper,
                codcon,
                valcon,
                situac,
                proceso,
                ucreac,
                uactua,
                fcreac,
                factua
            )
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        c.codcon,
                        0,
                        'S',
                        0,
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             planilla_auxiliar pa
                        INNER JOIN concepto c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                                                 AND c.fijvar = 'F'
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );

            -- ACTUALIZA LOS CONCEPTOS FIJOS CARGADOS ATRAVES DE LA TABLA PERSONAL_CONCEPTO
            FOR x IN (
                SELECT
                    pc.codper,
                    pc.codcon,
                    pc.valcon
                FROM
                         personal_concepto pc
                    INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                                             AND c.empobr = rec_planilla.empobr
                WHERE
                        pc.id_cia = pin_id_cia
                    AND c.fijvar = 'F' -- SOLO CONCEPTOS FIJOS
                    AND pc.codper = pc.codper
                    AND pc.codcon = pc.codcon
                    AND pc.periodo = rec_planilla.anopla
                    AND pc.mes = rec_planilla.mespla
            ) LOOP
                UPDATE planilla_concepto
                SET
                    valcon = x.valcon
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = x.codper
                    AND codcon = x.codcon;

            END LOOP;

            -- ACTUALIZA EN 0 EL VALOR DE LOS CONCEPTOS, DEL PERSONAL NO AFECTO
            FOR y IN (
                SELECT
                    *
                FROM
                    planilla_concepto pc
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = pin_numpla
                    AND EXISTS (
                        SELECT
                            *
                        FROM
                            personal_noafecto pn
                        WHERE
                                pn.id_cia = pc.id_cia
                            AND pn.codper = pc.codper
                            AND pn.codcon = pc.codcon
                    )
            ) LOOP
                UPDATE planilla_concepto
                SET
                    valcon = 0
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = y.codper
                    AND codcon = y.codcon;

            END LOOP;

            -- GENERA LA PLANILLA DE SALDOS DE PRESTAMOS
            INSERT INTO planilla_saldoprestamo
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        NULL,
                        rec_planilla.empobr,
                        NULL,
                        0,
                        0,
                        'N',
                        pin_coduser,
                        pin_coduser,
                        current_timestamp,
                        current_timestamp
                    FROM
                        planilla_auxiliar pa
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );

        ELSE
            -- PLANILLA DE LIQUIDACION
            -- PRIMERO LA PLANILLA AUXILIAR
            INSERT INTO planilla_auxiliar
                (
                    SELECT
                        p.id_cia,
                        pin_numpla,
                        p.codper,
                        rec_planilla.fecini,
                        rec_planilla.fecfin,
                        p.id_plab,
                        p.finicio,
                        p.ffinal,
                        p.situac,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin)
                        p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.situac = v_situac
                        AND EXTRACT(YEAR FROM p.ffinal) = rec_planilla.anopla
                        AND EXTRACT(MONTH FROM p.ffinal) = rec_planilla.mespla
                );

            -- CLONANDO CONCEPTOS FIJOS - PERIODO ANTERIOR
            pack_hr_personal_concepto.sp_clonar(pin_id_cia, pin_numpla, rec_planilla.anopla, rec_planilla.mespla, rec_planilla.ucreac
            ,
                                               v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            INSERT INTO planilla_resumen
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        rec_planilla.hornor,
                        rec_planilla.dianor,
                        0,
                        0,
                        0,
                        0,
                        0,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        planilla_auxiliar pa
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );
            -- AGREGA EL NUEVO PERSONAL INCORPORADO A LA PLANILLA DE AFP
            INSERT INTO planilla_afp
                (
                    SELECT
                        p.id_cia,
                        pin_numpla,
                        p.codper,
                        p.codafp,
                        'S',
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             pack_hr_personal_periodo_rpension.sp_regimenpension(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini
                             , rec_planilla.fecfin) p
                        INNER JOIN planilla_auxiliar pa ON pa.id_cia = pin_id_cia
                                                           AND pa.numpla = pin_numpla
                                                           AND pa.codper = p.codper
                    WHERE
                        p.id_cia = pin_id_cia
                );

            -- ADICIONA LOS CONCEPTOS VARIABLES, PARA EL NUEVO PERSONAL INCOPORADO
            INSERT INTO planilla_concepto
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        c.codcon,
                        0,
                        'S',
                        0,
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             planilla_auxiliar pa
                        INNER JOIN concepto              c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                                                 AND c.fijvar <> 'F'
                        INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = c.id_cia
                                                               AND c.codcon = tc.codcon
                                                               AND tc.tippla = rec_planilla.tippla
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );

                -- ADICIONA LOS CONCEPTOS FIJOS, PARA EL NUEVO PERSONAL INCOPORADO
            INSERT INTO planilla_concepto
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        c.codcon,
                        0,
                        'S',
                        0,
                        rec_planilla.ucreac,
                        rec_planilla.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                             planilla_auxiliar pa
                        INNER JOIN concepto c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                                                 AND c.fijvar = 'F'
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );

               -- ACTUALIZA LOS CONCEPTOS FIJOS CARGADOS ATRAVES DE LA TABLA PERSONAL_CONCEPTO
            FOR x IN (
                SELECT
                    pc.codper,
                    pc.codcon,
                    pc.valcon
                FROM
                         personal_concepto pc
                    INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
--                                                 AND c.empobr = rec_planilla.empobr
                                             AND c.empobr = 'E'
                WHERE
                        pc.id_cia = pin_id_cia
                    AND c.fijvar = 'F' -- SOLO CONCEPTOS FIJOS
                    AND pc.codper = pc.codper
                    AND pc.codcon = pc.codcon
                    AND pc.periodo = rec_planilla.anopla
                    AND pc.mes = rec_planilla.mespla
            ) LOOP
                UPDATE planilla_concepto
                SET
                    valcon = x.valcon
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = x.codper
                    AND codcon = x.codcon;

            END LOOP;

            -- ACTUALIZA EN 0 EL VALOR DE LOS CONCEPTOS, DEL PERSONAL NO AFECTO
            FOR y IN (
                SELECT
                    *
                FROM
                    planilla_concepto pc
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = pin_numpla
                    AND EXISTS (
                        SELECT
                            *
                        FROM
                            personal_noafecto pn
                        WHERE
                                pn.id_cia = pc.id_cia
                            AND pn.codper = pc.codper
                            AND pn.codcon = pc.codcon
                    )
            ) LOOP
                UPDATE planilla_concepto
                SET
                    valcon = 0
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = y.codper
                    AND codcon = y.codcon;

            END LOOP;

            -- GENERA LA PLANILLA DE SALDOS DE PRESTAMOS
            INSERT INTO planilla_saldoprestamo
                (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        NULL,
                        rec_planilla.empobr,
                        NULL,
                        0,
                        0,
                        'N',
                        pin_coduser,
                        pin_coduser,
                        current_timestamp,
                        current_timestamp
                    FROM
                        planilla_auxiliar pa
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                );

        END IF;

        -- PROCESANDO CONCEPTO DE SISTEMA
        FOR k IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'S'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
        ) LOOP
            pack_hr_planilla_formula.sp_decodificar_csistema(pin_id_cia, pin_numpla, k.codper, k.codcon, 'S',
                                                            pin_coduser, k.codcon, v_formula, v_aux_formula, v_valor,
                                                            v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        -- PROCESANDO CONCEPTO DE PRESTAMO
        FOR k IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'P'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
        ) LOOP
            pack_hr_planilla_formula.sp_decodificar_cprestamo(pin_id_cia, pin_numpla, k.codper, k.codcon, 'S',
                                                             pin_coduser, k.codcon, v_formula, v_aux_formula, v_valor,
                                                             v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La Planilla se Proceso correctamente ...!'
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

            ROLLBACK;
            DELETE FROM planilla_auxiliar
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            COMMIT;
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

                ROLLBACK;
                DELETE FROM planilla_auxiliar
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                DELETE FROM planilla
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                COMMIT;
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

                ROLLBACK;
                DELETE FROM planilla_auxiliar
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                DELETE FROM planilla
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                COMMIT;
            END IF;
    END sp_generar;

    PROCEDURE sp_refrescar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_situac      VARCHAR2(2) := '';
        o             json_object_t;
        m             json_object_t;
        rec_planilla  planilla%rowtype;
        pout_mensaje  VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_conpre      VARCHAR2(3) := '';
        v_indgen      VARCHAR2(1) := '';
        v_indcam      VARCHAR2(1) := '';
        v_aux         VARCHAR2(1000) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_valor       VARCHAR2(1000) := '';
    BEGIN
        -- SEGUNDO VALIDACION SEGUN EL TIPO DE PLANILLA
        o := json_object_t.parse(pin_datos);
        rec_planilla.tippla := o.get_string('tippla');
        rec_planilla.empobr := o.get_string('empobr');
        rec_planilla.situac := o.get_string('situac');
        rec_planilla.anopla := o.get_number('anopla');
        rec_planilla.mespla := o.get_number('mespla');
        rec_planilla.sempla := o.get_number('sempla');
        rec_planilla.fecini := o.get_date('fecini');
        rec_planilla.fecfin := o.get_date('fecfin');
        rec_planilla.hornor := o.get_number('hornor');
        rec_planilla.dianor := o.get_number('dianor');
        rec_planilla.ucreac := o.get_string('ucreac');
        rec_planilla.uactua := o.get_string('uactua');
        BEGIN
            SELECT
                situac
            INTO v_aux
            FROM
                pack_hr_planilla.sp_obtener(pin_id_cia, pin_numpla)
            WHERE
                situac = 'S';

            dbms_output.put_line(v_aux);
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('LA PLANILLA ESTA CERRADA');
                pout_mensaje := 'No se puede Refrescar una Planilla [ '
                                || rec_planilla.tippla
                                || rec_planilla.empobr
                                || '-'
                                || rec_planilla.anopla
                                || '/'
                                || trim(to_char(rec_planilla.mespla, '00'))
                                || '-'
                                || rec_planilla.sempla
                                || ' ] cerrada ...!';

                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF ( ( rec_planilla.tippla = 'G' ) OR ( rec_planilla.tippla = 'N' ) OR ( rec_planilla.tippla = 'S' ) OR ( rec_planilla.tippla = 'P'
        ) OR ( rec_planilla.tippla = 'X' ) OR ( rec_planilla.tippla = 'Y' ) OR ( rec_planilla.tippla = 'Z' ) ) THEN
            v_situac := '01';
        ELSIF ( rec_planilla.tippla = 'C' ) THEN
            v_situac := '03';
        ELSIF ( rec_planilla.tippla = 'V' ) THEN
            v_situac := '02';
        ELSIF ( rec_planilla.tippla = 'L' ) THEN
            v_situac := '05';
        END IF;

    -- VERIFICAMOS SI EXISTE, ALGUN CAMBIO EN LA PLANILLA*
        BEGIN
            SELECT
                'S'
            INTO v_indcam
            FROM
                planilla
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla
                AND ( tippla <> rec_planilla.tippla
                      OR empobr <> rec_planilla.empobr
                      OR anopla <> rec_planilla.anopla
                      OR mespla <> rec_planilla.mespla
                      OR sempla <> rec_planilla.sempla );

        EXCEPTION
            WHEN no_data_found THEN
                v_indcam := 'N';
        END;
    -- ACTUALIZAMOS LA PLANILLA
        UPDATE planilla
        SET
            tippla = rec_planilla.tippla,
            empobr = rec_planilla.empobr,
            anopla = rec_planilla.anopla,
            mespla = rec_planilla.mespla,
            sempla = rec_planilla.sempla,
            fecini = rec_planilla.fecini,
            fecfin = rec_planilla.fecfin,
            dianor = rec_planilla.dianor,
            hornor = rec_planilla.hornor,
            situac = rec_planilla.situac,
            tcambio = rec_planilla.tcambio
        WHERE
                id_cia = pin_id_cia
            AND numpla = rec_planilla.numpla;

        IF v_indcam = 'S' THEN
        -- SI SE MODIFICO LA PLANILLA
            --  REGERENEGAMOS TODOS LOS DESCUENTOS POR PRESTAMOS
            DELETE FROM dsctoprestamo
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            -- REGERENEGAMOS TODOS LOS SALDOS DEL MES REGISTRADOS
            DELETE FROM planilla_saldoprestamo
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla_concepto
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla_resumen
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla_afp
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla_auxiliar
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla_rango
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            DELETE FROM planilla
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            pack_hr_planilla.sp_generar(pin_id_cia, pin_numpla, pin_datos, 1, pin_coduser,
                                       v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSE

            -- REGERENEGAMOS TODOS LOS TRABAJADORES ELIMINADOS
            UPDATE planilla_resumen
            SET
                situac = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            UPDATE planilla_concepto
            SET
                situac = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            UPDATE planilla_auxiliar
            SET
                situac = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            UPDATE planilla_afp
            SET
                situac = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            --  REGERENEGAMOS TODOS LOS DESCUENTOS POR PRESTAMOS
            DELETE FROM dsctoprestamo
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            -- REGERENEGAMOS TODOS LOS SALDOS DEL MES REGISTRADOS
            DELETE FROM planilla_saldoprestamo
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla;

            -- REGENERAMOS LOS CONCEPTOS RELACIONADOS A LOS PRESTAMOS
            IF v_situac <> '05' THEN
            -- NO ES PLANILLA DE LIQUIDACION

            -- PRIMERO LA PLANILLA AUXILIAR
                INSERT INTO planilla_auxiliar
                    (
                        SELECT
                            p.id_cia,
                            pin_numpla,
                            p.codper,
                            rec_planilla.fecini,
                            rec_planilla.fecfin,
                            p.id_plab,
                            p.finicio,
                            p.ffinal,
                            p.situac,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                            pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin
                            ) p
                        WHERE
                                p.id_cia = pin_id_cia
                            AND ( p.situac = v_situac
                                  OR ( p.situac = CASE
                                                      WHEN ( ( rec_planilla.tippla = 'X' )
                                                             OR ( rec_planilla.tippla = 'Y' )
                                                             OR ( rec_planilla.tippla = 'Z' )
                                                             OR ( rec_planilla.tippla = 'S' ) ) THEN
                                                          '02'
                                                  END )
                                  OR ( p.situac = CASE
                                                      WHEN ( ( ( rec_planilla.tippla = 'X' )
                                                               OR ( rec_planilla.tippla = 'Y' )
                                                               OR ( rec_planilla.tippla = 'Z' )
                                                               OR ( rec_planilla.tippla = 'S' ) ) ) THEN
                                                          '05'
                                                  END ) )
                            AND NOT EXISTS (
                                SELECT
                                    pr.*
                                FROM
                                    planilla_auxiliar pa
                                WHERE
                                        pa.id_cia = p.id_cia
                                    AND pa.numpla = pin_numpla
                                    AND pa.codper = p.codper
                            )
                    );        

                -- ACTUALIZANDO LA PLANILLA AUXILIAR, NUEVA FECHAS DE  CESE / SITUACION
                FOR i IN (
                    SELECT
                        p.codper,
                        p.finicio,
                        p.ffinal,
                        p.situac
                    FROM
                        pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin)
                        p
                ) LOOP
                    UPDATE planilla_auxiliar
                    SET
                        finicio = i.finicio,
                        ffinal = i.ffinal,
                        situacper = i.situac
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper;

                END LOOP;
                -- CLONANDO CONCEPTOS FIJOS - PERIODO ANTERIOR
                pack_hr_personal_concepto.sp_clonar(pin_id_cia, pin_numpla, rec_planilla.anopla, rec_planilla.mespla, rec_planilla.ucreac
                ,
                                                   v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            -- AGREGA EL NUEVO PERSONAL INCORPORADO, SEGUN EL TIPO DE TRABAJADOR, A LA PLANILLA RESUMEN
                INSERT INTO planilla_resumen
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            rec_planilla.hornor,
                            rec_planilla.dianor,
                            0,
                            0,
                            0,
                            0,
                            0,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                            planilla_auxiliar pa
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    pr.*
                                FROM
                                    planilla_resumen pr
                                WHERE
                                        pr.id_cia = pa.id_cia
                                    AND pr.numpla = pa.numpla
                                    AND pr.codper = pa.codper
                            )
                    );

                -- AGREGA EL NUEVO PERSONAL INCORPORADO A LA PLANILLA DE AFP
                -- REINSERTAMOS, LA PLANILLA AFP
                DELETE FROM planilla_afp
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                INSERT INTO planilla_afp
                    (
                        SELECT
                            p.id_cia,
                            pin_numpla,
                            p.codper,
                            p.codafp,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 planilla_auxiliar pa
                            INNER JOIN pack_hr_personal_periodo_rpension.sp_regimenpension(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini
                            , rec_planilla.fecfin) p ON p.id_cia = pa.id_cia
                                                                                                                                        AND
                                                                                                                                        pa.numpla = pin_numpla
                                                                                                                                        AND
                                                                                                                                        p.codper = pa.codper
                        WHERE
                            p.id_cia = pin_id_cia
                    );

                -- ADICIONA LOS CONCEPTOS VARIABLES, PARA EL NUEVO PERSONAL INCOPORADO
                INSERT INTO planilla_concepto
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            c.codcon,
                            0,
                            'S',
                            0,
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 planilla_auxiliar pa
                            INNER JOIN concepto              c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                     AND c.empobr = 'E'
                                                     AND c.fijvar <> 'F'
                            INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = c.id_cia
                                                                   AND c.codcon = tc.codcon
                                                                   AND tc.tippla = rec_planilla.tippla
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    *
                                FROM
                                    planilla_concepto pc
                                WHERE
                                        pc.id_cia = pa.id_cia
                                    AND pc.numpla = pa.numpla
                                    AND pc.codper = pa.codper
                                    AND pc.codcon = c.codcon
                            )
                    );

                -- ADICIONA LOS CONCEPTOS FIJOS, PARA EL NUEVO PERSONAL INCOPORADO
                INSERT INTO planilla_concepto
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            c.codcon,
                            0,
                            'S',
                            0,
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 planilla_auxiliar pa
                            INNER JOIN concepto c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                     AND c.empobr = 'E'
                                                     AND c.fijvar = 'F'
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    *
                                FROM
                                    planilla_concepto pc
                                WHERE
                                        pc.id_cia = pa.id_cia
                                    AND pc.numpla = pa.numpla
                                    AND pc.codper = pa.codper
                                    AND pc.codcon = c.codcon
                            )
                    );

                -- ACTUALIZA LOS CONCEPTOS FIJOS CARGADOS ATRAVES DE LA TABLA PERSONAL_CONCEPTO
                FOR x IN (
                    SELECT
                        pc.codper,
                        pc.codcon,
                        pc.valcon
                    FROM
                             personal_concepto pc
                        INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                 AND c.codcon = pc.codcon
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND c.fijvar = 'F' -- SOLO CONCEPTOS FIJOS
                        AND pc.codper = pc.codper
                        AND pc.codcon = pc.codcon
                        AND pc.periodo = rec_planilla.anopla
                        AND pc.mes = rec_planilla.mespla
                ) LOOP
                    UPDATE planilla_concepto
                    SET
                        valcon = x.valcon
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = x.codper
                        AND codcon = x.codcon;

                END LOOP;

                -- ACTUALIZA EN 0 EL VALOR DE LOS CONCEPTOS, DEL PERSONAL NO AFECTO
                FOR y IN (
                    SELECT
                        *
                    FROM
                        planilla_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = pin_numpla
                        AND EXISTS (
                            SELECT
                                *
                            FROM
                                personal_noafecto pn
                            WHERE
                                    pn.id_cia = pc.id_cia
                                AND pn.codper = pc.codper
                                AND pn.codcon = pc.codcon
                        )
                ) LOOP
                    UPDATE planilla_concepto
                    SET
                        valcon = 0
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = y.codper
                        AND codcon = y.codcon;

                END LOOP;

                -- GENERA LA PLANILLA DE SALDOS DE PRESTAMOS
                INSERT INTO planilla_saldoprestamo
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            NULL,
                            rec_planilla.empobr,
                            NULL,
                            0,
                            0,
                            'N',
                            pin_coduser,
                            pin_coduser,
                            current_timestamp,
                            current_timestamp
                        FROM
                            planilla_auxiliar pa
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                    );

            ELSE
                -- LIQUIDACIONES

                -- PRIMERO LA PLANILLA AUXILIAR
                INSERT INTO planilla_auxiliar
                    (
                        SELECT
                            p.id_cia,
                            pin_numpla,
                            p.codper,
                            rec_planilla.fecini,
                            rec_planilla.fecfin,
                            p.id_plab,
                            p.finicio,
                            p.ffinal,
                            p.situac,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                            pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin
                            ) p
                        WHERE
                                p.id_cia = pin_id_cia
                            AND p.situac = v_situac
                            AND EXTRACT(YEAR FROM p.ffinal) = rec_planilla.anopla
                            AND EXTRACT(MONTH FROM p.ffinal) = rec_planilla.mespla
                            AND NOT EXISTS (
                                SELECT
                                    pr.*
                                FROM
                                    planilla_auxiliar pa
                                WHERE
                                        pa.id_cia = p.id_cia
                                    AND pa.numpla = pin_numpla
                                    AND pa.codper = p.codper
                            )
                    );

                -- ACTUALIZANDO LA PLANILLA AUXILIAR, NUEVA FECHAS DE  CESE / SITUACION
                FOR i IN (
                    SELECT
                        p.codper,
                        p.finicio,
                        p.ffinal,
                        p.situac
                    FROM
                        pack_hr_planilla.sp_periodolaboral(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini, rec_planilla.fecfin)
                        p
                ) LOOP
                    UPDATE planilla_auxiliar
                    SET
                        finicio = i.finicio,
                        ffinal = i.ffinal,
                        situacper = i.situac
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper;

                END LOOP;
                -- CLONANDO CONCEPTOS FIJOS - PERIODO ANTERIOR
                pack_hr_personal_concepto.sp_clonar(pin_id_cia, pin_numpla, rec_planilla.anopla, rec_planilla.mespla, rec_planilla.ucreac
                ,
                                                   v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                -- AGREGA AL PERSONAL, SEGUN EL TIPO DE TRABAJADOR, A LA PLANILLA RESUMEN
                -- RECIENTEMENTE ACTUALIZADA                
                INSERT INTO planilla_resumen
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            rec_planilla.hornor,
                            rec_planilla.dianor,
                            0,
                            0,
                            0,
                            0,
                            0,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                            planilla_auxiliar pa
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    pr.*
                                FROM
                                    planilla_resumen pr
                                WHERE
                                        pr.id_cia = pa.id_cia
                                    AND pr.numpla = pa.numpla
                                    AND pr.codper = pa.codper
                            )
                    );

                -- AGREGA EL NUEVO PERSONAL INCORPORADO A LA PLANILLA DE AFP
                -- REINSERTAMOS, LA PLANILLA AFP
                DELETE FROM planilla_afp
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla;

                INSERT INTO planilla_afp
                    (
                        SELECT
                            p.id_cia,
                            pin_numpla,
                            p.codper,
                            p.codafp,
                            'S',
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 pack_hr_personal_periodo_rpension.sp_regimenpension(pin_id_cia, rec_planilla.empobr, rec_planilla.fecini
                                 , rec_planilla.fecfin) p
                            INNER JOIN planilla_auxiliar pa ON pa.id_cia = pin_id_cia
                                                               AND pa.numpla = pin_numpla
                                                               AND pa.codper = p.codper
                        WHERE
                            p.id_cia = pin_id_cia
                    );

                -- ADICIONA LOS CONCEPTOS VARIABLES, PARA EL NUEVO PERSONAL INCOPORADO
                INSERT INTO planilla_concepto
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            c.codcon,
                            0,
                            'S',
                            0,
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 planilla_auxiliar pa
                            INNER JOIN concepto              c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                     AND c.empobr = 'E'
                                                     AND c.fijvar <> 'F'
                            INNER JOIN tipoplanilla_concepto tc ON tc.id_cia = c.id_cia
                                                                   AND c.codcon = tc.codcon
                                                                   AND tc.tippla = rec_planilla.tippla
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    *
                                FROM
                                    planilla_concepto pc
                                WHERE
                                        pc.id_cia = pa.id_cia
                                    AND pc.numpla = pa.numpla
                                    AND pc.codper = pa.codper
                                    AND pc.codcon = c.codcon
                            )
                    );

                -- ADICIONA LOS CONCEPTOS FIJOS, PARA EL NUEVO PERSONAL INCOPORADO
                INSERT INTO planilla_concepto
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            c.codcon,
                            0,
                            'S',
                            0,
                            rec_planilla.ucreac,
                            rec_planilla.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 planilla_auxiliar pa
                            INNER JOIN concepto c ON c.id_cia = pa.id_cia
--                                                 AND c.empobr = rec_planilla.empobr
                                                     AND c.empobr = 'E'
                                                     AND c.fijvar = 'F'
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                            AND NOT EXISTS (
                                SELECT
                                    *
                                FROM
                                    planilla_concepto pc
                                WHERE
                                        pc.id_cia = pa.id_cia
                                    AND pc.numpla = pa.numpla
                                    AND pc.codper = pa.codper
                                    AND pc.codcon = c.codcon
                            )
                    );

                -- ACTUALIZA LOS CONCEPTOS FIJOS CARGADOS ATRAVES DE LA TABLA PERSONAL_CONCEPTO
                FOR x IN (
                    SELECT
                        pc.codper,
                        pc.codcon,
                        pc.valcon
                    FROM
                             personal_concepto pc
                        INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                                 AND c.codcon = pc.codcon
--                                                 AND c.empobr = rec_planilla.empobr
                                                 AND c.empobr = 'E'
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND c.fijvar = 'F' -- SOLO CONCEPTOS FIJOS
                        AND pc.codper = pc.codper
                        AND pc.codcon = pc.codcon
                        AND pc.periodo = rec_planilla.anopla
                        AND pc.mes = rec_planilla.mespla
                ) LOOP
                    UPDATE planilla_concepto
                    SET
                        valcon = x.valcon
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = x.codper
                        AND codcon = x.codcon;

                END LOOP;

                -- ACTUALIZA EN 0 EL VALOR DE LOS CONCEPTOS, DEL PERSONAL NO AFECTO
                FOR y IN (
                    SELECT
                        *
                    FROM
                        planilla_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = pin_numpla
                        AND EXISTS (
                            SELECT
                                *
                            FROM
                                personal_noafecto pn
                            WHERE
                                    pn.id_cia = pc.id_cia
                                AND pn.codper = pc.codper
                                AND pn.codcon = pc.codcon
                        )
                ) LOOP
                    UPDATE planilla_concepto
                    SET
                        valcon = 0
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = y.codper
                        AND codcon = y.codcon;

                END LOOP;

                -- ADICIONAR A LA PLANILLA DE PRESTAMO A LOS TRABAJADORES ADICIONALES
                -- GENERA LA PLANILLA DE SALDOS DE PRESTAMOS
                INSERT INTO planilla_saldoprestamo
                    (
                        SELECT
                            pa.id_cia,
                            pa.numpla,
                            pa.codper,
                            NULL,
                            rec_planilla.empobr,
                            NULL,
                            0,
                            0,
                            'N',
                            pin_coduser,
                            pin_coduser,
                            current_timestamp,
                            current_timestamp
                        FROM
                            planilla_auxiliar pa
                        WHERE
                                pa.id_cia = pin_id_cia
                            AND pa.numpla = pin_numpla
                    );

            END IF;

        END IF;

        -- PROCESANDO CONCEPTO DE SISTEMA
        FOR k IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'S'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
        ) LOOP
            pack_hr_planilla_formula.sp_decodificar_csistema(pin_id_cia, pin_numpla, k.codper, k.codcon, 'S',
                                                            pin_coduser, k.codcon, v_formula, v_aux_formula, v_valor,
                                                            v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        -- PROCESANDO CONCEPTO DE PRESTAMO
        FOR k IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'P'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
        ) LOOP
            pack_hr_planilla_formula.sp_decodificar_cprestamo(pin_id_cia, pin_numpla, k.codper, k.codcon, 'S',
                                                             pin_coduser, k.codcon, v_formula, v_aux_formula, v_valor,
                                                             v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La Planilla se Re-Proceso correctamente ...!'
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

            ROLLBACK;
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

                ROLLBACK;
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

                ROLLBACK;
            END IF;
    END sp_refrescar;

    FUNCTION sp_valida_objeto_ordenado (
        pin_id_cia  NUMBER,
        pin_datos   CLOB,
        pin_orderby NUMBER
    ) RETURN datatable
        PIPELINED
    AS
        v_table datatable;
    BEGIN
        SELECT
            v.*
        BULK COLLECT
        INTO v_table
        FROM
            pack_hr_planilla.sp_valida_objeto(pin_id_cia, pin_datos) v
        ORDER BY
            CASE
                WHEN pin_orderby = 1 THEN
                    v.orden
--                v.codper DESC
                WHEN pin_orderby = 2 THEN
--                v.codper DESC,
                    v.orden
            END;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_valida_objeto_ordenado;

    PROCEDURE sp_planilla_cerrada (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000) := '';
        rec_planilla planilla%rowtype;
        v_aux        VARCHAR2(100) := '';
    BEGIN
        dbms_output.put_line('BUSCANDO PLANILLA');
        SELECT
            situac
        INTO v_aux
        FROM
            pack_hr_planilla.sp_obtener(pin_id_cia, pin_numpla)
        WHERE
            situac = 'S';

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Succees ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN no_data_found THEN
            SELECT
                tippla,
                empobr,
                anopla,
                mespla,
                sempla
            INTO
                rec_planilla.tippla,
                rec_planilla.empobr,
                rec_planilla.anopla,
                rec_planilla.mespla,
                rec_planilla.sempla
            FROM
                pack_hr_planilla.sp_obtener(pin_id_cia, pin_numpla);

            dbms_output.put_line('LA PLANILLA ESTA CERRADA');
            pout_mensaje := 'No se puede Refrescar una Planilla [ '
                            || rec_planilla.tippla
                            || rec_planilla.empobr
                            || '-'
                            || rec_planilla.anopla
                            || '/'
                            || trim(to_char(rec_planilla.mespla, '00'))
                            || '-'
                            || rec_planilla.sempla
                            || ' ] cerrada ...!';

            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' fijvar :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_planilla_cerrada;

END;

/
