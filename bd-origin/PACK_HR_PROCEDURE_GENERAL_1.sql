--------------------------------------------------------
--  DDL for Package Body PACK_HR_PROCEDURE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PROCEDURE_GENERAL" AS

    PROCEDURE sp_dialab (
        pin_ano      IN INTEGER,
        pin_mes      IN INTEGER,
        pin_fingreso IN DATE,
        pin_fcese    IN DATE,
        pin_formula  IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000) := '';
        v_mdcalc     INTEGER := 30;--máximo días para cálculo
        v_mdcale     INTEGER := TO_NUMBER ( to_char(last_day(TO_DATE('01/'
                                                                 || pin_mes
                                                                 || '/'
                                                                 || pin_ano, 'DD/MM/YYYY')),
                                                'DD') );--máximo días calendario
        v_yy         INTEGER := 0;
        v_mm         INTEGER := 0;
        v_dd         INTEGER := 0;
        v_dlab       INTEGER := 0;
        v_dingre     INTEGER := 0;
        v_dcese      INTEGER := 0;
    BEGIN
        v_dlab := v_mdcalc;
        v_dingre := 0;
        IF pin_fingreso IS NOT NULL THEN
            v_yy := extract(YEAR FROM pin_fingreso);
            v_mm := extract(MONTH FROM pin_fingreso);
            v_dd := extract(DAY FROM pin_fingreso);
            IF (
                ( pin_ano = v_yy )
                AND ( pin_mes = v_mm )
            ) THEN
                v_dingre := v_dd - 1;
            END IF;

        END IF;

        v_dcese := 0;
        IF pin_fcese IS NOT NULL THEN
            v_yy := extract(YEAR FROM pin_fcese);
            v_mm := extract(MONTH FROM pin_fcese);
            v_dd := extract(DAY FROM pin_fcese);
            IF (
                ( pin_ano = v_yy )
                AND ( pin_mes = v_mm )
            ) THEN
                v_dcese := v_dd;
            END IF;

        END IF;

        IF ( v_dingre > 0 ) THEN
            v_dlab :=
                CASE
                    WHEN ( v_dcese > 0 ) THEN
                        v_dcese - v_dingre
                    WHEN ( v_dcese = 0 ) THEN
                        v_mdcale - v_dingre
                END;
        ELSIF ( v_dcese > 0 ) THEN
            v_dlab :=
                CASE
                    WHEN (
                        ( v_dcese = v_mdcale )
                        AND ( ( v_mdcale < 30 ) OR ( v_mdcale > 30 ) )
                    ) THEN
                        30
                    ELSE v_dcese
                END;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        pin_formula := v_dlab;
        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje || ' [ sp_dialab ]'
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
                    'message' VALUE pin_mensaje || ' [ sp_dialab ]'
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_dialab;

    PROCEDURE sp_mesfactor_proyecciongrati (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_mesgra   IN INTEGER,
        pin_periodo  IN NUMBER,
        pin_fdesde   IN DATE,
        pin_fhasta   IN DATE,
        pout_formula OUT VARCHAR2,
        pin_valcon   OUT NUMBER,
        pin_mensaje  OUT VARCHAR2
    ) AS

        v_empobr VARCHAR2(1 CHAR);
        v_fecini DATE;
        v_fecfin DATE;
        v_year   NUMBER;
        v_valcnt NUMBER(15, 4) := 0;
    BEGIN
        IF
            pin_periodo IS NOT NULL
            AND pin_fdesde IS NOT NULL
            AND pin_fhasta IS NOT NULL
        THEN
            v_year := pin_periodo;
            v_fecini := pin_fdesde;
            v_fecfin := pin_fhasta;
        ELSE
            SELECT
                EXTRACT(YEAR FROM pa.fecini) AS year,
                pa.finicio,
                pa.ffinal
            INTO
                v_year,
                v_fecini,
                v_fecfin
            FROM
                planilla_auxiliar pa
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.numpla = pin_numpla
                AND pa.codper = pin_codper;

        END IF;

        FOR i IN (
            SELECT
                *
            FROM
                pack_hr_function_general.sp_meses_completos_gratificacion(pin_id_cia, v_year, v_fecini, v_fecfin, pin_mesgra)
        ) LOOP
            IF pin_mesgra = 7 THEN
                IF i.enero >= 30 THEN
                    pout_formula := pout_formula
                                    || 'ENERO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'ENERO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.febrero >= 30 THEN
                    pout_formula := pout_formula
                                    || 'FEBRERO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'FEBRERO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.marzo >= 30 THEN
                    pout_formula := pout_formula
                                    || 'MARZO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'MARZO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.abril >= 30 THEN
                    pout_formula := pout_formula
                                    || 'ABRIL ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'ABRIL ==> +0 '
                                    || chr(13);
                END IF;

                IF i.mayo >= 30 THEN
                    pout_formula := pout_formula
                                    || 'MAYO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'MAYO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.junio >= 30 THEN
                    pout_formula := pout_formula
                                    || 'JUNIO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'JUNIO ==> +0 '
                                    || chr(13);
                END IF;

            ELSIF pin_mesgra = 12 THEN
                IF i.julio >= 30 THEN
                    pout_formula := pout_formula
                                    || 'JULIO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'JULIO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.agosto >= 30 THEN
                    pout_formula := pout_formula
                                    || 'AGOSTO ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'AGOSTO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.septiembre >= 30 THEN
                    pout_formula := pout_formula
                                    || 'SEPTIEMBRE ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'SEPTIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.octubre >= 30 THEN
                    pout_formula := pout_formula
                                    || 'OCTUBRE ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'OCTUBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.noviembre >= 30 THEN
                    pout_formula := pout_formula
                                    || 'NOVIEMBRE ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'NOVIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.diciembre >= 30 THEN
                    pout_formula := pout_formula
                                    || 'DICIEMBRE ==> +1 '
                                    || chr(13);
                    v_valcnt := v_valcnt + 1;
                ELSE
                    pout_formula := pout_formula
                                    || 'DICIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

            END IF;
        END LOOP;

        pin_valcon := v_valcnt;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
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

    END sp_mesfactor_proyecciongrati;

    PROCEDURE sp_diafactor_proyecciongrati (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_mesgra   IN INTEGER,
        pin_periodo  IN NUMBER,
        pin_fdesde   IN DATE,
        pin_fhasta   IN DATE,
        pout_formula OUT VARCHAR2,
        pin_valcon   OUT NUMBER,
        pin_mensaje  OUT VARCHAR2
    ) AS

        v_empobr VARCHAR2(1 CHAR);
        v_fecini DATE;
        v_fecfin DATE;
        v_year   NUMBER;
        v_valcnt NUMBER(15, 4) := 0;
    BEGIN
        IF
            pin_periodo IS NOT NULL
            AND pin_fdesde IS NOT NULL
            AND pin_fhasta IS NOT NULL
        THEN
            v_year := pin_periodo;
            v_fecini := pin_fdesde;
            v_fecfin := pin_fhasta;
        ELSE
            SELECT
                EXTRACT(YEAR FROM pa.fecini) AS year,
                pa.finicio,
                pa.ffinal
            INTO
                v_year,
                v_fecini,
                v_fecfin
            FROM
                planilla_auxiliar pa
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.numpla = pin_numpla
                AND pa.codper = pin_codper;

        END IF;

        FOR i IN (
            SELECT
                *
            FROM
                pack_hr_function_general.sp_meses_completos_gratificacion(pin_id_cia, v_year, v_fecini, v_fecfin, pin_mesgra)
        ) LOOP
            IF pin_mesgra = 7 THEN
                IF i.enero < 30 THEN
                    pout_formula := pout_formula
                                    || 'ENERO ==> +'
                                    || to_char(i.enero)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.enero;
                ELSE
                    pout_formula := pout_formula
                                    || 'ENERO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.febrero < 30 THEN
                    pout_formula := pout_formula
                                    || 'FEBRERO ==> +'
                                    || to_char(i.febrero)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.febrero;
                ELSE
                    pout_formula := pout_formula
                                    || 'FEBRERO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.marzo < 30 THEN
                    pout_formula := pout_formula
                                    || 'MARZO ==> +'
                                    || to_char(i.marzo)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.marzo;
                ELSE
                    pout_formula := pout_formula
                                    || 'MARZO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.abril < 30 THEN
                    pout_formula := pout_formula
                                    || 'ABRIL ==> +'
                                    || to_char(i.abril)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.abril;
                ELSE
                    pout_formula := pout_formula
                                    || 'ABRIL ==> +0 '
                                    || chr(13);
                END IF;

                IF i.mayo < 30 THEN
                    pout_formula := pout_formula
                                    || 'MAYO ==> +'
                                    || to_char(i.mayo)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.mayo;
                ELSE
                    pout_formula := pout_formula
                                    || 'MAYO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.junio < 30 THEN
                    pout_formula := pout_formula
                                    || 'JUNIO ==> +'
                                    || to_char(i.junio)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.junio;
                ELSE
                    pout_formula := pout_formula
                                    || 'JUNIO ==> +0 '
                                    || chr(13);
                END IF;

            ELSIF pin_mesgra = 12 THEN
                IF i.julio < 30 THEN
                    pout_formula := pout_formula
                                    || 'JULIO ==> +1 '
                                    || to_char(i.junio)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.julio;
                ELSE
                    pout_formula := pout_formula
                                    || 'JULIO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.agosto < 30 THEN
                    pout_formula := pout_formula
                                    || 'AGOSTO ==> +1 '
                                    || to_char(i.agosto)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.agosto;
                ELSE
                    pout_formula := pout_formula
                                    || 'AGOSTO ==> +0 '
                                    || chr(13);
                END IF;

                IF i.septiembre < 30 THEN
                    pout_formula := pout_formula
                                    || 'SEPTIEMBRE ==> +1 '
                                    || to_char(i.septiembre)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.septiembre;
                ELSE
                    pout_formula := pout_formula
                                    || 'SEPTIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.octubre < 30 THEN
                    pout_formula := pout_formula
                                    || 'OCTUBRE ==> +1 '
                                    || to_char(i.octubre)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.octubre;
                ELSE
                    pout_formula := pout_formula
                                    || 'OCTUBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.noviembre < 30 THEN
                    pout_formula := pout_formula
                                    || 'NOVIEMBRE ==> +1 '
                                    || to_char(i.noviembre)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.noviembre;
                ELSE
                    pout_formula := pout_formula
                                    || 'NOVIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

                IF i.diciembre < 30 THEN
                    pout_formula := pout_formula
                                    || 'DICIEMBRE ==> +1 '
                                    || to_char(i.diciembre)
                                    || chr(13);

                    v_valcnt := v_valcnt + i.diciembre;
                ELSE
                    pout_formula := pout_formula
                                    || 'DICIEMBRE ==> +0 '
                                    || chr(13);
                END IF;

            END IF;
        END LOOP;

        pin_valcon := v_valcnt;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
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

    END sp_diafactor_proyecciongrati;

END;

/
