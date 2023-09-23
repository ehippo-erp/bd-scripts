--------------------------------------------------------
--  DDL for Package Body PACK_CF_USUARIO_GRUPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_USUARIO_GRUPO" AS

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER,
        pin_coduser  VARCHAR2
    ) RETURN datatable_usuario_grupo
        PIPELINED
    AS
        v_table datatable_usuario_grupo;
    BEGIN
        SELECT
            um.id_cia,
            um.codgrupo,
            m.desgrupo AS desgrupo,
            um.coduser,
            u.nombres  AS nomuser,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            usuario_grupo um
            LEFT OUTER JOIN grupo_usuario m ON m.id_cia = um.id_cia
                                               AND m.codgrupo = um.codgrupo
            LEFT OUTER JOIN usuarios      u ON u.id_cia = um.id_cia
                                          AND u.coduser = um.coduser
        WHERE
                um.id_cia = pin_id_cia
            AND um.codgrupo = pin_codgrupo
            AND um.coduser = pin_coduser;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codgrupo NUMBER,
        pin_coduser  VARCHAR2
    ) RETURN datatable_usuario_grupo
        PIPELINED
    AS
        v_table datatable_usuario_grupo;
    BEGIN
        SELECT
            um.id_cia,
            um.codgrupo,
            m.desgrupo AS desmot,
            um.coduser,
            u.nombres  AS nomuser,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            usuario_grupo um
            LEFT OUTER JOIN grupo_usuario m ON m.id_cia = um.id_cia
                                               AND m.codgrupo = um.codgrupo
            LEFT OUTER JOIN usuarios      u ON u.id_cia = um.id_cia
                                          AND u.coduser = um.coduser
        WHERE
                um.id_cia = pin_id_cia
            AND ( nvl(pin_codgrupo, - 1) = - 1
                  OR um.codgrupo = pin_codgrupo )
            AND ( pin_coduser IS NULL
                  OR um.coduser = pin_coduser );

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
--                "codgrupo":33,
--                "coduser":"CALV",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cf_USUARIO_GRUPO.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_USUARIO_GRUPO.sp_obtener(25,33,'CALV');
--
--SELECT * FROM pack_cf_USUARIO_GRUPO.sp_buscar(25,NULL,NULL,'S');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                 json_object_t;
        rec_usuario_grupo usuario_grupo%rowtype;
        v_accion          VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_usuario_grupo.id_cia := pin_id_cia;
        rec_usuario_grupo.codgrupo := o.get_number('codgrupo');
        rec_usuario_grupo.coduser := o.get_string('coduser');
        rec_usuario_grupo.ucreac := o.get_string('ucreac');
        rec_usuario_grupo.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO usuario_grupo (
                    id_cia,
                    codgrupo,
                    coduser,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_usuario_grupo.id_cia,
                    rec_usuario_grupo.codgrupo,
                    rec_usuario_grupo.coduser,
                    rec_usuario_grupo.ucreac,
                    rec_usuario_grupo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
--                UPDATE usuario_grupo
--                SET
--                    uactua = rec_usuario_grupo.uactua,
--                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
--             'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_usuario_grupo.id_cia
--                    AND codgrupo = rec_usuario_grupo.codgrupo
--                    AND coduser = rec_usuario_grupo.coduser;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM usuario_grupo
                WHERE
                        id_cia = rec_usuario_grupo.id_cia
                    AND codgrupo = rec_usuario_grupo.codgrupo
                    AND coduser = rec_usuario_grupo.coduser;

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
                    'message' VALUE 'El registro con el GRUPO [ '
                                    || rec_usuario_grupo.codgrupo
                                    || ' ] y USUARIO [ '
                                    || rec_usuario_grupo.coduser
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
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el GRUPO [ '
                                        || rec_usuario_grupo.codgrupo
                                        || ' ] no existe ...! '
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
