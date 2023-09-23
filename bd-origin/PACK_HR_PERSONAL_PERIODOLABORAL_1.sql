--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_PERIODOLABORAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_PERIODOLABORAL" AS

    FUNCTION sp_obtener (
        pin_id_cia  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_id_plab IN NUMBER
    ) RETURN datatable_personal_periodolaboral
        PIPELINED
    IS
        v_table datatable_personal_periodolaboral;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            personal_periodolaboral
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper
            AND id_plab = pin_id_plab;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_personal_periodolaboral
        PIPELINED
    IS
        v_table datatable_personal_periodolaboral;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            personal_periodolaboral c
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
--        "codper":"P002",
--        "id_plab":7,
--        "finicio":"2023-01-05",
--        "ffinal":"2023-06-05",
--        "ucreac":"admin1",
--        "uactua":"admin1"
--        }';
--
--pack_hr_personal_periodolaboral.sp_save(30, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_periodolaboral.sp_obtener(30,'P002',1);
--
--SELECT * FROM pack_hr_personal_periodolaboral.sp_buscar(30,'P002');
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o                           json_object_t;
        rec_personal_periodolaboral personal_periodolaboral%rowtype;
        v_id_plab                   rec_personal_periodolaboral.id_plab%TYPE;
        v_accion                    VARCHAR2(50) := '';
        v_aux                       VARCHAR2(10) := '';
        v_conteo                    NUMBER := 0;
        pout_mensaje                VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_periodolaboral.id_cia := pin_id_cia;
        rec_personal_periodolaboral.codper := o.get_string('codper');
        rec_personal_periodolaboral.id_plab := o.get_number('id_plab');
        rec_personal_periodolaboral.finicio := o.get_date('finicio');
        rec_personal_periodolaboral.ffinal := o.get_date('ffinal');
        rec_personal_periodolaboral.ucreac := o.get_string('ucreac');
        rec_personal_periodolaboral.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        IF rec_personal_periodolaboral.finicio > rec_personal_periodolaboral.ffinal THEN
            pout_mensaje := 'La fecha DESDE [ '
                            || to_char(rec_personal_periodolaboral.finicio, 'DD/MM/YYYY')
                            || ' ] , no puede ser mayor a la fecha HASTA [ '
                            || to_char(rec_personal_periodolaboral.ffinal, 'DD/MM/YYYY')
                            || ' ] en un periodo laboral ...!';

            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF NOT ( EXTRACT(YEAR FROM rec_personal_periodolaboral.finicio) BETWEEN 2000 AND 3000 ) THEN
            pout_mensaje := 'Ingrese una fecha valida, estamos en el siglo XXI ...!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        nvl(id_plab, 0) + 1
                    INTO rec_personal_periodolaboral.id_plab
                    FROM
                        personal_periodolaboral
                    WHERE
                            id_cia = rec_personal_periodolaboral.id_cia
                        AND codper = rec_personal_periodolaboral.codper
                    ORDER BY
                        id_plab DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_personal_periodolaboral.id_plab := 1;
                END;

                IF
                    rec_personal_periodolaboral.ffinal IS NULL
                    AND pin_opcdml <> 3
                THEN
                    BEGIN
                        SELECT
                            id_plab,
                            'S'
                        INTO
                            v_id_plab,
                            v_aux
                        FROM
                            personal_periodolaboral
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodolaboral.codper
                            AND ffinal IS NULL;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_aux := 'N';
                    END;

                    IF
                        v_aux = 'S'
                        AND v_id_plab <> rec_personal_periodolaboral.id_plab
                    THEN
                        pout_mensaje := 'Nos de admiten dos o más periodos laborales con FECHA FINAL VACIA ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

                INSERT INTO personal_periodolaboral (
                    id_cia,
                    codper,
                    id_plab,
                    finicio,
                    ffinal,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_periodolaboral.id_cia,
                    rec_personal_periodolaboral.codper,
                    rec_personal_periodolaboral.id_plab,
                    rec_personal_periodolaboral.finicio,
                    rec_personal_periodolaboral.ffinal,
                    rec_personal_periodolaboral.ucreac,
                    rec_personal_periodolaboral.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                IF
                    rec_personal_periodolaboral.ffinal IS NULL
                    AND pin_opcdml <> 3
                THEN
                    BEGIN
                        SELECT
                            id_plab,
                            'S'
                        INTO
                            v_id_plab,
                            v_aux
                        FROM
                            personal_periodolaboral
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodolaboral.codper
                            AND ffinal IS NULL;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_aux := 'N';
                    END;

                    IF
                        v_aux = 'S'
                        AND v_id_plab <> rec_personal_periodolaboral.id_plab
                    THEN
                        pout_mensaje := 'Nos de admiten dos o más periodos laborales con FECHA FINAL VACIA ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

                UPDATE personal_periodolaboral
                SET
                    finicio =
                        CASE
                            WHEN rec_personal_periodolaboral.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_personal_periodolaboral.finicio
                        END,
                    ffinal = rec_personal_periodolaboral.ffinal,
--                    ffinal =
--                        CASE
--                            WHEN rec_personal_periodolaboral.ffinal IS NULL THEN
--                                ffinal
--                            ELSE
--                                rec_personal_periodolaboral.ffinal
--                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_periodolaboral.id_cia
                    AND codper = rec_personal_periodolaboral.codper
                    AND id_plab = rec_personal_periodolaboral.id_plab;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_periodolaboral
                WHERE
                        id_cia = rec_personal_periodolaboral.id_cia
                    AND codper = rec_personal_periodolaboral.codper
                    AND id_plab = rec_personal_periodolaboral.id_plab;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

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
                    'message' VALUE 'El registro con codper de personal [ '
                                    || rec_personal_periodolaboral.codper
                                    || ' ] y ID [ '
                                    || rec_personal_periodolaboral.id_plab
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
                        'message' VALUE 'No se insertar o modificar este registro porque el codigo de Personal [ '
                                        || rec_personal_periodolaboral.codper
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque algun campo obligatorio no ha sido ingresado, revise la Fecha de Inicio'
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
