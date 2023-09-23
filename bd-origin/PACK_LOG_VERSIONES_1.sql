--------------------------------------------------------
--  DDL for Package Body PACK_LOG_VERSIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_LOG_VERSIONES" AS

    FUNCTION sp_obtener (
        pin_id_log NUMBER
    ) RETURN datatable_log_versiones
        PIPELINED
    AS
        v_table datatable_log_versiones;
    BEGIN
        SELECT
            p.id_log,
            p.version,
            p.deslog,
            p.titulo,
            p.notifica,
            p.observ,
            p.fecha,
            p.swacti,
            p.imgnoti,
            p.url_imagen,
            p.fdesde,
            p.fhasta,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            log_versiones p
        WHERE
            p.id_log = pin_id_log;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_deslog VARCHAR2
    ) RETURN datatable_log_versiones
        PIPELINED
    AS
        v_table datatable_log_versiones;
    BEGIN
        SELECT
            p.id_log,
            p.version,
            p.deslog,
            p.titulo,
            p.notifica,
            p.observ,
            p.fecha,
            p.swacti,
            p.imgnoti,
            p.url_imagen,
            p.fdesde,
            p.fhasta,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            log_versiones p
        WHERE
            pin_deslog IS NULL
            OR instr(upper(deslog),
                     upper(pin_deslog)) > 0
        ORDER BY
            p.id_log DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_notificar (
        pin_fdesde DATE
    ) RETURN datatable_log_versiones
        PIPELINED
    AS
        v_table  datatable_log_versiones;
        v_fdesde DATE;
    BEGIN
        IF pin_fdesde IS NULL THEN
            v_fdesde := current_date;
        ELSE
            v_fdesde := pin_fdesde;
        END IF;

        SELECT
            p.id_log,
            p.version,
            p.deslog,
            p.titulo,
            p.notifica,
            p.observ,
            p.fecha,
            p.swacti,
            p.imgnoti,
            p.url_imagen,
            p.fdesde,
            p.fhasta,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            log_versiones p
        WHERE
                p.swacti = 'S'
            AND p.imgnoti IS NOT NULL
            AND trunc(v_fdesde) BETWEEN trunc(p.fdesde) AND trunc(p.fhasta)
        ORDER BY
            p.id_log DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_notificar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "id_log":1,
--                "version":"1.1 - DasbBoard",
--                "deslog":"Actualizacion Prueba",
--                "titulo":"Actualizacion Prueba",
--                "notifica":"Actualizacion Prueba",
--                "fecha":"2022-06-06",
--                "swacti":"S",
--                "fdesde":"2022-01-01",
--                "fhasta":"2022-01-01",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--
--pack_log_versiones.sp_save(NULL,NULL, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--end;
--
--SELECT
--    *
--FROM
--    pack_log_versiones.sp_obtener ( 1 );
--
--SELECT
--    *
--FROM
--    pack_log_versiones.sp_buscar ( NULL );

    PROCEDURE sp_save (
        pin_observ  IN BLOB,
        pin_imgnoti IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                 json_object_t;
        rec_log_versiones log_versiones%rowtype;
        v_accion          VARCHAR2(50) := '';
        pout_mensaje      VARCHAR2(1000) := '';
        v_idmes           NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_log_versiones.id_log := o.get_number('id_log');
        rec_log_versiones.version := o.get_string('version');
        rec_log_versiones.deslog := o.get_string('deslog');
        rec_log_versiones.titulo := o.get_string('titulo');
        rec_log_versiones.notifica := o.get_string('notifica');
        rec_log_versiones.fecha := o.get_date('fecha');
        rec_log_versiones.swacti := o.get_string('swacti');
        rec_log_versiones.url_imagen := o.get_string('url_imagen');
        rec_log_versiones.fdesde := o.get_timestamp('fdesde');
        rec_log_versiones.fhasta := o.get_timestamp('fhasta');
        rec_log_versiones.ucreac := o.get_string('ucreac');
        rec_log_versiones.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                rec_log_versiones.observ := pin_observ;
                rec_log_versiones.imgnoti := pin_imgnoti;
                INSERT INTO log_versiones (
                    id_log,
                    version,
                    deslog,
                    titulo,
                    notifica,
                    observ,
                    fecha,
                    swacti,
                    imgnoti,
                    url_imagen,
                    fdesde,
                    fhasta,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_log_versiones.id_log,
                    rec_log_versiones.version,
                    rec_log_versiones.deslog,
                    rec_log_versiones.titulo,
                    rec_log_versiones.notifica,
                    rec_log_versiones.observ,
                    rec_log_versiones.fecha,
                    rec_log_versiones.swacti,
                    rec_log_versiones.imgnoti,
                    rec_log_versiones.url_imagen,
                    rec_log_versiones.fdesde,
                    rec_log_versiones.fhasta,
                    rec_log_versiones.ucreac,
                    rec_log_versiones.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                rec_log_versiones.observ := pin_observ;
                rec_log_versiones.imgnoti := pin_imgnoti;
                UPDATE log_versiones
                SET
                    version =
                        CASE
                            WHEN rec_log_versiones.version IS NULL THEN
                                version
                            ELSE
                                rec_log_versiones.version
                        END,
                    deslog =
                        CASE
                            WHEN rec_log_versiones.deslog IS NULL THEN
                                deslog
                            ELSE
                                rec_log_versiones.deslog
                        END,
                    titulo =
                        CASE
                            WHEN rec_log_versiones.titulo IS NULL THEN
                                titulo
                            ELSE
                                rec_log_versiones.titulo
                        END,
                    notifica =
                        CASE
                            WHEN rec_log_versiones.notifica IS NULL THEN
                                notifica
                            ELSE
                                rec_log_versiones.notifica
                        END,
                    observ =
                        CASE
                            WHEN rec_log_versiones.observ IS NULL THEN
                                observ
                            ELSE
                                rec_log_versiones.observ
                        END,
                    fecha =
                        CASE
                            WHEN rec_log_versiones.fecha IS NULL THEN
                                fecha
                            ELSE
                                rec_log_versiones.fecha
                        END,
                    swacti =
                        CASE
                            WHEN rec_log_versiones.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_log_versiones.swacti
                        END,
                    imgnoti =
                        CASE
                            WHEN rec_log_versiones.imgnoti IS NULL THEN
                                imgnoti
                            ELSE
                                rec_log_versiones.imgnoti
                        END,
                    url_imagen =
                        CASE
                            WHEN rec_log_versiones.url_imagen IS NULL THEN
                                url_imagen
                            ELSE
                                rec_log_versiones.url_imagen
                        END,
                    fdesde =
                        CASE
                            WHEN rec_log_versiones.fdesde IS NULL THEN
                                fdesde
                            ELSE
                                rec_log_versiones.fdesde
                        END,
                    fhasta =
                        CASE
                            WHEN rec_log_versiones.fhasta IS NULL THEN
                                fhasta
                            ELSE
                                rec_log_versiones.fhasta
                        END,
                    uactua =
                        CASE
                            WHEN rec_log_versiones.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_log_versiones.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                    id_log = rec_log_versiones.id_log;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM log_versiones
                WHERE
                    id_log = rec_log_versiones.id_log;

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
                    'message' VALUE 'El registro con codigo de version [ '
                                    || rec_log_versiones.id_log
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

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                NULL;
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

            END IF;
    END sp_save;

END;

/
