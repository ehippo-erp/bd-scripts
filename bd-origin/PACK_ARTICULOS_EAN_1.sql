--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_EAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_EAN" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_ean
        PIPELINED
    AS
        v_table datatable_articulos_ean;
    BEGIN
        SELECT
            ean.id_cia,
            ean.tipinv,
            t.dtipinv,
            ean.codart,
            a.descri AS desart,
            ean.item,
            ean.ean,
            ean.ucreac,
            ean.uactua,
            ean.fcreac,
            ean.factua
        BULK COLLECT
        INTO v_table
        FROM
            articulos_ean ean
            LEFT OUTER JOIN t_inventario  t ON t.id_cia = ean.id_cia
                                              AND t.tipinv = ean.tipinv
            LEFT OUTER JOIN articulos     a ON a.id_cia = ean.id_cia
                                           AND a.tipinv = ean.tipinv
                                           AND a.codart = ean.codart
        WHERE
                ean.id_cia = pin_id_cia
            AND ean.tipinv = pin_tipinv
            AND ean.codart = pin_codart
            AND ean.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_ean
        PIPELINED
    AS
        v_table datatable_articulos_ean;
    BEGIN
        SELECT
            ean.id_cia,
            ean.tipinv,
            t.dtipinv,
            ean.codart,
            a.descri AS desart,
            ean.item,
            ean.ean,
            ean.ucreac,
            ean.uactua,
            ean.fcreac,
            ean.factua
        BULK COLLECT
        INTO v_table
        FROM
            articulos_ean ean
            LEFT OUTER JOIN t_inventario  t ON t.id_cia = ean.id_cia
                                              AND t.tipinv = ean.tipinv
            LEFT OUTER JOIN articulos     a ON a.id_cia = ean.id_cia
                                           AND a.tipinv = ean.tipinv
                                           AND a.codart = ean.codart
        WHERE
                ean.id_cia = pin_id_cia
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR ean.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR ean.codart = pin_codart )
            AND ( nvl(pin_item, - 1) = - 1
                  OR ean.item = pin_item );

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
--                "tipinv":1,
--                "codart":"0003858",
--                "item":2,
--                "ean":"CODPRUEBA2",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_articulos_ean.sp_save(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_articulos_ean.sp_obtener(66,1,'0003858',1);
--
--SELECT * FROM pack_articulos_ean.sp_buscar(66,1,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                 json_object_t;
        rec_articulos_ean articulos_ean%rowtype;
        v_accion          VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos_ean.id_cia := pin_id_cia;
        rec_articulos_ean.tipinv := o.get_number('tipinv');
        rec_articulos_ean.codart := o.get_string('codart');
        rec_articulos_ean.item := o.get_number('item');
        rec_articulos_ean.ean := o.get_string('ean');
        rec_articulos_ean.ucreac := o.get_string('ucreac');
        rec_articulos_ean.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_articulos_ean.item, 0) = 0 THEN
                    BEGIN
                        SELECT
                            nvl(MAX(nvl(item, 0)),
                                0)
                        INTO rec_articulos_ean.item
                        FROM
                            articulos_ean
                        WHERE
                                id_cia = rec_articulos_ean.id_cia
                            AND tipinv = rec_articulos_ean.tipinv
                            AND codart = rec_articulos_ean.codart;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_articulos_ean.item := 0;
                    END;

                    rec_articulos_ean.item := rec_articulos_ean.item + 1;
                END IF;

                v_accion := 'La inserción';
                INSERT INTO articulos_ean (
                    id_cia,
                    tipinv,
                    codart,
                    item,
                    ean,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_articulos_ean.id_cia,
                    rec_articulos_ean.tipinv,
                    rec_articulos_ean.codart,
                    rec_articulos_ean.item,
                    rec_articulos_ean.ean,
                    rec_articulos_ean.ucreac,
                    rec_articulos_ean.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE articulos_ean
                SET
                    ean =
                        CASE
                            WHEN rec_articulos_ean.ean IS NULL THEN
                                ean
                            ELSE
                                rec_articulos_ean.ean
                        END,
                    uactua = rec_articulos_ean.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_articulos_ean.id_cia
                    AND tipinv = rec_articulos_ean.tipinv
                    AND codart = rec_articulos_ean.codart
                    AND item = rec_articulos_ean.item;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM articulos_ean
                WHERE
                        id_cia = rec_articulos_ean.id_cia
                    AND tipinv = rec_articulos_ean.tipinv
                    AND codart = rec_articulos_ean.codart
                    AND item = rec_articulos_ean.item;

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
                    'message' VALUE 'El registro con TIPO DE INVENTARIO [ '
                                    || rec_articulos_ean.tipinv
                                    || ' ], ARTICULO [ '
                                    || rec_articulos_ean.codart
                                    || ' ] y ITEM [ '
                                    || rec_articulos_ean.item
                                    || ' YA EXISTE Y NO PUEDE DUPLICARSE'
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
                        'message' VALUE 'No se INSERTAR O MODIFICAR este registro porque el TIPO DE INVENTARIO [ '
                                        || rec_articulos_ean.codart
                                        || ' ] O ARTICULO [ '
                                        || rec_articulos_ean.tipinv
                                        || ' ] NO EXISTE'
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
    END sp_save;

END;

/
