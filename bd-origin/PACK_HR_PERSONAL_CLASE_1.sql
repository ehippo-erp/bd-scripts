--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_CLASE" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2
    ) RETURN datatable_personal_clase
        PIPELINED
    AS
        v_table datatable_personal_clase;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.clase,
            cp.descri AS desclase,
            pc.codigo,
            cc.descri AS descodigo,
            pc.situac,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_clase        pc
            LEFT OUTER JOIN clase_personal        cp ON cp.id_cia = pc.id_cia
                                                 AND cp.clase = pc.clase
            LEFT OUTER JOIN clase_codigo_personal cc ON cc.id_cia = pc.id_cia
                                                        AND cc.clase = pc.clase
                                                        AND cc.codigo = pc.codigo
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
            AND pc.clase = pin_clase
            AND pc.codigo = pin_codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_clase
        PIPELINED
    AS
        v_table datatable_personal_clase;
    BEGIN
        SELECT
            pc.id_cia,
            pc.codper,
            pc.clase,
            cp.descri AS desclase,
            pc.codigo,
            cc.descri AS descodigo,
            pc.situac,
            pc.ucreac,
            pc.uactua,
            pc.fcreac,
            pc.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_clase        pc
            LEFT OUTER JOIN clase_personal        cp ON cp.id_cia = pc.id_cia
                                                 AND cp.clase = pc.clase
            LEFT OUTER JOIN clase_codigo_personal cc ON cc.id_cia = pc.id_cia
                                                        AND cc.clase = pc.clase
                                                        AND cc.codigo = pc.codigo
        WHERE
                pc.id_cia = pin_id_cia
            AND pc.codper = pin_codper
        ORDER BY
            pc.clase ASC;

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
--                "codper":"P008",
--                "clase":3,
--                "codigo":"01",
--                "situac":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_clase.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_clase.sp_obtener(66,'P008',3,'01');
--
--SELECT * FROM pack_hr_personal_clase.sp_buscar(66,'P008');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_personal_clase personal_clase%rowtype;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_clase.id_cia := pin_id_cia;
        rec_personal_clase.codper := o.get_string('codper');
        rec_personal_clase.clase := o.get_number('clase');
        rec_personal_clase.codigo := o.get_string('codigo');
        rec_personal_clase.situac := o.get_string('situac');
        rec_personal_clase.ucreac := o.get_string('ucreac');
        rec_personal_clase.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_clase (
                    id_cia,
                    codper,
                    clase,
                    codigo,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_clase.id_cia,
                    rec_personal_clase.codper,
                    rec_personal_clase.clase,
                    rec_personal_clase.codigo,
                    'S',
                    rec_personal_clase.ucreac,
                    rec_personal_clase.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                IF rec_personal_clase.codigo IS NULL OR rec_personal_clase.codigo = 'ND' THEN
                    UPDATE personal_clase
                    SET
                        situac = 'N'
                    WHERE
                            id_cia = rec_personal_clase.id_cia
                        AND codper = rec_personal_clase.codper
                        AND clase = rec_personal_clase.clase;

                END IF;

            WHEN 2 THEN
                v_accion := 'La actualización';
                IF rec_personal_clase.clase = 11 THEN
                    pout_mensaje := 'No se puede modificar o eliminar esta la clase  [ 11 - REGIMEN PENSIONARIO ], su asignacion es automatica al momento de definir un regimen de pensionario ...!'
                    ;
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                UPDATE personal_clase
                SET
                    codigo = rec_personal_clase.codigo,
                    situac = 'S',
                    uactua = rec_personal_clase.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_clase.id_cia
                    AND codper = rec_personal_clase.codper
                    AND clase = rec_personal_clase.clase;

                IF rec_personal_clase.codigo IS NULL OR rec_personal_clase.codigo = 'ND' THEN
                    UPDATE personal_clase
                    SET
                        situac = 'N'
                    WHERE
                            id_cia = rec_personal_clase.id_cia
                        AND codper = rec_personal_clase.codper
                        AND clase = rec_personal_clase.clase;

                END IF;

            WHEN 3 THEN
                IF rec_personal_clase.clase = 11 THEN
                    pout_mensaje := 'No se puede modificar o eliminar esta la clase  [ 11 - REGIMEN PENSIONARIO ], su asignacion es automatica al momento de definir un regimen de pensionario ...!'
                    ;
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                v_accion := 'La eliminación';
                DELETE FROM personal_clase
                WHERE
                        id_cia = rec_personal_clase.id_cia
                    AND codper = rec_personal_clase.codper
                    AND clase = rec_personal_clase.clase;

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
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro para el codigo de PERSONAL [ '
                                    || rec_personal_clase.codper
                                    || ' ], con la CLASE [ '
                                    || rec_personal_clase.clase
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
                        'message' VALUE 'No se insertar o modificar este registro porque la CLASE [ '
                                        || rec_personal_clase.clase
                                        || ' ] con el CODIGO [ '
                                        || rec_personal_clase.codigo
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque no se cagaron las clases Obligatorias ( Nacionalidad o Relación ) ...!'
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
