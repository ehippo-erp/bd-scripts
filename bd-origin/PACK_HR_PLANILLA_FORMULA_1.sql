--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_FORMULA" AS

    PROCEDURE sp_decodificar (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m                     json_object_t;
        v_rec_factor_planilla factor_planilla%rowtype;
        v_rec_planilla_afp    planilla_afp%rowtype;
        v_rec_planilla        planilla%rowtype;
        v_nivel               NUMBER := 0;
        v_char                VARCHAR2(1) := '';
        v_salir               VARCHAR2(1) := 'S';
        v_codigo              VARCHAR2(20 CHAR) := '';
        v_valor               VARCHAR2(4000) := '';
        v_valcon              planilla_concepto.valcon%TYPE;
        v_codcon              VARCHAR2(20 CHAR) := '';
        v_fijvar              concepto.fijvar%TYPE;
        v_tipori              VARCHAR2(2 CHAR) := '';
        v_proceso             NUMBER := 0;
        v_ultimocaracter      VARCHAR2(1) := 'N';
        v_poutformula         VARCHAR2(4000) := '';
        v_formula             concepto.formul%TYPE;
        v_pout_formula        VARCHAR2(4000) := '';
        v_aux_formula         VARCHAR2(4000) := '';
        pout_mensaje          VARCHAR2(4000) := '';
        v_mensaje             VARCHAR2(4000) := '';
        v_desley              VARCHAR2(4000) := '';
    BEGIN
        -- VERIFICANDO SI EL CONCEPTO, SE PROCESO ANTERIORMENTE
        -- TAMBIEN EXTRAERMOS EL CAMPO FORMULA DE SER NECESARIO
        BEGIN --446 -- NOEXISTE ( 447 )
            SELECT
                pc.proceso,
                pc.valcon,
                pcc.formul,
                c.fijvar
            INTO
                v_proceso,
                v_valcon,
                v_formula,
                v_fijvar
            FROM
                     planilla pl
                INNER JOIN planilla_concepto                                                             pc ON pc.id_cia = pl.id_cia
                                                   AND pc.numpla = pl.numpla
                                                   AND pc.codper = pin_codper
                                                   AND pc.codcon = pin_codcon
                INNER JOIN concepto                                                                      c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                INNER JOIN pack_hr_concepto_formula.sp_ayuda(pc.id_cia, pc.codcon, pl.empobr, pl.tippla) pcc ON 0 = 0
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
                AND pc.codper = pin_codper
                AND pc.codcon = pin_codcon
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
        -- SI EL CONCEPTO NO EXISTE O NO SE ENCUENTRA ASINADO AL TRABAJADOR, ERROR ...!
            WHEN no_data_found THEN
                BEGIN
                    -- SI EL CONCEPTO NO SE ENCUENTRA ASIGNADO EN PLANILLA CONCEPTO, PERO SI ESTA CONFIGURADO ( TIPOPLANILLA_CONCEPTO ) 
                    -- PARA QUE FIGURE EN DICHA PLANILLA ( ERROR )
                    -- ESTA VALIDACION NO AFECTA A CONCEPTOS FIJOS ( IMPLICITAMENTE )
                    SELECT
                        '0'
                    INTO v_char
                    FROM
                             planilla p
                        INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = p.id_cia
                                                                AND tpc.tippla = p.tippla
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.numpla = pin_numpla
                        AND tpc.codcon = pin_codcon;

                    IF pin_formula IS NULL THEN -- POR DEFAULT
                        pout_mensaje := 'ERROR! - CONCEPTO [ '
                                        || pin_codcon
                                        || ' ] PARA EL TRABAJADOR [ '
                                        || pin_codper
                                        || ' ], REFRESCAR PLANILLA Y/O REVISAR CONFIGURACION DEL CONCEPTO';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    ELSE -- SI TENEMOS INFOMACION DE LA FORMULA DEL PADRE, ENTONCES DETALLAMOS EL ERROR
                        pout_mensaje := 'ERROR! - CONCEPTO [ '
                                        || pin_codcon
                                        || ' ] DEFINIDO EN LA FORMULA [ '
                                        || chr(13)
                                        || pin_formula
                                        || ' ]'
                                        || chr(13)
                                        || ' PARA EL TRABAJADOR [ '
                                        || pin_codper
                                        || ' ], REFRESCAR PLANILLA Y/O REVISAR CONFIGURACION DEL CONCEPTO';

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                EXCEPTION -- OK
                    WHEN no_data_found THEN
                        pin_formula := 'CONCEPTO NO DEFINIDO PARA EL TRABAJADOR';
                        pout_formula := 'CONCEPTO NO DEFINIDO PARA EL TRABAJADOR :  '
                                        || chr(13)
                                        || 'NO PERTENECE AL TIPO DE PLANILLA PROCESADA, POR ENDE EL VALOR SE ASIGNA EN "0"'
                                        || chr(13)
                                        || 'NOTA: SI EL CONCEPTO SI HUBIERA ESTADO ASIGNADO AL TIPO DE PLANILLA EL PROCESO SE DETIENE!'
                                        ;

                        v_valcon := 0; -- OK
                        v_proceso := 1;
                END;
        END;

        -- VERICANDO EL ENVIO DEL CAMPO FORMULA
        IF pin_formula IS NULL THEN
            CASE
                WHEN v_fijvar = 'C' THEN -- CONCEPTO DE TIPO CALCULADO
                    IF v_formula IS NULL THEN
                        -- CONCEPTO NO DEFINIDO
                        pack_hr_planilla_formula.sp_decodificar_cnodefinido(pin_id_cia, pin_numpla, pin_codper, pin_codcon, pin_swacti
                        ,
                                                                           pin_coduser, pin_concepto, v_formula, v_aux_formula, v_valor
                                                                           ,
                                                                           v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    ELSE
                        -- CONCEPTO DEFINIDO
                        pin_formula := v_formula;
                    END IF;
                WHEN v_fijvar = 'P' THEN
                    -- CONCEPTO REFERIDO AL PRESTAMO
                    pack_hr_planilla_formula.sp_decodificar_cprestamo(pin_id_cia, pin_numpla, pin_codper, pin_codcon, pin_swacti,
                                                                     pin_coduser, pin_concepto, v_formula, v_aux_formula, v_valor,
                                                                     v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                    v_proceso := 1;
                WHEN v_fijvar = 'S' THEN -- CONCEPTO DE TIPO SISTEMA
                -- ESTOS CONCEPTOS SE PROCESAN DURANTE LA GENERACION DE LA PLANILLA
                    v_proceso := 1;
                ELSE --CONCEPTO DE TIPO FIJO / VARIABLE
                -- ESTOS CONCEPTOS NO SE PROCESAN
                    v_proceso := 1;
            END CASE;

        END IF;

        IF v_proceso = 0 THEN
            pin_formula := pin_formula || ' ';
--        dbms_output.put_line(pin_formula);
            v_nivel := v_nivel + 1; -- INCREMENTA POR CADA ANIDACION
            FOR i IN 1..length(pin_formula) LOOP
                v_char := substr(pin_formula, i, 1);
--                dbms_output.put_line(v_char);
                IF v_char = ':' OR v_salir = 'N' THEN
                    v_salir := 'N';
                    v_codigo := v_codigo || v_char;
                    v_formula := NULL;
                    v_aux_formula := NULL;
                    v_valor := NULL;
                    v_mensaje := NULL;
                    IF v_char = ' ' THEN
                        IF substr(v_codigo, 2, 1) = 'C' THEN --- CONCEPTO
                            v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));
--                          dbms_output.put_line('Buscando al ' || v_codcon);
--                          dbms_output.put_line('Iniciando Recursividad');
                            pack_hr_planilla_formula.sp_decodificar(pin_id_cia, pin_numpla, pin_codper, v_codcon, pin_swacti,
                                                                   pin_coduser, pin_codcon, v_formula, v_aux_formula, v_valor,
                                                                   v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        ELSIF substr(v_codigo, 2, 1) = 'S' THEN -- FUNCION
                            v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));

                            pack_hr_planilla_formula.sp_decodificar_fsistema(pin_id_cia, pin_numpla, pin_codper, v_codcon, pin_swacti
                            ,
                                                                            pin_coduser, pin_codcon, v_formula, v_aux_formula, v_valor
                                                                            ,
                                                                            v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        ELSIF substr(v_codigo, 2, 1) = 'F' THEN -- FACTOR
                            v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));

                            pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, v_codcon, pin_swacti,
                                                                           pin_coduser, pin_codcon, v_formula, v_aux_formula, v_valor
                                                                           ,
                                                                           v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        END IF;

                        v_pout_formula := v_pout_formula
                                          || v_valor
                                          || v_char;
                        v_codigo := '';
                        v_salir := 'S';
                    END IF;

                ELSE
                    v_pout_formula := v_pout_formula || v_char;
                END IF;

            END LOOP;

            pout_formula := v_pout_formula;
            dbms_output.put_line(v_pout_formula);
            EXECUTE IMMEDIATE 'SELECT '
                              || v_pout_formula
                              || ' FROM DUAL '
            INTO v_valor;
            pin_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
            IF pin_swacti = 'S' THEN
                UPDATE planilla_concepto
                SET
                    valcon = v_valor,
                    proceso = 1,
                    uactua = pin_coduser,
                    factua = current_date
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = pin_codper
                    AND codcon = pin_codcon;

            ELSE
                pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                           'C', 0, pin_formula, pout_formula, pin_valor,
                                                           v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END IF;

        ELSE
            pin_valor := rtrim(to_char(v_valcon, 'FM999999999999990.999999'), ',');
            IF pin_swacti = 'N' THEN
                pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                           v_fijvar, 0, pin_formula, pout_formula, pin_valor,
                                                           v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || pin_codper
                                || ' - '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO CALCULADO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO CALCULADO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar;

    PROCEDURE sp_decodificar_fsistema (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        CURSOR cur_planilla IS
        SELECT
            *
        FROM
            planilla
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla;

        CURSOR cur_personal IS
        SELECT
            *
        FROM
            personal
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper;

        v_rpla       planilla%rowtype;
        v_rper       personal%rowtype;
        v_rperlab    personal_periodolaboral%rowtype;
        v_nombre     VARCHAR2(100) := upper(pin_codcon);
        v_result     VARCHAR2(30);
        v_integer    INTEGER := 0;
        v_date       DATE;
        v_date2      DATE;
        v_char       VARCHAR2(1 CHAR);
        v_desclase   clase_codigo_personal.descri%TYPE;
        v_descodigo  clase_codigo_personal.descri%TYPE;
        v_ayuda      VARCHAR2(1000) := '';
        v_ayuda2     VARCHAR2(1000) := '';
        pout_mensaje VARCHAR2(1000) := '';
        o            json_object_t;
        m            json_object_t;
        v_mensaje    VARCHAR2(1000) := '';
        v_formula    VARCHAR2(1000) := '';
    BEGIN
        v_result := '0';
        IF v_nombre = 'RANGO' THEN
            BEGIN
                SELECT
                    to_char(nvl(SUM(nvl(dias, 0)),
                                0))
                INTO v_result
                FROM
                    planilla_rango pr
                WHERE
                        pr.id_cia = pin_id_cia
                    AND pr.numpla = pin_numpla
                    AND pr.codper = pin_codper
                    AND pr.codcon = pin_concepto;

            EXCEPTION
                WHEN no_data_found THEN
                    v_result := '0.';
            END;

            pin_formula := 'RANGO ACUMULADO EN DIAS';
            pout_formula := 'RANGO EN DIAS CALCULADO EN BASE AL CONCEPTO [ '
                            || pin_concepto
                            || ' ] EN BASE AL REGISTRO DE FECHA EN EL PLANILLON ( PLANILLA RANGO )';
        ELSIF v_nombre = 'NHESCOLAR' THEN
            BEGIN
                SELECT
                    p.fecfin
                INTO v_date
                FROM
                    planilla p
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.numpla = pin_numpla;

                SELECT
                    to_char(COUNT(0))
                INTO v_result
                FROM
                    personal_dependiente pd
                WHERE
                        pd.id_cia = pin_id_cia
                    AND pd.codper = pin_codper
                    AND pd.codi20 IS NULL
                    AND floor(months_between(sysdate, pd.fecnac) / 12) BETWEEN 3 AND 25;

            EXCEPTION
                WHEN no_data_found THEN
                    v_result := '0.';
            END;

            pin_formula := 'NUMERO DE HIJOS EN EDAD ESCOLAR';
            pout_formula := 'NUMERO DE PERSONAL DEPENDIENTE ( HIJOS, ... ) SIN MOTIVO DE BAJA Y EN LA EDAD DE 3 A 25 AÑOS DEL TRABAJADOR [ '
                            || pin_codper
                            || ' ] Y A LA FECHA FINAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'NO' THEN
            v_result := '0';
            pin_formula := 'NO';
            pout_formula := '0';
        ELSIF v_nombre = 'SI' THEN
            v_result := '1';
            pin_formula := 'SI';
            pout_formula := '1';
        ELSIF v_nombre = 'FREGLAB' THEN
            v_result := '1';
            pin_formula := 'FACTOR DE GRATIFICACION';
            BEGIN
                SELECT
                    CASE
                        WHEN pc.codigo = '01' THEN
                            '1'
                        WHEN pc.codigo = '16' THEN
                            '0'--15--NOCTS
                        WHEN pc.codigo = '17' THEN
                            '0.5' --15
                        ELSE
                            '1'
                    END,
                    CASE
                        WHEN pc.codigo = '01' THEN
                            'COMPLETA'
                        WHEN pc.codigo = '16' THEN
                            'NULA'--15--NOCTS
                        WHEN pc.codigo = '17' THEN
                            'PARCIAL' --15
                        ELSE
                            'NO DEFINIDO, REVISAR LA ASIGNACION DE LA CLASE N°33 DEL PERSONAL!'
                    END,
                    ccp.descri AS desclase,
                    ccp.descri AS descodigo
                INTO
                    v_result,
                    v_ayuda,
                    v_desclase,
                    v_descodigo
                FROM
                    personal_clase        pc
                    LEFT OUTER JOIN clase_personal        cp ON cp.id_cia = pc.id_cia
                                                         AND cp.clase = pc.clase
                    LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = pc.id_cia
                                                                 AND ccp.clase = pc.clase
                                                                 AND ccp.codigo = pc.codigo
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.codper = pin_codper
                    AND pc.clase = 33;

            EXCEPTION
                WHEN no_data_found THEN
                    v_result := '1';
            END;

            pout_formula := 'FACTOR DE GRATIFICACION : ( COMPLETA, PARTIAL, NULA  ? )'
                            || chr(13)
                            || 'CONFIGURARA SEGUN LA CLASE 33 - '
                            || v_desclase
                            || ' DEFINIDA CON EL CODIGO [ '
                            || v_descodigo
                            || ' ] '
                            || chr(13)
                            || ' LE CORRESPONDE UN FACTOR GRATIFICACION : '
                            || v_ayuda;

        ELSIF v_nombre = 'AÑO' THEN
            v_result := to_char(current_date, 'YYYY');
            pin_formula := 'AÑO DEL PROCESO';
            pout_formula := 'AÑO DEL PROCESO';
        ELSIF v_nombre = 'MES' THEN
            v_result := to_char(current_date, 'MM');
            pin_formula := 'MES DEL PROCESO';
            pout_formula := 'MES DEL PROCESO';
        ELSIF v_nombre = 'DIA' THEN
            v_result := to_char(current_date, 'DD');
            pin_formula := 'DIA DEL PROCESO';
            pout_formula := 'DIA DEL PROCESO';
        ELSIF v_nombre = 'DIASEM' THEN
            v_integer := TO_NUMBER ( to_char(current_date, 'D', 'NLS_DATE_LANGUAGE =SPANISH') );
            IF v_integer = 1 THEN
                v_result := '7';
            ELSE
                v_result := to_char(v_integer - 1);
            END IF;

            pout_formula := 'DIA DE LA SEMANA DEL PROCESO';
            pin_formula := 'DIA DE LA SEMANA DEL PROCESO';
        ELSIF v_nombre = 'ANOPLA' THEN
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    v_result := to_char(v_rpla.anopla);
                END IF;

            END LOOP;

            CLOSE cur_planilla;
            pin_formula := 'AÑO DE LA PLANILLA';
            pout_formula := 'AÑO DE LA PLANILLA';
        ELSIF v_nombre = 'MESPLA' THEN
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    v_result := to_char(v_rpla.mespla);
                END IF;

            END LOOP;

            CLOSE cur_planilla;
            pin_formula := 'MES DE LA PLANILLA';
            pout_formula := 'MES DE LA PLANILLA';
        ELSIF v_nombre = 'SEMPLA' THEN
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    v_result := to_char(v_rpla.sempla);
                END IF;

            END LOOP;

            CLOSE cur_planilla;
            pin_formula := 'SEMANA DE LA PLANILLA';
            pout_formula := 'SEMANA DE LA PLANILLA';
        ELSIF v_nombre = 'TCPLA' THEN
            v_result := 1;
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    v_result := to_char(nvl(v_rpla.tcambio, 1));
                END IF;

            END LOOP;

            pin_formula := 'TIPO DE CAMBIO DE LA PLANILLA';
            pout_formula := 'TIPO DE CAMBIO DE LA PLANILLA';
            CLOSE cur_planilla;
        ELSIF v_nombre = 'TIPPLA' THEN
            BEGIN
                SELECT
                    p.tippla
                INTO v_char
                FROM
                    planilla p
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.numpla = pin_numpla;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'ERROR, no se encontro la PLANILLA ['
                                    || pin_numpla
                                    || '], revisar el STATUS de la planilla actual';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'EXTRAE EL CODIGO ASCCII DEL TIPO DE PLANILLA';
            pout_formula := 'ASCII('
                            || v_char
                            || ')';
            v_result := to_char(ascii(v_char));
        ELSIF v_nombre = 'DIFMESFFIN' THEN
            BEGIN
                SELECT
                    pa.fecfin,
                    pa.finicio,
                    to_char(floor(months_between(pa.fecfin, pa.finicio) -(floor(months_between(pa.fecfin, pa.finicio) / 12) * 12)))
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA FINAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA FINAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'DIFDIAFFIN' THEN
            BEGIN
                SELECT
                    pa.fecfin,
                    pa.finicio,
                    floor((months_between(pa.fecini, pa.finicio) - floor(months_between(pa.fecini, pa.finicio))) * 30) + 1 AS dialiq
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA FINAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA FINAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'DIFMESFINI' THEN
            BEGIN
                SELECT
                    pa.fecini,
                    pa.finicio,
                    to_char(floor(months_between(pa.fecini, pa.finicio) -(floor(months_between(pa.fecini, pa.finicio) / 12) * 12)))
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA INICIAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA INICIAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'DIFDIAFINI' THEN
            BEGIN
                SELECT
                    pa.fecini,
                    pa.finicio,
                    floor((months_between(pa.fecini, pa.finicio) - floor(months_between(pa.fecini, pa.finicio))) * 30) + 1 AS dialiq
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA INICIAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA INICIAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'MESES_DURACION' THEN
            -- CTS, CUANDO MEESES DESDE FINGRESO DE INGRESO DEL TRABAJADOR HASTA LA FECHA FINAL DE LA PLANILLA
            -- MESES COMPLETOS
            BEGIN
                SELECT
                    pa.fecfin,
                    pa.finicio,
                    to_char(floor(months_between(pa.fecfin, pa.finicio) -(floor(months_between(pa.fecfin, pa.finicio) / 12) * 12)))
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA FINAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN MESES ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA FINAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF v_nombre = 'DMES' THEN
            v_result := 0;
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    v_result := to_char(last_day(TO_DATE('01/'
                                                         || v_rpla.mespla
                                                         || '/'
                                                         || v_rpla.anopla, 'DD/MM/YYYY')), 'DD');
                END IF;

            END LOOP;

            CLOSE cur_planilla;
            pout_formula := 'ULTIMO DIA DEL MES EN LA PLANILLA';
        ELSIF v_nombre = 'DLABMES' THEN
            v_result := '0';

            -- CONTABILIZA DESDE EL DIA DE INGRESO , SIMPRE CONSIDERA EL DIA ACTUAL
            --10FEBERO   / 30 = 20
            --10 FEBERRO = 19 (DIAS)
            -- FECHA INGRSO 
            -- FECHA CESE ( EN CASO NO TENGA FECHA DE LA FINAL DE LA PLANILLA GENERADA  )
            OPEN cur_planilla;
            LOOP
                FETCH cur_planilla INTO v_rpla;
                EXIT WHEN cur_planilla%notfound;
                IF cur_planilla%rowcount = 1 THEN
                    BEGIN
                        SELECT
                            finicio,
                            ffinal
                        INTO
                            v_rperlab.finicio,
                            v_rperlab.ffinal
                        FROM
                            pack_hr_personal.sp_periodolaboral(v_rpla.id_cia, v_rpla.empobr, v_rpla.fecini, v_rpla.fecfin)
                        WHERE
                            codper = pin_codper;

                    EXCEPTION
                        WHEN no_data_found THEN
                            pout_mensaje := 'No se encontro una FECHA INGRESO y una FECHA DE CESE para este trabajador';
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        WHEN too_many_rows THEN
                            pout_mensaje := 'Se encontro mas de una FECHA INGRESO y una FECHA DE CESE para este trabajador';
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                    END;
                END IF;

                pack_hr_procedure_general.sp_dialab(v_rpla.anopla, v_rpla.mespla, v_rperlab.finicio, v_rperlab.ffinal, v_result,
                                                   v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END LOOP;

            pin_formula := 'CONTABILIZA LOS DIAS LABORADOS EN EL MES';
            pout_formula := 'CONTABILIZA LOS DIAS LABORADOS EN EL MES SEGUN LA FECHA DE INGRESO Y CESE DEL TRABAJADOR '
                            || chr(13)
                            || 'DE HABER LABORADO COMPLETAMENTE EN EL PERIODO, EL VALOR ASIGNADO ES 30'
                            || chr(13)
                            || 'FECHA DE INGRESO :  '
                            || to_char(v_rperlab.finicio, 'DD/MM/YY')
                            || chr(13)
                            || 'FECHA CESE : '
                            || to_char(v_rperlab.ffinal, 'DD/MM/YY');

        ELSIF v_nombre = 'EDAD' THEN -- RESPECTO A LA FECHA FINAL DE LA PLANILLA
            BEGIN
                SELECT
                    p.fecfin
                INTO v_date
                FROM
                    planilla p
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.numpla = pin_numpla;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'ERROR, no se encontro la PLANILLA ['
                                    || pin_numpla
                                    || '], revisar el STATUS de la planilla actual';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            BEGIN
                SELECT
                    p.fecnac,
                    to_char(floor(months_between(v_date, p.fecnac) / 12))
                INTO
                    v_date2,
                    v_result
                FROM
                    personal p
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se registro una FECHA DE NACIMIENTO valida para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ] ';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'EDAD DEL TRABAJADOR';
            pout_formula := 'FECHA NACIMIENTO ==> '
                            || to_char(v_date2, 'DD/MM/YY')
                            || chr(13)
                            || 'FECHA DE FINAL DE LA PLANILLA ==> '
                            || to_char(v_date, 'DD/MM/YY')
                            || chr(13)
                            || 'EDAD ==> '
                            || v_result;

        ELSIF v_nombre = 'DIALAB' THEN
            BEGIN
                SELECT
                    to_char(floor((months_between(nvl(pa.ffinal, pa.fecfin),
                                                  pa.finicio) - floor(months_between(nvl(pa.ffinal, pa.fecfin),
                                                                                     pa.finicio))) * 30))
                INTO v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pout_formula := 'DIAS LABORADOS POR EL TRABAJADOR';
        ELSIF v_nombre = 'MESLAB' THEN
            BEGIN
                SELECT
                    to_char(floor(months_between(nvl(pa.ffinal, pa.fecfin),
                                                 pa.finicio) -(floor(months_between(nvl(pa.ffinal, pa.fecfin),
                                                                                    pa.finicio) / 12) * 12)))
                INTO v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'MESES LABORADOS POR EL TRABAJADOR';
            pout_formula := 'MESES LABORADOS POR EL TRABAJADOR';
        ELSIF v_nombre = 'ANIOLAB' THEN
            BEGIN
                SELECT
                    to_char(floor(months_between(nvl(pa.ffinal, pa.fecfin),
                                                 pa.finicio) / 12))
                INTO v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'AÑOS LABORADOS POR EL TRABAJADOR';
            pout_formula := 'AÑOS LABORADOS POR EL TRABAJADOR';
        ELSIF v_nombre = 'FPRMGR7' THEN
            pin_formula := 'MESES COMPLETOS PARA LA GRATIFICACION DE JULIO';
            pack_hr_procedure_general.sp_mesfactor_proyecciongrati(pin_id_cia, pin_numpla, pin_codper, 7, NULL,
                                                                  NULL, NULL, pout_formula, v_result, v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSIF v_nombre = 'FPRDGR7' THEN
            pin_formula := 'DIAS COMPLEMENTARIOS PARA LA GRATIFICACION DE JULIO';
            pack_hr_procedure_general.sp_diafactor_proyecciongrati(pin_id_cia, pin_numpla, pin_codper, 7, NULL,
                                                                  NULL, NULL, pout_formula, v_result, v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSIF v_nombre = 'FPRMGR12' THEN
            pin_formula := 'MESES COMPLETOS PARA LA GRATIFICACION DE DICIEMBRE';
            pack_hr_procedure_general.sp_mesfactor_proyecciongrati(pin_id_cia, pin_numpla, pin_codper, 12, NULL,
                                                                  NULL, NULL, pout_formula, v_result, v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSIF v_nombre = 'FPRDGR12' THEN
            pin_formula := 'DIAS COMPLEMENTARIOS PARA LA GRATIFICACION DE DICIEMBRE';
            pack_hr_procedure_general.sp_diafactor_proyecciongrati(pin_id_cia, pin_numpla, pin_codper, 12, NULL,
                                                                  NULL, NULL, pout_formula, v_result, v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSIF v_nombre = 'DIAING' THEN
            BEGIN
                SELECT
                    pa.fecfin,
                    pa.finicio,
                    to_char(floor((months_between(pa.fecfin, pa.finicio) - floor(months_between(pa.fecfin, pa.finicio))) * 30))
                INTO
                    v_date,
                    v_date2,
                    v_result
                FROM
                    planilla_auxiliar pa
                WHERE
                        pa.id_cia = pin_id_cia
                    AND pa.numpla = pin_numpla
                    AND pa.codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No se encontro una FECHA INGRESO VALIDA para este trabajador';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR Y FECHA FINAL DE PLANILLA';
            pout_formula := 'DIFERENCIA QUE EXISTE EN DIAS ENTRE FECHA DE INGRESO DEL TRABAJADOR [ '
                            || to_char(v_date2, 'DD/MM/YY')
                            || ' ] Y FECHA FINAL DE PLANILLA [ '
                            || to_char(v_date, 'DD/MM/YY')
                            || ' ]';

        ELSIF substr(v_nombre, 1, 5) = 'LETRA' THEN
            v_result := ascii(substr(v_nombre, 6, 1));
            pin_formula := 'EXTRAE EL CODIGO ASCCI DE LA ULTIMA LETRA';
            pout_formula := 'ASCCI('
                            || substr(v_nombre, 1, 5)
                            || ')';
        ELSIF v_nombre = 'INDAFP' THEN
            BEGIN
                SELECT
                    CASE
                        WHEN codafp = '0000' THEN
                            '0'
                        ELSE
                            '1'
                    END
                INTO v_result
                FROM
                    planilla_afp
                WHERE
                        id_cia = pin_id_cia
                    AND numpla = pin_numpla
                    AND codper = pin_codper;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'No existe la AFP para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ] en la PLANILLA_AFP, vefique que el TRABAJADOR tenga un PERIODO de REGIMEN PENSIONARIO valido y vuelva a REFRESCAR la PLANILLA ...!'
                                    ;
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_formula := 'TIENE AFP?';
            pout_formula := 'TIENE AFP? - SI = 1 | NO = 0';
        ELSIF v_nombre = 'AFP_EXO' THEN
            v_result := '-1';
            pin_formula := 'EXPONERADO [1] / AFECTO [0] A AFP, SEGUN EL CONCEPTO POR TIPO DE TRABAJADOR, ASOCIADO A LOS FACTORES [ '
                           || 'F418 - F420 - F423 - F425'
                           || ' ]';
            pout_formula := 'FORMULA NO CALCULADA, REFRESCAR, LA PLANILLA';
            pout_mensaje := 'FORMULA NO CALCULADA, REFRESCAR, LA PLANILLA';
            FOR i IN (
                SELECT
                    p.empobr,
                    fcp418.vstrg AS c418,
                    fcp420.vstrg AS c420,
                    fcp423.vstrg AS c423,
                    fcp425.vstrg AS c425,
                    pc1.valcon   AS v418,
                    pc2.valcon   AS v420,
                    pc3.valcon   AS v423,
                    pc4.valcon   AS v425,
                    CASE
                        WHEN pc1.valcon = 1
                             OR pc2.valcon = 1
                             OR pc3.valcon = 1
                             OR pc4.valcon = 1 THEN
                            '1'
                        ELSE
                            '0'
                    END          AS vresult
                FROM
                    planilla              p
                    LEFT OUTER JOIN factor_clase_planilla fcp418 ON fcp418.id_cia = p.id_cia
                                                                    AND fcp418.codfac = '418'
                                                                    AND fcp418.tipcla = 1
                                                                    AND fcp418.codcla = p.empobr
                    LEFT OUTER JOIN factor_clase_planilla fcp420 ON fcp420.id_cia = p.id_cia
                                                                    AND fcp420.codfac = '420'
                                                                    AND fcp420.tipcla = 1
                                                                    AND fcp420.codcla = p.empobr
                    LEFT OUTER JOIN factor_clase_planilla fcp423 ON fcp423.id_cia = p.id_cia
                                                                    AND fcp423.codfac = '423'
                                                                    AND fcp423.tipcla = 1
                                                                    AND fcp423.codcla = p.empobr
                    LEFT OUTER JOIN factor_clase_planilla fcp425 ON fcp425.id_cia = p.id_cia
                                                                    AND fcp425.codfac = '425'
                                                                    AND fcp425.tipcla = 1
                                                                    AND fcp425.codcla = p.empobr
                    LEFT OUTER JOIN planilla_concepto     pc1 ON pc1.id_cia = p.id_cia
                                                             AND pc1.numpla = p.numpla
                                                             AND pc1.codper = pin_codper
                                                             AND pc1.codcon = fcp418.vstrg
                    LEFT OUTER JOIN planilla_concepto     pc2 ON pc2.id_cia = p.id_cia
                                                             AND pc2.numpla = p.numpla
                                                             AND pc2.codper = pin_codper
                                                             AND pc2.codcon = fcp420.vstrg
                    LEFT OUTER JOIN planilla_concepto     pc3 ON pc3.id_cia = p.id_cia
                                                             AND pc3.numpla = p.numpla
                                                             AND pc3.codper = pin_codper
                                                             AND pc3.codcon = fcp423.vstrg
                    LEFT OUTER JOIN planilla_concepto     pc4 ON pc4.id_cia = p.id_cia
                                                             AND pc4.numpla = p.numpla
                                                             AND pc4.codper = pin_codper
                                                             AND pc4.codcon = fcp425.vstrg
                WHERE
                        p.id_cia = pin_id_cia
                    AND p.numpla = pin_numpla
            ) LOOP
                IF i.c418 IS NULL OR i.c420 IS NULL OR i.c423 IS NULL OR i.c425 IS NULL THEN
                    pout_mensaje := 'FACTOR 418 - 420 - 423 - 425, NO TIENE UN CONCEPTO FIJO ASIGNADO, '
                                    || 'PARA EL TIPO DE PERSONAL : '
                                    || i.empobr;
                    IF pin_swacti = 'S' THEN
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;
                END IF;

                pout_formula := 'EXPONERADO [1] / AFECTO [0] A AFP '
                                || chr(13)
                                || 'TIPO DE PERSONAL : '
                                || i.empobr
                                || chr(13)
                                || 'SEGUN LOS CONCEPTOS FIJOS [ '
                                || i.c418
                                || ' - '
                                || i.c420
                                || ' - '
                                || i.c423
                                || ' - '
                                || i.c425
                                || ' ]'
                                || chr(13)
                                || i.c418
                                || ' ==> '
                                || i.v418
                                || chr(13)
                                || i.c420
                                || ' ==> '
                                || i.v420
                                || chr(13)
                                || i.c423
                                || ' ==> '
                                || i.v423
                                || chr(13)
                                || i.c425
                                || ' ==> '
                                || i.v425
                                || chr(13)
                                || 'EXOAFP ==> '
                                || i.vresult;

                v_result := i.vresult;
            END LOOP;

            IF
                pin_swacti = 'S'
                AND v_result = '-1'
            THEN
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        ELSE
            pin_formula := 'FORMULA NO DEFINIDA';
            pout_formula := 'FORMULA NO DEFINIDA, ESTO PRODUCE UN ERROR AL PROCESAR LA PLANILLA'
                            || chr(13)
                            || 'VARIFICAR LA ESCRITURA DE LA FORMULA : '
                            || v_nombre;
            pout_mensaje := 'FORMULA NO DEFINIDA';
            v_result := '0';
            IF pin_swacti = 'S' THEN
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        END IF;

        pin_valor := v_result;
        IF pin_swacti = 'N' THEN
            pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                       'SS', 0, pin_formula, pout_formula, pin_valor,
                                                       v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
                                || ' - PERSONAL [ '
                                || pin_codper
                                || ' ] - FUNCION [ '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - FUNCION [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - FUNCION [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_fsistema;

    PROCEDURE sp_decodificar_ffactor (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m                     json_object_t;
        v_rec_factor_planilla factor_planilla%rowtype;
        v_rec_planilla_afp    planilla_afp%rowtype;
        v_rec_planilla        planilla%rowtype;
        pout_mensaje          VARCHAR2(1000) := '';
        v_formula             VARCHAR2(1000) := '';
        v_aux_formula         VARCHAR2(1000) := '';
        v_mensaje             VARCHAR2(1000) := '';
        v_desley              VARCHAR2(1000) := '';
        v_desfun              VARCHAR2(1000) := '';
        v_tipcla              NUMBER;
        v_valor               VARCHAR2(20) := '';
        v_string              VARCHAR2(20) := '';
    BEGIN
        -- SUPONEMOS, EN PRIMERA INSTANCIA QUE ES UN FACTOR SIN CLASE
        BEGIN
            SELECT
                fp.nombre,
                fp.indafp,
                rtrim(to_char(nvl(fp.valfa1, '0'),
                              'FM999999999999990.999999'),
                      ',')
            INTO
                v_desley,
                v_rec_factor_planilla.indafp,
                v_valor
            FROM
                factor_planilla fp
            WHERE
                    fp.id_cia = pin_id_cia
                AND fp.codfac = pin_codcon
                AND fp.tipfac = 'N'; -- FACTOR SIN CLASE

            -- SI ES UN FACTOR RELACIONADO A LA AFP
            IF v_rec_factor_planilla.indafp = 'S' THEN
                -- EXTRAEMOS INFORMACION DE LA PLANILLA Y LA AFP DEL TRABAJADOR
                BEGIN
                    SELECT
                        p.anopla,
                        p.mespla,
                        afp.codafp
                    INTO
                        v_rec_planilla.anopla,
                        v_rec_planilla.mespla,
                        v_rec_planilla_afp.codafp
                    FROM
                             planilla p
                        INNER JOIN planilla_afp afp ON afp.id_cia = p.id_cia
                                                       AND afp.numpla = p.numpla
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.numpla = pin_numpla
                        AND afp.codper = pin_codper;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'No existe la AFP para el TRABAJADOR [ '
                                        || pin_codper
                                        || ' ] en la PLANILLA_AFP, vuelva a REFRESCAR la PLANILLA';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                -- EXTRAEMOS EL FACTOR PARA LA AFP DEL TRABAJADOR
                IF v_rec_planilla_afp.codafp <> '0000' THEN
                    BEGIN
                        SELECT
                            'FACTOR AFP - ' || v_rec_planilla_afp.codafp,
                            rtrim(to_char(nvl(valfa1, '0'),
                                          'FM999999999999990.999999'),
                                  ',')
                        INTO
                            v_desley,
                            v_valor
                        FROM
                            factor_afp
                        WHERE
                                id_cia = pin_id_cia
                            AND anio = v_rec_planilla.anopla
                            AND mes = v_rec_planilla.mespla
                            AND codafp = v_rec_planilla_afp.codafp
                            AND codfac = pin_codcon;

                    EXCEPTION
                        WHEN no_data_found THEN
                            pout_mensaje := 'No existe el FACTOR AFP [ '
                                            || v_rec_planilla_afp.codafp
                                            || ' ] para el PERIODO [ '
                                            || v_rec_planilla.anopla
                                            || ' - '
                                            || v_rec_planilla.mespla
                                            || ' ], vuelva a REFRESCAR la PLANILLA o contacte con el administrador del sistema';

                            RAISE pkg_exceptionuser.ex_error_inesperado;
                    END;

                ELSE -- SIN AFP
                    v_valor := '0';
                END IF;

            END IF;

        EXCEPTION -- AHORA SI NO ENCONTRAMOS INFORMACION, ENTONCES QUE ES UN FACTOR CON CLASE*
            WHEN no_data_found THEN
                BEGIN
                    SELECT
                        p.anopla,
                        p.mespla,
                        p.empobr
                    INTO
                        v_rec_planilla.anopla,
                        v_rec_planilla.mespla,
                        v_rec_planilla.empobr
                    FROM
                        planilla p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.numpla = pin_numpla;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE la PLANILLA [ '
                                        || pin_numpla
                                        || ' ], revisar el STATUS de la planilla actual';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                BEGIN
                    SELECT
                        fcp.nombre
                        || ' - [ '
                        || upper(ctfp.destipcla)
                        || ' - '
                        || upper(tv.destipvar)
                        || ' ]',
                        CASE
                            WHEN fcp.tipvar = 'R' THEN
                                rtrim(to_char(nvl(fcp.vreal, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            WHEN fcp.tipvar = 'S' THEN
                                rtrim(to_char(nvl(0, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            WHEN fcp.tipvar = 'C' THEN
                                rtrim(to_char(nvl(ascii(fcp.vchar),
                                                  '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            WHEN fcp.tipvar = 'D' THEN
                                rtrim(to_char(nvl(0, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            WHEN fcp.tipvar = 'T' THEN
                                rtrim(to_char(nvl(0, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            WHEN fcp.tipvar = 'E' THEN
                                rtrim(to_char(nvl(fcp.ventero, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                            ELSE
                                rtrim(to_char(nvl(fcp.vreal, '0'),
                                              'FM999999999999990.999999'),
                                      ',')
                        END AS valor,
                        CASE
                            WHEN fcp.tipvar = 'S' THEN
                                fcp.vstrg
                            ELSE
                                NULL
                        END AS conceptorel,
                        fcp.tipcla
                    INTO
                        v_desley,
                        v_valor,
                        v_string,
                        v_tipcla
                    FROM
                        factor_planilla                                                        fp
                        LEFT OUTER JOIN factor_clase_planilla                                                  fcp ON fcp.id_cia = fp.id_cia
                                                                     AND fcp.codfac = fp.codfac
                        LEFT OUTER JOIN pack_hr_factor_planilla.sp_buscar_tipoclase(fcp.id_cia, fcp.tipcla)    ctfp ON ctfp.tipcla = fcp.tipcla
                        LEFT OUTER JOIN pack_hr_factor_planilla.sp_buscar_tipovariable(fcp.id_cia, fcp.tipvar) tv ON tv.tipvar = fcp.tipvar
                    WHERE
                            fp.id_cia = pin_id_cia
                        AND fp.codfac = pin_codcon
                        AND fp.tipfac = 'S'
                        AND ( ( fcp.tipcla = 1
                                AND fcp.codcla = v_rec_planilla.empobr )
                              OR ( fcp.tipcla = 2
                                   AND fcp.codcla = to_char(v_rec_planilla.anopla) ) );

                    -- SI TIENE UN CONCEPTO RELACIONADO ENTONCES           
                    IF v_string IS NOT NULL THEN
                        pack_hr_planilla_formula.sp_decodificar(pin_id_cia, pin_numpla, pin_codper, v_string, pin_swacti,
                                                               pin_coduser, pin_codcon, v_formula, v_aux_formula, v_valor,
                                                               v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                        -- FORMATEANDO EL VALOR
                        IF v_tipcla = 1 THEN
                            v_desfun := 'FACTOR DEFINIDO POR CONCEPTO RELACIONADO [ '
                                        || v_string
                                        || ' ] SEGUN EL TIPO DE TRABAJADOR [ '
                                        || v_rec_planilla.empobr
                                        || ' ]';
                        ELSIF v_tipcla = 2 THEN
                            v_desfun := 'FACTOR DEFINIDO POR CONCEPTO RELACIONADO [ '
                                        || v_string
                                        || ' ] SEGUN EL PERIODO DE LA PLANILLA [ '
                                        || v_rec_planilla.anopla
                                        || ' ]';
                        END IF;

                        v_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
                    END IF;

                EXCEPTION -- EL FACTOR NO ESTA DEFINIDO
                    WHEN no_data_found THEN
                        BEGIN
                            SELECT
                                fcp.nombre,
                                fcp.tipcla
                            INTO
                                v_desley,
                                v_tipcla
                            FROM
                                factor_planilla       fp
                                LEFT OUTER JOIN factor_clase_planilla fcp ON fcp.id_cia = fp.id_cia
                                                                             AND fcp.codfac = fp.codfac
                            WHERE
                                    fp.id_cia = pin_id_cia
                                AND fp.codfac = pin_codcon
                                AND fp.tipfac = 'S'
                                AND fcp.tipcla IN ( 1, 2 )
                            FETCH NEXT 1 ROWS ONLY;

                            pin_formula := 'FACTOR NO DEFINIDO';
                            IF v_tipcla = 1 THEN
                                pout_formula := 'FACTOR '
                                                || upper(v_desley)
                                                || ' NO DEFINIDO PARA EL TIPO DE TRABAJADOR [ '
                                                || v_rec_planilla.empobr
                                                || ' ]';
                            ELSIF v_tipcla = 2 THEN
                                pout_formula := 'FACTOR '
                                                || upper(v_desley)
                                                || ' NO DEFINIDO PARA EL PERIODO DE LA PLANILLA [ '
                                                || v_rec_planilla.anopla
                                                || ' ]';
                            ELSE
                                pout_formula := 'FACTOR NO DEFINIDO, REVISAR LA ASIGNACION DEL CONCEPTO PADRE [ '
                                                || pin_concepto
                                                || ' ]';
                            END IF;

                            pout_mensaje := pin_formula;
                            v_valor := '0';
                            IF pin_swacti = 'S' THEN
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;
                        EXCEPTION
                            WHEN no_data_found THEN
                                pin_formula := 'FACTOR NO DEFINIDO';
                                pout_formula := 'FACTOR NO DEFINIDO, REVISAR LA ASIGNACION DEL CONCEPTO PADRE [ '
                                                || pin_concepto
                                                || ' ]';
                                pout_mensaje := 'FACTOR NO DEFINIDO';
                                v_valor := '0';
                                IF pin_swacti = 'S' THEN
                                    RAISE pkg_exceptionuser.ex_error_inesperado;
                                END IF;
                        END;
                END;

        END;

        pin_formula := v_desley;
        pout_formula := nvl(v_desfun, v_desley);
        pin_valor := v_valor;
        IF pin_swacti = 'N' THEN
            pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                       'FT', 0, pin_formula, pout_formula, pin_valor,
                                                       v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || ' - PERSONAL [ '
                                || pin_codper
                                || ' ] - FACTOR [ '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - FACTOR [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - FACTOR [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_ffactor;

    PROCEDURE sp_decodificar_cfijo (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m             json_object_t;
        pout_mensaje  VARCHAR2(1000) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_valor       planilla_concepto.valcon%TYPE;
    BEGIN
        pin_formula := 'CONCEPTO FIJO'
                       || chr(13)
                       || 'SE EXTRAE DEL VALOR REGISTRADO EN EL MANTENIMIENTO DE CONCEPTOS FIJOS DEL PERSONAL PARA EL PERIODO Y MES DE PLANILLA'
                       ;
        pout_formula := 'CONCEPTO FIJO'
                        || chr(13)
                        || 'SE EXTRAE DEL VALOR REGISTRADO EN EL MANTENIMIENTO DE CONCEPTOS FIJOS DEL PERSONAL PARA EL PERIODO Y MES DE PLANILLA'
                        ;
        IF pin_swacti = 'N' THEN
            BEGIN
                SELECT
                    pc.valcon
                INTO v_valor
                FROM
                    planilla_concepto pc
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = pin_numpla
                    AND pc.codper = pin_codper
                    AND pc.codcon = pin_codcon;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'ERROR el CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] no esta definido para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
            pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                       'F', 0, pin_formula, pout_formula, pin_valor,
                                                       v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || pin_codper
                                || ' - '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_cfijo;

    PROCEDURE sp_decodificar_cvariable (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m             json_object_t;
        pout_mensaje  VARCHAR2(1000) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_valor       planilla_concepto.valcon%TYPE;
    BEGIN
        pin_formula := 'CONCEPTO VARIABLE'
                       || chr(13)
                       || 'SE EXTRAE DEL VALOR REGISTRADO EN EL PLANILLON';
        pout_formula := 'CONCEPTO VARIABLE'
                        || chr(13)
                        || 'SE EXTRAE DEL VALOR REGISTRADO EN EL PLANILLON';
        IF pin_swacti = 'N' THEN
            BEGIN
                SELECT
                    pc.valcon
                INTO v_valor
                FROM
                    planilla_concepto pc
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = pin_numpla
                    AND pc.codper = pin_codper
                    AND pc.codcon = pin_codcon;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'ERROR el CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] no esta definido para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            pin_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
            pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                       'V', 0, pin_formula, pout_formula, pin_valor,
                                                       v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || pin_codper
                                || ' - '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_cvariable;

    PROCEDURE sp_decodificar_cprestamo (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m                json_object_t;
        pout_mensaje     VARCHAR2(1000) := '';
        v_formula        VARCHAR2(1000) := '';
        v_aux_formula    VARCHAR2(1000) := '';
        v_mensaje        VARCHAR2(1000) := '';
        v_codigo         VARCHAR2(20 CHAR) := '';
        v_valor          VARCHAR2(4000) := '';
        v_valcon         planilla_concepto.valcon%TYPE;
        v_codcon         VARCHAR2(20 CHAR) := '';
        v_fijvar         concepto.fijvar%TYPE;
        v_tipori         VARCHAR2(2 CHAR) := '';
        v_proceso        NUMBER := 0;
        v_ultimocaracter VARCHAR2(1) := 'N';
        v_poutformula    VARCHAR2(4000) := '';
        v_pout_formula   VARCHAR2(4000) := '';
        v_char           VARCHAR2(1) := '';
        v_salpre         prestamo.salpre%TYPE;
    BEGIN
        IF pin_formula IS NULL THEN
            BEGIN
                SELECT
                    pc.proceso,
                    pc.valcon,
                    c.formul,
                    c.fijvar
                INTO
                    v_proceso,
                    v_valcon,
                    v_formula,
                    v_fijvar
                FROM
                         planilla_concepto pc
                    INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                             AND c.codcon = pc.codcon
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.numpla = pin_numpla
                    AND pc.codper = pin_codper
                    AND pc.codcon = pin_codcon;

            EXCEPTION
        -- SI EL CONCEPTO NO EXISTE O NO SE ENCUENTRA ASINADO AL TRABAJADOR, ERROR ...!
                WHEN no_data_found THEN
                    BEGIN
                        SELECT
                            '0'
                        INTO v_char
                        FROM
                                 planilla p
                            INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = p.id_cia
                                                                    AND tpc.tippla = p.tippla
                        WHERE
                                p.id_cia = pin_id_cia
                            AND p.numpla = pin_numpla
                            AND tpc.codcon = pin_codcon;

                    -- SI EL CONCEPTO, NO ESTA ASOCIADO AL TIPO DE PLANILLA, ENTONCES MARCARA ERROR Y SE SALTARA ESTA VALIDACION!
                        IF pin_formula IS NULL THEN
                            pout_mensaje := 'ERROR el CONCEPTO [ '
                                            || pin_codcon
                                            || ' ] no esta definido para el TRABAJADOR [ '
                                            || pin_codper
                                            || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                        ELSE
                            pout_mensaje := 'ERROR el CONCEPTO [ '
                                            || pin_codcon
                                            || ' ] definido en la FORMULA [ '
                                            || chr(13)
                                            || pin_formula
                                            || ' ]'
                                            || chr(13)
                                            || ' no esta definido para el TRABAJADOR [ '
                                            || pin_codper
                                            || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                        END IF;

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    EXCEPTION
                        WHEN no_data_found THEN
                            pin_formula := 'CONCEPTO NO DEFINIDO PARA EL TRABAJADOR';
                            pout_formula := 'CONCEPTO NO DEFINIDO PARA EL TRABAJADOR :  '
                                            || chr(13)
                                            || 'NO PERTENECE AL TIPO DE PLANILLA PROCESADA, POR ENDE EL VALOR SE ASIGNA EN "0"'
                                            || chr(13)
                                            || 'NOTA: SI EL CONCEPTO SI HUBIERA ESTADO ASIGNADO AL TIPO DE PLANILLA EL PROCESO SE DETIENE!'
                                            ;

                            v_valcon := 0;
                            v_proceso := 1;
                    END;
            END;
        ELSE
            v_formula := pin_formula;
        END IF;

        IF v_formula LIKE ':PRESTAMO' THEN
            pin_formula := 'CONCEPTO DE TIPO PRESTAMO DIFERENCIA';
            pout_formula := 'ACUMULA EL VALOR DE LAS CUOTAS DE LOS PRESTAMOS QUE CORRESPONDEN A LA PLANILLA ACTUAL DE FORMA DIREFENCIADA'
            ;
            pin_valor := '0';
        ELSE
            pin_formula := 'CONCEPTO DE TIPO PRESTAMO ACUMULADO';
            pout_formula := 'ACUMULA EL VALOR DE TODAS LAS CUOTAS DE LOS PRESTAMOS QUE CORRESPONDEN A LA PLANILLA ACTUAL';
            IF
                pin_swacti = 'S'
                AND v_proceso = 0
            THEN
                -- RECALCULAMOS EL SALDO DEL INICIAL DEL PRESTAMO
                FOR j IN (
                    SELECT
                        ps.id_cia,
                        p.numpla,
                        p.anopla,
                        p.mespla,
                        pa.fecini,
                        pa.fecfin,
                        ps.id_pre,
                        ps.codper
                    FROM
                             prestamo ps
                        INNER JOIN planilla              p ON p.id_cia = ps.id_cia
                                                 AND p.numpla = pin_numpla
                        INNER JOIN prestamo_tipoplanilla ptp ON ptp.id_cia = ps.id_cia -- SOLO PRESTAMO INCLUIDO EN EL TIPO DE PLANILLA
                                                                AND ptp.id_pre = ps.id_pre
                                                                AND ( ptp.tippla = p.tippla
                                                                      OR ptp.tippla = 'L' ) -- SIEMPRE SE INGLUYE EN LA PLANILLA DE LIQUIDACION
                        INNER JOIN planilla_auxiliar     pa ON pa.id_cia = ps.id_cia -- SOLO PERSONAL INCLUIDO EN LA PLANILLA
                                                           AND pa.numpla = pin_numpla
                                                           AND pa.codper = ps.codper
                    WHERE
                            ps.id_cia = pin_id_cia
                        AND ps.fecpre < pa.fecfin
                        AND ( pin_codper IS NULL
                              OR pa.codper = pin_codper )
                ) LOOP

                    -- RECALCULAMOS EL SALDO DEL INICIAL DE CADA PRESTAMO
                    UPDATE prestamo
                    SET
                        salpre = ( monpre - nvl(monpag, 0) ) - (
                            SELECT
                                nvl(SUM(nvl(d.valcuo, 0)),
                                    0)
                            FROM
                                     dsctoprestamo d
                                INNER JOIN planilla p ON p.id_cia = d.id_cia
                                                         AND p.numpla = d.numpla
                            WHERE
                                    d.id_cia = j.id_cia
                                AND d.id_pre = j.id_pre
                                AND d.numpla < j.numpla -- SALDO INICIAL, PLANILLA DIFERENTE
                                AND ( p.anopla * 100 + p.mespla ) <= ( j.anopla * 100 + j.mespla ) -- PERIODO ANTERIOR 
                                AND d.aplica IN ( 'S', 'M' )
                        ),
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = j.id_cia
                        AND id_pre = j.id_pre;

                    -- VERIFICAMOS EL ESTADO DEL SALDO
                    BEGIN
                        SELECT
                            p.salpre
                        INTO v_salpre
                        FROM
                            prestamo p
                        WHERE
                                p.id_cia = j.id_cia
                            AND p.id_pre = j.id_pre;

                    END;

                    IF v_salpre > 0 THEN -- SOLO SI HAY SALDO
                    -- REGISTRAMOS LA CUOTA POR DEFECTO PARA ESTE PRESTAMO
                    -- SOLO SE ACTUALIZARA, SI SOLO SI NO SE MANIPULO MANUALMENTE
                        pack_hr_dsctoprestamo.sp_registrar(pin_id_cia, pin_numpla, j.id_pre, j.codper, j.fecfin,
                                                          pin_coduser, v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    -- RECALCULAMOS EL SALDO DEL FINAL DE CADA DEL PRESTAMO
                        UPDATE prestamo
                        SET
                            salpre = ( monpre - nvl(monpag, 0) ) - (
                                SELECT
                                    nvl(SUM(nvl(d.valcuo, 0)),
                                        0)
                                FROM
                                         dsctoprestamo d
                                    INNER JOIN planilla p ON p.id_cia = d.id_cia
                                                             AND p.numpla = d.numpla
                                WHERE
                                        d.id_cia = j.id_cia
                                    AND d.id_pre = j.id_pre
                                    AND d.numpla <= j.numpla -- SALDO INICIAL, PLANILLA DIFERENTE
                                    AND ( p.anopla * 100 + p.mespla ) <= ( j.anopla * 100 + j.mespla ) -- PERIODO ANTERIOR 
                                    AND d.aplica IN ( 'S', 'M' )
                            ),
                            uactua = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = j.id_cia
                            AND id_pre = j.id_pre;

                    END IF;

                END LOOP;

                -- ACTUALIZO EL CONCEPTO, EN LA PLANILLA CONCEPTO
                FOR k IN (
                    SELECT
                        pa.id_cia,
                        pa.numpla,
                        pa.codper,
                        SUM(nvl(d.valcuo, 0))                      AS valcuo,
                        SUM(nvl(ps.salpre, 0))                     AS salpre,
                        SUM(nvl(ps.monpre, 0) - nvl(ps.monpag, 0)) AS monpre
                    FROM
                             prestamo ps
                        INNER JOIN planilla              p ON p.id_cia = ps.id_cia
                                                 AND p.numpla = pin_numpla
                        INNER JOIN prestamo_tipoplanilla ptp ON ptp.id_cia = ps.id_cia -- SOLO PRESTAMO INCLUIDO EN EL TIPO DE PLANILLA
                                                                AND ptp.id_pre = ps.id_pre
                                                                AND ptp.tippla = p.tippla
                        INNER JOIN planilla_auxiliar     pa ON pa.id_cia = ps.id_cia -- SOLO PERSONAL INCLUIDO EN LA PLANILLA
                                                           AND pa.numpla = pin_numpla
                                                           AND pa.codper = ps.codper
                        INNER JOIN dsctoprestamo         d ON d.id_cia = ps.id_cia -- SOLO DESCUENTOS INCLUIDOS EN ESTA PLANILLA
                                                      AND d.id_pre = ps.id_pre
                                                      AND d.numpla = pa.numpla
                                                      AND d.aplica IN ( 'S', 'M' )
                    WHERE
                            pa.id_cia = pin_id_cia
                        AND pa.numpla = pin_numpla
                        AND ( pin_codper IS NULL
                              OR pa.codper = pin_codper )
                    GROUP BY
                        pa.id_cia,
                        pa.numpla,
                        pa.codper
                ) LOOP
                    UPDATE planilla_concepto pc
                    SET
                        pc.valcon = nvl(k.valcuo, 0),
                        pc.proceso = 1
                    WHERE
                            pc.id_cia = k.id_cia
                        AND pc.numpla = k.numpla
                        AND pc.codper = k.codper
                        AND pc.codcon = pin_codcon;

                    UPDATE planilla_saldoprestamo psp
                    SET
                        psp.codcon = pin_codcon,
                        psp.id_pres = (
                            SELECT
                                LISTAGG(p.id_pre, ',')
                            FROM
                                     prestamo p
                                INNER JOIN dsctoprestamo d ON d.id_cia = p.id_cia
                                                              AND d.id_pre = p.id_pre
                                                              AND d.numpla = k.numpla
                            WHERE
                                    p.id_cia = k.id_cia
                                AND p.codper = k.codper
                        ),
                        psp.valcuo = k.valcuo,
                        psp.saldo = k.monpre - ( k.salpre + k.valcuo ),
                        psp.situac = 'S'
                    WHERE
                            psp.id_cia = k.id_cia
                        AND psp.numpla = k.numpla
                        AND psp.codper = k.codper;

                END LOOP;

            ELSIF
                pin_swacti = 'S'
                AND v_proceso = 1
            THEN
                BEGIN
                    SELECT
                        pc.valcon
                    INTO v_valor
                    FROM
                        planilla_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = pin_numpla
                        AND pc.codper = pin_codper
                        AND pc.codcon = pin_codcon;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'ERROR el CONCEPTO [ '
                                        || pin_codcon
                                        || ' ] no esta definido para el TRABAJADOR [ '
                                        || pin_codper
                                        || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                pin_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
            ELSE
                BEGIN
                    SELECT
                        pc.valcon
                    INTO v_valor
                    FROM
                        planilla_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.numpla = pin_numpla
                        AND pc.codper = pin_codper
                        AND pc.codcon = pin_codcon;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'ERROR el CONCEPTO [ '
                                        || pin_codcon
                                        || ' ] no esta definido para el TRABAJADOR [ '
                                        || pin_codper
                                        || ' ], revisar la asignacion de CONCEPTOS FIJOS Y POR TIPO DE PLANILLA';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                pin_valor := rtrim(to_char(v_valor, 'FM999999999999990.999999'), ',');
                pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                           'P', 0, pin_formula, pout_formula, pin_valor,
                                                           v_mensaje);

                m := json_object_t.parse(v_mensaje);
                IF ( m.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := m.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || pin_codper
                                || ' - '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO PRESTAMO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' -  PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO PRESTAMO [ '
                                    || pin_codcon
                                    || ' ]'
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_cprestamo;

    PROCEDURE sp_decodificar_csistema (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m             json_object_t;
        pout_mensaje  VARCHAR2(1000) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_valor       VARCHAR2(20) := '';
        v_pdesde      NUMBER := 0;
        v_phasta      NUMBER := 0;
        v_tipfun      funcion_planilla.tipfun%TYPE;
        v_nummes      funcion_planilla.nummes%TYPE;
        v_actual      funcion_planilla.mactual%TYPE;
        v_codcon      concepto.codcon%TYPE;
        v_codper      personal.codper%TYPE;
        v_valacu      NUMBER(16, 2);
    BEGIN
        FOR i IN (
            SELECT
                p.anopla,
                p.mespla,
                p.empobr,
                p.tippla,
                pc.codper,
                pc.codcon,
                cf.conori,
                cf.condes,
                fp.tipfun,
                fp.nummes,
                fp.mactual,
                ( ( EXTRACT(YEAR FROM pa.finicio) * 100 ) + EXTRACT(MONTH FROM pa.finicio) ) AS pinicio,
                ppp.pdesde,
                ppp.phasta,
                upper(nvl(fp.observ, 'ND'))                                                  AS observ
            FROM
                     planilla p
                INNER JOIN planilla_concepto                                                                                pc ON pc.id_cia = p.id_cia
                                                   AND pc.numpla = p.numpla
                                                   AND pc.situac = 'S' -- SOLO PERSONAL ACTIVO
                INNER JOIN planilla_auxiliar                                                                                pa ON pa.id_cia = p.id_cia
                                                   AND pa.numpla = p.numpla
                                                   AND pa.codper = pc.codper
                INNER JOIN concepto                                                                                         c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'S' -- SOLO CONCEPTOS DE SISTEMA
                LEFT OUTER JOIN concepto_funcion                                                                                 cf ON
                cf.id_cia = c.id_cia
                                                       AND cf.condes = c.codcon
                LEFT OUTER JOIN funcion_planilla                                                                                 fp ON
                fp.id_cia = cf.id_cia
                                                       AND fp.codfun = cf.codfun
                INNER JOIN pack_hr_function_general.sp_periodo_rango(p.anopla, p.mespla, fp.nummes, fp.pactual, fp.mactual) ppp ON 0 = 0
            WHERE
                    p.id_cia = pin_id_cia
                AND p.numpla = pin_numpla
                AND ( pin_codper IS NULL
                      OR pc.codper = pin_codper )
                AND ( pin_codcon IS NULL
                      OR pc.codcon = pin_codcon )
                AND pc.situac = 'S'
                AND c.fijvar = 'S'
                AND NOT EXISTS (
                    SELECT
                        tp.conpre
                    FROM
                        tipo_trabajador tp
                    WHERE
                            tp.id_cia = p.id_cia
                        AND tp.tiptra = p.empobr
                        AND tp.conpre = pc.codcon
                )
            ORDER BY
                pc.codper ASC,
                fp.tipfun ASC
        ) LOOP
            IF
                i.tipfun IN ( 1, 2, 3, 4, 5,
                              6, 7 )
                AND nvl(i.nummes, 0) <= 0
            THEN
                pin_formula := 'FORMULA DEFINIDA, ASOCIADA AL CONCEPTO DE SISTEMA, TIENE EL NUMERO DE MESES EN CERO O EN NEGATIVO';
                pout_formula := 'FORMULA DEFINIDA, ASOCIADA AL CONCEPTO DE SISTEMA, TIENE EL NUMERO DE MESES EN CERO O EN NEGATIVO';
                pout_mensaje := 'FORMULA DEFINIDA, ASOCIADA AL CONCEPTO DE SISTEMA, TIENE EL NUMERO DE MESES EN CERO O EN NEGATIVO';
                v_codper := i.codper;
                v_codcon := i.codcon;
                pin_valor := '0.';
                IF pin_swacti = 'S' THEN
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            END IF;

            IF i.condes IS NULL OR i.conori IS NULL THEN
                pin_formula := 'CONCEPTO MARCADO COMO DE SISTEMA, NO TIENE UN CONCEPTO DE ORIGEN Y DESTINO ASOCIADOS, NI TAMPOCO UNA DEFINICION DE FORMULA'
                ;
                pout_formula := 'CONCEPTO MARCADO COMO DE SISTEMA, NO TIENE UN CONCEPTO DE ORIGEN Y DESTINO ASOCIADOS, NI TAMPOCO UNA DEFINICION DE FORMULA'
                ;
                pout_mensaje := 'CONCEPTO MARCADO COMO DE SISTEMA, NO TIENE UN CONCEPTO DE ORIGEN Y DESTINO ASOCIADOS, NI TAMPOCO UNA DEFINICION DE FORMULA'
                ;
                pin_valor := '0.';
                v_codper := i.codper;
                v_codcon := i.codcon;
                IF pin_swacti = 'S' THEN
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            END IF;

            IF i.tipfun IN ( 1, 2, 3, 4, 7 ) THEN
                FOR j IN (
                    SELECT
                        nvl(
                            CASE
                                WHEN i.tipfun = 1 THEN
                                    COUNT(nvl(pc.valcon, 0))
                                WHEN i.tipfun = 2 THEN
                                    SUM(nvl(pc.valcon, 0))
                                WHEN i.tipfun = 3 THEN
                                    MAX(nvl(pc.valcon, 0))
                                WHEN i.tipfun = 4 THEN
                                    MIN(nvl(pc.valcon, 0))
                                WHEN i.tipfun = 7 THEN
                                    AVG(nvl(pc.valcon, 0))
                            END,
                            0) AS valcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON p.id_cia = pc.id_cia
                                                 AND p.numpla = pc.numpla
                        INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = pc.id_cia
                                                                AND tpc.tippla = p.tippla
                                                                AND tpc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND ( p.anopla * 100 + p.mespla ) BETWEEN i.pdesde AND i.phasta
                        AND ( p.anopla * 100 + p.mespla ) > i.pinicio
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND pc.valcon > 0
                        AND pc.numpla <> pin_numpla
                        AND p.empobr = i.empobr
                        AND pc.situac = 'S'
                ) LOOP
                    pin_valor := nvl(rtrim(to_char(nvl(j.valcon, 0), 'FM999999999999990.999999'), ','), '0.');

                    pin_formula := i.observ;
                    pout_formula := 'FUNCION ==> '
                                    ||
                        CASE
                            WHEN i.tipfun = 1 THEN
                                'CONTAR VALOR'
                            WHEN i.tipfun = 2 THEN
                                'ACUMULAR VALOR '
                            WHEN i.tipfun = 3 THEN
                                'MAXIMO VALOR'
                            WHEN i.tipfun = 4 THEN
                                'MINIMO VALOR'
                            WHEN i.tipfun = 7 THEN
                                'PROMEDIAR VALOR'
                        END
                                    || chr(13)
                                    || 'CONCEPTO ORIGEN ==> '
                                    || i.conori
                                    || chr(13)
                                    || 'PERIODO DESDE ==> '
                                    || i.pdesde
                                    || chr(13)
                                    || 'PERIODO HASTA ==> '
                                    || i.phasta
                                    || chr(13)
                                    || 'PERIODO INICIO TRABAJADOR ==> '
                                    || i.pinicio
                                    || chr(13);

                    IF pin_swacti = 'S' THEN
                        UPDATE planilla_concepto
                        SET
                            valcon = j.valcon,
                            uactua = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = i.codper
                            AND codcon = i.condes
                            AND situac = 'S';

                    ELSE
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                                   'S', 0, i.observ, i.observ, pin_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                END LOOP;
            ELSIF i.tipfun IN ( 5 ) THEN
                FOR k IN (
                    SELECT
                        nvl(pc.valcon, 0) AS valcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON p.id_cia = pc.id_cia
                                                 AND p.numpla = pc.numpla
                        INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = pc.id_cia
                                                                AND tpc.tippla = p.tippla
                                                                AND tpc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND ( p.anopla * 100 + p.mespla ) BETWEEN i.pdesde AND i.phasta
                        AND ( p.anopla * 100 + p.mespla ) > i.pinicio
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND pc.valcon > 0
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                    ORDER BY
                        p.anopla ASC,
                        p.mespla ASC,
                        p.numpla ASC
                    FETCH NEXT 1 ROWS ONLY
                ) LOOP
                    pin_valor := nvl(rtrim(to_char(nvl(k.valcon, 0), 'FM999999999999990.999999'), ','), '0.');

                    pin_formula := i.observ;
                    pout_formula := 'FUNCION ==> '
                                    || 'PRIMER VALOR'
                                    || chr(13)
                                    || 'CONCEPTO ORIGEN ==> '
                                    || i.conori
                                    || chr(13)
                                    || 'PERIODO DESDE ==> '
                                    || i.pdesde
                                    || chr(13)
                                    || 'PERIODO HASTA ==> '
                                    || i.phasta
                                    || chr(13)
                                    || 'PERIODO INICIO TRABAJADOR ==> '
                                    || i.pinicio
                                    || chr(13);

                    IF pin_swacti = 'S' THEN
                        UPDATE planilla_concepto
                        SET
                            valcon = k.valcon,
                            uactua = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = i.codper
                            AND codcon = i.condes
                            AND situac = 'S';

                    ELSE
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                                   'S', 0, i.observ, i.observ, pin_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                END LOOP;
            ELSIF i.tipfun IN ( 6 ) THEN
                FOR k IN (
                    SELECT
                        nvl(pc.valcon, 0) AS valcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON p.id_cia = pc.id_cia
                                                 AND p.numpla = pc.numpla
                        INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = pc.id_cia
                                                                AND tpc.tippla = p.tippla
                                                                AND tpc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND ( p.anopla * 100 + p.mespla ) BETWEEN i.pdesde AND i.phasta
                        AND ( p.anopla * 100 + p.mespla ) > i.pinicio
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND pc.valcon > 0
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                    ORDER BY
                        p.anopla DESC,
                        p.mespla DESC,
                        p.numpla DESC
                    FETCH NEXT 1 ROWS ONLY
                ) LOOP
                    pin_valor := nvl(rtrim(to_char(nvl(k.valcon, 0), 'FM999999999999990.999999'), ','), '0.');

                    pin_formula := i.observ;
                    pout_formula := 'FUNCION ==> '
                                    || 'ULTIMO VALOR'
                                    || chr(13)
                                    || 'CONCEPTO ORIGEN ==> '
                                    || i.conori
                                    || chr(13)
                                    || 'PERIODO DESDE ==> '
                                    || i.pdesde
                                    || chr(13)
                                    || 'PERIODO HASTA ==> '
                                    || i.phasta
                                    || chr(13)
                                    || 'PERIODO INICIO TRABAJADOR ==> '
                                    || i.pinicio
                                    || chr(13);

                    IF pin_swacti = 'S' THEN
                        UPDATE planilla_concepto
                        SET
                            valcon = k.valcon,
                            uactua = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = i.codper
                            AND codcon = i.condes
                            AND situac = 'S';

                    ELSE
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                                   'S', 0, i.observ, i.observ, pin_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                END LOOP;
            ELSIF i.tipfun IN ( 8 ) THEN
                FOR k IN (
                    SELECT
                        nvl(pc.valcon, 0) AS valcon
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON p.id_cia = pc.id_cia
                                                 AND p.numpla = pc.numpla
                        INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = pc.id_cia
                                                                AND tpc.tippla = p.tippla
                                                                AND tpc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND ( p.anopla * 100 + p.mespla ) BETWEEN i.pdesde AND i.phasta
                        AND ( p.anopla * 100 + p.mespla ) > i.pinicio
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND pc.valcon > 0
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND p.tippla = 'N'
                        AND pc.situac = 'S'
                    ORDER BY
                        p.anopla DESC,
                        p.mespla DESC,
                        p.numpla DESC
                    FETCH NEXT 1 ROWS ONLY
                ) LOOP
                    pin_valor := nvl(rtrim(to_char(nvl(k.valcon, 0), 'FM999999999999990.999999'), ','), '0.');

                    pin_formula := i.observ;
                    pout_formula := 'FUNCION ==> '
                                    || 'ULTIMO VALOR DE LA PLANILLA NORMAL'
                                    || chr(13)
                                    || 'CONCEPTO ORIGEN ==> '
                                    || i.conori
                                    || chr(13)
                                    || 'PERIODO DESDE ==> '
                                    || i.pdesde
                                    || chr(13)
                                    || 'PERIODO HASTA ==> '
                                    || i.phasta
                                    || chr(13)
                                    || 'PERIODO INICIO TRABAJADOR ==> '
                                    || i.pinicio
                                    || chr(13);

                    IF pin_swacti = 'S' THEN
                        UPDATE planilla_concepto
                        SET
                            valcon = k.valcon,
                            uactua = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = pin_id_cia
                            AND numpla = pin_numpla
                            AND codper = i.codper
                            AND codcon = i.condes
                            AND situac = 'S';

                    ELSE
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                                   'S', 0, i.observ, i.observ, pin_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    END IF;

                END LOOP;
            ELSIF nvl(i.tipfun, 10) IN ( 9, 10 ) THEN
                -- AQUI SE DEFINEN FUNCIONES DE TIPO ESPECIAL
                pin_formula := 'FUNCION DE CONCEPTO SISTEMA NO DEFINIDO';
                pout_formula := 'FUNCION DE CONCEPTO SISTEMA NO DEFINIDO';
                pout_mensaje := 'FUNCION DE CONCEPTO SISTEMA NO DEFINIDO';
                pin_valor := '0.';
                v_codper := i.codper;
                v_codcon := i.condes;
                IF pin_swacti = 'S' THEN
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            ELSIF i.tipfun = 11 THEN
                -- FUNCION RENTA DE QUINTA

                IF i.mespla < 4 THEN /* CUANDO EL MES ES MENOR A ABRIL EL VALOR RETORNADO ES CERO */
                    v_valacu := 0;
                ELSIF i.mespla = 4 THEN /*CUANDO ES ABRIL EL ACUMULADO DE ENERO A MARZO */
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND 3;

                ELSIF
                    i.mespla > 4
                    AND i.mespla < 8
                THEN /*CUANDO ES DE MAYO A JULIO EL ACUMULADO DE ENERO A ABRIL*/

                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND 4;

                ELSIF i.mespla = 8 THEN /*CUANDO ES AGOSTO EL ACUMULADO DE ENERO A JULIO*/

                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND 7;

                ELSIF
                    i.mespla >= 9
                    AND i.mespla <= 11
                THEN /*CUANDO ES SETIEMBRE A NOVIEMBRE EL ACUMULADO DE ENERO A AGOSTO*/

                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND 8;

                ELSIF ( i.mespla = 12 ) THEN /*CUANDO ES DICIEMBRE EL ACUMULADO DE ENERO A NOVIEMBRE*/

                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND 11;

                END IF;

                pin_valor := nvl(rtrim(to_char(v_valacu, 'FM999999999999990.999999'), ','), '0.');

                pin_formula := i.observ;
                pout_formula := 'FUNCION  ==> '
                                || 'ESPECIAL - FUNCION RENTA DE QUINTA'
                                || chr(13)
                                || 'CONCEPTO ORIGEN ==> '
                                || i.conori
                                || chr(13);

                IF pin_swacti = 'S' THEN
                    UPDATE planilla_concepto
                    SET
                        valcon = v_valacu,
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper
                        AND codcon = i.condes
                        AND situac = 'S';

                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            ELSIF i.tipfun = 12 THEN
             -- ACUMULADO PRIMER SEMESTRE DEL AÑO
                IF i.mespla BETWEEN 2 AND 7 THEN
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND ( i.mespla - 1 );

                ELSE
                    v_valacu := 0;
                END IF;

                pin_valor := nvl(rtrim(to_char(v_valacu, 'FM999999999999990.999999'), ','), '0.');

                pin_formula := i.observ;
                pout_formula := 'FUNCION  ==> '
                                || 'ESPECIAL - ACUMULADO PRIMER SEMESTRE DEL AÑO'
                                || chr(13)
                                || 'CONCEPTO ORIGEN ==> '
                                || i.conori
                                || chr(13);

                IF pin_swacti = 'S' THEN
                    UPDATE planilla_concepto
                    SET
                        valcon = v_valacu,
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper
                        AND codcon = i.condes
                        AND situac = 'S';

                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            ELSIF i.tipfun = 13 THEN
              -- ACUMULADO SEGUNDO SEMESTRE DEL AÑO A
                IF i.mespla BETWEEN 8 AND 12 THEN
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 7 AND ( i.mespla - 1 );

                ELSE
                    v_valacu := 0;
                END IF;

                pin_valor := nvl(rtrim(to_char(v_valacu, 'FM999999999999990.999999'), ','), '0.');

                pin_formula := i.observ;
                pout_formula := 'FUNCION  ==> '
                                || 'ESPECIAL - ACUMULADO SEGUNDO SEMESTRE DEL AÑO A'
                                || chr(13)
                                || 'CONCEPTO ORIGEN ==> '
                                || i.conori
                                || chr(13);

                IF pin_swacti = 'S' THEN
                    UPDATE planilla_concepto
                    SET
                        valcon = v_valacu,
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper
                        AND codcon = i.condes
                        AND situac = 'S';

                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            ELSIF i.tipfun = 14 THEN
             -- ACUMULADO SEGUNDO SEMESTRE DEL AÑO B
                IF i.mespla BETWEEN 7 AND 12 THEN
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 6 AND ( i.mespla - 1 );

                ELSE
                    v_valacu := 0;
                END IF;

                pin_valor := nvl(rtrim(to_char(v_valacu, 'FM999999999999990.999999'), ','), '0.');

                pin_formula := i.observ;
                pout_formula := 'FUNCION  ==> '
                                || 'ESPECIAL - ACUMULADO SEGUNDO SEMESTRE DEL AÑO B'
                                || chr(13)
                                || 'CONCEPTO ORIGEN ==> '
                                || i.conori
                                || chr(13);

                IF pin_swacti = 'S' THEN
                    UPDATE planilla_concepto
                    SET
                        valcon = v_valacu,
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper
                        AND codcon = i.condes
                        AND situac = 'S';

                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            ELSIF i.tipfun = 15 THEN
            -- ACUMULADO POR SEMESTRE
                IF i.mespla BETWEEN 2 AND 7 THEN
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 1 AND ( i.mespla - 1 );

                ELSIF i.mespla BETWEEN 8 AND 12 THEN
                    SELECT
                        nvl(SUM(nvl(pc.valcon, 0)),
                            0) AS valacu
                    INTO v_valacu
                    FROM
                             planilla_concepto pc
                        INNER JOIN planilla              p ON pc.numpla = p.numpla
                        INNER JOIN tipoplanilla_concepto tc ON tc.tippla = p.tippla
                                                               AND tc.codcon = pc.codcon
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codcon = i.conori
                        AND pc.codper = i.codper
                        AND p.empobr = i.empobr
                        AND pc.numpla <> pin_numpla
                        AND pc.situac = 'S'
                        AND p.anopla = i.anopla
                        AND p.mespla BETWEEN 7 AND ( i.mespla - 1 );

                ELSE
                    v_valacu := 0;
                END IF;

                pin_valor := nvl(rtrim(to_char(v_valacu, 'FM999999999999990.999999'), ','), '0.');

                pin_formula := i.observ;
                pout_formula := 'FUNCION  ==> '
                                || 'ESPECIAL - ACUMULADO POR SEMESTRE'
                                || chr(13)
                                || 'CONCEPTO ORIGEN ==> '
                                || i.conori
                                || chr(13);

                IF pin_swacti = 'S' THEN
                    UPDATE planilla_concepto
                    SET
                        valcon = v_valacu,
                        uactua = pin_coduser,
                        factua = current_timestamp
                    WHERE
                            id_cia = pin_id_cia
                        AND numpla = pin_numpla
                        AND codper = i.codper
                        AND codcon = i.condes
                        AND situac = 'S';

                ELSE
                    pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                               'S', 0, i.observ, i.observ, pin_valor,
                                                               v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            END IF;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || ' - PERSONAL [ '
                                || pin_codper
                                || ' ] - CONCEPTO SISTEMA [ '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' - PERSONAL [ '
                                    || v_codper
                                    || ' ] - CONCEPTO SISTEMA [ '
                                    || v_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO SISTEMA [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_csistema;

    PROCEDURE sp_decodificar_cnodefinido (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        m             json_object_t;
        pout_mensaje  VARCHAR2(1000) := '';
        v_formula     VARCHAR2(1000) := '';
        v_aux_formula VARCHAR2(1000) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_valor       VARCHAR2(20) := '';
    BEGIN
        pin_formula := ' CONCEPTO MARCADO COMO CALCULADO [ '
                       || pin_codcon
                       || ' ] =  NO TIENE FORMULA DEFINIDO';
        pout_formula := 'FORMULA NO DEFINIDA ==> 0';
        pin_valor := '0';
        IF pin_swacti = 'S' THEN
            pout_mensaje := 'El CONCEPTO marcado como CALCULADO [ '
                            || pin_codcon
                            || ' ] no tiene FORMULA definida';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        ELSE
            pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_concepto, pin_codcon,
                                                       'C', 0, pin_formula, pout_formula, pin_valor,
                                                       v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || ' - PERSONAL [ '
                                || pin_codper
                                || ' ] - CONCEPTO [ '
                                || pin_codcon
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                                    || ' - PERSONAL [ '
                                    || pin_codper
                                    || ' ] - CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] '
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_decodificar_cnodefinido;

END;

/
