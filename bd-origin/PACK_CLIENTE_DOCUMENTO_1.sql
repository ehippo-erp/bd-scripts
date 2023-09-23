--------------------------------------------------------
--  DDL for Package Body PACK_CLIENTE_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CLIENTE_DOCUMENTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_cliente_documento
        PIPELINED
    AS
        v_table datatable_cliente_documento;
    BEGIN
        SELECT
            cd.id_cia,
            cd.codcli,
            c.razonc,
            cd.item,
            cd.desdoc,
            cd.archivo,
            cd.formato,
            cd.ucreac,
            cd.uactua,
            cd.fcreac,
            cd.factua
        BULK COLLECT
        INTO v_table
        FROM
            cliente_documento cd
            LEFT OUTER JOIN cliente           c ON c.id_cia = cd.id_cia
                                         AND c.codcli = cd.codcli
        WHERE
                cd.id_cia = pin_id_cia
            AND cd.codcli = pin_codcli
            AND cd.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_cliente_documento
        PIPELINED
    AS
        v_table datatable_cliente_documento;
    BEGIN
        SELECT
            cd.id_cia,
            cd.codcli,
            c.razonc,
            cd.item,
            cd.desdoc,
            cd.archivo,
            cd.formato,
            cd.ucreac,
            cd.uactua,
            cd.fcreac,
            cd.factua
        BULK COLLECT
        INTO v_table
        FROM
            cliente_documento cd
            LEFT OUTER JOIN cliente           c ON c.id_cia = cd.id_cia
                                         AND c.codcli = cd.codcli
        WHERE
                cd.id_cia = pin_id_cia
            AND ( pin_codcli IS NULL
                  OR cd.codcli = pin_codcli )
            AND ( nvl(pin_item, - 1) = - 1
                  OR cd.item = pin_item );

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
--                "item":2,
--                "codcli":"20520696378",
--                "desdoc":"S",
--                "formato":"PDF",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cliente_documento.sp_save(37, NULL, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cliente_documento.sp_obtener(37,'20520696378',1);
--
--SELECT * FROM pack_cliente_documento.sp_buscar(37,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                     json_object_t;
        rec_cliente_documento cliente_documento%rowtype;
        v_accion              VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cliente_documento.id_cia := pin_id_cia;
        rec_cliente_documento.codcli := o.get_string('codcli');
        rec_cliente_documento.item := o.get_number('item');
        rec_cliente_documento.desdoc := o.get_string('desdoc');
        rec_cliente_documento.formato := o.get_string('formato');
        rec_cliente_documento.ucreac := o.get_string('ucreac');
        rec_cliente_documento.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                BEGIN
                    SELECT
                        nvl(MAX(nvl(item, 0)),
                            0)
                    INTO rec_cliente_documento.item
                    FROM
                        cliente_documento
                    WHERE
                            id_cia = rec_cliente_documento.id_cia
                        AND codcli = rec_cliente_documento.codcli;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_cliente_documento.item := 0;
                END;

                rec_cliente_documento.item := rec_cliente_documento.item + 1;
                INSERT INTO cliente_documento (
                    id_cia,
                    codcli,
                    item,
                    desdoc,
                    archivo,
                    formato,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_cliente_documento.id_cia,
                    rec_cliente_documento.codcli,
                    rec_cliente_documento.item,
                    rec_cliente_documento.desdoc,
                    pin_archivo,
                    rec_cliente_documento.formato,
                    rec_cliente_documento.ucreac,
                    rec_cliente_documento.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE cliente_documento
                SET
                    desdoc =
                        CASE
                            WHEN rec_cliente_documento.desdoc IS NULL THEN
                                desdoc
                            ELSE
                                rec_cliente_documento.desdoc
                        END,
                    archivo = pin_archivo,
                    formato =
                        CASE
                            WHEN rec_cliente_documento.formato IS NULL THEN
                                formato
                            ELSE
                                rec_cliente_documento.formato
                        END,
                    uactua = rec_cliente_documento.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_cliente_documento.id_cia
                    AND codcli = rec_cliente_documento.codcli
                    AND item = rec_cliente_documento.item;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM cliente_documento
                WHERE
                        id_cia = rec_cliente_documento.id_cia
                    AND codcli = rec_cliente_documento.codcli
                    AND item = rec_cliente_documento.item;

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
                    'message' VALUE 'El registro con CODIGO DE CLIENTE [ '
                                    || rec_cliente_documento.codcli
                                    || ' ] y ITEM [ '
                                    || rec_cliente_documento.item
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede INSERTAR O MODIFICAR este registro, porque el CLIENTE [ '
                                        || rec_cliente_documento.codcli
                                        || ' ] NO EXISTE'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codite :'
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
