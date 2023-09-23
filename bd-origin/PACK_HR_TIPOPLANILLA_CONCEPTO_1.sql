--------------------------------------------------------
--  DDL for Package Body PACK_HR_TIPOPLANILLA_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_TIPOPLANILLA_CONCEPTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_tipoplanilla_concepto
        PIPELINED
    AS
        v_table datatable_tipoplanilla_concepto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.tippla,
            pc.codcon,
            tp.nombre,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            tipoplanilla_concepto pc
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pc.id_cia
                                               AND tp.tippla = pc.tippla
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.tippla = pin_tippla
            AND pc.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_tipoplanilla_concepto
        PIPELINED
    AS
        v_table datatable_tipoplanilla_concepto;
    BEGIN
        SELECT
            pc.id_cia,
            pc.tippla,
            pc.codcon,
            tp.nombre,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            tipoplanilla_concepto pc
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pc.id_cia
                                               AND tp.tippla = pc.tippla
        WHERE
                pc.id_cia = pin_id_cia
            AND ( pin_tippla IS NULL
                  OR pc.tippla = pin_tippla )
            AND ( pin_codcon IS NULL
                  OR pc.codcon = pin_codcon );

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
--                "tippla":"A",
--                "codcon":"PPPPP",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_tipoplanilla_concepto.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_tipoplanilla_concepto.sp_obtener(66,'A','PPPPP');
--
--SELECT * FROM pack_hr_tipoplanilla_concepto.sp_buscar(66,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                         json_object_t;
        rec_tipoplanilla_concepto tipoplanilla_concepto%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipoplanilla_concepto.id_cia := pin_id_cia;
        rec_tipoplanilla_concepto.tippla := o.get_string('tippla');
        rec_tipoplanilla_concepto.codcon := o.get_string('codcon');
        rec_tipoplanilla_concepto.ucreac := o.get_string('ucreac');
        rec_tipoplanilla_concepto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO tipoplanilla_concepto (
                    id_cia,
                    tippla,
                    codcon,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_tipoplanilla_concepto.id_cia,
                    rec_tipoplanilla_concepto.tippla,
                    rec_tipoplanilla_concepto.codcon,
                    rec_tipoplanilla_concepto.ucreac,
                    rec_tipoplanilla_concepto.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE tipoplanilla_concepto
--                SET
--                    nombre =
--                        CASE
--                            WHEN rec_tipoplanilla_concepto.nombre IS NULL THEN
--                                nombre
--                            ELSE
--                                rec_tipoplanilla_concepto.nombre
--                        END,
--                    uactua =
--                        CASE
--                            WHEN rec_tipoplanilla_concepto.uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_tipoplanilla_concepto.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_tipoplanilla_concepto.id_cia
--                    AND tippla = rec_tipoplanilla_concepto.tippla
--                    AND codcon = rec_tipoplanilla_concepto.codcon;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tipoplanilla_concepto
                WHERE
                        id_cia = rec_tipoplanilla_concepto.id_cia
                    AND tippla = rec_tipoplanilla_concepto.tippla
                    AND codcon = rec_tipoplanilla_concepto.codcon;

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
                    'message' VALUE 'El registro con codigo de Tipo de Planilla [ '
                                    || rec_tipoplanilla_concepto.tippla
                                    || ' ] y con el Codigo de Concepto [ '
                                    || rec_tipoplanilla_concepto.codcon
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Tipo de Planilla [ '
                                        || rec_tipoplanilla_concepto.tippla
                                        || ' ] o el Codigo de Concepto [ '
                                        || rec_tipoplanilla_concepto.codcon
                                        || 'no existe ...! '
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
