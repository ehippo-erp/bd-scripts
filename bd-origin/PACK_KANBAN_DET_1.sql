--------------------------------------------------------
--  DDL for Package Body PACK_KANBAN_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KANBAN_DET" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_codart VARCHAR2
    ) RETURN datatable_kanban_det
        PIPELINED
    AS
        v_table datatable_kanban_det;
    BEGIN
        SELECT
            kd.id_cia,
            kd.codkan,
            kc.descri AS deskan,
            kd.tipinv,
            i.dtipinv,
            kd.codalm,
            a.descri,
            kd.codart,
            ar.descri,
            kd.cantid,
            kd.cantidmin,
            kd.cantidmax,
            kd.swacti,
            kd.ucreac,
            kd.uactua,
            kd.fcreac,
            kd.factua
        BULK COLLECT
        INTO v_table
        FROM
            kanban_det   kd
            LEFT OUTER JOIN kanban_cab   kc ON kc.id_cia = kd.id_cia
                                             AND kc.codkan = kd.codkan
                                             AND kc.tipinv = kd.tipinv
            LEFT OUTER JOIN t_inventario i ON i.id_cia = kd.id_cia
                                              AND i.tipinv = kd.tipinv
            LEFT OUTER JOIN almacen      a ON a.id_cia = kd.id_cia
                                         AND a.tipinv = kd.tipinv
                                         AND a.codalm = kd.codalm
            LEFT OUTER JOIN articulos    ar ON ar.id_cia = kd.id_cia
                                            AND ar.tipinv = kd.tipinv
                                            AND ar.codart = kd.codart
        WHERE
                kd.id_cia = pin_id_cia
            AND kd.codkan = pin_codkan
            AND kd.tipinv = pin_tipinv
            AND kd.codalm = pin_codalm
            AND kd.codart = pin_codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_codart VARCHAR2,
        pin_swacti VARCHAR2
    ) RETURN datatable_kanban_det
        PIPELINED
    AS
        v_table datatable_kanban_det;
    BEGIN
        SELECT
            kd.id_cia,
            kd.codkan,
            kc.descri AS deskan,
            kd.tipinv,
            i.dtipinv,
            kd.codalm,
            a.descri,
            kd.codart,
            ar.descri,
            kd.cantid,
            kd.cantidmin,
            kd.cantidmax,
            kd.swacti,
            kd.ucreac,
            kd.uactua,
            kd.fcreac,
            kd.factua
        BULK COLLECT
        INTO v_table
        FROM
            kanban_det   kd
            LEFT OUTER JOIN kanban_cab   kc ON kc.id_cia = kd.id_cia
                                             AND kc.codkan = kd.codkan
                                             AND kc.tipinv = kd.tipinv
            LEFT OUTER JOIN t_inventario i ON i.id_cia = kd.id_cia
                                              AND i.tipinv = kd.tipinv
            LEFT OUTER JOIN almacen      a ON a.id_cia = kd.id_cia
                                         AND a.tipinv = kd.tipinv
                                         AND a.codalm = kd.codalm
            LEFT OUTER JOIN articulos    ar ON ar.id_cia = kd.id_cia
                                            AND ar.tipinv = kd.tipinv
                                            AND ar.codart = kd.codart
        WHERE
                kd.id_cia = pin_id_cia
            AND ( pin_codkan IS NULL
                  OR kc.codkan = pin_codkan )
            AND ( pin_tipinv IS NULL
                  OR pin_tipinv = - 1
                  OR kc.tipinv = pin_tipinv )
            AND ( pin_codalm IS NULL
                  OR pin_codalm = - 1
                  OR kc.codalm = pin_codalm )
            AND ( pin_codart IS NULL
                  OR kd.codart = pin_codart )
            AND ( pin_swacti = 'N'
                  OR pin_swacti IS NULL
                  OR kc.swacti = pin_swacti );

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
--                "codkan":"KP01",
--                "tipinv":1,
--                "codalm":1,
--                "codart":"0004152",
--                "cantid":10,
--                "cantidmin":0,
--                "cantidmax":100,
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_kanban_det.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_kanban_det.sp_obtener(66,'KP01',1,1,'0004152');
--
--SELECT * FROM pack_kanban_det.sp_buscar(66,'KP01',1,1,NULL,'S');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o              json_object_t;
        rec_kanban_det kanban_det%rowtype;
        v_desfila      VARCHAR2(50) := ' ';
        v_accion       VARCHAR2(50) := '';
        v_aux          VARCHAR2(1);
        pout_mensaje   VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_kanban_det.id_cia := pin_id_cia;
        rec_kanban_det.codkan := o.get_string('codkan');
        rec_kanban_det.tipinv := o.get_number('tipinv');
        rec_kanban_det.codalm := o.get_number('codalm');
        rec_kanban_det.codart := o.get_string('codart');
        rec_kanban_det.cantid := o.get_number('cantid');
        rec_kanban_det.cantidmin := o.get_number('cantidmin');
        rec_kanban_det.cantidmax := o.get_number('cantidmax');
        rec_kanban_det.swacti := o.get_string('swacti');
        rec_kanban_det.ucreac := o.get_string('ucreac');
        rec_kanban_det.uactua := o.get_string('uactua');
        rec_kanban_det.swacti := o.get_string('swacti');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO kanban_det (
                    id_cia,
                    codkan,
                    tipinv,
                    codalm,
                    codart,
                    cantid,
                    cantidmin,
                    cantidmax,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_kanban_det.id_cia,
                    rec_kanban_det.codkan,
                    rec_kanban_det.tipinv,
                    rec_kanban_det.codalm,
                    rec_kanban_det.codart,
                    rec_kanban_det.cantid,
                    rec_kanban_det.cantidmin,
                    rec_kanban_det.cantidmax,
                    rec_kanban_det.swacti,
                    rec_kanban_det.ucreac,
                    rec_kanban_det.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE kanban_det
                SET
                    cantid =
                        CASE
                            WHEN rec_kanban_det.cantid IS NULL THEN
                                cantid
                            ELSE
                                rec_kanban_det.cantid
                        END,
                    cantidmin =
                        CASE
                            WHEN rec_kanban_det.cantidmin IS NULL THEN
                                cantidmin
                            ELSE
                                rec_kanban_det.cantidmin
                        END,
                    cantidmax =
                        CASE
                            WHEN rec_kanban_det.cantidmax IS NULL THEN
                                cantidmax
                            ELSE
                                rec_kanban_det.cantidmax
                        END,
                    swacti =
                        CASE
                            WHEN rec_kanban_det.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_kanban_det.swacti
                        END,
                    uactua = rec_kanban_det.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_kanban_det.id_cia
                    AND codkan = rec_kanban_det.codkan
                    AND tipinv = rec_kanban_det.tipinv
                    AND codalm = rec_kanban_det.codalm
                    AND codart = rec_kanban_det.codart;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM kanban_det
                WHERE
                        id_cia = rec_kanban_det.id_cia
                    AND codkan = rec_kanban_det.codkan
                    AND tipinv = rec_kanban_det.tipinv
                    AND codalm = rec_kanban_det.codalm
                    AND codart = rec_kanban_det.codart;

            WHEN 4 THEN
                v_accion := 'La importacion';
                v_desfila := ' ( FILA N°'
                             || o.get_number('fila')
                             || ' )';
                BEGIN
                    SELECT
                        'S'
                    INTO v_aux
                    FROM
                        articulos
                    WHERE
                            id_cia = rec_kanban_det.id_cia
                        AND tipinv = rec_kanban_det.tipinv
                        AND codart = rec_kanban_det.codart;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'EL ARTICULO [ '
                                        || rec_kanban_det.codart
                                        || ' ] NO EXISTE EN EL TIPO DE INVENTARIO SELECIONADO!'
                                        || v_desfila;
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;
                
                
                -- MERGE INTO KANBAN_DET
                MERGE INTO kanban_det kd
                USING dual dd ON ( kd.id_cia = rec_kanban_det.id_cia
                                   AND kd.codkan = rec_kanban_det.codkan
                                   AND kd.tipinv = rec_kanban_det.tipinv
                                   AND kd.codalm = rec_kanban_det.codalm
                                   AND kd.codart = rec_kanban_det.codart )
                WHEN MATCHED THEN UPDATE
                SET cantidmin =
                    CASE
                        WHEN rec_kanban_det.cantidmin IS NULL THEN
                            cantidmin
                        ELSE
                            rec_kanban_det.cantidmin
                    END,
                    cantidmax =
                    CASE
                        WHEN rec_kanban_det.cantidmax IS NULL THEN
                            cantidmax
                        ELSE
                            rec_kanban_det.cantidmax
                    END,
                    swacti =
                    CASE
                        WHEN rec_kanban_det.swacti IS NULL THEN
                            swacti
                        ELSE
                            rec_kanban_det.swacti
                    END,
                    uactua = rec_kanban_det.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_kanban_det.id_cia
                    AND codkan = rec_kanban_det.codkan
                    AND tipinv = rec_kanban_det.tipinv
                    AND codalm = rec_kanban_det.codalm
                    AND codart = rec_kanban_det.codart
                WHEN NOT MATCHED THEN
                INSERT (
                    id_cia,
                    codkan,
                    tipinv,
                    codalm,
                    codart,
                    cantidmin,
                    cantidmax,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua )
                VALUES
                    ( rec_kanban_det.id_cia,
                      rec_kanban_det.codkan,
                      rec_kanban_det.tipinv,
                      rec_kanban_det.codalm,
                      rec_kanban_det.codart,
                      rec_kanban_det.cantidmin,
                      rec_kanban_det.cantidmax,
                      rec_kanban_det.swacti,
                      rec_kanban_det.ucreac,
                      rec_kanban_det.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS') );

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
                    'message' VALUE 'EL REGISTRO DE  KANBAN [ '
                                    || rec_kanban_det.codkan
                                    || ' - '
                                    || rec_kanban_det.tipinv
                                    || ' - '
                                    || rec_kanban_det.codalm
                                    || ' ], CON EL ARTICULO [ '
                                    || rec_kanban_det.codart
                                    || ' ] YA EXISTE, Y NO PUEDE DUPLICARSE!'
                                    || v_desfila
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'EL REGISTRO EXECEDE EL LIMITE PERMITIDO POR EL CAMPO Y/O SE ENCUENTRA EN UN FORMATO INCORRECTO' |
                    | v_desfila
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el KANBAN [ '
                                        || rec_kanban_det.codkan
                                        || ' - '
                                        || rec_kanban_det.tipinv
                                        || ' - '
                                        || rec_kanban_det.codalm
                                        || ' ] O EL ARTICULO [ '
                                        || rec_kanban_det.tipinv
                                        || ' - '
                                        || rec_kanban_det.codart
                                        || ' ] NO EXISTE!'
                                        || v_desfila
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codart :'
                               || sqlcode
                               || v_desfila;
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
