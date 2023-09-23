--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_PCUENTAS" AS

    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            id_cia,
            clase,
            descri AS desclase,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            obliga,
            ucreac AS ucreac,
            usuari AS uactua,
            fcreac,
            factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_pcuentas
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
            id_cia,
            clase,
            descri AS desclase,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            obliga,
            ucreac AS ucreac,
            usuari AS uactua,
            fcreac,
            factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_pcuentas
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
--                "clase":100,
--                "desclase":"Clase Pcuentas Prueba",
--                "vreal":"S",
--                "vstrg":"S",
--                "vchar":"S",
--                "vdate":"S",
--                "vtime":"S",
--                "ventero":"N",
--                "swacti":"S",
--                "obliga":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clase_pcuentas.sp_save_clase(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_pcuentas.sp_obtener_clase(66,100);
--
--SELECT * FROM pack_clase_pcuentas.sp_buscar_clase(66,'%PRUEBA');

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                  json_object_t;
        rec_clase_pcuentas clase_pcuentas%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_pcuentas.id_cia := pin_id_cia;
        rec_clase_pcuentas.clase := o.get_number('clase');
        rec_clase_pcuentas.descri := o.get_string('desclase');
        rec_clase_pcuentas.vreal := o.get_string('vreal');
        rec_clase_pcuentas.vstrg := o.get_string('vstrg');
        rec_clase_pcuentas.vchar := o.get_string('vchar');
        rec_clase_pcuentas.vdate := o.get_string('vdate');
        rec_clase_pcuentas.vtime := o.get_string('vtime');
        rec_clase_pcuentas.ventero := o.get_string('ventero');
        rec_clase_pcuentas.swacti := o.get_string('swacti');
        rec_clase_pcuentas.obliga := o.get_string('obliga');
        rec_clase_pcuentas.ucreac := o.get_string('ucreac');
        rec_clase_pcuentas.usuari := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_pcuentas (
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
                    ucreac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_pcuentas.id_cia,
                    rec_clase_pcuentas.clase,
                    rec_clase_pcuentas.descri,
                    rec_clase_pcuentas.vreal,
                    rec_clase_pcuentas.vstrg,
                    rec_clase_pcuentas.vchar,
                    rec_clase_pcuentas.vdate,
                    rec_clase_pcuentas.vtime,
                    rec_clase_pcuentas.ventero,
                    rec_clase_pcuentas.swacti,
                    rec_clase_pcuentas.obliga,
                    rec_clase_pcuentas.ucreac,
                    rec_clase_pcuentas.usuari,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_pcuentas
                SET
                    descri =
                        CASE
                            WHEN rec_clase_pcuentas.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_pcuentas.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_pcuentas.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_pcuentas.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_pcuentas.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_pcuentas.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_pcuentas.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_pcuentas.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_pcuentas.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_pcuentas.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_pcuentas.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_pcuentas.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_pcuentas.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_pcuentas.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_pcuentas.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_pcuentas.swacti
                        END,
                    obliga =
                        CASE
                            WHEN rec_clase_pcuentas.obliga IS NULL THEN
                                obliga
                            ELSE
                                rec_clase_pcuentas.obliga
                        END,
                    usuari =
                        CASE
                            WHEN rec_clase_pcuentas.usuari IS NULL THEN
                                ''
                            ELSE
                                rec_clase_pcuentas.usuari
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_pcuentas.id_cia
                    AND clase = rec_clase_pcuentas.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_pcuentas
                WHERE
                        id_cia = rec_clase_pcuentas.id_cia
                    AND clase = rec_clase_pcuentas.clase;

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
                                    || rec_clase_pcuentas.clase
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
                                        || rec_clase_pcuentas.clase
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
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_pcuentas_codigo cdcc
            LEFT OUTER JOIN clase_pcuentas        cdc ON cdc.id_cia = cdcc.id_cia
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
        pin_clase     NUMBER,
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
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_pcuentas_codigo cdcc
            LEFT OUTER JOIN clase_pcuentas        cdc ON cdc.id_cia = cdcc.id_cia
                                                  AND cdc.clase = cdcc.clase
        WHERE
                cdcc.id_cia = pin_id_cia
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
--                "clase":100,
--                "codigo":"01",
--                "descodigo":"Codigo del PCuentas Prueba",
--                "abrevi":"CODPRV",
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clase_pcuentas.sp_save_clase_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_pcuentas.sp_obtener_clase_codigo(66,100,'01');
--
--SELECT * FROM pack_clase_pcuentas.sp_buscar_clase_codigo(66,5,'%');

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                         json_object_t;
        rec_clase_pcuentas_codigo clase_pcuentas_codigo%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_pcuentas_codigo.id_cia := pin_id_cia;
        rec_clase_pcuentas_codigo.clase := o.get_number('clase');
        rec_clase_pcuentas_codigo.codigo := o.get_string('codigo');
        rec_clase_pcuentas_codigo.descri := o.get_string('descodigo');
        rec_clase_pcuentas_codigo.abrevi := o.get_string('abrevi');
        rec_clase_pcuentas_codigo.swacti := o.get_string('swacti');
        rec_clase_pcuentas_codigo.codusercrea := o.get_string('ucreac');
        rec_clase_pcuentas_codigo.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_pcuentas_codigo (
                    id_cia,
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
                    rec_clase_pcuentas_codigo.id_cia,
                    rec_clase_pcuentas_codigo.clase,
                    rec_clase_pcuentas_codigo.codigo,
                    rec_clase_pcuentas_codigo.descri,
                    rec_clase_pcuentas_codigo.abrevi,
                    rec_clase_pcuentas_codigo.swacti,
                    rec_clase_pcuentas_codigo.codusercrea,
                    rec_clase_pcuentas_codigo.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_pcuentas_codigo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_pcuentas_codigo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_pcuentas_codigo.descri
                        END,
                    abrevi =
                        CASE
                            WHEN rec_clase_pcuentas_codigo.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_clase_pcuentas_codigo.abrevi
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_pcuentas_codigo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_pcuentas_codigo.swacti
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_pcuentas_codigo.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_pcuentas_codigo.coduseractu
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_pcuentas_codigo.id_cia
                    AND clase = rec_clase_pcuentas_codigo.clase
                    AND codigo = rec_clase_pcuentas_codigo.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_pcuentas_codigo
                WHERE
                        id_cia = rec_clase_pcuentas_codigo.id_cia
                    AND clase = rec_clase_pcuentas_codigo.clase
                    AND codigo = rec_clase_pcuentas_codigo.codigo;

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
                                    || rec_clase_pcuentas_codigo.clase
                                    || ' ] y CODIGO [ '
                                    || rec_clase_pcuentas_codigo.codigo
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
                                        || rec_clase_pcuentas_codigo.clase
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
