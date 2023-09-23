--------------------------------------------------------
--  DDL for Package Body PACK_CF_COMPANIA_BANCO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_COMPANIA_BANCO" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codban IN NUMBER,
        pin_tipcta IN NUMBER,
        pin_codmon VARCHAR2
    ) RETURN datatable_compania_banco
        PIPELINED
    IS
        v_table datatable_compania_banco;
    BEGIN
        SELECT
            c.id_cia,
            c.codban,
            e.descri  AS desban,
            c.tipcta,
            et.descri AS descta,
            c.codmon,
            c.nrocta,
            c.observ,
            c.ucreac,
            c.uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            compania_banco    c
            LEFT OUTER JOIN e_financiera      e ON e.id_cia = c.id_cia
                                              AND e.codigo = c.codban
            LEFT OUTER JOIN e_financiera_tipo et ON et.id_cia = c.id_cia
                                                    AND et.tipcta = c.tipcta
        WHERE
                c.id_cia = pin_id_cia
            AND c.codban = pin_codban
            AND c.tipcta = pin_tipcta
            AND c.codmon = pin_codmon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER
    ) RETURN datatable_compania_banco
        PIPELINED
    IS
        v_table datatable_compania_banco;
    BEGIN
        SELECT
            c.id_cia,
            c.codban,
            e.descri  AS desban,
            c.tipcta,
            et.descri AS descta,
            c.codmon,
            c.nrocta,
            c.observ,
            c.ucreac,
            c.uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            compania_banco    c
            LEFT OUTER JOIN e_financiera      e ON e.id_cia = c.id_cia
                                              AND e.codigo = c.codban
            LEFT OUTER JOIN e_financiera_tipo et ON et.id_cia = c.id_cia
                                                    AND et.tipcta = c.tipcta
        WHERE
            c.id_cia = pin_id_cia;

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
--                "codban":1,
--                "tipcta":1,
--                "codmon":"PEN",
--                "nrocta":"65456465456SD5646",
--                "observ":"PRUEBA",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_cf_compania_banco.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_compania_banco.sp_obtener(25,1,1,'PEN');
--
--SELECT * FROM pack_cf_compania_banco.sp_buscar(25);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o                  json_object_t;
        rec_compania_banco compania_banco%rowtype;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_compania_banco.id_cia := pin_id_cia;
        rec_compania_banco.codban := o.get_number('codban');
        rec_compania_banco.tipcta := o.get_number('tipcta');
        rec_compania_banco.codmon := o.get_string('codmon');
        rec_compania_banco.nrocta := o.get_string('nrocta');
        rec_compania_banco.observ := o.get_string('observ');
        rec_compania_banco.ucreac := o.get_string('ucreac');
        rec_compania_banco.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        IF nvl(rec_compania_banco.tipcta, 1) NOT IN ( 1, 3 ) THEN
            pout_mensaje := 'TIPO DE CUENTA NO PERMITIDA, SOLO PUEDE SER ASIGNADO UNA CUENTA CORRIENTE Y/O MAESTRA!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO compania_banco (
                    id_cia,
                    codban,
                    tipcta,
                    codmon,
                    nrocta,
                    observ,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_compania_banco.id_cia,
                    rec_compania_banco.codban,
                    rec_compania_banco.tipcta,
                    rec_compania_banco.codmon,
                    rec_compania_banco.nrocta,
                    rec_compania_banco.observ,
                    rec_compania_banco.ucreac,
                    rec_compania_banco.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE compania_banco
                SET
                    nrocta =
                        CASE
                            WHEN rec_compania_banco.nrocta IS NULL THEN
                                nrocta
                            ELSE
                                rec_compania_banco.nrocta
                        END,
                    observ =
                        CASE
                            WHEN rec_compania_banco.observ IS NULL THEN
                                observ
                            ELSE
                                rec_compania_banco.observ
                        END,
                    uactua = rec_compania_banco.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_compania_banco.id_cia
                    AND codban = rec_compania_banco.codban
                    AND tipcta = rec_compania_banco.tipcta
                    AND codmon = rec_compania_banco.codmon;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM compania_banco
                WHERE
                        id_cia = rec_compania_banco.id_cia
                    AND codban = rec_compania_banco.codban
                    AND tipcta = rec_compania_banco.tipcta
                    AND codmon = rec_compania_banco.codmon;

                COMMIT;
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
                    'message' VALUE 'EL REGISTRO CON EL BANCO [ '
                                    || rec_compania_banco.codban
                                    || ' ], TIPO DE CUENTA [ '
                                    || rec_compania_banco.tipcta
                                    || ' ] Y MONEDA [ '
                                    || rec_compania_banco.codmon
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

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'NO SE PUEDE INSERTAR EL REGISTRO POR EL BANCO [ '
                                        || rec_compania_banco.codban
                                        || ' ]  O TIPO DE OPERACION NO EXISTEN [ '
                                        || rec_compania_banco.tipcta
                                        || ' ] NO EXISTEN!'
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
