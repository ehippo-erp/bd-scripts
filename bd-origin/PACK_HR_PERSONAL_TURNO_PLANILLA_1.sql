--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_TURNO_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_TURNO_PLANILLA" AS

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codper   VARCHAR2,
        pin_id_turno NUMBER
    ) RETURN datatable_personal_turno_planilla
        PIPELINED
    AS
        v_table datatable_personal_turno_planilla;
    BEGIN
        SELECT
            ptp.id_cia,
            ptp.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            ptp.id_turno,
            apt.desturn,
            to_char(apt.hingtur, 'HH:MI:SS'),
            to_char(apt.hsaltur, 'HH:MI:SS'),
            apt.mintur,
            apt.toletur,
            apt.incref,
            to_char(apt.hingref, 'HH:MI:SS'),
            to_char(apt.hsalref, 'HH:MI:SS'),
            apt.minref,
            apt.toleref,
            apt.dia,
            apt.extra,
            apt.tipoasig,
            ptp.ucreac,
            ptp.uactua,
            ptp.fcreac,
            ptp.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_turno_planilla   ptp
            LEFT OUTER JOIN personal                  p ON p.id_cia = ptp.id_cia
                                          AND p.codper = ptp.codper
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ptp.id_cia
                                                             AND apt.id_turno = ptp.id_turno
        WHERE
                ptp.id_cia = pin_id_cia
            AND ptp.codper = pin_codper
            AND ptp.id_turno = pin_id_turno;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codper   VARCHAR2,
        pin_id_turno NUMBER
    ) RETURN datatable_personal_turno_planilla
        PIPELINED
    AS
        v_table datatable_personal_turno_planilla;
    BEGIN
        SELECT
            ptp.id_cia,
            ptp.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            ptp.id_turno,
            apt.desturn,
            to_char(apt.hingtur, 'HH:MI:SS'),
            to_char(apt.hsaltur, 'HH:MI:SS'),
            apt.mintur,
            apt.toletur,
            apt.incref,
            to_char(apt.hingref, 'HH:MI:SS'),
            to_char(apt.hsalref, 'HH:MI:SS'),
            apt.minref,
            apt.toleref,
            apt.dia,
            apt.extra,
            apt.tipoasig,
            ptp.ucreac,
            ptp.uactua,
            ptp.fcreac,
            ptp.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_turno_planilla   ptp
            LEFT OUTER JOIN personal                  p ON p.id_cia = ptp.id_cia
                                          AND p.codper = ptp.codper
            LEFT OUTER JOIN asistencia_planilla_turno apt ON apt.id_cia = ptp.id_cia
                                                             AND apt.id_turno = ptp.id_turno
        WHERE
                ptp.id_cia = pin_id_cia
            AND ( pin_codper IS NULL
                  OR ptp.codper = pin_codper )
            AND ( pin_id_turno = - 1
                  OR pin_id_turno IS NULL
                  OR ptp.id_turno = pin_id_turno );

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
--                "codper":"P008",
--                "id_turno":"1",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_turno_planilla.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_turno_planilla.sp_obtener(66,'P008',1);
--
--SELECT * FROM pack_hr_personal_turno_planilla.sp_buscar(66,NULL,-1);


    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                           json_object_t;
        rec_personal_turno_planilla personal_turno_planilla%rowtype;
        v_accion                    VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_turno_planilla.id_cia := pin_id_cia;
        rec_personal_turno_planilla.codper := o.get_string('codper');
        rec_personal_turno_planilla.id_turno := o.get_number('id_turno');
        rec_personal_turno_planilla.ucreac := o.get_string('ucreac');
        rec_personal_turno_planilla.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_turno_planilla (
                    id_cia,
                    codper,
                    id_turno,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_turno_planilla.id_cia,
                    rec_personal_turno_planilla.codper,
                    rec_personal_turno_planilla.id_turno,
                    rec_personal_turno_planilla.ucreac,
                    rec_personal_turno_planilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE personal_turno_planilla
--                SET
--                    uactua =
--                        CASE
--                            WHEN rec_personal_turno_planilla.uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_personal_turno_planilla.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_personal_turno_planilla.id_cia
--                    AND id_turno = rec_personal_turno_planilla.id_turno;

                NULL;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_turno_planilla
                WHERE
                        id_cia = rec_personal_turno_planilla.id_cia
                    AND codper = rec_personal_turno_planilla.codper
                    AND id_turno = rec_personal_turno_planilla.id_turno;

            WHEN 4 THEN

                DELETE FROM personal_turno_planilla
                WHERE
                        id_cia = rec_personal_turno_planilla.id_cia
                    AND codper = rec_personal_turno_planilla.codper
                    AND id_turno = rec_personal_turno_planilla.id_turno;

                INSERT INTO personal_turno_planilla (
                    id_cia,
                    codper,
                    id_turno,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_turno_planilla.id_cia,
                    rec_personal_turno_planilla.codper,
                    rec_personal_turno_planilla.id_turno,
                    rec_personal_turno_planilla.ucreac,
                    rec_personal_turno_planilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

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
                    'message' VALUE 'El registro con el ID del Turno de Asistencia [ '
                                    || rec_personal_turno_planilla.id_turno
                                    || ' ] y Codigo de Personal [ '
                                    || rec_personal_turno_planilla.codper
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
                        'message' VALUE 'No se insertar o modificar este registro porque el ID del Turno de Asistencia [ '
                                        || rec_personal_turno_planilla.id_turno
                                        || ' ] no existe ...! '
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

    FUNCTION sp_exportar (
        pin_id_cia NUMBER,
        pin_codper CLOB
    ) RETURN datatable_exportar
        PIPELINED
    AS
        v_table datatable_exportar;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            NULL        AS id_turno
        BULK COLLECT
        INTO v_table
        FROM
            personal p
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_codper) )
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_exportar;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores                 r_errores := r_errores(NULL, NULL);
        o                           json_object_t;
        rec_personal_turno_planilla personal_turno_planilla%rowtype;
        v_aux1                      VARCHAR2(1000);
        v_aux2                      NUMBER(20, 8);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_turno_planilla.id_cia := pin_id_cia;
        rec_personal_turno_planilla.codper := o.get_string('codper');
        rec_personal_turno_planilla.id_turno := o.get_number('id_turno');
        BEGIN
            SELECT
                id_turno
            INTO v_aux2
            FROM
                asistencia_planilla_turno
            WHERE
                    id_cia = pin_id_cia
                AND id_turno = rec_personal_turno_planilla.id_turno;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_turno_planilla.id_turno;
                reg_errores.deserror := 'No Existe el Turno [ '
                                        || rec_personal_turno_planilla.id_turno
                                        || ' ]';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                codper
            INTO v_aux1
            FROM
                personal
            WHERE
                    id_cia = pin_id_cia
                AND codper = rec_personal_turno_planilla.codper;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_turno_planilla.codper;
                reg_errores.deserror := 'No Existe el Personal con el Codigo [ '
                                        || rec_personal_turno_planilla.codper
                                        || ' ]';
                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

END;

/
