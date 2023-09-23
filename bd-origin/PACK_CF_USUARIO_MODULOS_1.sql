--------------------------------------------------------
--  DDL for Package Body PACK_CF_USUARIO_MODULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_USUARIO_MODULOS" AS

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codmod  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_usuario_modulos
        PIPELINED
    AS
        v_table datatable_usuario_modulos;
    BEGIN
        SELECT
            um.id_cia,
            um.codmod,
            m.descri  AS desmod,
            um.coduser,
            u.nombres AS nomuser,
            um.swacti,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            usuario_modulos um
            LEFT OUTER JOIN modulos         m ON m.id_cia = 1
                                         AND m.codmod = um.codmod
            LEFT OUTER JOIN usuarios        u ON u.id_cia = um.id_cia
                                          AND u.coduser = um.coduser
        WHERE
                um.id_cia = pin_id_cia
            AND um.codmod = pin_codmod
            AND um.coduser = pin_coduser;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codmod  NUMBER,
        pin_coduser VARCHAR2,
        pin_swacti  VARCHAR2
    ) RETURN datatable_usuario_modulos
        PIPELINED
    AS
        v_table datatable_usuario_modulos;
    BEGIN
        SELECT
            um.id_cia,
            um.codmod,
            m.descri  AS desmot,
            um.coduser,
            u.nombres AS nomuser,
            um.swacti,
            um.ucreac,
            um.uactua,
            um.fcreac,
            um.factua
        BULK COLLECT
        INTO v_table
        FROM
            usuario_modulos um
            LEFT OUTER JOIN modulos         m ON m.id_cia = 1
                                         AND m.codmod = um.codmod
            LEFT OUTER JOIN usuarios        u ON u.id_cia = um.id_cia
                                          AND u.coduser = um.coduser
        WHERE
                um.id_cia = pin_id_cia
            AND ( nvl(pin_codmod, - 1) = - 1
                  OR um.codmod = pin_codmod )
            AND ( pin_coduser IS NULL
                  OR um.coduser = pin_coduser )
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
--                "codmod":33,
--                "coduser":"CALV",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cf_usuario_modulos.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_usuario_modulos.sp_obtener(25,33,'CALV');
--
--SELECT * FROM pack_cf_usuario_modulos.sp_buscar(25,NULL,NULL,'S');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                   json_object_t;
        rec_usuario_modulos usuario_modulos%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_usuario_modulos.id_cia := pin_id_cia;
        rec_usuario_modulos.codmod := o.get_number('codmod');
        rec_usuario_modulos.coduser := o.get_string('coduser');
        rec_usuario_modulos.swacti := o.get_string('swacti');
        rec_usuario_modulos.ucreac := o.get_string('ucreac');
        rec_usuario_modulos.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO usuario_modulos (
                    id_cia,
                    codmod,
                    coduser,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_usuario_modulos.id_cia,
                    rec_usuario_modulos.codmod,
                    rec_usuario_modulos.coduser,
                    rec_usuario_modulos.swacti,
                    rec_usuario_modulos.ucreac,
                    rec_usuario_modulos.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE usuario_modulos
                SET
                    swacti =
                        CASE
                            WHEN rec_usuario_modulos.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_usuario_modulos.swacti
                        END,
                    uactua = rec_usuario_modulos.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_usuario_modulos.id_cia
                    AND codmod = rec_usuario_modulos.codmod
                    AND coduser = rec_usuario_modulos.coduser;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM usuario_modulos
                WHERE
                        id_cia = rec_usuario_modulos.id_cia
                    AND codmod = rec_usuario_modulos.codmod
                    AND coduser = rec_usuario_modulos.coduser;

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
                    'message' VALUE 'El registro con del MODULO [ '
                                    || rec_usuario_modulos.codmod
                                    || ' ] y USUARIO [ '
                                    || rec_usuario_modulos.coduser
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
                        'message' VALUE 'No se insertar o modificar este registro porque el MODULO [ '
                                        || rec_usuario_modulos.codmod
                                        || ' ] o USUARIO [ '
                                        || rec_usuario_modulos.coduser
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
