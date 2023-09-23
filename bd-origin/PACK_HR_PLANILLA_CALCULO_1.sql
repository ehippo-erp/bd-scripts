--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_CALCULO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_CALCULO" AS

    FUNCTION sp_valida_objeto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores  r_errores := r_errores(NULL, NULL);
        m            json_object_t;
        pout_mensaje VARCHAR2(1000);
        v_mensaje    VARCHAR2(1000) := '';
    BEGIN
        pack_hr_planilla.sp_planilla_cerrada(pin_id_cia, pin_numpla, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            reg_errores.orden := 1;
            reg_errores.concepto := '1 - Planilla Cerrada';
            reg_errores.valor := 'N';
            reg_errores.deserror := 'La Planilla actualmente se encuntra CERRADA por lo que no se puede realizar ninguna OPERACION';
            PIPE ROW ( reg_errores );
        END IF;

        FOR i IN (
            SELECT
                codcon,
                nomcon
            FROM
                pack_hr_planilla_calculo.sp_valida_concepto_noincluido(pin_id_cia, pin_numpla)
        ) LOOP
            reg_errores.orden := 3;
            reg_errores.concepto := '3 - Concepto No Incluido';
            reg_errores.valor := i.codcon;
            reg_errores.deserror := 'La Planilla no tiene asginado el Concepto [ '
                                    || i.codcon
                                    || ' - '
                                    || i.nomcon
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END LOOP;

    END sp_valida_objeto;

    FUNCTION sp_valida_objeto_ordenado (
        pin_id_cia  NUMBER,
        pin_numpla  NUMBER,
        pin_codper  VARCHAR2,
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
            pack_hr_planilla_calculo.sp_valida_objeto(pin_id_cia, pin_numpla, NULL) v
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

    FUNCTION sp_valida_concepto_noincluido (
        pin_id_cia NUMBER,
        pin_numpla NUMBER
    ) RETURN datatable_concepto_noincluido
        PIPELINED
    AS

        v_table  datatable_concepto_noincluido;
        v_tippla VARCHAR2(1) := '';
        v_empobr VARCHAR2(1) := '';
    BEGIN
        BEGIN
            SELECT
                empobr,
                tippla
            INTO
                v_empobr,
                v_tippla
            FROM
                planilla
            WHERE
                id_cia = pin_numpla;

        EXCEPTION
            WHEN no_data_found THEN
                v_empobr := NULL;
                v_tippla := NULL;
        END;

        IF ( v_empobr IS NOT NULL OR v_tippla IS NOT NULL ) THEN
            SELECT
                t.codcon,
                c.nombre
            BULK COLLECT
            INTO v_table
            FROM
                     tipoplanilla_concepto t
                INNER JOIN concepto c ON c.id_cia = t.id_cia
                                         AND t.codcon = c.codcon
                                         AND c.empobr = v_empobr
            WHERE
                    t.id_cia = pin_id_cia
                AND t.tippla = v_tippla
                AND NOT EXISTS (
                    SELECT DISTINCT
                        p.codcon
                    FROM
                             planilla_concepto p
                        INNER JOIN tipoplanilla_concepto tpp ON tpp.id_cia = p.id_cia
                                                                AND tpp.codcon = p.codcon
                                                                AND tpp.tippla = v_tippla
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.numpla = pin_numpla
                        AND p.codcon = t.codcon
                );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END IF;

        RETURN;
    END sp_valida_concepto_noincluido;

    FUNCTION sp_planilla_calculo (
        pin_id_cia IN NUMBER,
        pin_numpla IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_codcon IN VARCHAR2
    ) RETURN datatable_planilla_calculo
        PIPELINED
    AS
        v_table datatable_planilla_calculo;
    BEGIN
        SELECT
            pr.id_cia,
            pl.numpla,
            pr.codper,
            ( p.apepat
              || ' '
              || p.apemat
              || ', '
              || p.nombre ) AS nomper,
            co.codcon,
            co.nombre,
            pc.valcon,
            co.fijvar,
            pcc.formul
        BULK COLLECT
        INTO v_table
        FROM
                 planilla_resumen pr
            INNER JOIN planilla_concepto                                                             pc ON pc.id_cia = pr.id_cia
                                               AND pc.numpla = pr.numpla
                                               AND pc.codper = pr.codper
            INNER JOIN personal                                                                      p ON p.id_cia = pr.id_cia
                                     AND p.codper = pr.codper
            INNER JOIN planilla                                                                      pl ON pl.id_cia = pr.id_cia
                                      AND pl.numpla = pr.numpla
            INNER JOIN pack_hr_concepto_formula.sp_ayuda(pc.id_cia, pc.codcon, pl.empobr, pl.tippla) pcc ON 0 = 0
            INNER JOIN concepto                                                                      co ON co.id_cia = pr.id_cia
                                      AND co.codcon = pc.codcon
        WHERE
                pr.id_cia = pin_id_cia
            AND pr.numpla = pin_numpla
            AND pc.situac = 'S'
            AND ( pin_codper IS NULL
                  OR p.codper = pin_codper )
            AND ( pin_codcon IS NULL
                  OR pc.codcon = pin_codcon )
        ORDER BY
            pr.codper ASC,
            co.codcon ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_planilla_calculo;

    PROCEDURE sp_calcular (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje   VARCHAR2(4000) := '';
        o              json_object_t;
        m              json_object_t;
        v_mensaje      VARCHAR2(4000) := '';
        v_formula      VARCHAR2(4000) := '';
        v_valor        VARCHAR2(4000) := '';
        v_pout_formula VARCHAR2(4000) := '';
    BEGIN
        UPDATE planilla_concepto
        SET
            proceso = 0
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla;

        COMMIT;
        FOR i IN (
            SELECT
                id_cia,
                numpla,
                codper,
                codcon,
                formul,
                tipori,
                valcon
            FROM
                pack_hr_planilla_calculo.sp_planilla_calculo(pin_id_cia, pin_numpla, pin_codper, NULL)
            WHERE
                tipori IN ( 'C', 'P' ) -- SOLO LOS CONCEPTOS DE TIPO CALCULADO
        ) LOOP
            CASE
                WHEN i.tipori = 'C' THEN
                    CASE -- SI ES UN CONCEPTO DE TIPO CALCULADO Y LA FORMULA NO ES NULL NI '0'*
                        WHEN
                            i.formul IS NOT NULL
                            AND i.formul <> '0'
                        THEN
                            v_formula := i.formul;
                            pack_hr_planilla_formula.sp_decodificar(i.id_cia, i.numpla, i.codper, i.codcon, 'S',
                                                                   pin_coduser, i.codcon, v_formula, v_pout_formula, v_valor,
                                                                   v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        WHEN i.formul IS NULL THEN -- CONCEPTO NO DEFINIDO
                            pack_hr_planilla_formula.sp_decodificar_cnodefinido(i.id_cia, i.numpla, i.codper, i.codcon, 'S',
                                                                               pin_coduser, i.codcon, v_formula, v_pout_formula, v_valor
                                                                               ,
                                                                               v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        ELSE -- CONCEPTO MARCADO EN  '0'
                            UPDATE planilla_concepto
                            SET
                                valcon = 0,
                                proceso = 1,
                                uactua = pin_coduser,
                                factua = current_date
                            WHERE
                                    id_cia = i.id_cia
                                AND numpla = i.numpla
                                AND codper = i.codper
                                AND codcon = i.codcon;

                    END CASE;
                ELSE
                    -- CONCEPTO REFERIDO AL PRESTAMO
                    pack_hr_planilla_formula.sp_decodificar_cprestamo(i.id_cia, i.numpla, i.codper, i.codcon, 'S',
                                                                     pin_coduser, i.codcon, v_formula, v_pout_formula, v_valor,
                                                                     v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                    NULL;
            END CASE;
        END LOOP;

        -- FINALMENTE, SE CALCULAN LOS SALDOS EN LA PLANILLA RESUMEN
        pack_hr_planilla_resumen.sp_updgen(pin_id_cia, pin_numpla, pin_codper, pin_coduser, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

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
                        'message' VALUE 'Mes cerrado en el Módulo de Planilla ...!'
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
    END sp_calcular;

    PROCEDURE sp_calcular_concepto (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      OUT VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    ) AS

        pout_mensaje          VARCHAR2(4000) := '';
        o                     json_object_t;
        m                     json_object_t;
        v_mensaje             VARCHAR2(4000) := '';
        v_formula             VARCHAR2(4000) := '';
        v_pout_formula        VARCHAR2(4000) := '';
        v_desley              VARCHAR2(4000) := '';
        v_valor               VARCHAR2(4000) := '';
        rec_planilla_calculo  datarecord_planilla_calculo;
        v_rec_factor_planilla factor_planilla%rowtype;
        v_rec_planilla_afp    planilla_afp%rowtype;
        v_rec_planilla        planilla%rowtype;
    BEGIN
        UPDATE planilla_concepto
        SET
            proceso = 0
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper
            AND codcon = pin_codcon;

        DELETE FROM planilla_concepto_leyenda
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper
            AND codori = pin_codcon;

        COMMIT;
        IF pin_tipori IS NULL OR pin_tipori IN ( 'C', 'F', 'S', 'V' ) THEN
            BEGIN
                SELECT
                    id_cia,
                    numpla,
                    codper,
                    codcon,
                    formul,
                    tipori,
                    valcon
                INTO
                    rec_planilla_calculo.id_cia,
                    rec_planilla_calculo.numpla,
                    rec_planilla_calculo.codper,
                    rec_planilla_calculo.codcon,
                    rec_planilla_calculo.formul,
                    rec_planilla_calculo.tipori,
                    rec_planilla_calculo.valcon
                FROM
                    pack_hr_planilla_calculo.sp_planilla_calculo(pin_id_cia, pin_numpla, pin_codper, pin_codcon);

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'El CONCEPTO no ha podido ser localizado, revisar que el CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] EXISTA para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ] y en la PLANILLA [ '
                                    || pin_numpla
                                    || ' ] ...!';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                WHEN too_many_rows THEN
                    pout_mensaje := 'Hay mas de un CONCEPTO relacionado al CONCEPTO [ '
                                    || pin_codcon
                                    || ' ] exista para el TRABAJADOR [ '
                                    || pin_codper
                                    || ' ] y en la PLANILLA [ '
                                    || pin_numpla
                                    || ' ] ...!';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            CASE
                WHEN rec_planilla_calculo.tipori = 'C' THEN
                    CASE 
                        -- SI ES UN CONCEPTO DE TIPO CALCULADO Y LA FORMULA NO ES NULL NI 0*
                        WHEN rec_planilla_calculo.formul IS NOT NULL THEN
                            v_formula := rec_planilla_calculo.formul;
                            pack_hr_planilla_formula.sp_decodificar(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla, rec_planilla_calculo.codper
                            , rec_planilla_calculo.codcon, 'N',
                                                                   pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado
                                                                   ,
                                                                   v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                        ELSE
                            -- CONCEPTO NO DEFINIDO
                            pack_hr_planilla_formula.sp_decodificar_cnodefinido(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla
                            , rec_planilla_calculo.codper, rec_planilla_calculo.codcon, 'N',
                                                                               pin_coduser, pin_codcon, pin_formula, pin_decodificado
                                                                               , pin_resultado,
                                                                               v_mensaje);

                            m := json_object_t.parse(v_mensaje);
                            IF ( m.get_number('status') <> 1.0 ) THEN
                                pout_mensaje := m.get_string('message');
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;

                    END CASE;
                WHEN rec_planilla_calculo.tipori = 'S' THEN -- CONCEPTO MARCADO COMO DE SISTEMA
                    pack_hr_planilla_formula.sp_decodificar_csistema(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla, rec_planilla_calculo.codper
                    , rec_planilla_calculo.codcon, 'N',
                                                                    pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado
                                                                    ,
                                                                    v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                WHEN rec_planilla_calculo.tipori = 'V' THEN -- CONCEPTO MARCADO COMO VARIABLE
                    pack_hr_planilla_formula.sp_decodificar_cvariable(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla, rec_planilla_calculo.codper
                    , rec_planilla_calculo.codcon, 'N',
                                                                     pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado
                                                                     ,
                                                                     v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                ELSE -- CONCEPTO MARCADO COMO FIJO
                    pack_hr_planilla_formula.sp_decodificar_cfijo(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla, rec_planilla_calculo.codper
                    , rec_planilla_calculo.codcon, 'N',
                                                                 pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado
                                                                 ,
                                                                 v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

            END CASE;

        ELSIF pin_tipori = 'SS' THEN
            pack_hr_planilla_formula.sp_decodificar_fsistema(pin_id_cia, pin_numpla, pin_codper, pin_codcon, 'N',
                                                            pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado,
                                                            v_mensaje);

            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        ELSIF pin_tipori = 'FT' THEN
            pack_hr_planilla_formula.sp_decodificar_ffactor(pin_id_cia, pin_numpla, pin_codper, pin_codcon, 'N',
                                                           pin_coduser, pin_codcon, pin_formula, pin_decodificado, pin_resultado,
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
                'message' VALUE 'El CONCEPTO [ '
                                || pin_codcon
                                || ' ] para el TRABAJADOR [ '
                                || pin_codper
                                || ' ] y en la PLANILLA [ '
                                || pin_numpla
                                || ' ] se CALCULO Y DECODIFICO correctamente ...!'
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
    END sp_calcular_concepto;

    PROCEDURE sp_calcular_concepto_pseudocodigo (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      OUT VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    ) AS

        pout_mensaje   VARCHAR2(4000) := '';
        o              json_object_t;
        m              json_object_t;
        v_mensaje      VARCHAR2(4000) := '';
        v_formula      VARCHAR2(4000) := '';
        v_decodificado VARCHAR2(4000) := '';
        v_resultado    VARCHAR2(4000) := '';
        v_pout_formula VARCHAR2(4000) := '';
        v_desley       VARCHAR2(4000) := '';
        v_valor        VARCHAR2(4000) := '';
    BEGIN
        pack_hr_planilla_calculo.sp_calcular_concepto(pin_id_cia, pin_numpla, pin_codper, pin_codcon, pin_tipori,
                                                     pin_coduser, v_formula, v_decodificado, v_resultado, v_mensaje);

        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF nvl(pin_tipori, 'C') = 'C' THEN
            SELECT
                replace(v_formula, 'CASE', 'SI'),
                replace(v_decodificado, 'CASE', 'SI')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'WHEN', 'CUMPLE'),
                replace(v_decodificado, 'WHEN', 'CUMPLE')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'THEN', 'ENTONCES'),
                replace(v_decodificado, 'THEN', 'ENTONCES')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'END', 'FIN'),
                replace(v_decodificado, 'END', 'FIN')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'OR', 'O'),
                replace(v_decodificado, 'OR', 'O')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'AND', 'Y'),
                replace(v_decodificado, 'AND', 'Y')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            SELECT
                replace(v_formula, 'ELSE', 'DE LO CONTRARIO'),
                replace(v_decodificado, 'ELSE', 'DE LO CONTRARIO')
            INTO
                v_formula,
                v_decodificado
            FROM
                dual;

            pin_formula := v_formula;
            pin_decodificado := v_decodificado;
        ELSE
            pin_formula := v_formula;
            pin_decodificado := v_decodificado;
        END IF;

        pin_resultado := v_resultado;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El CONCEPTO [ '
                                || pin_codcon
                                || ' ] para el TRABAJADOR [ '
                                || pin_codper
                                || ' ] y en la PLANILLA [ '
                                || pin_numpla
                                || ' ] se CALCULO Y DECODIFICO correctamente ...!'
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
    END sp_calcular_concepto_pseudocodigo;

    PROCEDURE sp_calcular_concepto_test (
        pin_id_cia       IN NUMBER,
        pin_numpla       IN NUMBER,
        pin_codper       IN VARCHAR2,
        pin_codcon       IN VARCHAR2,
        pin_tipori       IN VARCHAR2,
        pin_coduser      IN VARCHAR2,
        pin_formula      IN VARCHAR2,
        pin_decodificado OUT VARCHAR2,
        pin_resultado    OUT VARCHAR2,
        pin_mensaje      OUT VARCHAR2
    ) AS

        pout_mensaje         VARCHAR2(4000) := '';
        o                    json_object_t;
        m                    json_object_t;
        v_mensaje            VARCHAR2(4000) := '';
        v_formula            VARCHAR2(4000) := '';
        v_pout_formula       VARCHAR2(4000) := '';
        v_valor              VARCHAR2(4000) := '';
        rec_planilla_calculo datarecord_planilla_calculo;
    BEGIN
        DELETE FROM planilla_concepto_leyenda
        WHERE
                id_cia = pin_id_cia
            AND numpla = pin_numpla
            AND codper = pin_codper
            AND codori = pin_codcon;

        BEGIN
            SELECT
                id_cia,
                numpla,
                codper,
                codcon,
                pin_formula,
                tipori,
                valcon
            INTO
                rec_planilla_calculo.id_cia,
                rec_planilla_calculo.numpla,
                rec_planilla_calculo.codper,
                rec_planilla_calculo.codcon,
                rec_planilla_calculo.formul,
                rec_planilla_calculo.tipori,
                rec_planilla_calculo.valcon
            FROM
                pack_hr_planilla_calculo.sp_planilla_calculo(pin_id_cia, pin_numpla, pin_codper, pin_codcon);

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'El CONCEPTO no ha podido ser localizado, revisar que el CONCEPTO [ '
                                || pin_codcon
                                || ' ] EXISTA para el TRABAJADOR [ '
                                || pin_codper
                                || ' ] y en la PLANILLA [ '
                                || pin_numpla
                                || ' ] ...!';

                RAISE pkg_exceptionuser.ex_error_inesperado;
            WHEN too_many_rows THEN
                pout_mensaje := 'Hay mas de un CONCEPTO relacionado al CONCEPTO [ '
                                || pin_codcon
                                || ' ] exista para el TRABAJADOR [ '
                                || pin_codper
                                || ' ] y en la PLANILLA [ '
                                || pin_numpla
                                || ' ] ...!';

                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        CASE
            WHEN rec_planilla_calculo.tipori = 'C' THEN
                CASE 
            -- SI ES UN CONCEPTO DE TIPO CALCULADO Y LA FORMULA NO ES NULL*
                    WHEN
                        rec_planilla_calculo.formul IS NOT NULL
                        AND rec_planilla_calculo.formul <> '0'
                    THEN
                        v_formula := rec_planilla_calculo.formul;
                        pack_hr_planilla_formula.sp_decodificar(rec_planilla_calculo.id_cia, rec_planilla_calculo.numpla, rec_planilla_calculo.codper
                        , rec_planilla_calculo.codcon, 'N',
                                                               pin_coduser, rec_planilla_calculo.codcon, v_formula, v_pout_formula, v_valor
                                                               ,
                                                               v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;
                    -- VALORES CALCULADOS
--                        pin_formula := rec_planilla_calculo.formul;
                        pin_decodificado := v_pout_formula;
                        pin_resultado := v_formula;
            -- CASO CONTRARIO
                    ELSE
--                        pin_formula := ' Concepto [ '
--                                       || pin_codcon
--                                       || ' ] =  No esta Definido ';
                        pin_decodificado := '0';
                        pin_resultado := '0';
                END CASE;
            ELSE
--                pin_formula := rec_planilla_calculo.valcon;
                pin_decodificado := ' Concepto [ '
                                    || pin_codcon
                                    || ' ] = '
                                    || rec_planilla_calculo.valcon;
                pin_resultado := rec_planilla_calculo.valcon;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El CONCEPTO [ '
                                || pin_codcon
                                || ' ] para el TRABAJADOR [ '
                                || pin_codper
                                || ' ] y en la PLANILLA [ '
                                || pin_numpla
                                || ' ] se CALCULO Y DECODIFICO correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;
--        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, pin_numpla, pin_codper, pin_codcon, pin_codcon,
--                                                   rec_planilla_calculo.tipori, 1, pin_resultado, rec_planilla_calculo.formul, v_mensaje);
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
    END sp_calcular_concepto_test;

END;

/
