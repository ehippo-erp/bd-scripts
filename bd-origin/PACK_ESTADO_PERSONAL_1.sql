--------------------------------------------------------
--  DDL for Package Body PACK_ESTADO_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ESTADO_PERSONAL" AS

    FUNCTION sp_buscar (
        pin_id_cia  IN  NUMBER,
        pin_codest  IN  VARCHAR2,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_estado_personal
        PIPELINED
    IS
        v_table t_estado_personal;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            estado_personal
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codest IS NULL )
                  OR ( codest = pin_codest ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                    json_object_t;
        rec_estado_personal  estado_personal%rowtype;
        v_accion             VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_estado_personal.id_cia := pin_id_cia;
        rec_estado_personal.codest := o.get_string('codest');
        rec_estado_personal.nombre := o.get_string('nombre');
        rec_estado_personal.ucreac := o.get_string('ucreac');
        rec_estado_personal.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO estado_personal (
                    id_cia,
                    codest,
                    nombre,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_estado_personal.id_cia,
                    rec_estado_personal.codest,
                    rec_estado_personal.nombre,
                    rec_estado_personal.ucreac,
                    rec_estado_personal.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE estado_personal
                SET
                    nombre = rec_estado_personal.nombre,
                    uactua = rec_estado_personal.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_estado_personal.id_cia
                    AND codest = rec_estado_personal.codest;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM estado_personal
                WHERE
                        id_cia = rec_estado_personal.id_cia
                    AND codest = rec_estado_personal.codest;

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
                    'message' VALUE 'El registro con codigo de estado de personal [ '
                                    || rec_estado_personal.codest
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
    END sp_save;

END;

/
