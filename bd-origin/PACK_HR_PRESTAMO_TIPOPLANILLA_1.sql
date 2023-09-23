--------------------------------------------------------
--  DDL for Package Body PACK_HR_PRESTAMO_TIPOPLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PRESTAMO_TIPOPLANILLA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER,
        pin_tippla VARCHAR2
    ) RETURN datatable_prestamo_tipoplanilla
        PIPELINED
    AS
        v_table datatable_prestamo_tipoplanilla;
    BEGIN
        SELECT
            pc.id_cia,
            pc.id_pre,
            pc.tippla,
            tp.nombre,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            prestamo_tipoplanilla pc
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pc.id_cia
                                               AND tp.tippla = pc.tippla
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.id_pre = pin_id_pre
            AND pc.tippla = pin_tippla;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER
    ) RETURN datatable_prestamo_tipoplanilla
        PIPELINED
    AS
        v_table datatable_prestamo_tipoplanilla;
    BEGIN
        SELECT
            pc.id_cia,
            pc.id_pre,
            pc.tippla,
            tp.nombre,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            prestamo_tipoplanilla pc
            LEFT OUTER JOIN tipoplanilla          tp ON tp.id_cia = pc.id_cia
                                               AND tp.tippla = pc.tippla
        WHERE
                pc.id_cia = pin_id_cia
            AND ( pin_id_pre IS NULL
                  OR pc.id_pre = pin_id_pre );

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
--                "id_pre":1,
--                "tippla":"G",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_prestamo_tipoplanilla.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_prestamo_tipoplanilla.sp_obtener(66,1,'N');
--
--SELECT * FROM pack_hr_prestamo_tipoplanilla.sp_buscar(66,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                         json_object_t;
        rec_prestamo_tipoplanilla prestamo_tipoplanilla%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_prestamo_tipoplanilla.id_cia := pin_id_cia;
        rec_prestamo_tipoplanilla.id_pre := o.get_number('id_pre');
        rec_prestamo_tipoplanilla.tippla := o.get_string('tippla');
        rec_prestamo_tipoplanilla.ucreac := o.get_string('ucreac');
        rec_prestamo_tipoplanilla.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO prestamo_tipoplanilla (
                    id_cia,
                    id_pre,
                    tippla,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_prestamo_tipoplanilla.id_cia,
                    rec_prestamo_tipoplanilla.id_pre,
                    rec_prestamo_tipoplanilla.tippla,
                    rec_prestamo_tipoplanilla.ucreac,
                    rec_prestamo_tipoplanilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE prestamo_tipoplanilla
--                SET
--                    nombre =
--                        CASE
--                            WHEN rec_prestamo_tipoplanilla.nombre IS NULL THEN
--                                nombre
--                            ELSE
--                                rec_prestamo_tipoplanilla.nombre
--                        END,
--                    uactua =
--                        CASE
--                            WHEN rec_prestamo_tipoplanilla.uactua IS NULL THEN
--                                uactua
--                            ELSE
--                                rec_prestamo_tipoplanilla.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_prestamo_tipoplanilla.id_cia
--                    AND id_pre = rec_prestamo_tipoplanilla.id_pre
--                    AND tippla = rec_prestamo_tipoplanilla.tippla;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM prestamo_tipoplanilla
                WHERE
                        id_cia = rec_prestamo_tipoplanilla.id_cia
                    AND id_pre = rec_prestamo_tipoplanilla.id_pre
                    AND tippla = rec_prestamo_tipoplanilla.tippla;

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
                                    || rec_prestamo_tipoplanilla.id_pre
                                    || ' ] y con el Codigo de Concepto [ '
                                    || rec_prestamo_tipoplanilla.tippla
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
                                        || rec_prestamo_tipoplanilla.id_pre
                                        || ' ] o el Codigo de Concepto [ '
                                        || rec_prestamo_tipoplanilla.tippla
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
