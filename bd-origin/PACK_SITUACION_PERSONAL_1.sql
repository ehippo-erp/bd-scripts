--------------------------------------------------------
--  DDL for Package Body PACK_SITUACION_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_SITUACION_PERSONAL" AS

    FUNCTION sp_sel_situacion_personal (
        pin_id_cia IN NUMBER,
        pin_codsit IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_situacion_personal
        PIPELINED
    IS
        v_table t_situacion_personal;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            situacion_personal s
        WHERE
                s.id_cia = pin_id_cia
            AND ( ( pin_codsit IS NULL )
                  OR ( s.codsit = pin_codsit ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( s.nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_situacion_personal;

    PROCEDURE sp_save_situacion_personal (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                      json_object_t;
        rec_situacion_personal situacion_personal%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_situacion_personal.id_cia := pin_id_cia;
        rec_situacion_personal.codsit := o.get_string('codsit');
        rec_situacion_personal.nombre := o.get_string('nombre');
        rec_situacion_personal.ucreac := o.get_string('ucreac');
        rec_situacion_personal.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO situacion_personal (
                    id_cia,
                    codsit,
                    nombre,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_situacion_personal.id_cia,
                    rec_situacion_personal.codsit,
                    rec_situacion_personal.nombre,
                    rec_situacion_personal.ucreac,
                    rec_situacion_personal.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE situacion_personal
                SET
                    nombre = rec_situacion_personal.nombre,
                    uactua = rec_situacion_personal.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_situacion_personal.id_cia
                    AND codsit = rec_situacion_personal.codsit;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM situacion_personal
                WHERE
                        id_cia = rec_situacion_personal.id_cia
                    AND codsit = rec_situacion_personal.codsit;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de situacion personal [ '
                                    || rec_situacion_personal.codsit
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

    END;

END;

/
