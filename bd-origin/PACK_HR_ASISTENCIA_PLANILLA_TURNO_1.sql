--------------------------------------------------------
--  DDL for Package Body PACK_HR_ASISTENCIA_PLANILLA_TURNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA_TURNO" AS

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_id_turno NUMBER
    ) RETURN datatable_asistencia_planilla_turno
        PIPELINED
    AS
        v_table datatable_asistencia_planilla_turno;
    BEGIN
        SELECT
            apt.id_cia,
            apt.id_turno,
            apt.tiptra,
            tp.nombre AS destiptra,
            apt.desturn,
            to_char(apt.hingtur, 'HH24:MI:SS'),
            to_char(apt.hsaltur, 'HH24:MI:SS'),
--            apt.hingtur,
--            apt.hsaltur,
            apt.mintur,
            apt.toletur,
            apt.incref,
            to_char(apt.hingref, 'HH24:MI:SS'),
            to_char(apt.hsalref, 'HH24:MI:SS'),
--            apt.hingref,
--            apt.hsalref,
            apt.minref,
            apt.toleref,
            apt.dia,
            apt.extra,
            apt.tipoasig,
            apt.ucreac,
            apt.uactua,
            apt.fcreac,
            apt.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla_turno apt
            LEFT OUTER JOIN tipo_trabajador           tp ON tp.id_cia = apt.id_cia
                                                  AND tp.tiptra = apt.tiptra
        WHERE
                apt.id_cia = pin_id_cia
            AND apt.id_turno = pin_id_turno;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN datatable_asistencia_planilla_turno
        PIPELINED
    AS
        v_table datatable_asistencia_planilla_turno;
    BEGIN
        SELECT
            apt.id_cia,
            apt.id_turno,
            apt.tiptra,
            tp.nombre AS destiptra,
            apt.desturn,
            to_char(apt.hingtur, 'HH24:MI:SS'),
            to_char(apt.hsaltur, 'HH24:MI:SS'),
--            apt.hingtur,
--            apt.hsaltur,
            apt.mintur,
            apt.toletur,
            apt.incref,
            to_char(apt.hingref, 'HH24:MI:SS'),
            to_char(apt.hsalref, 'HH24:MI:SS'),
            apt.minref,
            apt.toleref,
            apt.dia,
            apt.extra,
            apt.tipoasig,
            apt.ucreac,
            apt.uactua,
            apt.fcreac,
            apt.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla_turno apt
            LEFT OUTER JOIN tipo_trabajador           tp ON tp.id_cia = apt.id_cia
                                                  AND tp.tiptra = apt.tiptra
        WHERE
                apt.id_cia = pin_id_cia
            AND apt.tiptra = pin_tiptra;

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
--                "id_turno":1,
--                "tiptra":"E",
--                "desturn":"PRIMER TURNO",
--                "hingtur":"2000-01-01T11:08:00.00",
--                "hsaltur":"2000-01-01T11:18:00.00",
--                "mintur":540,
--                "toletur":0,
--                "incref":"S",
--                "hingref":"2000-01-01T11:13:00.00",
--                "hsalref":"2000-01-01T11:14:00.00",
--                "minref":60,
--                "toleref":0,
--                "dia":"1,2,3,4,5",
--                "extra":"N",
--                "tipoasig":"A",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_asistencia_planilla_turno.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_asistencia_planilla_turno.sp_obtener(66,1);
--
--SELECT * FROM pack_hr_asistencia_planilla_turno.sp_buscar(66,'E');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                             json_object_t;
        rec_asistencia_planilla_turno asistencia_planilla_turno%rowtype;
        v_accion                      VARCHAR2(50) := '';
        pout_mensaje                  VARCHAR2(1000);
        v_count                       NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_asistencia_planilla_turno.id_cia := pin_id_cia;
        rec_asistencia_planilla_turno.id_turno := o.get_number('id_turno');
        rec_asistencia_planilla_turno.tiptra := o.get_string('tiptra');
        rec_asistencia_planilla_turno.desturn := o.get_string('desturn');
        rec_asistencia_planilla_turno.hingtur := o.get_timestamp('hingtur');
        rec_asistencia_planilla_turno.hsaltur := o.get_timestamp('hsaltur');
        rec_asistencia_planilla_turno.toletur := o.get_number('toletur');
