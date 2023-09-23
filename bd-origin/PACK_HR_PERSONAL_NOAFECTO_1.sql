--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_NOAFECTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_NOAFECTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_noafecto
        PIPELINED
    AS
        v_table datatable_personal_noafecto;
    BEGIN
        SELECT
            pa.id_cia,
            pa.codcon,
            pa.codper,
            p.nombre,
            pa.ucreac,
            pa.uactua,
            pa.fcreac,
            pa.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_noafecto pa
            LEFT OUTER JOIN personal          p ON p.id_cia = pa.id_cia
                                          AND p.codper = pa.codper
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.codper = pin_codper
            AND pa.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_personal_noafecto
        PIPELINED
    AS
        v_table datatable_personal_noafecto;
    BEGIN
        SELECT
            pa.id_cia,
            pa.codcon,
            pa.codper,
            p.nombre,
            pa.ucreac,
            pa.uactua,
            pa.fcreac,
            pa.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_noafecto pa
            LEFT OUTER JOIN personal          p ON p.id_cia = pa.id_cia
                                          AND p.codper = pa.codper
        WHERE
                pa.id_cia = pin_id_cia
            AND pa.codcon = pin_codcon;

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
--                "codcon":"102",
--                "codper":"98765431",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_noafecto.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_noafecto.sp_obtener(66,'102','98765431');
--
--SELECT * FROM pack_hr_personal_noafecto.sp_buscar(66,'102');
--
--SELECT * FROM pack_hr_personal_noafecto.sp_obtener(66,'102','98765431');


    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                     json_object_t;
        rec_personal_noafecto personal_noafecto%rowtype;
        v_accion              VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_noafecto.id_cia := pin_id_cia;
        rec_personal_noafecto.codcon := o.get_string('codcon');
        rec_personal_noafecto.codper := o.get_string('codper');
        rec_personal_noafecto.ucreac := o.get_string('ucreac');
        rec_personal_noafecto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_noafecto (
                    id_cia,
                    codcon,
                    codper,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_noafecto.id_cia,
                    rec_personal_noafecto.codcon,
                    rec_personal_noafecto.codper,
                    rec_personal_noafecto.ucreac,
                    rec_personal_noafecto.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE personal_noafecto
--                SET
--                    uactua =
--                        CASE
--                            WHEN rec_personal_noafecto.uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_personal_noafecto.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_personal_noafecto.id_cia
--                    AND codper = rec_personal_noafecto.codper
--                    AND codcon = rec_personal_noafecto.codcon;
                NULL;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_noafecto
                WHERE
                        id_cia = rec_personal_noafecto.id_cia
                    AND codcon = rec_personal_noafecto.codcon
                    AND codper = rec_personal_noafecto.codper;

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
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_personal_noafecto.codper
                                    || ' ] y con el Concepto [ '
                                    || rec_personal_noafecto.codcon
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Concepto [ '
                                        || rec_personal_noafecto.codcon
                                        || ' ] o porque el Codigo de Personal [ '
                                        || rec_personal_noafecto.codper
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
