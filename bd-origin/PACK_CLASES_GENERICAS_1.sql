--------------------------------------------------------
--  DDL for Package Body PACK_CLASES_GENERICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASES_GENERICAS" AS

    FUNCTION sp_obtener_clase_articulos_alternativo (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase_articulos_alternativo
        PIPELINED
    AS
        v_table datatable_clase_articulos_alternativo;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_articulos_alternativo
        WHERE
                id_cia = pin_id_cia
            AND clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase_articulos_alternativo;

    FUNCTION sp_buscar_clase_articulos_alternativo (
        pin_id_cia   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase_articulos_alternativo
        PIPELINED
    AS
        v_table datatable_clase_articulos_alternativo;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_articulos_alternativo
        WHERE
                id_cia = pin_id_cia
            AND ( instr(upper(descri), upper(pin_desclase)) > 0
                  OR pin_desclase IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_articulos_alternativo;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "clase":3,
--                "desclase":"Unidad de Medida Prueba",
--                "vreal":"N",
--                "vstrg":"N",
--                "vchar":"N",
--                "vdate":"N",
--                "vtime":"N",
--                "ventero":"N",
--                "swacti":"S",
--                "obliga":"N",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clases_genericas.sp_save_clase_articulos_alternativo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clases_genericas.sp_obtener_clase_articulos_alternativo(66,3);
--
--SELECT * FROM pack_clases_genericas.sp_buscar_clase_articulos_alternativo(66,'');

    PROCEDURE sp_save_clase_articulos_alternativo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                               json_object_t;
        rec_clase_articulos_alternativo clase_articulos_alternativo%rowtype;
        v_accion                        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_articulos_alternativo.id_cia := pin_id_cia;
        rec_clase_articulos_alternativo.clase := o.get_number('clase');
        rec_clase_articulos_alternativo.descri := o.get_string('desclase');
        rec_clase_articulos_alternativo.vreal := o.get_string('vreal');
        rec_clase_articulos_alternativo.vstrg := o.get_string('vstrg');
        rec_clase_articulos_alternativo.vchar := o.get_string('vchar');
        rec_clase_articulos_alternativo.vdate := o.get_string('vdate');
        rec_clase_articulos_alternativo.vtime := o.get_string('vtime');
        rec_clase_articulos_alternativo.ventero := o.get_string('ventero');
        rec_clase_articulos_alternativo.swacti := o.get_string('swacti');
        rec_clase_articulos_alternativo.obliga := o.get_string('obliga');
        rec_clase_articulos_alternativo.codusercrea := o.get_string('ucreac');
        rec_clase_articulos_alternativo.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_articulos_alternativo (
                    id_cia,
                    clase,
                    descri,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    swacti,
                    obliga,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_articulos_alternativo.id_cia,
                    rec_clase_articulos_alternativo.clase,
                    rec_clase_articulos_alternativo.descri,
                    rec_clase_articulos_alternativo.vreal,
                    rec_clase_articulos_alternativo.vstrg,
                    rec_clase_articulos_alternativo.vchar,
                    rec_clase_articulos_alternativo.vdate,
                    rec_clase_articulos_alternativo.vtime,
                    rec_clase_articulos_alternativo.ventero,
                    rec_clase_articulos_alternativo.swacti,
                    rec_clase_articulos_alternativo.obliga,
                    rec_clase_articulos_alternativo.codusercrea,
                    rec_clase_articulos_alternativo.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_articulos_alternativo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_articulos_alternativo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_articulos_alternativo.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_articulos_alternativo.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_articulos_alternativo.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_articulos_alternativo.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_articulos_alternativo.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_articulos_alternativo.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_articulos_alternativo.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_articulos_alternativo.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_articulos_alternativo.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_articulos_alternativo.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_articulos_alternativo.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_articulos_alternativo.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_articulos_alternativo.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_articulos_alternativo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_articulos_alternativo.swacti
                        END,
                    obliga =
                        CASE
                            WHEN rec_clase_articulos_alternativo.obliga IS NULL THEN
                                obliga
                            ELSE
                                rec_clase_articulos_alternativo.obliga
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_articulos_alternativo.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_articulos_alternativo.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_articulos_alternativo.id_cia
                    AND clase = rec_clase_articulos_alternativo.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_articulos_alternativo
                WHERE
                        id_cia = rec_clase_articulos_alternativo.id_cia
                    AND clase = rec_clase_articulos_alternativo.clase;

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
                    'message' VALUE 'El registro con codigo de clase [ '
                                    || rec_clase_articulos_alternativo.clase
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
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el Codigo de Personal [ '
--                                        || rec_clase_articulos_alternativo.clase
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
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
    END sp_save_clase_articulos_alternativo;

    FUNCTION sp_obtener_clase_tdoccobranza (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase_tdoccobranza
        PIPELINED
    AS
        v_table datatable_clase_tdoccobranza;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_tdoccobranza
        WHERE
                id_cia = pin_id_cia
            AND tipdoc = pin_tipdoc
            AND clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase_tdoccobranza;

    FUNCTION sp_buscar_clase_tdoccobranza (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase_tdoccobranza
        PIPELINED
    AS
        v_table datatable_clase_tdoccobranza;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_tdoccobranza
        WHERE
                id_cia = pin_id_cia
            AND ( pin_tipdoc IS NULL
                  OR tipdoc = pin_tipdoc )
            AND ( instr(upper(descri), upper(pin_desclase)) > 0
                  OR pin_desclase IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_tdoccobranza;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "tipdoc":1,
--                "clase":99,
--                "desclase":"Unidad de Medida Prueba",
--                "vreal":"S",
--                "vstrg":"N",
--                "vchar":"S",
--                "vdate":"N",
--                "vtime":"S",
--                "ventero":"N",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clases_genericas.sp_save_clase_tdoccobranza(66, cadjson, 3, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clases_genericas.sp_obtener_clase_tdoccobranza(66,1,99);
--
--SELECT * FROM pack_clases_genericas.sp_buscar_clase_tdoccobranza(66,NULL,NULL);

    PROCEDURE sp_save_clase_tdoccobranza (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                      json_object_t;
        rec_clase_tdoccobranza clase_tdoccobranza%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_tdoccobranza.id_cia := pin_id_cia;
        rec_clase_tdoccobranza.clase := o.get_number('clase');
        rec_clase_tdoccobranza.tipdoc := o.get_number('tipdoc');
        rec_clase_tdoccobranza.descri := o.get_string('desclase');
        rec_clase_tdoccobranza.vreal := o.get_string('vreal');
        rec_clase_tdoccobranza.vstrg := o.get_string('vstrg');
        rec_clase_tdoccobranza.vchar := o.get_string('vchar');
        rec_clase_tdoccobranza.vdate := o.get_string('vdate');
        rec_clase_tdoccobranza.vtime := o.get_string('vtime');
        rec_clase_tdoccobranza.ventero := o.get_string('ventero');
        rec_clase_tdoccobranza.swacti := o.get_string('swacti');
--        rec_clase_tdoccobranza.obliga := o.get_string('obliga');
        rec_clase_tdoccobranza.codusercrea := o.get_string('ucreac');
        rec_clase_tdoccobranza.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_tdoccobranza (
                    id_cia,
                    clase,
                    tipdoc,
                    descri,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    swacti,
--                    obliga,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_tdoccobranza.id_cia,
                    rec_clase_tdoccobranza.clase,
                    rec_clase_tdoccobranza.tipdoc,
                    rec_clase_tdoccobranza.descri,
                    rec_clase_tdoccobranza.vreal,
                    rec_clase_tdoccobranza.vstrg,
                    rec_clase_tdoccobranza.vchar,
                    rec_clase_tdoccobranza.vdate,
                    rec_clase_tdoccobranza.vtime,
                    rec_clase_tdoccobranza.ventero,
                    rec_clase_tdoccobranza.swacti,
--                    rec_clase_tdoccobranza.obliga,
                    rec_clase_tdoccobranza.codusercrea,
                    rec_clase_tdoccobranza.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_tdoccobranza
                SET
                    descri =
                        CASE
                            WHEN rec_clase_tdoccobranza.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_tdoccobranza.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_tdoccobranza.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_tdoccobranza.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_tdoccobranza.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_tdoccobranza.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_tdoccobranza.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_tdoccobranza.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_tdoccobranza.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_tdoccobranza.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_tdoccobranza.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_tdoccobranza.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_tdoccobranza.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_tdoccobranza.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_tdoccobranza.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_tdoccobranza.swacti
                        END,
--                    obliga =
--                        CASE
--                            WHEN rec_clase_tdoccobranza.obliga IS NULL THEN
--                                obliga
--                            ELSE
--                                rec_clase_tdoccobranza.obliga
--                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_tdoccobranza.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_tdoccobranza.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_tdoccobranza.id_cia
                    AND tipdoc = rec_clase_tdoccobranza.tipdoc
                    AND clase = rec_clase_tdoccobranza.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_tdoccobranza
                WHERE
                        id_cia = rec_clase_tdoccobranza.id_cia
                    AND tipdoc = rec_clase_tdoccobranza.tipdoc
                    AND clase = rec_clase_tdoccobranza.clase;

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
                    'message' VALUE 'El registro con codigo de clase [ '
                                    || rec_clase_tdoccobranza.clase
                                    || ' ] para el Tipo de Documento [ '
                                    || rec_clase_tdoccobranza.tipdoc
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
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el Codigo de Personal [ '
--                                        || rec_clase_tdoccobranza.clase
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
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
    END sp_save_clase_tdoccobranza;

    FUNCTION sp_obtener_clases_tdocume (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clases_tdocume
        PIPELINED
    AS
        v_table datatable_clases_tdocume;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clases_tdocume
        WHERE
                id_cia = pin_id_cia
            AND clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clases_tdocume;

    FUNCTION sp_buscar_clases_tdocume (
        pin_id_cia   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clases_tdocume
        PIPELINED
    AS
        v_table datatable_clases_tdocume;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clases_tdocume
        WHERE
                id_cia = pin_id_cia
            AND ( instr(upper(descri), upper(pin_desclase)) > 0
                  OR pin_desclase IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clases_tdocume;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "clase":3,
--                "desclase":"Unidad de Medida Prueba",
--                "vreal":"N",
--                "vstrg":"N",
--                "vchar":"N",
--                "vdate":"N",
--                "vtime":"N",
--                "ventero":"N",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clases_genericas.sp_save_clases_tdocume(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clases_genericas.sp_obtener_clases_tdocume(66,3);
--
--SELECT * FROM pack_clases_genericas.sp_buscar_clases_tdocume(66,'');

    PROCEDURE sp_save_clases_tdocume (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                  json_object_t;
        rec_clases_tdocume clases_tdocume%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clases_tdocume.id_cia := pin_id_cia;
        rec_clases_tdocume.clase := o.get_number('clase');
        rec_clases_tdocume.descri := o.get_string('desclase');
        rec_clases_tdocume.vreal := o.get_string('vreal');
        rec_clases_tdocume.vstrg := o.get_string('vstrg');
        rec_clases_tdocume.vchar := o.get_string('vchar');
        rec_clases_tdocume.vdate := o.get_string('vdate');
        rec_clases_tdocume.vtime := o.get_string('vtime');
        rec_clases_tdocume.ventero := o.get_string('ventero');
        rec_clases_tdocume.swacti := o.get_string('swacti');
--        rec_clases_tdocume.obliga := o.get_string('obliga');
        rec_clases_tdocume.codusercrea := o.get_string('ucreac');
        rec_clases_tdocume.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clases_tdocume (
                    id_cia,
                    clase,
                    descri,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    swacti,
--                    obliga,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clases_tdocume.id_cia,
                    rec_clases_tdocume.clase,
                    rec_clases_tdocume.descri,
                    rec_clases_tdocume.vreal,
                    rec_clases_tdocume.vstrg,
                    rec_clases_tdocume.vchar,
                    rec_clases_tdocume.vdate,
                    rec_clases_tdocume.vtime,
                    rec_clases_tdocume.ventero,
                    rec_clases_tdocume.swacti,
--                    rec_clases_tdocume.obliga,
                    rec_clases_tdocume.codusercrea,
                    rec_clases_tdocume.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clases_tdocume
                SET
                    descri =
                        CASE
                            WHEN rec_clases_tdocume.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clases_tdocume.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clases_tdocume.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clases_tdocume.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clases_tdocume.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clases_tdocume.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clases_tdocume.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clases_tdocume.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clases_tdocume.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clases_tdocume.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clases_tdocume.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clases_tdocume.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clases_tdocume.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clases_tdocume.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clases_tdocume.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clases_tdocume.swacti
                        END,
--                    obliga =
--                        CASE
--                            WHEN rec_clases_tdocume.obliga IS NULL THEN
--                                obliga
--                            ELSE
--                                rec_clases_tdocume.obliga
--                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clases_tdocume.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clases_tdocume.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clases_tdocume.id_cia
                    AND clase = rec_clases_tdocume.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clases_tdocume
                WHERE
                        id_cia = rec_clases_tdocume.id_cia
                    AND clase = rec_clases_tdocume.clase;

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
                    'message' VALUE 'El registro con codigo de clase [ '
                                    || rec_clases_tdocume.clase
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
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el Codigo de Personal [ '
--                                        || rec_clases_tdocume.clase
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
--
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
    END sp_save_clases_tdocume;

END;

/