--        rec_asistencia_planilla_turno.mintur := o.get_number('mintur');
        rec_asistencia_planilla_turno.incref := o.get_string('incref');
        -- CALCULANDO LOS MINUTOS DEL REFRIGERIO
        IF
            rec_asistencia_planilla_turno.hingtur IS NOT NULL
            AND rec_asistencia_planilla_turno.hsaltur IS NOT NULL
        THEN
            SELECT
                ajustado
            INTO rec_asistencia_planilla_turno.mintur
            FROM
                pack_ayuda_general.sp_difmin_number(rec_asistencia_planilla_turno.hingtur, rec_asistencia_planilla_turno.hsaltur);

            IF rec_asistencia_planilla_turno.mintur < 0 THEN
                pout_mensaje := 'La Hora de Entrada del Turno [ '
                                || to_char(rec_asistencia_planilla_turno.hingtur, 'HH24:MI:SS')
                                || ' ] no puede ser mayor que la hora de Salida del Turno [ '
                                || to_char(rec_asistencia_planilla_turno.hsaltur, 'HH24:MI:SS')
                                || ' ]';

                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        IF rec_asistencia_planilla_turno.incref = 'S' THEN
            rec_asistencia_planilla_turno.hingref := o.get_timestamp('hingref');
            rec_asistencia_planilla_turno.hsalref := o.get_timestamp('hsalref');
            -- CALCULANDO LOS MINUTOS DEL REFRIGERIO
            IF
                rec_asistencia_planilla_turno.hingref IS NOT NULL
                AND rec_asistencia_planilla_turno.hsalref IS NOT NULL
            THEN
                SELECT
                    ajustado
                INTO rec_asistencia_planilla_turno.minref
                FROM
                    pack_ayuda_general.sp_difmin_number(rec_asistencia_planilla_turno.hingref, rec_asistencia_planilla_turno.hsalref);

                dbms_output.put_line(rec_asistencia_planilla_turno.hingref
                                     || ' - '
                                     || rec_asistencia_planilla_turno.hsalref);
                IF rec_asistencia_planilla_turno.minref < 0 THEN
                    pout_mensaje := 'La Hora de Entrada del Refrigerio [ '
                                    || to_char(rec_asistencia_planilla_turno.hingref, 'HH24:MI:SS')
                                    || ' ] no puede ser mayor que la hora de Salida del Refrigerio [ '
                                    || to_char(rec_asistencia_planilla_turno.hsalref, 'HH24:MI:SS')
                                    || ' ]';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END IF;

            IF rec_asistencia_planilla_turno.mintur < rec_asistencia_planilla_turno.minref THEN
                pout_mensaje := 'El Tiempo del Refrigerio no puede ser mayor al Turno ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            dbms_output.put_line(rec_asistencia_planilla_turno.mintur
                                 || ' - '
                                 || rec_asistencia_planilla_turno.minref);
            rec_asistencia_planilla_turno.mintur := rec_asistencia_planilla_turno.mintur - rec_asistencia_planilla_turno.minref;
            rec_asistencia_planilla_turno.toleref := o.get_number('toleref');
        ELSE
            rec_asistencia_planilla_turno.hingref := NULL;
            rec_asistencia_planilla_turno.hsalref := NULL;
            rec_asistencia_planilla_turno.minref := 0;
            rec_asistencia_planilla_turno.toleref := 0;
        END IF;

        rec_asistencia_planilla_turno.dia := o.get_string('dia');
        rec_asistencia_planilla_turno.extra := o.get_string('extra');
        rec_asistencia_planilla_turno.tipoasig := o.get_string('tipoasig');
        rec_asistencia_planilla_turno.ucreac := o.get_string('ucreac');
        rec_asistencia_planilla_turno.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                BEGIN
                    SELECT
                        nvl(MAX(nvl(id_turno, 0)), 0)
                    INTO rec_asistencia_planilla_turno.id_turno
                    FROM
                        asistencia_planilla_turno
                    WHERE
                        id_cia = pin_id_cia;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_asistencia_planilla_turno.id_turno := 0;
                END;

                rec_asistencia_planilla_turno.id_turno := rec_asistencia_planilla_turno.id_turno + 1;
                INSERT INTO asistencia_planilla_turno (
                    id_cia,
                    id_turno,
                    tiptra,
                    desturn,
                    hingtur,
                    hsaltur,
                    mintur,
                    toletur,
                    incref,
                    hingref,
                    hsalref,
                    minref,
                    toleref,
                    dia,
                    extra,
                    tipoasig,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_asistencia_planilla_turno.id_cia,
                    rec_asistencia_planilla_turno.id_turno,
                    rec_asistencia_planilla_turno.tiptra,
                    rec_asistencia_planilla_turno.desturn,
                    rec_asistencia_planilla_turno.hingtur,
                    rec_asistencia_planilla_turno.hsaltur,
                    rec_asistencia_planilla_turno.mintur,
                    rec_asistencia_planilla_turno.toletur,
                    rec_asistencia_planilla_turno.incref,
                    rec_asistencia_planilla_turno.hingref,
                    rec_asistencia_planilla_turno.hsalref,
                    rec_asistencia_planilla_turno.minref,
                    rec_asistencia_planilla_turno.toleref,
                    rec_asistencia_planilla_turno.dia,
                    rec_asistencia_planilla_turno.extra,
                    rec_asistencia_planilla_turno.tipoasig,
                    rec_asistencia_planilla_turno.ucreac,
                    rec_asistencia_planilla_turno.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE asistencia_planilla_turno
                SET
                    tiptra =
                        CASE
                            WHEN rec_asistencia_planilla_turno.tiptra IS NULL THEN
                                tiptra
                            ELSE
                                rec_asistencia_planilla_turno.tiptra
                        END,
                    desturn =
                        CASE
                            WHEN rec_asistencia_planilla_turno.desturn IS NULL THEN
                                desturn
                            ELSE
                                rec_asistencia_planilla_turno.desturn
                        END,
                    hingtur =
                        CASE
                            WHEN rec_asistencia_planilla_turno.hingtur IS NULL THEN
                                hingtur
                            ELSE
                                rec_asistencia_planilla_turno.hingtur
                        END,
                    hsaltur =
                        CASE
                            WHEN rec_asistencia_planilla_turno.hsaltur IS NULL THEN
                                hsaltur
                            ELSE
                                rec_asistencia_planilla_turno.hsaltur
                        END,
                    mintur =
                        CASE
                            WHEN rec_asistencia_planilla_turno.mintur IS NULL THEN
                                mintur
                            ELSE
                                rec_asistencia_planilla_turno.mintur
                        END,
                    toletur =
                        CASE
                            WHEN rec_asistencia_planilla_turno.toletur IS NULL THEN
                                toletur
                            ELSE
                                rec_asistencia_planilla_turno.toletur
                        END,
                    incref =
                        CASE
                            WHEN rec_asistencia_planilla_turno.incref IS NULL THEN
                                incref
                            ELSE
                                rec_asistencia_planilla_turno.incref
                        END,
                    hingref = rec_asistencia_planilla_turno.hingref,
                    hsalref = rec_asistencia_planilla_turno.hsalref,
                    minref = rec_asistencia_planilla_turno.minref,
                    toleref = rec_asistencia_planilla_turno.toleref,
                    dia =
                        CASE
                            WHEN rec_asistencia_planilla_turno.dia IS NULL THEN
                                dia
                            ELSE
                                rec_asistencia_planilla_turno.dia
                        END,
                    extra =
                        CASE
                            WHEN rec_asistencia_planilla_turno.extra IS NULL THEN
                                extra
                            ELSE
                                rec_asistencia_planilla_turno.extra
                        END,
                    tipoasig =
                        CASE
                            WHEN rec_asistencia_planilla_turno.tipoasig IS NULL THEN
                                tipoasig
                            ELSE
                                rec_asistencia_planilla_turno.tipoasig
                        END,
                    uactua =
                        CASE
                            WHEN rec_asistencia_planilla_turno.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_asistencia_planilla_turno.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_asistencia_planilla_turno.id_cia
                    AND id_turno = rec_asistencia_planilla_turno.id_turno;

                NULL;
            WHEN 3 THEN
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count
                    FROM
                        asistencia_planilla
                    WHERE
                            id_cia = pin_id_cia
                        AND id_turno = rec_asistencia_planilla_turno.id_turno;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                IF v_count > 0 THEN
                    pout_mensaje := 'No se puede eliminar este turno, porque contiene registros historicos relacionados en la asistencia';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;
                v_accion := 'La eliminación';
                DELETE FROM personal_turno_planilla
                WHERE
                        id_cia = rec_asistencia_planilla_turno.id_cia
                    AND id_turno = rec_asistencia_planilla_turno.id_turno;

                DELETE FROM asistencia_planilla_turno
                WHERE
                        id_cia = rec_asistencia_planilla_turno.id_cia
                    AND id_turno = rec_asistencia_planilla_turno.id_turno;

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
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con el ID del Turno de Asistencia [ '
                                    || rec_asistencia_planilla_turno.id_turno
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Tipo de Trabajador [ '
                                        || rec_asistencia_planilla_turno.tiptra
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

END;

/
