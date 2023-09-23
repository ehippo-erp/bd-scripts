--------------------------------------------------------
--  DDL for Package Body PACK_USUARIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_USUARIOS" AS

    PROCEDURE sp_clean_sessions (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        UPDATE usuarios_activos
        SET
            activo = 'N'
        WHERE
                id_cia = pin_id_cia
            AND coduser = pin_coduser
            AND activo = 'S';

        pin_mensaje := 'Success.';
    END sp_clean_sessions;

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_usuarios
        PIPELINED
    AS
        v_table datatable_usuarios;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            usuarios
        WHERE
                id_cia = pin_id_cia
            AND coduser = pin_coduser;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_nombre VARCHAR2
    ) RETURN datatable_usuarios
        PIPELINED
    AS
        v_table datatable_usuarios;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            usuarios
        WHERE
                id_cia = pin_id_cia
            AND ( instr(upper(nombres), upper(pin_nombre)) > 0 );

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
--                "coduser":"P001",
--                "nombres":"102",
--                "ucreac":"Admin",
--                "usuari":"Admin"
--                }';
--pack_hr_usuarios.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_usuarios.sp_obtener(66,'P001','102');
--
--SELECT * FROM pack_hr_usuarios.sp_buscar(66,'P001');

    PROCEDURE sp_validacion_eliminar_usuario (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_existe     VARCHAR2(1) := 'S';
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        BEGIN
            SELECT
                'N' AS no_existe
            INTO v_existe
            FROM
                usuarios u
            WHERE
                    u.id_cia = pin_id_cia
                AND u.coduser = pin_coduser
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        asienhea ah
                    WHERE
                            ah.id_cia = u.id_cia
                        AND ah.usuari = u.coduser
                )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        dcta102 d102
                    WHERE
                            d102.id_cia = u.id_cia
                        AND d102.usuari = u.coduser
                )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        prov102 p102
                    WHERE
                            p102.id_cia = u.id_cia
                        AND p102.usuari = u.coduser
                )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        documentos_cab c
                    WHERE
                            c.id_cia = u.id_cia
                        AND ( c.usuari = u.coduser
                              OR c.ucreac = u.coduser )
                )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        dcta101 d101
                    WHERE
                            d101.id_cia = u.id_cia
                        AND d101.usuari = u.coduser
                )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        prov101 p101
                    WHERE
                            p101.id_cia = u.id_cia
                        AND p101.usuari = u.coduser
                );

        EXCEPTION
            WHEN no_data_found THEN
                v_existe := 'S';
                pout_mensaje := 'No se puede eliminar el usuario [ '
                                || pin_coduser
                                || ' ] porque existen movimientos relacionados a este ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Procede ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        rec_usuarios usuarios%rowtype;
        pout_mensaje VARCHAR2(1000);
        v_mensaje    VARCHAR2(1000);
        v_accion     VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_usuarios.id_cia := pin_id_cia;
        rec_usuarios.coduser := o.get_string('coduser');
        rec_usuarios.nombres := o.get_string('nombres');
        rec_usuarios.clave := o.get_string('clave');
        rec_usuarios.atributos := o.get_number('atributos');
        rec_usuarios.fexpira := o.get_date('fexpira');
        rec_usuarios.situac := o.get_string('situac');
        rec_usuarios.swacti := o.get_string('swacti');
        rec_usuarios.usuari := o.get_string('usuari');
        rec_usuarios.comentario := o.get_string('comentario');
        rec_usuarios.impeti := o.get_number('impeti');
        rec_usuarios.numcaja := o.get_number('numcaja');
        rec_usuarios.cargo := o.get_string('cargo');
        rec_usuarios.codsuc := o.get_number('codsuc');
        rec_usuarios.email := o.get_string('email');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO usuarios (
                    id_cia,
                    coduser,
                    nombres,
                    clave,
                    atributos,
                    fexpira,
                    situac,
                    fcreac,
                    factua,
                    swacti,
                    usuari,
                    comentario,
                    impeti,
                    numcaja,
                    cargo,
                    codsuc,
                    email
                ) VALUES (
                    rec_usuarios.id_cia,
                    rec_usuarios.coduser,
                    rec_usuarios.nombres,
                    rec_usuarios.clave,
                    rec_usuarios.atributos,
                    rec_usuarios.fexpira,
                    rec_usuarios.situac,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    rec_usuarios.swacti,
                    rec_usuarios.usuari,
                    rec_usuarios.comentario,
                    rec_usuarios.impeti,
                    rec_usuarios.numcaja,
                    rec_usuarios.cargo,
                    rec_usuarios.codsuc,
                    rec_usuarios.email
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE usuarios
                SET
                    nombres =
                        CASE
                            WHEN rec_usuarios.nombres IS NULL THEN
                                nombres
                            ELSE
                                rec_usuarios.nombres
                        END,
                    clave =
                        CASE
                            WHEN rec_usuarios.clave IS NULL THEN
                                clave
                            ELSE
                                rec_usuarios.clave
                        END,
                    atributos =
                        CASE
                            WHEN rec_usuarios.atributos IS NULL THEN
                                atributos
                            ELSE
                                rec_usuarios.atributos
                        END,
                    fexpira =
                        CASE
                            WHEN rec_usuarios.fexpira IS NULL THEN
                                fexpira
                            ELSE
                                rec_usuarios.fexpira
                        END,
                    situac =
                        CASE
                            WHEN rec_usuarios.situac IS NULL THEN
                                situac
                            ELSE
                                rec_usuarios.situac
                        END,
                    swacti =
                        CASE
                            WHEN rec_usuarios.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_usuarios.swacti
                        END,
                    comentario =
                        CASE
                            WHEN rec_usuarios.comentario IS NULL THEN
                                comentario
                            ELSE
                                rec_usuarios.comentario
                        END,
                    impeti =
                        CASE
                            WHEN rec_usuarios.impeti IS NULL THEN
                                impeti
                            ELSE
                                rec_usuarios.impeti
                        END,
                    numcaja =
                        CASE
                            WHEN rec_usuarios.numcaja IS NULL THEN
                                numcaja
                            ELSE
                                rec_usuarios.numcaja
                        END,
                    cargo =
                        CASE
                            WHEN rec_usuarios.cargo IS NULL THEN
                                cargo
                            ELSE
                                rec_usuarios.cargo
                        END,
                    codsuc =
                        CASE
                            WHEN rec_usuarios.codsuc IS NULL THEN
                                codsuc
                            ELSE
                                rec_usuarios.codsuc
                        END,
                    email =
                        CASE
                            WHEN rec_usuarios.email IS NULL THEN
                                email
                            ELSE
                                rec_usuarios.email
                        END,
                    usuari =
                        CASE
                            WHEN rec_usuarios.usuari IS NULL THEN
                                usuari
                            ELSE
                                rec_usuarios.usuari
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_usuarios.id_cia
                    AND coduser = rec_usuarios.coduser;

            WHEN 3 THEN
                pack_usuarios.sp_validacion_eliminar_usuario(pin_id_cia, rec_usuarios.coduser, v_mensaje);
                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                ELSE
                    v_accion := 'La eliminación';
                    DELETE FROM permisos
                    WHERE
                            id_cia = rec_usuarios.id_cia
                        AND coduser = rec_usuarios.coduser;

                    DELETE FROM usuarios_propiedades
                    WHERE
                            id_cia = rec_usuarios.id_cia
                        AND coduser = rec_usuarios.coduser;

                    DELETE FROM usuarios_activos
                    WHERE
                            id_cia = rec_usuarios.id_cia
                        AND coduser = rec_usuarios.coduser;

                    DELETE FROM usuarios_imagen
                    WHERE
                            id_cia = rec_usuarios.id_cia
                        AND coduser = rec_usuarios.coduser;

                    DELETE FROM usuarios
                    WHERE
                            id_cia = rec_usuarios.id_cia
                        AND coduser = rec_usuarios.coduser;

                    COMMIT;
                END IF;

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
                    'message' VALUE 'El registro con codigo de usuario [ '
                                    || rec_usuarios.coduser
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;
            ROLLBACK;
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;
                ROLLBACK;
        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se eliminar el Usuario [ '
                                        || rec_usuarios.coduser
                                        || ' ] porque se encuentra referenciado en otro registro ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;
                ROLLBACK;
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
                ROLLBACK;
            END IF;
    END sp_save;

END;

/
