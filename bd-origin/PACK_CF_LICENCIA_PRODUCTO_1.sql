--------------------------------------------------------
--  DDL for Package Body PACK_CF_LICENCIA_PRODUCTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_LICENCIA_PRODUCTO" AS

    FUNCTION sp_producto (
        pin_id_cia NUMBER
    ) RETURN datatable_producto
        PIPELINED
    AS
        v_table datatable_producto;
    BEGIN
        SELECT
            pin_id_cia,
            pl.codpro,
            pl.despro,
            pl.coment,
            pl.observ,
            pl.codmods,
            (
                SELECT
                    LISTAGG(m.descri, ',')
                FROM
                    modulos m
                WHERE
                    m.codmod IN (
                        SELECT
                            regexp_substr(pl.codmods, '[^,]+', 1, level)
                        FROM
                            dual
                        CONNECT BY
                            regexp_substr(pl.codmods, '[^,]+', 1, level) IS NOT NULL
                    )
            )
        BULK COLLECT
        INTO v_table
        FROM
            producto_licencia pl;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_producto;

    FUNCTION sp_obtener (
        pin_id_cia      NUMBER,
        pin_id_licencia NUMBER
    ) RETURN t_licencia_producto
        PIPELINED
    AS
        v_table t_licencia_producto;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            licencia_producto
        WHERE
                id_cia = pin_id_cia
            AND id_licencia = pin_id_licencia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codpro VARCHAR2,
        pin_situac VARCHAR2
    ) RETURN t_licencia_producto
        PIPELINED
    IS
        v_table t_licencia_producto;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            licencia_producto
        WHERE
            ( nvl(pin_id_cia, - 1) = - 1
              OR id_cia = pin_id_cia )
            AND ( pin_codpro IS NULL
                  OR codpro = pin_codpro )
            AND ( pin_situac IS NULL
                  OR ( pin_situac = 'S'
                       AND situac = 'S'
                       AND trunc(current_timestamp) BETWEEN fregis AND fvenci )
                  OR ( pin_situac = 'N'
                       AND situac = 'N' ) );

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
--  "licencia": "D105612",
--  "codpro": "PLANILLA",
--  "fregis": "2024-01-01",
--  "fvenci": "2025-01-01",
--  "observ": "REG PRUEBA",
--  "situac": "S",
--  "ucreac": "admin",
--  "uactua": "admin"
--}';
--    pack_cf_licencia_producto.sp_save(25, cadjson, 1, mensaje);
--
--    dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_licencia_producto.sp_obtener(25,2);
--
--SELECT * FROM pack_cf_licencia_producto.sp_buscar(25,'PLANILLA',NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                     json_object_t;
        rec_licencia_producto licencia_producto%rowtype;
        v_accion              VARCHAR2(50) := '';
        v_count               INTEGER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_licencia_producto.id_cia := pin_id_cia;
        rec_licencia_producto.id_licencia := o.get_number('id_licencia');
        rec_licencia_producto.licencia := o.get_string('licencia');
        rec_licencia_producto.codpro := o.get_string('codpro');
        rec_licencia_producto.fregis := o.get_date('fregis');
        rec_licencia_producto.fvenci := o.get_date('fvenci');
        rec_licencia_producto.observ := o.get_string('observ');
        rec_licencia_producto.situac := o.get_string('situac');
        rec_licencia_producto.ucreac := o.get_string('ucreac');
        rec_licencia_producto.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_licencia_producto.id_licencia, 0) = 0 THEN
                    BEGIN
                        SELECT
                            id_licencia + 1
                        INTO rec_licencia_producto.id_licencia
                        FROM
                            licencia_producto
                        WHERE
                            id_cia = pin_id_cia
                        ORDER BY
                            id_licencia DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_licencia_producto.id_licencia := 1;
                    END;
                END IF;

                INSERT INTO licencia_producto (
                    id_cia,
                    id_licencia,
                    licencia,
                    codpro,
                    fregis,
                    fvenci,
                    observ,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_licencia_producto.id_cia,
                    rec_licencia_producto.id_licencia,
                    rec_licencia_producto.licencia,
                    rec_licencia_producto.codpro,
                    rec_licencia_producto.fregis,
                    rec_licencia_producto.fvenci,
                    rec_licencia_producto.observ,
                    rec_licencia_producto.situac,
                    rec_licencia_producto.ucreac,
                    rec_licencia_producto.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE licencia_producto
                SET
                    licencia = nvl(rec_licencia_producto.licencia, licencia),
                    codpro = nvl(rec_licencia_producto.codpro, codpro),
                    fregis = nvl(rec_licencia_producto.fregis, fregis),
                    fvenci = nvl(rec_licencia_producto.fvenci, fvenci),
                    observ = nvl(rec_licencia_producto.observ, observ),
                    situac = nvl(rec_licencia_producto.situac, situac),
                    uactua = rec_licencia_producto.uactua,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_licencia_producto.id_cia
                    AND id_licencia = rec_licencia_producto.id_licencia;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM licencia_producto
                WHERE
                        id_cia = rec_licencia_producto.id_cia
                    AND id_licencia = rec_licencia_producto.id_licencia;

                COMMIT;
        END CASE;

        -- ACTUALIZANDO LICENCIA RESUMEN
        FOR j IN (
            SELECT
                *
            FROM
                producto_licencia
        ) LOOP
            BEGIN
                SELECT
                    COUNT(0)
                INTO v_count
                FROM
                    licencia_producto
                WHERE
                        id_cia = pin_id_cia
                    AND codpro = j.codpro
                    AND situac = 'S'
                    AND trunc(current_timestamp) BETWEEN fregis AND fvenci;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            MERGE INTO licencia_resumen lr
            USING dual ddd ON ( lr.id_cia = pin_id_cia
                                AND lr.codpro = j.codpro )
            WHEN MATCHED THEN UPDATE
            SET nrolicencia = v_count,
                factua = current_timestamp
            WHERE
                    id_cia = pin_id_cia
                AND lr.codpro = j.codpro
            WHEN NOT MATCHED THEN
            INSERT (
                id_cia,
                codpro,
                nrolicencia,
                fcreac,
                factua )
            VALUES
                ( pin_id_cia,
                  j.codpro,
                  v_count,
                  current_timestamp,
                  current_timestamp );

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL REGISTRO CON EL NUMERO INTERNO [ '
                                    || rec_licencia_producto.id_licencia
                                    || ' ] YA EXISTE Y NO PUEDE DUPLICARSE!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'EL REGISTRO EXECEDE EL LIMITE PERMITIDO POR EL CAMPO Y/O SE ENCUENTRA EN UN FORMATO INCORRECTO'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE 'CODIGO DE PRODUCTO NO VALIDO!'
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

    PROCEDURE sp_replicar (
        pin_id_cia  IN NUMBER,
        pin_codpro  IN VARCHAR2,
        pin_date    IN DATE,
        pin_days    IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_licencia INTEGER;
    BEGIN
        FOR i IN (
            SELECT
                *
            FROM
                licencia_producto
            WHERE
                    id_cia = pin_id_cia
                AND codpro = nvl(pin_codpro, codpro)
                AND situac = 'S'
                AND trunc(pin_date) BETWEEN fregis AND fvenci
            ORDER BY
                codpro ASC
        ) LOOP
            BEGIN
                SELECT
                    id_licencia + 1
                INTO v_licencia
                FROM
                    licencia_producto
                WHERE
                    id_cia = i.id_cia
                ORDER BY
                    id_licencia DESC
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    v_licencia := 1;
            END;

            INSERT INTO licencia_producto
                (
                    SELECT
                        i.id_cia,
                        v_licencia,
                        i.licencia,
                        i.codpro,
                        ( i.fvenci + 1 ),
                        ( i.fvenci + pin_days ),
                        i.observ,
                        'S',
                        pin_coduser,
                        pin_coduser,
                        current_timestamp,
                        current_timestamp
                    FROM
                        licencia_producto
                    WHERE
                            id_cia = i.id_cia
                        AND id_licencia = i.id_licencia
                );

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Replico correctamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL REGISTRO CON EL NUMERO INTERNO [ '
                                    || v_licencia
                                    || ' ] YA EXISTE Y NO PUEDE DUPLICARSE!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'EL REGISTRO EXECEDE EL LIMITE PERMITIDO POR EL CAMPO Y/O SE ENCUENTRA EN UN FORMATO INCORRECTO'
                )
            INTO pin_mensaje
            FROM
                dual;

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

    END;

END;

/
