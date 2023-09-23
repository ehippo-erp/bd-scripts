--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_DOCUMENTOS_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_TIPO" AS

    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            cdc.id_cia,
            cdc.clase,
            cdc.descri,
            cdc.vreal,
            cdc.vstrg,
            cdc.vchar,
            cdc.vdate,
            cdc.vtime,
            cdc.ventero,
            cdc.swacti,
            cdc.swcodigo,
            cdc.ucreac,
            cdc.uactua,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_tipo cdc
        WHERE
                cdc.id_cia = pin_id_cia
            AND cdc.clase = pin_clase;

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
            cdc.id_cia,
            cdc.clase,
            cdc.descri,
            cdc.vreal,
            cdc.vstrg,
            cdc.vchar,
            cdc.vdate,
            cdc.vtime,
            cdc.ventero,
            cdc.swacti,
            cdc.swcodigo,
            cdc.ucreac,
            cdc.uactua,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_tipo cdc
        WHERE
                cdc.id_cia = pin_id_cia
            AND upper(cdc.descri) LIKE ( '%'
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
--                "clase":1,
--                "desclase":"Clase de Documentos Tipo - Prueba",
--                "vreal":"S",
--                "vstrg":"N",
--                "vchar":"N",
--                "vdate":"N",
--                "vtime":"N",
--                "ventero":"N",
--                "swacti":"N",
--                "swcodigo":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--                
--pack_clase_documentos_tipo.sp_save_clase(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_tipo.sp_obtener_clase(66,1);
--
--SELECT * FROM pack_clase_documentos_tipo.sp_buscar_clase(66,'%Tipo%');


    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                         json_object_t;
        rec_clase_documentos_tipo clase_documentos_tipo%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_tipo.id_cia := pin_id_cia;
        rec_clase_documentos_tipo.clase := o.get_number('clase');
        rec_clase_documentos_tipo.descri := o.get_string('desclase');
        rec_clase_documentos_tipo.vreal := o.get_string('vreal');
        rec_clase_documentos_tipo.vstrg := o.get_string('vstrg');
        rec_clase_documentos_tipo.vchar := o.get_string('vchar');
        rec_clase_documentos_tipo.vdate := o.get_string('vdate');
        rec_clase_documentos_tipo.vtime := o.get_string('vtime');
        rec_clase_documentos_tipo.ventero := o.get_string('ventero');
        rec_clase_documentos_tipo.swacti := o.get_string('swacti');
        rec_clase_documentos_tipo.swcodigo := o.get_string('swcodigo');
        rec_clase_documentos_tipo.ucreac := o.get_string('ucreac');
        rec_clase_documentos_tipo.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_tipo (
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
                    swcodigo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_documentos_tipo.id_cia,
                    rec_clase_documentos_tipo.clase,
                    rec_clase_documentos_tipo.descri,
                    rec_clase_documentos_tipo.vreal,
                    rec_clase_documentos_tipo.vstrg,
                    rec_clase_documentos_tipo.vchar,
                    rec_clase_documentos_tipo.vdate,
                    rec_clase_documentos_tipo.vtime,
                    rec_clase_documentos_tipo.ventero,
                    rec_clase_documentos_tipo.swacti,
                    rec_clase_documentos_tipo.swcodigo,
                    rec_clase_documentos_tipo.ucreac,
                    rec_clase_documentos_tipo.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_tipo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_tipo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_tipo.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_documentos_tipo.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_documentos_tipo.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_documentos_tipo.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_documentos_tipo.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_documentos_tipo.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_documentos_tipo.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_documentos_tipo.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_documentos_tipo.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_documentos_tipo.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_documentos_tipo.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_documentos_tipo.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_documentos_tipo.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_tipo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_tipo.swacti
                        END,
                    swcodigo =
                        CASE
                            WHEN rec_clase_documentos_tipo.swcodigo IS NULL THEN
                                swcodigo
                            ELSE
                                rec_clase_documentos_tipo.swcodigo
                        END,
                    uactua =
                        CASE
                            WHEN rec_clase_documentos_tipo.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_tipo.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_tipo.id_cia
                    AND clase = rec_clase_documentos_tipo.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_tipo
                WHERE
                        id_cia = rec_clase_documentos_tipo.id_cia
                    AND clase = rec_clase_documentos_tipo.clase;

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
                    'message' VALUE 'El registro con CLASE [ '
                                    || rec_clase_documentos_tipo.clase
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
                        'message' VALUE 'No se puede modificar o eliminar la CLASE [ '
                                        || rec_clase_documentos_tipo.clase
                                        || ' ] porque tiene registros relacionados ...! '
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
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.clase,
            cdc.descri  AS desclase,
            cdcc.codigo,
            cdcc.descri AS descodigo,
            cdcc.abrevi,
            cdcc.swacti,
            cdcc.ucreac,
            cdcc.uactua,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_tipo_codigo cdcc
            LEFT OUTER JOIN clase_documentos_tipo        cdc ON cdc.id_cia = cdcc.id_cia
                                                         AND cdc.clase = cdcc.clase
        WHERE
                cdcc.id_cia = pin_id_cia
            AND cdcc.clase = pin_clase
            AND cdcc.codigo = pin_codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase_codigo;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
        pin_descodigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.clase,
            cdc.descri  AS desclase,
            cdcc.codigo,
            cdcc.descri AS descodigo,
            cdcc.abrevi,
            cdcc.swacti,
            cdcc.ucreac,
            cdcc.uactua,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_tipo_codigo cdcc
            LEFT OUTER JOIN clase_documentos_tipo        cdc ON cdc.id_cia = cdcc.id_cia
                                                         AND cdc.clase = cdcc.clase
        WHERE
                cdcc.id_cia = pin_id_cia
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
--                "clase":1,
--                "codigo":"01",
--                "descodigo":"Codigo de Documentos Tipo - Prueba",
--                "abrevi":"CODPRV",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clase_documentos_tipo.sp_save_clase_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_tipo.sp_obtener_clase_codigo(66,1,'01');
--
--SELECT * FROM pack_clase_documentos_tipo.sp_buscar_clase_codigo(66,'%Tipo%');

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                                json_object_t;
        rec_clase_documentos_tipo_codigo clase_documentos_tipo_codigo%rowtype;
        v_accion                         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_tipo_codigo.id_cia := pin_id_cia;
        rec_clase_documentos_tipo_codigo.clase := o.get_number('clase');
        rec_clase_documentos_tipo_codigo.codigo := o.get_string('codigo');
        rec_clase_documentos_tipo_codigo.descri := o.get_string('descodigo');
        rec_clase_documentos_tipo_codigo.abrevi := o.get_string('abrevi');
        rec_clase_documentos_tipo_codigo.swacti := o.get_string('swacti');
        rec_clase_documentos_tipo_codigo.ucreac := o.get_string('ucreac');
        rec_clase_documentos_tipo_codigo.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_tipo_codigo (
                    id_cia,
                    clase,
                    codigo,
                    descri,
                    abrevi,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_documentos_tipo_codigo.id_cia,
                    rec_clase_documentos_tipo_codigo.clase,
                    rec_clase_documentos_tipo_codigo.codigo,
                    rec_clase_documentos_tipo_codigo.descri,
                    rec_clase_documentos_tipo_codigo.abrevi,
                    rec_clase_documentos_tipo_codigo.swacti,
                    rec_clase_documentos_tipo_codigo.ucreac,
                    rec_clase_documentos_tipo_codigo.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_tipo_codigo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_tipo_codigo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_tipo_codigo.descri
                        END,
                    abrevi =
                        CASE
                            WHEN rec_clase_documentos_tipo_codigo.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_clase_documentos_tipo_codigo.abrevi
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_tipo_codigo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_tipo_codigo.swacti
                        END,
                    uactua =
                        CASE
                            WHEN rec_clase_documentos_tipo_codigo.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_tipo_codigo.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_tipo_codigo.id_cia
                    AND clase = rec_clase_documentos_tipo_codigo.clase
                    AND codigo = rec_clase_documentos_tipo_codigo.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_tipo_codigo
                WHERE
                        id_cia = rec_clase_documentos_tipo_codigo.id_cia
                    AND clase = rec_clase_documentos_tipo_codigo.clase
                    AND codigo = rec_clase_documentos_tipo_codigo.codigo;

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
                    'message' VALUE 'El registro con CLASE [ '
                                    || rec_clase_documentos_tipo_codigo.clase
                                    || ' ] y CODIGO [ '
                                    || rec_clase_documentos_tipo_codigo.codigo
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
                        'message' VALUE 'No se insertar o modificar este registro porque la CLASE [ '
                                        || rec_clase_documentos_tipo_codigo.clase
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
