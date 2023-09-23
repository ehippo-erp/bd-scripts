--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_CCOSTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_CCOSTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codcco VARCHAR2
    ) RETURN datatable_personal_ccosto
        PIPELINED
    AS
        v_table datatable_personal_ccosto;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.codcco,
            tc.descri AS descoo,
            p.prcdis,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_ccosto p
            LEFT OUTER JOIN tccostos        tc ON tc.id_cia = p.id_cia
                                           AND tc.codigo = p.codcco
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper = pin_codper
            AND p.codcco = pin_codcco;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_ccosto
        PIPELINED
    AS
        v_table datatable_personal_ccosto;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.codcco,
            tc.descri AS descoo,
            p.prcdis,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_ccosto p
            LEFT OUTER JOIN tccostos        tc ON tc.id_cia = p.id_cia
                                           AND tc.codigo = p.codcco
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper = pin_codper;

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
--                "codper":"P001",
--                "codcco":"921010",
--                "prcdis":1564,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_ccosto.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_ccosto.sp_obtener(66,'P001','921010');
--
--SELECT * FROM pack_hr_personal_ccosto.sp_buscar(66,'P001');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                   json_object_t;
        rec_personal_ccosto personal_ccosto%rowtype;
        v_accion            VARCHAR2(50) := '';
        pout_mensaje        VARCHAR2(1000) := '';
        v_prcdis            NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_ccosto.id_cia := pin_id_cia;
        rec_personal_ccosto.codper := o.get_string('codper');
        rec_personal_ccosto.codcco := o.get_string('codcco');
        rec_personal_ccosto.prcdis := o.get_number('prcdis');
        rec_personal_ccosto.ucreac := o.get_string('ucreac');
        rec_personal_ccosto.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                BEGIN
                    SELECT
                        SUM(prcdis)
                    INTO v_prcdis
                    FROM
                        pack_hr_personal_ccosto.sp_buscar(pin_id_cia, rec_personal_ccosto.codper);

                EXCEPTION
                    WHEN no_data_found THEN
                        v_prcdis := 0;
                END;

                IF v_prcdis + rec_personal_ccosto.prcdis > 100 THEN
                    pout_mensaje := 'La suma total de los porcentajes de distribución no puede exceder el 100% [ '
                                    || ( v_prcdis + rec_personal_ccosto.prcdis )
                                    || '% ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                INSERT INTO personal_ccosto (
                    id_cia,
                    codper,
                    codcco,
                    prcdis,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_ccosto.id_cia,
                    rec_personal_ccosto.codper,
                    rec_personal_ccosto.codcco,
                    rec_personal_ccosto.prcdis,
                    rec_personal_ccosto.ucreac,
                    rec_personal_ccosto.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE personal_ccosto
                SET
                    prcdis =
                        CASE
                            WHEN rec_personal_ccosto.prcdis IS NULL THEN
                                prcdis
                            ELSE
                                rec_personal_ccosto.prcdis
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal_ccosto.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_personal_ccosto.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_ccosto.id_cia
                    AND codper = rec_personal_ccosto.codper
                    AND codcco = rec_personal_ccosto.codcco;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_ccosto
                WHERE
                        id_cia = rec_personal_ccosto.id_cia
                    AND codper = rec_personal_ccosto.codper
                    AND codcco = rec_personal_ccosto.codcco;

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
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_personal_ccosto.codper
                                    || ' ] y con el TCCostos [ '
                                    || rec_personal_ccosto.codcco
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

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el TCCostos [ '
                                        || rec_personal_ccosto.codcco
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
