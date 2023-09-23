--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_TITULOLISTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_TITULOLISTA" AS

    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clases_titulolista
        WHERE
                id_cia = pin_id_cia
            AND clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase;

    FUNCTION sp_buscar_clase (
        pin_id_cia   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clases_titulolista
        WHERE
                id_cia = pin_id_cia
            AND upper(descri) LIKE ( '%'
                                     || upper(pin_desclase)
                                     || '%' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "clase":3,
--                "desclase":"Clase Titulo Lista Prueba",
--                "vreal":"N",
--                "vstrg":"N",
--                "vchar":"N",
--                "vdate":"N",
--                "vtime":"N",
--                "ventero":"N",
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clases_genericas.sp_save_clases_titulolista(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clases_genericas.sp_obtener_clases_titulolista(66,3);
--
--SELECT * FROM pack_clases_genericas.sp_buscar_clases_titulolista(66,'');

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                      json_object_t;
        rec_clases_titulolista clases_titulolista%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clases_titulolista.id_cia := pin_id_cia;
        rec_clases_titulolista.clase := o.get_number('clase');
        rec_clases_titulolista.descri := o.get_string('desclase');
        rec_clases_titulolista.vreal := o.get_string('vreal');
        rec_clases_titulolista.vstrg := o.get_string('vstrg');
        rec_clases_titulolista.vchar := o.get_string('vchar');
        rec_clases_titulolista.vdate := o.get_string('vdate');
        rec_clases_titulolista.vtime := o.get_string('vtime');
        rec_clases_titulolista.ventero := o.get_string('ventero');
        rec_clases_titulolista.swacti := o.get_string('swacti');
        rec_clases_titulolista.codusercrea := o.get_string('ucreac');
        rec_clases_titulolista.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clases_titulolista (
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
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clases_titulolista.id_cia,
                    rec_clases_titulolista.clase,
                    rec_clases_titulolista.descri,
                    rec_clases_titulolista.vreal,
                    rec_clases_titulolista.vstrg,
                    rec_clases_titulolista.vchar,
                    rec_clases_titulolista.vdate,
                    rec_clases_titulolista.vtime,
                    rec_clases_titulolista.ventero,
                    rec_clases_titulolista.swacti,
                    rec_clases_titulolista.codusercrea,
                    rec_clases_titulolista.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clases_titulolista
                SET
                    descri =
                        CASE
                            WHEN rec_clases_titulolista.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clases_titulolista.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clases_titulolista.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clases_titulolista.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clases_titulolista.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clases_titulolista.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clases_titulolista.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clases_titulolista.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clases_titulolista.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clases_titulolista.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clases_titulolista.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clases_titulolista.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clases_titulolista.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clases_titulolista.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clases_titulolista.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clases_titulolista.swacti
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clases_titulolista.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clases_titulolista.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clases_titulolista.id_cia
                    AND clase = rec_clases_titulolista.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clases_titulolista
                WHERE
                        id_cia = rec_clases_titulolista.id_cia
                    AND clase = rec_clases_titulolista.clase;

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
                    'message' VALUE 'El registro con codigo de CLASE [ '
                                    || rec_clases_titulolista.clase
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
            IF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque la CLASE [ '
                                        || rec_clases_titulolista.clase
                                        || ' ] tiene CODIGOS relacionados ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

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
    END sp_save_clase;

    FUNCTION sp_obtener_clase_codigo (
        pin_id_cia NUMBER,
        pin_codtit NUMBER,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.codtit,
            dt.titulo,
            cdcc.clase,
            cdc.descri  AS desclase,
            cdcc.codigo,
            cdcc.descri AS descodigo,
            cdcc.abrevi,
            cdcc.swacti,
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clases_titulolista_codigo cdcc
            LEFT OUTER JOIN clases_titulolista        cdc ON cdc.id_cia = cdcc.id_cia
                                                      AND cdc.clase = cdcc.clase
            LEFT OUTER JOIN titulolista               dt ON dt.id_cia = cdcc.id_cia
                                              AND dt.codtit = cdcc.codtit
        WHERE
                cdcc.id_cia = pin_id_cia
            AND cdcc.codtit = pin_codtit
            AND cdcc.clase = pin_clase
            AND cdcc.codigo = pin_codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase_codigo;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
        pin_codtit    NUMBER,
        pin_clase     NUMBER,
        pin_descodigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.codtit,
            dt.titulo,
            cdcc.clase,
            cdc.descri  AS desclase,
            cdcc.codigo,
            cdcc.descri AS descodigo,
            cdcc.abrevi,
            cdcc.swacti,
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clases_titulolista_codigo cdcc
            LEFT OUTER JOIN clases_titulolista        cdc ON cdc.id_cia = cdcc.id_cia
                                                      AND cdc.clase = cdcc.clase
            LEFT OUTER JOIN titulolista               dt ON dt.id_cia = cdcc.id_cia
                                              AND dt.codtit = cdcc.codtit
        WHERE
                cdcc.id_cia = pin_id_cia
            AND ( pin_codtit IS NULL
                  OR pin_codtit = - 1
                  OR cdcc.codtit = pin_codtit )
            AND ( pin_clase IS NULL
                  OR pin_clase = - 1
                  OR cdcc.clase = pin_clase )
            AND upper(cdcc.descri) LIKE ( '%'
                                          || upper(pin_descodigo)
                                          || '%' );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_codigo;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codtit":1,
--                "clase":3,
--                "codigo":"01",
--                "descodigo":"Codigo del Titulo Lista Prueba",
--                "abrevi":"CODPRV",
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clase_titulolista.sp_save_clase_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_titulolista.sp_obtener_clase_codigo(66,1,3,'01');
--
--SELECT * FROM pack_clase_titulolista.sp_buscar_clase_codigo(66,NULL,NULL,'%');

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                             json_object_t;
        rec_clases_titulolista_codigo clases_titulolista_codigo%rowtype;
        v_accion                      VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clases_titulolista_codigo.id_cia := pin_id_cia;
        rec_clases_titulolista_codigo.codtit := o.get_number('codtit');
        rec_clases_titulolista_codigo.clase := o.get_number('clase');
        rec_clases_titulolista_codigo.codigo := o.get_string('codigo');
        rec_clases_titulolista_codigo.descri := o.get_string('descodigo');
        rec_clases_titulolista_codigo.abrevi := o.get_string('abrevi');
        rec_clases_titulolista_codigo.swacti := o.get_string('swacti');
        rec_clases_titulolista_codigo.codusercrea := o.get_string('ucreac');
        rec_clases_titulolista_codigo.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clases_titulolista_codigo (
                    id_cia,
                    codtit,
                    clase,
                    codigo,
                    descri,
                    abrevi,
                    swacti,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clases_titulolista_codigo.id_cia,
                    rec_clases_titulolista_codigo.codtit,
                    rec_clases_titulolista_codigo.clase,
                    rec_clases_titulolista_codigo.codigo,
                    rec_clases_titulolista_codigo.descri,
                    rec_clases_titulolista_codigo.abrevi,
                    rec_clases_titulolista_codigo.swacti,
                    rec_clases_titulolista_codigo.codusercrea,
                    rec_clases_titulolista_codigo.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clases_titulolista_codigo
                SET
                    descri =
                        CASE
                            WHEN rec_clases_titulolista_codigo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clases_titulolista_codigo.descri
                        END,
                    abrevi =
                        CASE
                            WHEN rec_clases_titulolista_codigo.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_clases_titulolista_codigo.abrevi
                        END,
                    swacti =
                        CASE
                            WHEN rec_clases_titulolista_codigo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clases_titulolista_codigo.swacti
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clases_titulolista_codigo.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clases_titulolista_codigo.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clases_titulolista_codigo.id_cia
                    AND codtit = rec_clases_titulolista_codigo.codtit
                    AND clase = rec_clases_titulolista_codigo.clase
                    AND codigo = rec_clases_titulolista_codigo.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clases_titulolista_codigo
                WHERE
                        id_cia = rec_clases_titulolista_codigo.id_cia
                    AND codtit = rec_clases_titulolista_codigo.codtit
                    AND clase = rec_clases_titulolista_codigo.clase
                    AND codigo = rec_clases_titulolista_codigo.codigo;

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
                    'message' VALUE 'El registro con la CLASE [ '
                                    || rec_clases_titulolista_codigo.clase
                                    || ' ] y CODIGO [ '
                                    || rec_clases_titulolista_codigo.codigo
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
                        'message' VALUE 'No se insertar o modificar este registro porque la con CLASE [ '
                                        || rec_clases_titulolista_codigo.clase
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

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
    END sp_save_clase_codigo;

END;

/
