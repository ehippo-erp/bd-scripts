--------------------------------------------------------
--  DDL for Package Body PACK_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TIPO" AS

    FUNCTION sp_sel_tipo (
        pin_id_cia IN NUMBER,
        pin_codtip IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_tipo
        PIPELINED
    IS
        v_table t_tipo;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tipo
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codtip IS NULL )
                  OR ( codtip = pin_codtip ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_tipo;

    PROCEDURE sp_save_tipo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o        json_object_t;
        rec_tipo tipo%rowtype;
        v_accion VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipo.id_cia := pin_id_cia;
        rec_tipo.codtip := o.get_string('codtip');
        rec_tipo.nombre := o.get_string('nombre');
        rec_tipo.ucreac := o.get_string('ucreac');
        rec_tipo.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tipo (
                    id_cia,
                    codtip,
                    nombre,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                    --imagen
                ) VALUES (
                    rec_tipo.id_cia,
                    rec_tipo.codtip,
                    rec_tipo.nombre,
                    rec_tipo.ucreac,
                    rec_tipo.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tipo
                SET
                    nombre =
                        CASE
                            WHEN rec_tipo.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_tipo.nombre
                        END,
                    uactua =
                        CASE
                            WHEN rec_tipo.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_tipo.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tipo.id_cia
                    AND codtip = rec_tipo.codtip;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tipo
                WHERE
                        id_cia = rec_tipo.id_cia
                    AND codtip = rec_tipo.codtip;

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
                    'message' VALUE 'El registro con codigo de tipo [ '
                                    || rec_tipo.codtip
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

    END sp_save_tipo;

END;

/
