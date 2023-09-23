--------------------------------------------------------
--  DDL for Package Body PACK_KARDEX001_IMPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KARDEX001_IMPR" AS

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "tipinv":1,
--                "codart":"AC132 UV",
--                "etiqueta":"117337",
--                "coduser":"admin",
--                "coment":""
--                }';
--pack_kardex001_impr.sp_save(66, cadjson, 4, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                  json_object_t;
        rec_kardex001_impr kardex001_impr%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_kardex001_impr.id_cia := pin_id_cia;
        rec_kardex001_impr.tipinv := o.get_number('tipinv');
        rec_kardex001_impr.codart := o.get_string('codart');
        rec_kardex001_impr.etiqueta := o.get_number('etiqueta');
        rec_kardex001_impr.coment := o.get_string('coment');
        rec_kardex001_impr.coduser := o.get_string('coduser');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO kardex001_impr (
                    id_cia,
                    codart,
                    tipinv,
                    etiqueta,
                    coment,
                    coduser,
                    fcreac
                ) VALUES (
                    rec_kardex001_impr.id_cia,
                    rec_kardex001_impr.codart,
                    rec_kardex001_impr.tipinv,
                    rec_kardex001_impr.etiqueta,
                    rec_kardex001_impr.coment,
                    rec_kardex001_impr.coduser,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE kardex001_impr
                SET
                    coment =
                        CASE
                            WHEN rec_kardex001_impr.coment IS NULL THEN
                                coment
                            ELSE
                                rec_kardex001_impr.coment
                        END,
                    coduser =
                        CASE
                            WHEN rec_kardex001_impr.coduser IS NULL THEN
                                coduser
                            ELSE
                                rec_kardex001_impr.coduser
                        END,
                    fcreac = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_kardex001_impr.id_cia
                    AND codart = rec_kardex001_impr.codart
                    AND tipinv = rec_kardex001_impr.tipinv
                    AND etiqueta = rec_kardex001_impr.etiqueta;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM kardex001_impr
                WHERE
                        id_cia = rec_kardex001_impr.id_cia
                    AND codart = rec_kardex001_impr.codart
                    AND tipinv = rec_kardex001_impr.tipinv
                    AND etiqueta = rec_kardex001_impr.etiqueta;

            WHEN 4 THEN
                v_accion := 'La impresión';
                INSERT INTO kardex001_impr (
                    id_cia,
                    codart,
                    tipinv,
                    etiqueta,
                    coment,
                    coduser,
                    fcreac
                ) VALUES (
                    rec_kardex001_impr.id_cia,
                    rec_kardex001_impr.codart,
                    rec_kardex001_impr.tipinv,
                    rec_kardex001_impr.etiqueta,
                    'Impresion',
                    rec_kardex001_impr.coduser,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

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
                    'message' VALUE 'El registro con codigo de KARDEX001_IMPR [ '
                                    || rec_kardex001_impr.codart
                                    || ' ], con el tipo de inventario [ '
                                    || rec_kardex001_impr.tipinv
                                    || ' ] y con el almacen [ '
                                    || rec_kardex001_impr.etiqueta
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
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' coment :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/
