--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_CONTRATO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_CONTRATO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_nrocon VARCHAR2
    ) RETURN datatable_personal_contrato
        PIPELINED
    AS
        v_table datatable_personal_contrato;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            personal_contrato
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper
            AND nrocon = pin_nrocon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_contrato
        PIPELINED
    AS
        v_table datatable_personal_contrato;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            personal_contrato
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper;

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
--                "codper":"72776354",
--                "nrocon":1000,
--                "finicio":"2021-01-05",
--                "ffin":"2023-01-05",
--                "ftermino":"",
--                "formato":"application/pdf",
--                "duracion":12,
--                "observ":"PRUEBA",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_hr_personal_contrato.sp_save(25,NULL, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_contrato.sp_obtener(25,'72776354',1000);
--
--SELECT * FROM pack_hr_personal_contrato.sp_buscar(25,'72776354');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                     json_object_t;
        rec_personal_contrato personal_contrato%rowtype;
        v_accion              VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_contrato.id_cia := pin_id_cia;
        rec_personal_contrato.codper := o.get_string('codper');
        rec_personal_contrato.nrocon := o.get_number('nrocon');
        rec_personal_contrato.finicio := o.get_date('finicio');
        rec_personal_contrato.ffin := o.get_date('ffin');
        rec_personal_contrato.ftermino := o.get_date('ftermino');
        rec_personal_contrato.duracion := o.get_number('duracion');
        rec_personal_contrato.countadj := o.get_number('countadj');
        rec_personal_contrato.observ := o.get_string('observ');
        rec_personal_contrato.ucreac := o.get_string('ucreac');
        rec_personal_contrato.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_contrato (
                    id_cia,
                    codper,
                    nrocon,
                    finicio,
                    ffin,
                    ftermino,
                    duracion,
                    countadj,
                    observ,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_contrato.id_cia,
                    rec_personal_contrato.codper,
                    rec_personal_contrato.nrocon,
                    rec_personal_contrato.finicio,
                    rec_personal_contrato.ffin,
                    rec_personal_contrato.ftermino,
                    rec_personal_contrato.duracion,
                    rec_personal_contrato.countadj,
                    rec_personal_contrato.observ,
                    rec_personal_contrato.ucreac,
                    rec_personal_contrato.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE personal_contrato
                SET
                    ffin =
                        CASE
                            WHEN rec_personal_contrato.ffin IS NULL THEN
                                ffin
                            ELSE
                                rec_personal_contrato.ffin
                        END,
                    finicio =
                        CASE
                            WHEN rec_personal_contrato.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_personal_contrato.finicio
                        END,
                    ftermino =
                        CASE
                            WHEN rec_personal_contrato.ftermino IS NULL THEN
                                ftermino
                            ELSE
                                rec_personal_contrato.ftermino
                        END,
                    observ =
                        CASE
                            WHEN rec_personal_contrato.observ IS NULL THEN
                                observ
                            ELSE
                                rec_personal_contrato.observ
                        END,
                    countadj =
                        CASE
                            WHEN rec_personal_contrato.countadj IS NULL THEN
                                countadj
                            ELSE
                                rec_personal_contrato.countadj
                        END,
                    uactua = rec_personal_contrato.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_contrato.id_cia
                    AND codper = rec_personal_contrato.codper
                    AND nrocon = rec_personal_contrato.nrocon;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_contrato
                WHERE
                        id_cia = rec_personal_contrato.id_cia
                    AND codper = rec_personal_contrato.codper
                    AND nrocon = rec_personal_contrato.nrocon;

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
                                    || rec_personal_contrato.codper
                                    || ' ] y con el NroContrato [ '
                                    || rec_personal_contrato.nrocon
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
                        'message' VALUE 'No se insertar o modificar este registro porque el Codigo de Personal [ '
                                        || rec_personal_contrato.codper
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

                NULL;
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
