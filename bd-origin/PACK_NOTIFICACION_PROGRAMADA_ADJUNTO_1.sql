--------------------------------------------------------
--  DDL for Package Body PACK_NOTIFICACION_PROGRAMADA_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_NOTIFICACION_PROGRAMADA_ADJUNTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_notificacion_programada_adjunto
        PIPELINED
    AS
        v_table datatable_notificacion_programada_adjunto;
    BEGIN
        SELECT
            pl.id_cia,
            pl.numint,
            npa.titulo,
            pl.numite,
            pl.nombre,
            pl.formato,
            pl.archivo,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
                 notificacion_programada_adjunto pl
            INNER JOIN notificacion_programada npa ON npa.id_cia = pl.id_cia
                                                      AND npa.numint = pl.numint
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.numint = pin_numint
            AND pl.numite = pin_numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_nombre VARCHAR2
    ) RETURN datatable_notificacion_programada_adjunto
        PIPELINED
    AS
        v_table datatable_notificacion_programada_adjunto;
    BEGIN
        SELECT
            pl.id_cia,
            pl.numint,
            npa.titulo,
            pl.numite,
            pl.nombre,
            pl.formato,
            pl.archivo,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
                 notificacion_programada_adjunto pl
            INNER JOIN notificacion_programada npa ON npa.id_cia = pl.id_cia
                                                      AND npa.numint = pl.numint
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_numint IS NULL
                  OR pin_numint = - 1
                  OR pl.numint = pin_numint )
            AND ( pin_nombre IS NULL
                  OR upper(pl.nombre) LIKE upper('%' || pin_nombre) );

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
--                "numint":4,
--                "numite":"",
--                "nombre":"NOMBRE PRUEBA",
--                "formato":"PDF",
--                "archivo":"",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--
--pack_notificacion_programada_adjunto.sp_save(66,NULL, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--end;
--
--
--SELECT
--    *
--FROM
--    pack_notificacion_programada_adjunto.sp_obtener(66, 4, 1);
--
--
--SELECT
--    *
--FROM
--    pack_notificacion_programada_adjunto.sp_buscar(66, 'NOM%');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                                   json_object_t;
        rec_notificacion_programada_adjunto notificacion_programada_adjunto%rowtype;
        v_accion                            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_notificacion_programada_adjunto.id_cia := pin_id_cia;
        rec_notificacion_programada_adjunto.numint := o.get_number('numint');
        rec_notificacion_programada_adjunto.numite := o.get_number('numite');
        rec_notificacion_programada_adjunto.nombre := o.get_string('nombre');
        rec_notificacion_programada_adjunto.formato := o.get_string('formato');
        rec_notificacion_programada_adjunto.ucreac := o.get_string('ucreac');
        rec_notificacion_programada_adjunto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                rec_notificacion_programada_adjunto.archivo := pin_archivo;
                BEGIN
                    SELECT
                        nvl(numite, 0) + 1
                    INTO rec_notificacion_programada_adjunto.numite
                    FROM
                        notificacion_programada_adjunto
                    WHERE
                            id_cia = notificacion_programada_adjunto.id_cia
                        AND numint = notificacion_programada_adjunto.numint
                    ORDER BY
                        numite DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_notificacion_programada_adjunto.numite := 1;
                END;

                INSERT INTO notificacion_programada_adjunto (
                    id_cia,
                    numint,
                    numite,
                    nombre,
                    formato,
                    archivo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_notificacion_programada_adjunto.id_cia,
                    rec_notificacion_programada_adjunto.numint,
                    rec_notificacion_programada_adjunto.numite,
                    rec_notificacion_programada_adjunto.nombre,
                    rec_notificacion_programada_adjunto.formato,
                    rec_notificacion_programada_adjunto.archivo,
                    rec_notificacion_programada_adjunto.ucreac,
                    rec_notificacion_programada_adjunto.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                rec_notificacion_programada_adjunto.archivo := pin_archivo;
                UPDATE notificacion_programada_adjunto
                SET
                    formato =
                        CASE
                            WHEN rec_notificacion_programada_adjunto.formato IS NULL THEN
                                formato
                            ELSE
                                rec_notificacion_programada_adjunto.formato
                        END,
                    archivo =
                        CASE
                            WHEN rec_notificacion_programada_adjunto.archivo IS NULL THEN
                                archivo
                            ELSE
                                rec_notificacion_programada_adjunto.archivo
                        END,
                    uactua =
                        CASE
                            WHEN rec_notificacion_programada_adjunto.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_notificacion_programada_adjunto.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_notificacion_programada_adjunto.id_cia
                    AND numint = rec_notificacion_programada_adjunto.numint
                    AND numite = rec_notificacion_programada_adjunto.numite;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM notificacion_programada_adjunto
                WHERE
                        id_cia = rec_notificacion_programada_adjunto.id_cia
                    AND numint = rec_notificacion_programada_adjunto.numint
                    AND numite = rec_notificacion_programada_adjunto.numite;

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
                                    || rec_notificacion_programada_adjunto.numint
                                    || ' ] y NUMITE [ '
                                    || rec_notificacion_programada_adjunto.numite
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
                        'message' VALUE 'No se insertar o modificar este registro porque el NUMINT [ '
                                        || rec_notificacion_programada_adjunto.numint
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' formato :'
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
