--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_ADJUNTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_item   NUMBER
    ) RETURN datatable_articulos_adjunto
        PIPELINED
    AS
        v_table datatable_articulos_adjunto;
    BEGIN
        SELECT
            aa.id_cia,
            aa.tipinv,
            ti.dtipinv AS dtipinv,
            aa.codart,
            a.descri   AS desart,
            aa.item,
            aa.nombre,
            aa.formato,
            aa.archivo,
            aa.observ,
            aa.ucreac,
            aa.uactua,
            aa.fcreac,
            aa.factua
        BULK COLLECT
        INTO v_table
        FROM
            articulos_adjunto aa
            LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = aa.id_cia
                                               AND ti.tipinv = aa.tipinv
            LEFT OUTER JOIN articulos         a ON a.id_cia = aa.id_cia
                                           AND a.tipinv = aa.tipinv
                                           AND a.codart = aa.codart
        WHERE
                aa.id_cia = pin_id_cia
            AND aa.tipinv = pin_tipinv
            AND aa.codart = pin_codart
            AND aa.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_desart VARCHAR2,
        pin_nombre VARCHAR2
    ) RETURN datatable_articulos_adjunto
        PIPELINED
    AS
        v_table datatable_articulos_adjunto;
    BEGIN
        SELECT
            aa.id_cia,
            aa.tipinv,
            ti.dtipinv AS dtipinv,
            aa.codart,
            a.descri   AS desart,
            aa.item,
            aa.nombre,
            aa.formato,
            aa.archivo,
            aa.observ,
            aa.ucreac,
            aa.uactua,
            aa.fcreac,
            aa.factua
        BULK COLLECT
        INTO v_table
        FROM
            articulos_adjunto aa
            LEFT OUTER JOIN t_inventario      ti ON ti.id_cia = aa.id_cia
                                               AND ti.tipinv = aa.tipinv
            LEFT OUTER JOIN articulos         a ON a.id_cia = aa.id_cia
                                           AND a.tipinv = aa.tipinv
                                           AND a.codart = aa.codart
        WHERE
                aa.id_cia = pin_id_cia
            AND ( pin_tipinv IS NULL
                  OR pin_tipinv = - 1
                  OR aa.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR aa.codart = pin_codart )
            AND ( pin_desart IS NULL
                  OR upper(a.descri) LIKE upper('%' || pin_desart) )
            AND ( pin_nombre IS NULL
                  OR upper(aa.nombre) LIKE upper('%' || pin_nombre) );

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
--                "item":1,
--                "nombre":"CUCHILLETE DE PRUEBA",
--                "formato":"PDF",
--                "observ":"PRUEBA PDF",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_articulos_adjunto.sp_save(66, NULL, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_articulos_adjunto.sp_obtener(66,1,'0003858',1);
--
--SELECT * FROM pack_articulos_adjunto.sp_buscar(66,1,NULL,'CUCHILL%',NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_archivo IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                     json_object_t;
        rec_articulos_adjunto articulos_adjunto%rowtype;
        v_accion              VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos_adjunto.id_cia := pin_id_cia;
        rec_articulos_adjunto.tipinv := o.get_number('tipinv');
        rec_articulos_adjunto.codart := o.get_string('codart');
        rec_articulos_adjunto.item := o.get_number('item');
        rec_articulos_adjunto.nombre := o.get_string('nombre');
        rec_articulos_adjunto.formato := o.get_string('formato');
        rec_articulos_adjunto.observ := o.get_string('observ');
        rec_articulos_adjunto.ucreac := o.get_string('ucreac');
        rec_articulos_adjunto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                rec_articulos_adjunto.archivo := pin_archivo;
                BEGIN
                    SELECT
                        nvl(item, 0) + 1
                    INTO rec_articulos_adjunto.item
                    FROM
                        articulos_adjunto
                    WHERE
                            id_cia = rec_articulos_adjunto.id_cia
                        AND tipinv = rec_articulos_adjunto.tipinv
                        AND codart = rec_articulos_adjunto.codart
                        AND item IS NOT NULL
                    ORDER BY
                        item DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_articulos_adjunto.item := 1;
                END;

                INSERT INTO articulos_adjunto (
                    id_cia,
                    tipinv,
                    codart,
                    item,
                    nombre,
                    formato,
                    archivo,
                    observ,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_articulos_adjunto.id_cia,
                    rec_articulos_adjunto.tipinv,
                    rec_articulos_adjunto.codart,
                    rec_articulos_adjunto.item,
                    rec_articulos_adjunto.nombre,
                    rec_articulos_adjunto.formato,
                    rec_articulos_adjunto.archivo,
                    rec_articulos_adjunto.observ,
                    rec_articulos_adjunto.ucreac,
                    rec_articulos_adjunto.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                rec_articulos_adjunto.archivo := pin_archivo;
                UPDATE articulos_adjunto
                SET
                    nombre =
                        CASE
                            WHEN rec_articulos_adjunto.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_articulos_adjunto.nombre
                        END,
                    formato =
                        CASE
                            WHEN rec_articulos_adjunto.formato IS NULL THEN
                                formato
                            ELSE
                                rec_articulos_adjunto.formato
                        END,
                    archivo =
                        CASE
                            WHEN rec_articulos_adjunto.archivo IS NULL THEN
                                archivo
                            ELSE
                                rec_articulos_adjunto.archivo
                        END,
                    observ =
                        CASE
                            WHEN rec_articulos_adjunto.observ IS NULL THEN
                                observ
                            ELSE
                                rec_articulos_adjunto.observ
                        END,
                    uactua =
                        CASE
                            WHEN rec_articulos_adjunto.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_articulos_adjunto.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_articulos_adjunto.id_cia
                    AND tipinv = rec_articulos_adjunto.tipinv
                    AND codart = rec_articulos_adjunto.codart
                    AND item = rec_articulos_adjunto.item;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM articulos_adjunto
                WHERE
                        id_cia = rec_articulos_adjunto.id_cia
                    AND tipinv = rec_articulos_adjunto.tipinv
                    AND codart = rec_articulos_adjunto.codart
                    AND item = rec_articulos_adjunto.item;

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
                    'message' VALUE 'El registro con el Tipo de Inventario [ '
                                    || rec_articulos_adjunto.tipinv
                                    || ' ], con el Articulo [ '
                                    || rec_articulos_adjunto.codart
                                    || ' ] y con el ITEM [ '
                                    || rec_articulos_adjunto.item
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
                        'message' VALUE 'No se insertar o modificar este registro porque el TipoItem [ '
                                        || rec_articulos_adjunto.archivo
                                        || ' - '
                                        || rec_articulos_adjunto.formato
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' formato :'
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
