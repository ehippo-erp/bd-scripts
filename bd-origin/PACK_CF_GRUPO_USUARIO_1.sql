--------------------------------------------------------
--  DDL for Package Body PACK_CF_GRUPO_USUARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_GRUPO_USUARIO" AS

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_grupo_usuario
        PIPELINED
    AS
        v_table datatable_grupo_usuario;
    BEGIN
        SELECT
            um.id_cia,
            um.codgrupo,
            um.desgrupo,
            um.swacti,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            grupo_usuario um
        WHERE
                um.id_cia = pin_id_cia
            AND um.codgrupo = pin_codgrupo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_desgrupo VARCHAR2,
        pin_swacti   VARCHAR2
    ) RETURN datatable_grupo_usuario
        PIPELINED
    AS
        v_table datatable_grupo_usuario;
    BEGIN
        SELECT
            um.id_cia,
            um.codgrupo,
            um.desgrupo,
            um.swacti,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            grupo_usuario um
        WHERE
                um.id_cia = pin_id_cia
            AND ( pin_desgrupo IS NULL
                  OR upper(um.desgrupo) LIKE upper('%'
                                                   || pin_desgrupo
                                                   || '%') )
            AND ( pin_swacti IS NULL
                  OR um.swacti = pin_swacti );

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
--                "codgrupo":1,
--                "desgrupo":"GRUPO DE PRUEBA - 1",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cf_grupo_usuario.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_grupo_usuario.sp_obtener(25,1);
--
--SELECT * FROM pack_cf_grupo_usuario.sp_buscar(25,'%PRUEBA%','S');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                 json_object_t;
        rec_grupo_usuario grupo_usuario%rowtype;
        v_accion          VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_grupo_usuario.id_cia := pin_id_cia;
        rec_grupo_usuario.codgrupo := o.get_number('codgrupo');
        rec_grupo_usuario.desgrupo := o.get_string('desgrupo');
        rec_grupo_usuario.swacti := o.get_string('swacti');
        rec_grupo_usuario.ucreac := o.get_string('ucreac');
        rec_grupo_usuario.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO grupo_usuario (
                    id_cia,
                    codgrupo,
                    desgrupo,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_grupo_usuario.id_cia,
                    rec_grupo_usuario.codgrupo,
                    rec_grupo_usuario.desgrupo,
                    rec_grupo_usuario.swacti,
                    rec_grupo_usuario.ucreac,
                    rec_grupo_usuario.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE grupo_usuario
                SET
                    desgrupo =
                        CASE
                            WHEN rec_grupo_usuario.desgrupo IS NULL THEN
                                desgrupo
                            ELSE
                                rec_grupo_usuario.desgrupo
                        END,
                    swacti =
                        CASE
                            WHEN rec_grupo_usuario.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_grupo_usuario.swacti
                        END,
                    uactua = rec_grupo_usuario.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_grupo_usuario.id_cia
                    AND codgrupo = rec_grupo_usuario.codgrupo;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM grupo_usuario
                WHERE
                        id_cia = rec_grupo_usuario.id_cia
                    AND codgrupo = rec_grupo_usuario.codgrupo;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
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
                    'message' VALUE 'El registro con codigo de GRUPO [ '
                                    || rec_grupo_usuario.codgrupo
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se eliminar este registro porque el GRUPO [ '
                                        || rec_grupo_usuario.codgrupo
                                        || ' ] aun contiene usuarios ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codite :'
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
