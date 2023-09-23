--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_CONCEPTO" AS

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_codcon  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_personal_concepto
        PIPELINED
    AS
        v_table datatable_personal_concepto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.codcon,
            pc.periodo,
            pc.mes,
            co.nombre AS nomcon,
            pc.valcon,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_concepto pc
            LEFT OUTER JOIN concepto          co ON co.id_cia = pc.id_cia
                                           AND co.codcon = pc.codcon
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
            AND pc.codcon = pin_codcon
            AND pc.periodo = pin_periodo
            AND pc.mes = pin_mes;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_personal_concepto
        PIPELINED
    AS
        v_table datatable_personal_concepto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.codcon,
            pc.periodo,
            pc.mes,
            co.nombre AS nomcon,
            pc.valcon,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_concepto pc
            LEFT OUTER JOIN concepto          co ON co.id_cia = pc.id_cia
                                           AND co.codcon = pc.codcon
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
            AND ( pin_periodo IS NULL
                  OR pc.periodo = pin_periodo )
            AND ( pin_mes IS NULL
                  OR pc.mes = pin_mes );

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
--                "codper":"07266565",
--                "codcon":"001",
--                "periodo":2022,
--                "mes":12,
--                "valcon":4500,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_concepto.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_concepto.sp_obtener(66,'07266565','001',2022,12);
--
--SELECT * FROM pack_hr_personal_concepto.sp_buscar(66,'07266565',NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                     json_object_t;
        rec_personal_concepto personal_concepto%rowtype;
        v_accion              VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_concepto.id_cia := pin_id_cia;
        rec_personal_concepto.codper := o.get_string('codper');
        rec_personal_concepto.codcon := o.get_string('codcon');
        rec_personal_concepto.periodo := o.get_number('periodo');
        rec_personal_concepto.mes := o.get_number('mes');
        rec_personal_concepto.valcon := o.get_number('valcon');
        rec_personal_concepto.ucreac := o.get_string('ucreac');
        rec_personal_concepto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_concepto (
                    id_cia,
                    codper,
                    codcon,
                    periodo,
                    mes,
                    valcon,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_concepto.id_cia,
                    rec_personal_concepto.codper,
                    rec_personal_concepto.codcon,
                    rec_personal_concepto.periodo,
                    rec_personal_concepto.mes,
                    rec_personal_concepto.valcon,
                    rec_personal_concepto.ucreac,
                    rec_personal_concepto.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE personal_concepto
                SET
                    valcon =
                        CASE
                            WHEN rec_personal_concepto.valcon IS NULL THEN
                                valcon
                            ELSE
                                rec_personal_concepto.valcon
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal_concepto.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_personal_concepto.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_concepto.id_cia
                    AND codper = rec_personal_concepto.codper
                    AND codcon = rec_personal_concepto.codcon
                    AND periodo = rec_personal_concepto.periodo
                    AND mes = rec_personal_concepto.mes;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_concepto
                WHERE
                        id_cia = rec_personal_concepto.id_cia
                    AND codper = rec_personal_concepto.codper
                    AND codcon = rec_personal_concepto.codcon
                    AND periodo = rec_personal_concepto.periodo
                    AND mes = rec_personal_concepto.mes;

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
                    'message' VALUE 'El registro para el codigo de Personal [ '
                                    || rec_personal_concepto.codper
                                    || ' ], con el Concepto [ '
                                    || rec_personal_concepto.codcon
                                    || ' ] para el Periodo [ '
                                    || rec_personal_concepto.periodo
                                    || ' ] y el Mes [ '
                                    || rec_personal_concepto.mes
                                    || ' ] ya existe y no puede duplicarse ...!'
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
                        'message' VALUE 'No es posible insertar o modificar este registro porque el concepto [ '
                                        || rec_personal_concepto.codcon
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

    PROCEDURE sp_replicar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000) := '';
        v_mes        NUMBER;
        v_anio       NUMBER;
        v_aux        VARCHAR2(10) := '';
    BEGIN
        IF pin_mes = 0 THEN
            v_mes := 12;
            v_anio := pin_periodo - 1;
        ELSE
            v_mes := pin_mes - 1;
            v_anio := pin_periodo;
        END IF;

        BEGIN
            SELECT
                '0'
            INTO v_aux
            FROM
                personal_concepto pc
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.codper = pin_codper
                AND pc.periodo = v_anio
                AND pc.mes = v_mes;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'No existen informacion del Periodo Anterior para Replicar ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
            WHEN too_many_rows THEN
                NULL;
        END;

        DELETE FROM personal_concepto
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper
            AND periodo = pin_periodo
            AND mes = pin_mes;

        INSERT INTO personal_concepto
            (
                SELECT
                    pc.id_cia,
                    pc.codper,
                    pc.codcon,
                    pin_periodo,
                    pin_mes,
                    pc.valcon,
                    pin_coduser,
                    pin_coduser,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                FROM
                    personal_concepto pc
                WHERE
                        pc.id_cia = pin_id_cia
                    AND pc.codper = pin_codper
                    AND pc.periodo = v_anio
                    AND pc.mes = v_mes
--                    AND NOT EXISTS (
--                        SELECT
--                            *
--                        FROM
--                            personal_concepto pc1
--                        WHERE
--                                pc1.id_cia = pc.id_cia
--                            AND pc1.codper = pc.codper
--                            AND pc1.codcon = pc.codcon
--                            AND pc1.periodo = pin_periodo
--                            AND pc1.mes = pin_mes
--                    )
            );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Los Conceptos Fijos se replicaron Conrrectamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
--        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro para el codigo de Personal [ '
--                                    || rec_personal_concepto.codper
--                                    || ' ], con el Concepto [ '
--                                    || rec_personal_concepto.codcon
--                                    || ' ] para el Periodo [ '
--                                    || rec_personal_concepto.periodo
--                                    || ' ] y el Mes [ '
--                                    || rec_personal_concepto.mes
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

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

    END sp_replicar;

    PROCEDURE sp_generar (
        pin_id_cia  NUMBER,
        pin_codper  VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000) := '';
        v_mes        NUMBER;
        v_anio       NUMBER;
        v_aux        VARCHAR2(10) := '';
    BEGIN
        DELETE FROM personal_concepto
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper
            AND periodo = pin_periodo
            AND mes = pin_mes;

        FOR i IN (
            SELECT
                p.codper,
                c.codcon
            FROM
                     concepto c
                INNER JOIN personal p ON p.id_cia = c.id_cia
                                         AND p.tiptra = c.empobr
            WHERE
                    c.id_cia = pin_id_cia
                AND c.fijvar = 'F'
                AND p.codper = pin_codper
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        personal_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codper = p.codper
                        AND pc.codcon = c.codcon
                        AND pc.periodo = pin_periodo
                        AND pc.mes = pin_mes
                )
        ) LOOP
            INSERT INTO personal_concepto VALUES (
                pin_id_cia,
                i.codper,
                i.codcon,
                pin_periodo,
                pin_mes,
                0,
                pin_coduser,
                pin_coduser,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS')
            );

            COMMIT;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Los Conceptos Fijos se generaron Conrrectamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
--        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro para el codigo de Personal [ '
--                                    || rec_personal_concepto.codper
--                                    || ' ], con el Concepto [ '
--                                    || rec_personal_concepto.codcon
--                                    || ' ] para el Periodo [ '
--                                    || rec_personal_concepto.periodo
--                                    || ' ] y el Mes [ '
--                                    || rec_personal_concepto.mes
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

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

    END sp_generar;

    PROCEDURE sp_asigna_conceptos_fijos (
        pin_id_cia  IN NUMBER,
        pin_codcon  IN VARCHAR2,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        FOR i IN (
            SELECT
                p.codper,
                c.codcon
            FROM
                     concepto c
                INNER JOIN personal p ON p.id_cia = c.id_cia
                                         AND p.tiptra = c.empobr
            WHERE
                    c.id_cia = pin_id_cia
                AND ( pin_codcon IS NULL
                      OR c.codcon = pin_codcon )
                AND c.fijvar = 'F'
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        personal_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codper = p.codper
                        AND pc.codcon = c.codcon
                        AND pc.periodo = pin_periodo
                        AND pc.mes = pin_mes
                )
        ) LOOP
            INSERT INTO personal_concepto VALUES (
                pin_id_cia,
                i.codper,
                i.codcon,
                pin_periodo,
                pin_mes,
                0,
                pin_coduser,
                pin_coduser,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS')
            );

            COMMIT;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
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

    END sp_asigna_conceptos_fijos;

    PROCEDURE sp_clonar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_coduser VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000) := '';
        v_mes        NUMBER;
        v_anio       NUMBER;
        v_codper     VARCHAR2(20) := NULL;
        v_codcon     VARCHAR2(5) := NULL;
        v_aux        NUMBER := NULL;
    BEGIN
        IF pin_mes = 0 THEN
            v_mes := 12;
            v_anio := pin_periodo - 1;
        ELSE
            v_mes := pin_mes - 1;
            v_anio := pin_periodo;
        END IF;

        FOR i IN (
            SELECT
                codper
            FROM
                planilla_auxiliar
            WHERE
                    id_cia = pin_id_cia
                AND numpla = pin_numpla
        ) LOOP
            INSERT INTO personal_concepto
                (
                    SELECT
                        pc.id_cia,
                        pc.codper,
                        pc.codcon,
                        pin_periodo,
                        pin_mes,
                        pc.valcon,
                        pin_coduser,
                        pin_coduser,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    FROM
                        personal_concepto pc
                    WHERE
                            pc.id_cia = pin_id_cia
                        AND pc.codper = i.codper
                        AND pc.periodo = v_anio
                        AND pc.mes = v_mes
                        AND NOT EXISTS (
                            SELECT
                                pc1.*
                            FROM
                                personal_concepto pc1
                            WHERE
                                    pc1.id_cia = pc.id_cia
                                AND pc1.codper = pc.codper
                                AND pc1.codcon = pc.codcon
                                AND pc1.periodo = pin_periodo
                                AND pc1.mes = pin_mes
                        )
                );

        END LOOP;

        COMMIT;

        --- VALIDANDO QUE EXISTAN TODOS LOS CONCEPTOS FIJOS ...
        FOR j IN (
            SELECT
                pc.codper,
                pc.codcon
            FROM
                     planilla_concepto pc
                INNER JOIN concepto c ON c.id_cia = pc.id_cia
                                         AND c.codcon = pc.codcon
                                         AND c.fijvar = 'F'
            WHERE
                    pc.id_cia = pin_id_cia
                AND pc.numpla = pin_numpla
        ) LOOP
            BEGIN
                SELECT
                    codper,
                    codcon,
                    COUNT(*)
                INTO
                    v_codper,
                    v_codcon,
                    v_aux
                FROM
                    (
                        SELECT
                            p.codper,
                            c.codcon
                        FROM
                                 concepto c
                            INNER JOIN personal p ON p.id_cia = c.id_cia
                                                     AND p.tiptra = c.empobr
                        WHERE
                                c.id_cia = pin_id_cia
                            AND p.codper = j.codper
                            AND c.codcon = j.codcon
                            AND c.fijvar = 'F'
                        UNION ALL
                        SELECT
                            pc.codper,
                            pc.codcon
                        FROM
                            personal_concepto pc
                        WHERE
                                id_cia = pin_id_cia
                            AND pc.codper = j.codper
                            AND pc.codcon = j.codcon
                            AND pc.periodo = pin_periodo
                            AND pc.mes = pin_mes
                    )
                GROUP BY
                    codper,
                    codcon
                HAVING
                    COUNT(*) <> 2;

            EXCEPTION
                WHEN no_data_found THEN
                    v_codper := NULL;
                    v_codcon := NULL;
                    v_aux := NULL;
            END;

            IF v_codper IS NOT NULL THEN
                pout_mensaje := 'ERROR AL REPLICAR CONCEPTOS FIJOS, VERIFIQUE QUE EN EL PERIODO ANTERIOR [ '
                                || v_anio
                                || '-'
                                || v_mes
                                || '  ] EL PERSONAL TENGA ASIGNADO TODOS LOS CONCEPTOS FIJOS [ '
                                || v_codper
                                || ' - '
                                || v_codcon
                                || ' ]';

                RAISE pkg_exceptionuser.ex_error_inesperado;
                EXIT;
            END IF;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Los Conceptos Fijos por Personal y Planilla se clonaron conrrectamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
--        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro para el codigo de Personal [ '
--                                    || rec_personal_concepto.codper
--                                    || ' ], con el Concepto [ '
--                                    || rec_personal_concepto.codcon
--                                    || ' ] para el Periodo [ '
--                                    || rec_personal_concepto.periodo
--                                    || ' ] y el Mes [ '
--                                    || rec_personal_concepto.mes
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

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

    END sp_clonar;

END;

/
