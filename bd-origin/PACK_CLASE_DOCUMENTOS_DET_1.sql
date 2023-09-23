--------------------------------------------------------
--  DDL for Package Body PACK_CLASE_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLASE_DOCUMENTOS_DET" AS

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
--            cdc.vblob,
            cdc.swacti,
            cdc.obliga,
--            cdc.editable,
            cdc.swcodigo,
            cdc.codusercrea,
            cdc.coduseractu,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_det cdc
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
            cdc.swacti,
            cdc.obliga,
            cdc.swcodigo,
            cdc.codusercrea,
            cdc.coduseractu,
            cdc.fcreac,
            cdc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_det cdc
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
--                "clase":1,
--                "desclase":"Clase del Documentos Det de Prueba",
--                "vreal":"N",
--                "vstrg":"N",
--                "vchar":"N",
--                "vdate":"N",
--                "vtime":"N",
--                "ventero":"N",
--                "swacti":"S",
--                "obliga":"N",
--                "swcodigo":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clase_documentos_det.sp_save_clase(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_det.sp_obtener_clase(66,1,1);
--
--SELECT * FROM pack_clase_documentos_det.sp_buscar_clase(66,NULL,'%');

    PROCEDURE sp_save_clase (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                        json_object_t;
        rec_clase_documentos_det clase_documentos_det%rowtype;
        v_accion                 VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_det.id_cia := pin_id_cia;
        rec_clase_documentos_det.tipdoc := o.get_number('tipdoc');
        rec_clase_documentos_det.clase := o.get_number('clase');
        rec_clase_documentos_det.descri := o.get_string('desclase');
        rec_clase_documentos_det.vreal := o.get_string('vreal');
        rec_clase_documentos_det.vstrg := o.get_string('vstrg');
        rec_clase_documentos_det.vchar := o.get_string('vchar');
        rec_clase_documentos_det.vdate := o.get_string('vdate');
        rec_clase_documentos_det.vtime := o.get_string('vtime');
        rec_clase_documentos_det.ventero := o.get_string('ventero');
        rec_clase_documentos_det.swacti := o.get_string('swacti');
        rec_clase_documentos_det.obliga := o.get_string('obliga');
        rec_clase_documentos_det.swcodigo := o.get_string('swcodigo');
        rec_clase_documentos_det.codusercrea := o.get_string('ucreac');
        rec_clase_documentos_det.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_det (
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
                    swacti,
                    obliga,
                    swcodigo,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_documentos_det.id_cia,
                    rec_clase_documentos_det.tipdoc,
                    rec_clase_documentos_det.clase,
                    rec_clase_documentos_det.descri,
                    rec_clase_documentos_det.vreal,
                    rec_clase_documentos_det.vstrg,
                    rec_clase_documentos_det.vchar,
                    rec_clase_documentos_det.vdate,
                    rec_clase_documentos_det.vtime,
                    rec_clase_documentos_det.ventero,
                    rec_clase_documentos_det.swacti,
                    rec_clase_documentos_det.obliga,
                    rec_clase_documentos_det.swcodigo,
                    rec_clase_documentos_det.codusercrea,
                    rec_clase_documentos_det.coduseractu,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_det
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_det.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_det.descri
                        END,
                    vstrg =
                        CASE
                            WHEN rec_clase_documentos_det.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_clase_documentos_det.vstrg
                        END,
                    vreal =
                        CASE
                            WHEN rec_clase_documentos_det.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_clase_documentos_det.vreal
                        END,
                    vchar =
                        CASE
                            WHEN rec_clase_documentos_det.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_clase_documentos_det.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_clase_documentos_det.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_clase_documentos_det.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_clase_documentos_det.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_clase_documentos_det.vtime
                        END,
                    ventero =
                        CASE
                            WHEN rec_clase_documentos_det.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_clase_documentos_det.ventero
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_det.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_det.swacti
                        END,
                    obliga =
                        CASE
                            WHEN rec_clase_documentos_det.obliga IS NULL THEN
                                obliga
                            ELSE
                                rec_clase_documentos_det.obliga
                        END,
                    swcodigo =
                        CASE
                            WHEN rec_clase_documentos_det.swcodigo IS NULL THEN
                                swcodigo
                            ELSE
                                rec_clase_documentos_det.swcodigo
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_documentos_det.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_det.coduseractu
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_det.id_cia
                    AND tipdoc = rec_clase_documentos_det.tipdoc
                    AND clase = rec_clase_documentos_det.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_det
                WHERE
                        id_cia = rec_clase_documentos_det.id_cia
                    AND tipdoc = rec_clase_documentos_det.tipdoc
                    AND clase = rec_clase_documentos_det.clase;

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
                                    || rec_clase_documentos_det.tipdoc
                                    || ' ] y CLASE [ '
                                    || rec_clase_documentos_det.clase
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
                        'message' VALUE 'No se eliminar o modificar este registro porque el TIPO DE DOCUMENTO [ '
                                        || rec_clase_documentos_det.tipdoc
                                        || ' ], con la CLASE [ '
                                        || rec_clase_documentos_det.clase
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
            cdcc.swdefaul,
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_det_codigo cdcc
            LEFT OUTER JOIN clase_documentos_det        cdc ON cdc.id_cia = cdcc.id_cia
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
            cdcc.swdefaul,
            cdcc.codusercrea,
            cdcc.coduseractu,
            cdcc.fcreac,
            cdcc.factua
        BULK COLLECT
        INTO v_table
        FROM
            clase_documentos_det_codigo cdcc
            LEFT OUTER JOIN clase_documentos_det        cdc ON cdc.id_cia = cdcc.id_cia
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
--                "clase":1,
--                "codigo":"01",
--                "descodigo":"Codigo del Documentos Det de Prueba",
--                "abrevi":"CODPRV",
--                "swacti":"S",
--                "swdefaul":"N",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_clase_documentos_det.sp_save_clase_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_clase_documentos_det.sp_obtener_clase_codigo(66,1,1,'01');
--
--SELECT * FROM pack_clase_documentos_det.sp_buscar_clase_codigo(66,1,1,'%');

    PROCEDURE sp_save_clase_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                               json_object_t;
        rec_clase_documentos_det_codigo clase_documentos_det_codigo%rowtype;
        v_accion                        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_documentos_det_codigo.id_cia := pin_id_cia;
        rec_clase_documentos_det_codigo.tipdoc := o.get_number('tipdoc');
        rec_clase_documentos_det_codigo.clase := o.get_number('clase');
        rec_clase_documentos_det_codigo.codigo := o.get_string('codigo');
        rec_clase_documentos_det_codigo.descri := o.get_string('descodigo');
        rec_clase_documentos_det_codigo.abrevi := o.get_string('abrevi');
        rec_clase_documentos_det_codigo.swacti := o.get_string('swacti');
        rec_clase_documentos_det_codigo.swdefaul := o.get_string('swdefaul');
        rec_clase_documentos_det_codigo.codusercrea := o.get_string('ucreac');
        rec_clase_documentos_det_codigo.coduseractu := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO clase_documentos_det_codigo (
                    id_cia,
                    tipdoc,
                    clase,
                    codigo,
                    descri,
                    abrevi,
                    swacti,
                    swdefaul,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_documentos_det_codigo.id_cia,
                    rec_clase_documentos_det_codigo.tipdoc,
                    rec_clase_documentos_det_codigo.clase,
                    rec_clase_documentos_det_codigo.codigo,
                    rec_clase_documentos_det_codigo.descri,
                    rec_clase_documentos_det_codigo.abrevi,
                    rec_clase_documentos_det_codigo.swacti,
                    rec_clase_documentos_det_codigo.swdefaul,
                    rec_clase_documentos_det_codigo.codusercrea,
                    rec_clase_documentos_det_codigo.coduseractu,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_documentos_det_codigo
                SET
                    descri =
                        CASE
                            WHEN rec_clase_documentos_det_codigo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_clase_documentos_det_codigo.descri
                        END,
                    abrevi =
                        CASE
                            WHEN rec_clase_documentos_det_codigo.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_clase_documentos_det_codigo.abrevi
                        END,
                    swacti =
                        CASE
                            WHEN rec_clase_documentos_det_codigo.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_clase_documentos_det_codigo.swacti
                        END,
                    swdefaul =
                        CASE
                            WHEN rec_clase_documentos_det_codigo.swdefaul IS NULL THEN
                                swdefaul
                            ELSE
                                rec_clase_documentos_det_codigo.swdefaul
                        END,
                    coduseractu =
                        CASE
                            WHEN rec_clase_documentos_det_codigo.coduseractu IS NULL THEN
                                ''
                            ELSE
                                rec_clase_documentos_det_codigo.coduseractu
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_documentos_det_codigo.id_cia
                    AND tipdoc = rec_clase_documentos_det_codigo.tipdoc
                    AND clase = rec_clase_documentos_det_codigo.clase
                    AND codigo = rec_clase_documentos_det_codigo.codigo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_documentos_det_codigo
                WHERE
                        id_cia = rec_clase_documentos_det_codigo.id_cia
                    AND tipdoc = rec_clase_documentos_det_codigo.tipdoc
                    AND clase = rec_clase_documentos_det_codigo.clase
                    AND codigo = rec_clase_documentos_det_codigo.codigo;

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
                                    || rec_clase_documentos_det_codigo.tipdoc
                                    || '], CLASE [ '
                                    || rec_clase_documentos_det_codigo.clase
                                    || ' ] y CODIGO [ '
                                    || rec_clase_documentos_det_codigo.codigo
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
                        'message' VALUE 'No se insertar o modificar este registro porque el TIPO DE DOCUMENTO [ '
                                        || rec_clase_documentos_det_codigo.tipdoc
                                        || ' ] con CLASE [ '
                                        || rec_clase_documentos_det_codigo.clase
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
