--------------------------------------------------------
--  DDL for Package Body PACK_NOTIFICACION_PROGRAMADA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_NOTIFICACION_PROGRAMADA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_notificacion_programada
        PIPELINED
    AS
        v_table datatable_notificacion_programada;
    BEGIN
        SELECT
            pl.id_cia,
            pl.numint,
            pl.titulo,
            pl.sqlnot,
            pl.emails,
            pl.head_html,
            pl.footer_html,
            pl.swacti,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            notificacion_programada pl
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_titulo VARCHAR2,
        pin_swacti VARCHAR2
    ) RETURN datatable_notificacion_programada
        PIPELINED
    AS
        v_table datatable_notificacion_programada;
    BEGIN
        SELECT
            pl.id_cia,
            pl.numint,
            pl.titulo,
            pl.sqlnot,
            pl.emails,
            pl.head_html,
            pl.footer_html,
            pl.swacti,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            notificacion_programada pl
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_titulo IS NULL
                  OR upper(pl.titulo) LIKE upper('%' || pin_titulo) )
            AND ( pin_swacti IS NULL
                  OR pl.swacti = pin_swacti );

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
--    cadjson := '{
--                "numint":1,
--                "titulo":"NOTIFICACION PRUEBA V2",
--                "sqlnot":"",
--                "emails":"pruebav2@gamil.com",
--                "head_html":"",
--                "footer_html":"",
--                "swacti":"N",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--    pack_notificacion_programada.sp_save(66, NULL, NULL, NULL, cadjson,
--                                        1, mensaje);
--
--    dbms_output.put_line(mensaje);
--END;
--
--
--SELECT
--    *
--FROM
--    pack_notificacion_programada.sp_obtener(66, 4);
--
--
--SELECT
--    *
--FROM
--    pack_notificacion_programada.sp_buscar(66, 'NOT%', NULL);


    PROCEDURE sp_save (
        pin_id_cia      IN NUMBER,
        pin_sqlnot      IN BLOB,
        pin_head_html   IN BLOB,
        pin_footer_html IN BLOB,
        pin_datos       IN VARCHAR2,
        pin_opcdml      IN INTEGER,
        pin_mensaje     OUT VARCHAR2
    ) AS
        o                           json_object_t;
        rec_notificacion_programada notificacion_programada%rowtype;
        v_accion                    VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_notificacion_programada.id_cia := pin_id_cia;
        rec_notificacion_programada.numint := o.get_number('numint');
        rec_notificacion_programada.titulo := o.get_string('titulo');
        rec_notificacion_programada.emails := o.get_string('emails');
        rec_notificacion_programada.swacti := o.get_string('swacti');
        rec_notificacion_programada.ucreac := o.get_string('ucreac');
        rec_notificacion_programada.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                rec_notificacion_programada.sqlnot := pin_sqlnot;
                rec_notificacion_programada.head_html := pin_head_html;
                rec_notificacion_programada.footer_html := pin_footer_html;
                BEGIN
                    SELECT
                        nvl(numint, 0) + 1
                    INTO rec_notificacion_programada.numint
                    FROM
                        notificacion_programada
                    WHERE
                        id_cia = notificacion_programada.id_cia
                    ORDER BY
                        numint DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_notificacion_programada.numint := 1;
                END;

                INSERT INTO notificacion_programada (
                    id_cia,
                    numint,
                    titulo,
                    sqlnot,
                    emails,
                    head_html,
                    footer_html,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_notificacion_programada.id_cia,
                    rec_notificacion_programada.numint,
                    rec_notificacion_programada.titulo,
                    rec_notificacion_programada.sqlnot,
                    rec_notificacion_programada.emails,
                    rec_notificacion_programada.head_html,
                    rec_notificacion_programada.footer_html,
                    rec_notificacion_programada.swacti,
                    rec_notificacion_programada.ucreac,
                    rec_notificacion_programada.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                rec_notificacion_programada.sqlnot := pin_sqlnot;
                rec_notificacion_programada.head_html := pin_head_html;
                rec_notificacion_programada.footer_html := pin_footer_html;
                UPDATE notificacion_programada
                SET
                    sqlnot =
                        CASE
                            WHEN rec_notificacion_programada.sqlnot IS NULL THEN
                                sqlnot
                            ELSE
                                rec_notificacion_programada.sqlnot
                        END,
                    emails =
                        CASE
                            WHEN rec_notificacion_programada.emails IS NULL THEN
                                emails
                            ELSE
                                rec_notificacion_programada.emails
                        END,
                    swacti =
                        CASE
                            WHEN rec_notificacion_programada.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_notificacion_programada.swacti
                        END,
                    head_html =
                        CASE
                            WHEN rec_notificacion_programada.head_html IS NULL THEN
                                head_html
                            ELSE
                                rec_notificacion_programada.head_html
                        END,
                    footer_html =
                        CASE
                            WHEN rec_notificacion_programada.footer_html IS NULL THEN
                                footer_html
                            ELSE
                                rec_notificacion_programada.footer_html
                        END,
                    uactua =
                        CASE
                            WHEN rec_notificacion_programada.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_notificacion_programada.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_notificacion_programada.id_cia
                    AND numint = rec_notificacion_programada.numint;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM notificacion_programada_adjunto
                WHERE
                        id_cia = rec_notificacion_programada.id_cia
                    AND numint = rec_notificacion_programada.numint;

                DELETE FROM notificacion_programada
                WHERE
                        id_cia = rec_notificacion_programada.id_cia
                    AND numint = rec_notificacion_programada.numint;

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
                    'message' VALUE 'El registro con NUMINT de Notificacion Programada [ '
                                    || rec_notificacion_programada.numint
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
--            IF sqlcode = -2291 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el TipoItem [ '
--                                        || rec_notificacion_programada.sqlnot
--                                        || ' - '
--                                        || rec_notificacion_programada.emails
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;

--            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' emails :'
                               || sqlcode;
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

--            END IF;
    END sp_save;

END;

/
