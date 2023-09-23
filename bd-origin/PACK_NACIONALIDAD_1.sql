--------------------------------------------------------
--  DDL for Package Body PACK_NACIONALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_NACIONALIDAD" AS

    FUNCTION sp_sel_nacionalidad (
        pin_id_cia  IN  NUMBER,
        pin_codnac  IN  VARCHAR2,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_nacionalidad
        PIPELINED
    IS
        v_table t_nacionalidad;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            nacionalidad
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codnac IS NULL )
                  OR ( codnac = pin_codnac ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_nacionalidad;

    PROCEDURE sp_save_nacionalidad (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                 json_object_t;
        rec_nacionalidad  nacionalidad%rowtype;
        v_accion          VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_nacionalidad.id_cia := pin_id_cia;
        rec_nacionalidad.codnac := o.get_number('codnac');
        rec_nacionalidad.nombre := o.get_string('nombre');
        rec_nacionalidad.ucreac := o.get_string('ucreac');
        rec_nacionalidad.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO nacionalidad (
                    id_cia,
                    codnac,
                    nombre,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_nacionalidad.id_cia,
                    rec_nacionalidad.codnac,
                    rec_nacionalidad.nombre,
                    rec_nacionalidad.ucreac,
                    rec_nacionalidad.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE nacionalidad
                SET
                    nombre = rec_nacionalidad.nombre,
                    uactua = rec_nacionalidad.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_nacionalidad.id_cia
                    AND codnac = rec_nacionalidad.codnac;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM nacionalidad
                WHERE
                        id_cia = rec_nacionalidad.id_cia
                    AND codnac = rec_nacionalidad.codnac;

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
                    'message' VALUE 'El registro con codigo de nacionalidad [ '
                                    || rec_nacionalidad.codnac
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
