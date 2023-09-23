--------------------------------------------------------
--  DDL for Package Body PACK_HR_CONCEPTO_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CONCEPTO_FORMULA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED
    AS
        v_table datatable_concepto_formula;
    BEGIN
        SELECT
            cf.id_cia,
            cf.codcon,
            c.nombre  AS descon,
            cf.tiptra,
            CASE
                WHEN cf.tiptra = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tt.nombre
            END       AS destra,
            cf.tippla,
            CASE
                WHEN cf.tippla = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tp.nombre
            END       AS despla,
            cf.formul,
            cf.swacti,
            cf.codcta,
            p1.nombre AS descta,
            cf.ctagasto,
            p2.nombre AS desgasto,
            cf.ucreac,
            cf.uactua,
            cf.fcreac,
            cf.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_formula cf
            LEFT OUTER JOIN concepto         c ON c.id_cia = cf.id_cia
                                          AND c.codcon = cf.codcon
            LEFT OUTER JOIN tipoplanilla     tp ON tp.id_cia = cf.id_cia
                                               AND tp.tippla = cf.tippla
            LEFT OUTER JOIN tipo_trabajador  tt ON tt.id_cia = cf.id_cia
                                                  AND tt.tiptra = cf.tiptra
            LEFT OUTER JOIN pcuentas         p1 ON p1.id_cia = cf.id_cia
                                           AND p1.cuenta = cf.codcta
            LEFT OUTER JOIN pcuentas         p2 ON p2.id_cia = cf.id_cia
                                           AND p2.cuenta = cf.ctagasto
        WHERE
                cf.id_cia = pin_id_cia
            AND cf.codcon = pin_codcon
            AND cf.tiptra = pin_tiptra
            AND cf.tippla = pin_tippla;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_leyenda_concepto (
        pin_id_cia NUMBER,
        pin_tipcon VARCHAR2 --  F ( CONCEPTO FIJO ) , C ( CONCEPTO CALCULADO ), V ( CONCEPTO VARIABLE ), S ( CONCEPTO DE SISTEMA), P (CONCEPTO DE PRESTAMO)  , FT ( FACTOR ), SS ( FORMULA DEL SISTEMA )  
    ) RETURN datatable_leyenda_concepto
        PIPELINED
    AS
        v_table datatable_leyenda_concepto;
    BEGIN
        IF nvl(pin_tipcon, 'ND') = 'ND' THEN
            SELECT
                codcon,
                nombre,
                ':C' || codcon AS formula
            BULK COLLECT
            INTO v_table
            FROM
                concepto
            WHERE
                id_cia = pin_id_cia;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            SELECT
                codfac,
                nombre,
                ':F' || codfac AS formula
            BULK COLLECT
            INTO v_table
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND nombre NOT IN ( 'LIBRE' );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            SELECT
                codfun,
                desfun,
                ':S' || codfun AS formula
            BULK COLLECT
            INTO v_table
            FROM
                funcion_sistema
            WHERE
                codfun NOT IN ( 'ND' );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF nvl(pin_tipcon, 'ND') IN ( 'C', 'F', 'V', 'S', 'P' ) THEN
            SELECT
                codcon,
                nombre,
                ':C' || codcon AS formula
            BULK COLLECT
            INTO v_table
            FROM
                concepto
            WHERE
                    id_cia = pin_id_cia
                AND fijvar = pin_tipcon;

        ELSIF nvl(pin_tipcon, 'ND') IN ( 'FT' ) THEN
            SELECT
                codfac,
                nombre,
                ':F' || codfac AS formula
            BULK COLLECT
            INTO v_table
            FROM
                factor_planilla
            WHERE
                    id_cia = pin_id_cia
                AND nombre NOT IN ( 'LIBRE' );

        ELSIF nvl(pin_tipcon, 'ND') IN ( 'SS' ) THEN
            SELECT
                codfun,
                desfun,
                ':S' || codfun AS formula
            BULK COLLECT
            INTO v_table
            FROM
                funcion_sistema
            WHERE
                codfun NOT IN ( 'ND' );

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_leyenda_concepto;

    PROCEDURE sp_refrescar (
        pin_id_cia  NUMBER,
        pin_codcon  VARCHAR2,
        pin_tiptra  VARCHAR2,
        pin_tippla  VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_formula     VARCHAR2(4000 CHAR);
        v_poutformula VARCHAR2(4000 CHAR);
        pout_mensaje  VARCHAR2(4000 CHAR);
        v_mensaje     VARCHAR2(4000 CHAR);
        m             json_object_t;
    BEGIN
        SELECT
            cf.formul
        INTO v_formula
        FROM
            concepto_formula cf
        WHERE
                cf.id_cia = pin_id_cia
            AND cf.codcon = pin_codcon
            AND cf.tiptra = pin_tiptra
            AND cf.tippla = pin_tippla;

        IF v_formula IS NOT NULL THEN
            pack_hr_concepto_formula.sp_sintaxis(pin_id_cia, pin_codcon, v_formula, v_poutformula, v_mensaje);
            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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

    END sp_refrescar;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_leyenda
        PIPELINED
    AS
        v_table  datatable_leyenda;
        v_formul VARCHAR2(4000 CHAR);
    BEGIN
        SELECT DISTINCT
            pcl.*
        BULK COLLECT
        INTO v_table
        FROM
            planilla_concepto_leyenda pcl
        WHERE
                pcl.id_cia = pin_id_cia
            AND pcl.numpla = - 1
            AND pcl.codper = 'ND'
            AND pcl.codori = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_leyenda;

    FUNCTION sp_ayuda (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_tiptra VARCHAR2,
        pin_tippla VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED
    AS
        v_table datatable_concepto_formula;
    BEGIN
        SELECT
            cf.id_cia,
            cf.codcon,
            c.nombre  AS descon,
            cf.tiptra,
            CASE
                WHEN cf.tiptra = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tt.nombre
            END       AS destra,
            cf.tippla,
            CASE
                WHEN cf.tippla = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tp.nombre
            END       AS despla,
            cf.formul,
            cf.swacti,
            cf.codcta,
            p1.nombre AS descta,
            cf.ctagasto,
            p2.nombre AS desgasto,
            cf.ucreac,
            cf.uactua,
            cf.fcreac,
            cf.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_formula cf
            LEFT OUTER JOIN concepto         c ON c.id_cia = cf.id_cia
                                          AND c.codcon = cf.codcon
            LEFT OUTER JOIN tipoplanilla     tp ON tp.id_cia = cf.id_cia
                                               AND tp.tippla = cf.tippla
            LEFT OUTER JOIN tipo_trabajador  tt ON tt.id_cia = cf.id_cia
                                                  AND tt.tiptra = cf.tiptra
            LEFT OUTER JOIN pcuentas         p1 ON p1.id_cia = cf.id_cia
                                           AND p1.cuenta = cf.codcta
            LEFT OUTER JOIN pcuentas         p2 ON p2.id_cia = cf.id_cia
                                           AND p2.cuenta = cf.ctagasto
        WHERE
                cf.id_cia = pin_id_cia
            AND cf.codcon = pin_codcon
            AND cf.tiptra IN ( 'A', pin_tiptra )
            AND cf.tippla IN ( 'A', pin_tippla )
        ORDER BY
            cf.tiptra DESC,
            cf.tippla DESC
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ayuda;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto_formula
        PIPELINED
    AS
        v_table datatable_concepto_formula;
    BEGIN
        SELECT
            cf.id_cia,
            cf.codcon,
            c.nombre  AS descon,
            cf.tiptra,
            CASE
                WHEN cf.tiptra = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tt.nombre
            END       AS destra,
            cf.tippla,
            CASE
                WHEN cf.tippla = 'A' THEN
                    'POR DEFECTO'
                ELSE
                    tp.nombre
            END       AS despla,
            cf.formul,
            cf.swacti,
            cf.codcta,
            p1.nombre AS descta,
            cf.ctagasto,
            p2.nombre AS desgasto,
            cf.ucreac,
            cf.uactua,
            cf.fcreac,
            cf.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_formula cf
            LEFT OUTER JOIN concepto         c ON c.id_cia = cf.id_cia
                                          AND c.codcon = cf.codcon
            LEFT OUTER JOIN tipoplanilla     tp ON tp.id_cia = cf.id_cia
                                               AND tp.tippla = cf.tippla
            LEFT OUTER JOIN tipo_trabajador  tt ON tt.id_cia = cf.id_cia
                                                  AND tt.tiptra = cf.tiptra
            LEFT OUTER JOIN pcuentas         p1 ON p1.id_cia = cf.id_cia
                                           AND p1.cuenta = cf.codcta
            LEFT OUTER JOIN pcuentas         p2 ON p2.id_cia = cf.id_cia
                                           AND p2.cuenta = cf.ctagasto
        WHERE
                cf.id_cia = pin_id_cia
            AND cf.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codcon":"POP",
--                "tiptra":"POP",
--                "tippla":2,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_concepto_formula.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_concepto_formula.sp_obtener(66,'POP','POP',2);
--
--SELECT * FROM pack_hr_concepto_formula.sp_buscar(66,'POP',NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                    json_object_t;
        rec_concepto_formula concepto_formula%rowtype;
        v_accion             VARCHAR2(50) := '';
        v_formula            VARCHAR2(4000 CHAR);
        v_poutformula        VARCHAR2(4000 CHAR);
        v_mensaje            VARCHAR2(4000 CHAR);
        m                    json_object_t;
        pout_mensaje         VARCHAR2(4000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_concepto_formula.id_cia := pin_id_cia;
        rec_concepto_formula.codcon := o.get_string('codcon');
        rec_concepto_formula.tiptra := o.get_string('tiptra');
        rec_concepto_formula.tippla := o.get_string('tippla');
        rec_concepto_formula.formul := o.get_string('formul');
        rec_concepto_formula.codcta := o.get_string('codcta');
        rec_concepto_formula.ctagasto := o.get_string('ctagasto');
        rec_concepto_formula.swacti := o.get_string('swacti');
        rec_concepto_formula.ucreac := o.get_string('ucreac');
        rec_concepto_formula.uactua := o.get_string('uactua');
        v_accion := '';
        v_formula := rec_concepto_formula.formul;
        IF v_formula IS NOT NULL THEN
            pack_hr_concepto_formula.sp_sintaxis(pin_id_cia, rec_concepto_formula.codcon, v_formula, v_poutformula, v_mensaje);
            m := json_object_t.parse(v_mensaje);
            IF ( m.get_number('status') <> 1.0 ) THEN
                pout_mensaje := m.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO concepto_formula (
                    id_cia,
                    codcon,
                    tiptra,
                    tippla,
                    formul,
                    codcta,
                    ctagasto,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_concepto_formula.id_cia,
                    rec_concepto_formula.codcon,
                    rec_concepto_formula.tiptra,
                    rec_concepto_formula.tippla,
                    rec_concepto_formula.formul,
                    rec_concepto_formula.codcta,
                    rec_concepto_formula.ctagasto,
                    rec_concepto_formula.swacti,
                    rec_concepto_formula.ucreac,
                    rec_concepto_formula.uactua,
                    current_timestamp,
                    current_timestamp
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                IF
                    rec_concepto_formula.tiptra = 'A'
                    AND rec_concepto_formula.tippla = 'A'
                THEN
                    UPDATE concepto
                    SET
                        formul = rec_concepto_formula.formul,
                        codcta = rec_concepto_formula.codcta,
                        ctagasto = rec_concepto_formula.ctagasto,
                        uactua = rec_concepto_formula.uactua,
                        factua = current_timestamp
                    WHERE
                            id_cia = rec_concepto_formula.id_cia
                        AND codcon = rec_concepto_formula.codcon;

                END IF;

                UPDATE concepto_formula
                SET
                    formul = rec_concepto_formula.formul,
                    codcta = rec_concepto_formula.codcta,
                    ctagasto = rec_concepto_formula.ctagasto,
                    uactua = rec_concepto_formula.uactua,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_concepto_formula.id_cia
                    AND codcon = rec_concepto_formula.codcon
                    AND tiptra = rec_concepto_formula.tiptra
                    AND tippla = rec_concepto_formula.tippla;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                IF
                    rec_concepto_formula.tiptra = 'A'
                    AND rec_concepto_formula.tippla = 'A'
                THEN
                    pout_mensaje := 'EL TIPO DE TRABAJADOR Y PLANILLA POR DEFECTO, NO SE PUEDE ELIMINAR';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                DELETE FROM concepto_formula
                WHERE
                        id_cia = rec_concepto_formula.id_cia
                    AND codcon = rec_concepto_formula.codcon
                    AND tiptra = rec_concepto_formula.tiptra
                    AND tippla = rec_concepto_formula.tippla;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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
                    'message' VALUE 'El CONCEPTO [ '
                                    || rec_concepto_formula.codcon
                                    || ' ], para el TIPO DE TRABAJADOR [ '
                                    || rec_concepto_formula.tiptra
                                    || ' ] y para la PLANILLA [ '
                                    || rec_concepto_formula.tippla
                                    || ' ] ya existe y no puede duplicarse!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No es posible insertar o modificar este registro porque el Codigo de formula [ '
                                        || rec_concepto_formula.tippla
                                        || ' ] o el Concepto de Origen [ '
                                        || rec_concepto_formula.tiptra
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede insertar o modificar este registro porque no se cagaron los conceptos Obligatorios  ...!'
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
    END sp_save;

    PROCEDURE sp_sintaxis (
        pin_id_cia   IN NUMBER,
        pin_codcon   IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        v_nivel          NUMBER := 0;
        v_char           VARCHAR2(1) := '';
        v_salir          VARCHAR2(1) := 'S';
        v_codigo         VARCHAR2(15) := '';
        v_valor          VARCHAR2(15) := '';
        v_valcon         NUMBER := '';
        v_codcon         VARCHAR2(1000) := '';
        v_tipori         VARCHAR2(1) := '';
        v_proceso        NUMBER := 0;
        v_ultimocaracter VARCHAR2(1) := 'N';
        v_poutformula    VARCHAR2(1000) := '';
        v_formula        VARCHAR2(1000) := '';
        v_pout_formula   VARCHAR2(1000) := '';
        v_aux_formula    VARCHAR2(1000) := '';
        pout_mensaje     VARCHAR2(1000) := '';
        v_mensaje        VARCHAR2(1000) := '';
        v_desley         VARCHAR2(1000) := '';
        m                json_object_t;
    BEGIN
        -- ELIMINAR LEYENDA
        DELETE FROM planilla_concepto_leyenda
        WHERE
                id_cia = pin_id_cia
            AND codori = pin_codcon;

        -- VERIFICANDO SI EL CONCEPTO, SE PROCESO ANTERIORMENTE
        pin_formula := pin_formula || ' ';
        dbms_output.put_line(pin_formula);
        FOR i IN 1..length(pin_formula) LOOP
            v_char := substr(pin_formula, i, 1);
            IF v_char = ':' OR v_salir = 'N' THEN
                v_salir := 'N';
                v_codigo := v_codigo || v_char;
                IF v_char = ' ' THEN
                    IF substr(v_codigo, 2, 1) = 'C' THEN
                        v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));

                        BEGIN
                            SELECT
                                0
                            INTO v_proceso
                            FROM
                                concepto
                            WHERE
                                    id_cia = pin_id_cia
                                AND codcon = v_codcon;

                        EXCEPTION-- SI EL CONCEPTO NO EXISTE, ERROR!
                            WHEN no_data_found THEN
                                pout_mensaje := 'ERROR DE SINTAXIS en la FORMULA, revisar que en la definicion del CONCEPTO [ '
                                                || ':C'
                                                || v_codcon
                                                || ' ] se mantenga separado de los simbolos y/o operadores !';
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                        END;

                        v_poutformula := '1';
                        v_valor := '1';
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, -1, 'ND', pin_codcon, v_codcon,
                                                                   'C', 0, pin_formula, pout_formula, v_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    ELSIF substr(v_codigo, 2, 1) = 'S' THEN
                        v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));

                        BEGIN
                            SELECT
                                0
                            INTO v_proceso
                            FROM
                                funcion_sistema
                            WHERE
                                codfun = v_codcon;

                        EXCEPTION-- SI EL FACTOR PLANILLA NO EXISTE, ERROR!
                            WHEN no_data_found THEN
                                IF substr(v_codcon, 1, length(v_codcon) - 1) = 'LETRA' THEN
                                    NULL; -- ES UNA FORMULA VALIDA

                                ELSE
                                    pout_mensaje := 'ERROR DE SINTAXIS en la FORMULA, revisar que en la definicion del FORMULA DE SISTEMA [ '
                                                    || ':S'
                                                    || v_codcon
                                                    || ' ] se mantenga separado de los simbolos y/o operadores !';
                                    RAISE pkg_exceptionuser.ex_error_inesperado;
                                END IF;
                        END;

                        v_valor := '1';
                        v_poutformula := '1';
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, -1, 'ND', pin_codcon, v_codcon,
                                                                   'SS', 0, pin_formula, pout_formula, v_valor,
                                                                   v_mensaje);

                        m := json_object_t.parse(v_mensaje);
                        IF ( m.get_number('status') <> 1.0 ) THEN
                            pout_mensaje := m.get_string('message');
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;

                    ELSIF substr(v_codigo, 2, 1) = 'F' THEN
                        v_codcon := trim(substr(v_codigo, 3, length(v_codigo) - 3));

                        BEGIN
                            SELECT
                                0
                            INTO v_proceso
                            FROM
                                factor_planilla
                            WHERE
                                    id_cia = pin_id_cia
                                AND codfac = v_codcon;

                        EXCEPTION-- SI EL FACTOR PLANILLA NO EXISTE, ERROR!
                            WHEN no_data_found THEN
                                pout_mensaje := 'ERROR DE SINTAXIS en la FORMULA, revisar que en la definicion del FACTOR [ '
                                                || ':F'
                                                || v_codcon
                                                || ' ] se mantenga separado de los simbolos y/o operadores !';
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                        END;

                        v_valor := '1';
                        v_poutformula := '1';
                        pack_hr_planilla_concepto_leyenda.sp_insgen(pin_id_cia, -1, 'ND', pin_codcon, v_codcon,
                                                                   'FT', 0, pin_formula, pout_formula, v_valor,
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

        dbms_output.put_line(v_pout_formula);
        pout_formula := v_pout_formula;
        EXECUTE IMMEDIATE 'SELECT '
                          || v_pout_formula
                          || ' FROM DUAL '
        INTO v_valor;
--        pin_formula := v_valor;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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

        WHEN zero_divide THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Success!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -920 THEN
                pin_mensaje := 'Error de sintaxis en la FORMULA - AYUDA [ '
                               || v_pout_formula
                               || ' ] ...!';
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode
                               || ' Revisar la FORMULA - AYUDA [ '
                               || v_pout_formula
                               || ' ]';

                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            END IF;
    END sp_sintaxis;

END;

/
