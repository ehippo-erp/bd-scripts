--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_CAB" AS

    FUNCTION sp_buscar_clase_cabecera (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_obliga VARCHAR2
    ) RETURN datatable_clase_cabecera
        PIPELINED
    AS
        v_table datatable_clase_cabecera;
    BEGIN
        SELECT
            c.id_cia,
            c.clase,
            c.descri  AS desclase,
            CASE
                WHEN c.vreal = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vreal,
            CASE
                WHEN c.vstrg = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vstrg,
            CASE
                WHEN c.vchar = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vchar,
            CASE
                WHEN c.vdate = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vdate,
            CASE
                WHEN c.vtime = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vtime,
            CASE
                WHEN c.ventero = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS ventero,
            CASE
                WHEN c.vblob = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS vglosa,
            CASE
                WHEN c.obliga = 'S' THEN
                    'true'
                ELSE
                    'false'
            END       AS obligatorio,
            cc.codigo AS codigo,
            cc.descri AS descodigo
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_cab        c
            LEFT OUTER JOIN clase_documentos_cab_codigo cc ON cc.id_cia = c.id_cia
                                                              AND cc.tipdoc = c.tipdoc
                                                              AND cc.clase = c.clase
                                                              AND cc.codigo <> 'ND'
                                                              AND cc.swacti = 'S'
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = pin_tipdoc
            AND c.swacti = 'S'
            AND c.editable = 'S'
            AND ( pin_obliga IS NULL
                  OR c.obliga = 'S' )
        ORDER BY
            c.clase,
            cc.codigo ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_clase_cabecera;

    PROCEDURE sp_valida_clases_obligatoria (
        pin_id_cia  NUMBER,
        pin_tipdoc  NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_texto VARCHAR2(3000) := '';
    BEGIN
        FOR i IN (
            SELECT
                descri
            FROM
                clase_documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND obliga = 'S'
        ) LOOP
            v_texto := v_texto
                       || i.descri
                       || ',';
        END LOOP;

        v_texto := substr(v_texto, 1, length(v_texto) - 1);
        IF length(v_texto) > 0 THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'Documento con clases obligatorias ...!',
                    'obliga' VALUE v_texto
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSE
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Documento sin clases obligatorias ...!',
                    'obliga' VALUE ''
                )
            INTO pin_mensaje
            FROM
                dual;

        END IF;

        COMMIT;
    EXCEPTION
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

    END sp_valida_clases_obligatoria;

    FUNCTION sp_obtener_clase (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_clase  NUMBER
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            cdc.id_cia,
            cdc.tipdoc,
            dt.descri,
            cdc.clase,
            cdc.descri,
            cdc.vreal,
            cdc.vstrg,
            cdc.vchar,
            cdc.vdate,
            cdc.vtime,
            cdc.ventero,
            cdc.vblob,
            cdc.swacti,
            cdc.obliga,
            cdc.editable,
            cdc.swcodigo,
            cdc.codusercrea,
            cdc.coduseractu,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_cab cdc
            LEFT OUTER JOIN documentos_tipo      dt ON dt.id_cia = cdc.id_cia
                                                  AND dt.tipdoc = cdc.tipdoc
        WHERE
                cdc.id_cia = pin_id_cia
            AND cdc.tipdoc = pin_tipdoc
            AND cdc.clase = pin_clase;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase;

    FUNCTION sp_buscar_clase (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_desclase VARCHAR2
    ) RETURN datatable_clase
        PIPELINED
    AS
        v_table datatable_clase;
    BEGIN
        SELECT
            cdc.id_cia,
            cdc.tipdoc,
            dt.descri,
            cdc.clase,
            cdc.descri,
            cdc.vreal,
            cdc.vstrg,
            cdc.vchar,
            cdc.vdate,
            cdc.vtime,
            cdc.ventero,
            cdc.vblob,
            cdc.swacti,
            cdc.obliga,
            cdc.editable,
            cdc.swcodigo,
            cdc.codusercrea,
            cdc.coduseractu,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_cab cdc
            LEFT OUTER JOIN documentos_tipo      dt ON dt.id_cia = cdc.id_cia
                                                  AND dt.tipdoc = cdc.tipdoc
        WHERE
                cdc.id_cia = pin_id_cia
            AND ( pin_tipdoc IS NULL
                  OR pin_tipdoc = - 1
                  OR cdc.tipdoc = pin_tipdoc )
            AND ( pin_desclase IS NULL
                  OR upper(cdc.descri) LIKE ( '%'
                                              || upper(pin_desclase)
                                              || '%' ) );

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
--                "tipdoc":1,
--                "clase":100,
--                "desclase":"Clase Documentos-Cab de Prueba",
--                "vreal":"S",
--                "vstrg":"S",
--                "vchar":"S",
--                "vdate":"S",
--                "vtime":"S",
--                "ventero":"N",
--                "vblob":"S",
--                "swacti":"S",
--                "obliga":"S",
--                "editable":"S",
--                "swcodigo":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clase_documentos_cab.sp_save_clase(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_cab.sp_obtener_clase(66,1,100);
--
--SELECT * FROM pack_clase_documentos_cab.sp_buscar_clase(66,1,'%clase');

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                        json_object_t;
        rec_clase_documentos_cab clase_documentos_cab%rowtype;
        v_accion                 VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_cab.id_cia := pin_id_cia;
        rec_clase_documentos_cab.tipdoc := o.get_number('tipdoc');
        rec_clase_documentos_cab.clase := o.get_number('clase');
        rec_clase_documentos_cab.descri := o.get_string('desclase');
        rec_clase_documentos_cab.vreal := o.get_string('vreal');
        rec_clase_documentos_cab.vstrg := o.get_string('vstrg');
        rec_clase_documentos_cab.vchar := o.get_string('vchar');
        rec_clase_documentos_cab.vdate := o.get_string('vdate');
        rec_clase_documentos_cab.vtime := o.get_string('vtime');
        rec_clase_documentos_cab.ventero := o.get_string('ventero');
        rec_clase_documentos_cab.vblob := o.get_string('vblob');
        rec_clase_documentos_cab.swacti := o.get_string('swacti');
        rec_clase_documentos_cab.obliga := o.get_string('obliga');
        rec_clase_documentos_cab.editable := o.get_string('editable');
        rec_clase_documentos_cab.swcodigo := o.get_string('swcodigo');
        rec_clase_documentos_cab.codusercrea := o.get_string('ucreac');
        rec_clase_documentos_cab.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_cab (
                    id_cia,
                    tipdoc,
                    clase,
                    descri,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    vblob,
                    swacti,
                    obliga,
                    editable,
                    swcodigo,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_documentos_cab.id_cia,
                    rec_clase_documentos_cab.tipdoc,
                    rec_clase_documentos_cab.clase,
                    rec_clase_documentos_cab.descri,
                    rec_clase_documentos_cab.vreal,
                    rec_clase_documentos_cab.vstrg,
                    rec_clase_documentos_cab.vchar,
                    rec_clase_documentos_cab.vdate,
                    rec_clase_documentos_cab.vtime,
                    rec_clase_documentos_cab.ventero,
                    rec_clase_documentos_cab.vblob,
                    rec_clase_documentos_cab.swacti,
                    rec_clase_documentos_cab.obliga,
                    rec_clase_documentos_cab.editable,
                    rec_clase_documentos_cab.swcodigo,
                    rec_clase_documentos_cab.codusercrea,
                    rec_clase_documentos_cab.coduseractu,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_cab
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_cab.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_cab.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_documentos_cab.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_documentos_cab.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_documentos_cab.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_documentos_cab.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_documentos_cab.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_documentos_cab.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_documentos_cab.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_documentos_cab.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_documentos_cab.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_documentos_cab.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_documentos_cab.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_documentos_cab.ventero
                        END,
                    vblob =
                        CASE
                            WHEN rec_clase_documentos_cab.vblob IS NULL THEN
                                vblob
                            ELSE
                                rec_clase_documentos_cab.vblob
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_cab.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_cab.swacti
                        END,
                    obliga =
                        CASE
                            WHEN rec_clase_documentos_cab.obliga IS NULL THEN
                                obliga
                            ELSE
                                rec_clase_documentos_cab.obliga
                        END,
                    editable =
                        CASE
                            WHEN rec_clase_documentos_cab.editable IS NULL THEN
                                editable
                            ELSE
                                rec_clase_documentos_cab.editable
                        END,
                    swcodigo =
                        CASE
                            WHEN rec_clase_documentos_cab.swcodigo IS NULL THEN
                                swcodigo
                            ELSE
                                rec_clase_documentos_cab.swcodigo
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_documentos_cab.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_cab.coduseractu
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_cab.id_cia
                    AND tipdoc = rec_clase_documentos_cab.tipdoc
                    AND clase = rec_clase_documentos_cab.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_cab
                WHERE
                        id_cia = rec_clase_documentos_cab.id_cia
                    AND tipdoc = rec_clase_documentos_cab.tipdoc
                    AND clase = rec_clase_documentos_cab.clase;

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
                    'message' VALUE 'El registro con TIPO DE DOCUMENTO [ '
                                    || rec_clase_documentos_cab.tipdoc
                                    || ' ] y CLASE [ '
                                    || rec_clase_documentos_cab.clase
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
                        'message' VALUE 'No se insertar o modificar este registro porque el TIPO DE DOCUMENTO [ '
                                        || rec_clase_documentos_cab.tipdoc
                                        || ' ] y CLASE [ '
                                        || rec_clase_documentos_cab.clase
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
        pin_tipdoc NUMBER,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.tipdoc,
            dt.descri   AS dtipdoc,
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
            clase_documentos_cab_codigo cdcc
            LEFT OUTER JOIN clase_documentos_cab        cdc ON cdc.id_cia = cdcc.id_cia
                                                        AND cdc.tipdoc = cdcc.tipdoc
                                                        AND cdc.clase = cdcc.clase
            LEFT OUTER JOIN documentos_tipo             dt ON dt.id_cia = cdcc.id_cia
                                                  AND dt.tipdoc = cdcc.tipdoc
        WHERE
                cdcc.id_cia = pin_id_cia
            AND cdcc.tipdoc = pin_tipdoc
            AND cdcc.clase = pin_clase
            AND cdcc.codigo = pin_codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_clase_codigo;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia    NUMBER,
        pin_tipdoc    NUMBER,
        pin_clase     NUMBER,
        pin_descodigo VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    AS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            cdcc.id_cia,
            cdcc.tipdoc,
            dt.descri   AS dtipdoc,
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
            clase_documentos_cab_codigo cdcc
            LEFT OUTER JOIN clase_documentos_cab        cdc ON cdc.id_cia = cdcc.id_cia
                                                        AND cdc.tipdoc = cdcc.tipdoc
                                                        AND cdc.clase = cdcc.clase
            LEFT OUTER JOIN documentos_tipo             dt ON dt.id_cia = cdcc.id_cia
                                                  AND dt.tipdoc = cdcc.tipdoc
        WHERE
                cdcc.id_cia = pin_id_cia
            AND ( pin_tipdoc IS NULL
                  OR pin_tipdoc = - 1
                  OR cdcc.tipdoc = pin_tipdoc )
            AND ( pin_clase IS NULL
                  OR pin_clase = - 1
                  OR cdcc.clase = pin_clase )
            AND ( pin_descodigo IS NULL
                  OR upper(cdcc.descri) LIKE ( '%'
                                               || upper(pin_descodigo)
                                               || '%' ) );

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
--                "tipdoc":1,
--                "clase":100,
--                "codigo":"01",
--                "descodigo":"Codigo de la Clase Documentos cab de Prueba",
--                "abrevi":"CODPRV",
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_clase_documentos_cab.sp_save_clase_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_cab.sp_obtener_clase_codigo(66,1,100,'01');
--
--SELECT * FROM pack_clase_documentos_cab.sp_buscar_clase_codigo(66,1,100,'%');

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                               json_object_t;
        rec_clase_documentos_cab_codigo clase_documentos_cab_codigo%rowtype;
        v_accion                        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_cab_codigo.id_cia := pin_id_cia;
        rec_clase_documentos_cab_codigo.tipdoc := o.get_number('tipdoc');
        rec_clase_documentos_cab_codigo.clase := o.get_number('clase');
        rec_clase_documentos_cab_codigo.codigo := o.get_string('codigo');
        rec_clase_documentos_cab_codigo.descri := o.get_string('descodigo');
        rec_clase_documentos_cab_codigo.abrevi := o.get_string('abrevi');
        rec_clase_documentos_cab_codigo.swacti := o.get_string('swacti');
        rec_clase_documentos_cab_codigo.codusercrea := o.get_string('ucreac');
        rec_clase_documentos_cab_codigo.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_cab_codigo (
                    id_cia,
                    tipdoc,
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
                    rec_clase_documentos_cab_codigo.id_cia,
                    rec_clase_documentos_cab_codigo.tipdoc,
                    rec_clase_documentos_cab_codigo.clase,
                    rec_clase_documentos_cab_codigo.codigo,
                    rec_clase_documentos_cab_codigo.descri,
                    rec_clase_documentos_cab_codigo.abrevi,
                    rec_clase_documentos_cab_codigo.swacti,
                    rec_clase_documentos_cab_codigo.codusercrea,
                    rec_clase_documentos_cab_codigo.coduseractu,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_cab_codigo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_cab_codigo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_cab_codigo.descri
                        END,
                    abrevi =
                        CASE
                            WHEN rec_clase_documentos_cab_codigo.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_clase_documentos_cab_codigo.abrevi
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_cab_codigo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_cab_codigo.swacti
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_documentos_cab_codigo.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_cab_codigo.coduseractu
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_cab_codigo.id_cia
                    AND tipdoc = rec_clase_documentos_cab_codigo.tipdoc
                    AND clase = rec_clase_documentos_cab_codigo.clase
                    AND codigo = rec_clase_documentos_cab_codigo.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_cab_codigo
                WHERE
                        id_cia = rec_clase_documentos_cab_codigo.id_cia
                    AND tipdoc = rec_clase_documentos_cab_codigo.tipdoc
                    AND clase = rec_clase_documentos_cab_codigo.clase
                    AND codigo = rec_clase_documentos_cab_codigo.codigo;

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
                    'message' VALUE 'El registro con TIPO DE DOCUMENTO [ '
                                    || rec_clase_documentos_cab_codigo.tipdoc
                                    || ' ], CLASE [ '
                                    || rec_clase_documentos_cab_codigo.clase
                                    || ' ] y CODIGO [ '
                                    || rec_clase_documentos_cab_codigo.codigo
                                    || ' ya existe y no puede duplicarse ...!'
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
                        'message' VALUE 'No se insertar o modificar este registro porque el TIPO DE DOCUMENTO [ '
                                        || rec_clase_documentos_cab_codigo.tipdoc
                                        || ' ] y CLASE [ '
                                        || rec_clase_documentos_cab_codigo.clase
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
