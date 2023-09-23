--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_CTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_CTS" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codban NUMBER
    ) RETURN datatable_personal_cts
        PIPELINED
    AS
        v_table datatable_personal_cts;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.codban,
            ef.descri   AS desban,
            pc.tipcta,
            tcta.descri AS destipcta,
            pc.codmon,
            pc.cuenta,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_cts      pc
            LEFT OUTER JOIN e_financiera      ef ON ef.id_cia = pc.id_cia
                                               AND ef.codigo = pc.codban
            LEFT OUTER JOIN e_financiera_tipo tcta ON tcta.id_cia = pc.id_cia
                                                      AND tcta.tipcta = pc.tipcta
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
            AND pc.codban = pin_codban;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_cts
        PIPELINED
    AS
        v_table datatable_personal_cts;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.codban,
            ef.descri   AS desban,
            pc.tipcta,
            tcta.descri AS destipcta,
            pc.codmon,
            pc.cuenta,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_cts      pc
            LEFT OUTER JOIN e_financiera      ef ON ef.id_cia = pc.id_cia
                                               AND ef.codigo = pc.codban
            LEFT OUTER JOIN e_financiera_tipo tcta ON tcta.id_cia = pc.id_cia
                                                      AND tcta.tipcta = pc.tipcta
        WHERE
                pc.id_cia = pin_id_cia
            AND ( pin_codper IS NULL
                  OR pc.codper = pin_codper );

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
--/
--SELECT * FROM pack_articulos_ean.sp_obtener(66,1,'0003858',1);
--
--SELECT * FROM pack_articulos_ean.sp_buscar(66,1,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                json_object_t;
        rec_personal_cts personal_cts%rowtype;
        v_accion         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_cts.id_cia := pin_id_cia;
        rec_personal_cts.codper := o.get_string('codper');
        rec_personal_cts.codban := o.get_number('codban');
        rec_personal_cts.tipcta := o.get_number('tipcta');
        rec_personal_cts.codmon := o.get_string('codmon');
        rec_personal_cts.cuenta := o.get_string('cuenta');
        rec_personal_cts.ucreac := o.get_string('ucreac');
        rec_personal_cts.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_cts (
                    id_cia,
                    codper,
                    codban,
                    tipcta,
                    codmon,
                    cuenta,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_cts.id_cia,
                    rec_personal_cts.codper,
                    rec_personal_cts.codban,
                    rec_personal_cts.tipcta,
                    rec_personal_cts.codmon,
                    rec_personal_cts.cuenta,
                    rec_personal_cts.ucreac,
                    rec_personal_cts.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE personal_cts
                SET
                    tipcta =
                        CASE
                            WHEN rec_personal_cts.tipcta IS NULL THEN
                                tipcta
                            ELSE
                                rec_personal_cts.tipcta
                        END,
                    codmon =
                        CASE
                            WHEN rec_personal_cts.codmon IS NULL THEN
                                codmon
                            ELSE
                                rec_personal_cts.codmon
                        END,
                    cuenta =
                        CASE
                            WHEN rec_personal_cts.cuenta IS NULL THEN
                                cuenta
                            ELSE
                                rec_personal_cts.cuenta
                        END,
                    uactua = rec_personal_cts.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_cts.id_cia
                    AND codper = rec_personal_cts.codper
                    AND codban = rec_personal_cts.codban;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_cts
                WHERE
                        id_cia = rec_personal_cts.id_cia
                    AND codper = rec_personal_cts.codper
                    AND codban = rec_personal_cts.codban;

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
                    'message' VALUE 'El registro con CODIGO DE PERSONAL [ '
                                    || rec_personal_cts.codper
                                    || ' ] y BANCO [ '
                                    || rec_personal_cts.codban
                                    || ' ] YA EXISTE Y NO PUEDE DUPLICARSE'
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Banco [ '
                                        || rec_personal_cts.codban
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
    END sp_save;

END;

/
