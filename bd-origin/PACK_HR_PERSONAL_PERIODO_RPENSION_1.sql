--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_PERIODO_RPENSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_PERIODO_RPENSION" AS

    FUNCTION sp_regimenpension (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_regimenpension
        PIPELINED
    AS
        v_table datatable_regimenpension;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            fs.codafp,
            p.situac,
            trunc(fs.finicio),
            trunc(fs.ffinal),
            trunc(pin_fhasta) - trunc(fs.finicio),
            nvl(fs.ffinal,(fs.finicio + 1000000)) - trunc(pin_fdesde)
        BULK COLLECT
        INTO v_table
        FROM
            personal                  p
            LEFT OUTER JOIN personal_periodo_rpension fs ON fs.id_cia = p.id_cia
                                                            AND fs.codper = p.codper
        WHERE
                p.id_cia = pin_id_cia
--            AND p.tiptra = pin_tiptra
            AND ( trunc(pin_fhasta) - trunc(fs.finicio) ) >= 0
            AND ( trunc(nvl(fs.ffinal,(fs.finicio + 1000000))) - trunc(pin_fdesde) >= 0 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_regimenpension;

    FUNCTION sp_obtener (
        pin_id_cia   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codafp   IN VARCHAR,
        pin_id_prpen IN NUMBER
    ) RETURN datatable_personal_periodo_rpension
        PIPELINED
    IS
        v_table datatable_personal_periodo_rpension;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.id_prpen,
            p.codafp,
            a.nombre AS desafp,
            p.finicio,
            p.ffinal,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_periodo_rpension p
            LEFT OUTER JOIN afp                       a ON a.id_cia = p.id_cia
                                     AND a.codafp = p.codafp
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper = pin_codper
            AND p.codafp = pin_codafp
            AND p.id_prpen = pin_id_prpen;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2,
        pin_codafp IN VARCHAR2
    ) RETURN datatable_personal_periodo_rpension
        PIPELINED
    IS
        v_table datatable_personal_periodo_rpension;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.id_prpen,
            p.codafp,
            a.nombre AS desafp,
            p.finicio,
            p.ffinal,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_periodo_rpension p
            LEFT OUTER JOIN afp                       a ON a.id_cia = p.id_cia
                                     AND a.codafp = p.codafp
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper = pin_codper
            AND ( pin_codafp IS NULL
                  OR p.codafp = pin_codafp )
        ORDER BY
            p.id_prpen DESC;

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
--        "codafp":"HORI",
--        "id_prpen":10,
--        "finicio":"2024-01-05",
--        "ffinal":"2024-06-05",
--        "ucreac":"admin1",
--        "uactua":"admin1"
--        }';
--
--pack_hr_personal_periodo_rpension.sp_save(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--end;
--
--SELECT * FROM pack_hr_personal_periodo_rpension.sp_obtener(66, 'P002','HORI',9);
--
--SELECT * FROM pack_hr_personal_periodo_rpension.sp_buscar(66, 'P002',NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o                             json_object_t;
        rec_personal_periodo_rpension personal_periodo_rpension%rowtype;
        v_accion                      VARCHAR2(50) := '';
        v_aux                         VARCHAR2(10) := '';
        v_id_prpen                    personal_periodo_rpension.id_prpen%TYPE;
        v_nombre                      afp.nombre%TYPE;
        v_codcla                      afp.codcla%TYPE;
        pout_mensaje                  VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_periodo_rpension.id_cia := pin_id_cia;
        rec_personal_periodo_rpension.codper := o.get_string('codper');
        rec_personal_periodo_rpension.codafp := o.get_string('codafp');
        rec_personal_periodo_rpension.id_prpen := o.get_number('id_prpen');
        rec_personal_periodo_rpension.finicio := o.get_date('finicio');
        rec_personal_periodo_rpension.ffinal := o.get_date('ffinal');
        rec_personal_periodo_rpension.ucreac := o.get_string('ucreac');
        rec_personal_periodo_rpension.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        BEGIN
            SELECT
                nombre,
                codcla
            INTO
                v_nombre,
                v_codcla
            FROM
                afp
            WHERE
                    id_cia = pin_id_cia
                AND codafp = rec_personal_periodo_rpension.codafp;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'La AFP con codigo [ '
                                || rec_personal_periodo_rpension.codafp
                                || ' ] no existe ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF rec_personal_periodo_rpension.finicio > rec_personal_periodo_rpension.ffinal THEN
            pout_mensaje := 'La fecha DESDE [ '
                            || to_char(rec_personal_periodo_rpension.finicio, 'DD/MM/YYYY')
                            || ' ] , no puede ser mayor a la fecha HASTA [ '
                            || to_char(rec_personal_periodo_rpension.ffinal, 'DD/MM/YYYY')
                            || ' ] en un Regimen de Pensiones ...!';

            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF NOT ( EXTRACT(YEAR FROM rec_personal_periodo_rpension.finicio) BETWEEN 2000 AND 3000 ) THEN
            pout_mensaje := 'Ingrese una fecha valida, estamos en el siglo XXI ...!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        nvl(id_prpen, 0) + 1
                    INTO rec_personal_periodo_rpension.id_prpen
                    FROM
                        personal_periodo_rpension
                    WHERE
                            id_cia = rec_personal_periodo_rpension.id_cia
                        AND codper = rec_personal_periodo_rpension.codper
                    ORDER BY
                        id_prpen DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_personal_periodo_rpension.id_prpen := 1;
                END;

                IF
                    rec_personal_periodo_rpension.ffinal IS NULL
                    AND pin_opcdml <> 3
                THEN
            -- VALIDAMOS QUE NO EXISTAN MAS DE UN REGUISTRO CON FECHA FINAL NULL
                    BEGIN
                        SELECT
                            id_prpen,
                            'S'
                        INTO
                            v_id_prpen,
                            v_aux
                        FROM
                            personal_periodo_rpension
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodo_rpension.codper
                            AND ffinal IS NULL;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_aux := 'N';
                            v_id_prpen := 0;
                    END;

                    IF
                        v_aux = 'S'
                        AND v_id_prpen <> rec_personal_periodo_rpension.id_prpen
                    THEN
                        pout_mensaje := 'Nos de admiten dos o más periodos laborales con FECHA FINAL VACIA ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

            -- ACTUALIZA EL CODAFP DEL PERSONAL
                    BEGIN
                        UPDATE personal
                        SET
                            codafp = rec_personal_periodo_rpension.codafp,
                            uactua = rec_personal_periodo_rpension.uactua,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodo_rpension.codper;

                    END;

            -- ACTUALIZA LA CLASE 11 - REGIMEN PENSIONARIO
                    BEGIN
                        MERGE INTO personal_clase pc
                        USING dual d ON ( pc.id_cia = pin_id_cia
                                          AND pc.codper = rec_personal_periodo_rpension.codper
                                          AND pc.clase = 11 )
                        WHEN MATCHED THEN UPDATE
                        SET pc.codigo = v_codcla,
                            pc.uactua = rec_personal_periodo_rpension.ucreac,
                            pc.factua = current_date
                        WHEN NOT MATCHED THEN
                        INSERT (
                            id_cia,
                            codper,
                            clase,
                            codigo,
                            situac,
                            ucreac,
                            uactua,
                            fcreac,
                            factua )
                        VALUES
                            ( pin_id_cia,
                              rec_personal_periodo_rpension.codper,
                            11,
                              v_codcla,
                            'S',
                              rec_personal_periodo_rpension.ucreac,
                              rec_personal_periodo_rpension.uactua,
                            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') );

                    EXCEPTION
                        WHEN OTHERS THEN
                            IF sqlcode = -2291 THEN
                                pout_mensaje := 'La Clase [ 11 - REGIMEN PENSIONARIO ] con el Codigo [ '
                                                || v_codcla
                                                || ' - '
                                                || v_nombre
                                                || ' ] no existe ...!';
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            ELSE
                                pout_mensaje := 'mensaje : '
                                                || sqlerrm
                                                || ' codigo :'
                                                || sqlcode;
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;
                    END;

                END IF;

                INSERT INTO personal_periodo_rpension (
                    id_cia,
                    codper,
                    codafp,
                    id_prpen,
                    finicio,
                    ffinal,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_periodo_rpension.id_cia,
                    rec_personal_periodo_rpension.codper,
                    rec_personal_periodo_rpension.codafp,
                    rec_personal_periodo_rpension.id_prpen,
                    rec_personal_periodo_rpension.finicio,
                    rec_personal_periodo_rpension.ffinal,
                    rec_personal_periodo_rpension.ucreac,
                    rec_personal_periodo_rpension.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                IF
                    rec_personal_periodo_rpension.ffinal IS NULL
                    AND pin_opcdml <> 3
                THEN
            -- VALIDAMOS QUE NO EXISTAN MAS DE UN REGUISTRO CON FECHA FINAL NULL
                    BEGIN
                        SELECT
                            id_prpen,
                            'S'
                        INTO
                            v_id_prpen,
                            v_aux
                        FROM
                            personal_periodo_rpension
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodo_rpension.codper
                            AND ffinal IS NULL;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_aux := 'N';
                            v_id_prpen := 0;
                    END;

                    IF
                        v_aux = 'S'
                        AND v_id_prpen <> rec_personal_periodo_rpension.id_prpen
                    THEN
                        pout_mensaje := 'Nos de admiten dos o más periodos laborales con FECHA FINAL VACIA ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

            -- ACTUALIZA EL CODAFP DEL PERSONAL
                    BEGIN
                        UPDATE personal
                        SET
                            codafp = rec_personal_periodo_rpension.codafp,
                            uactua = rec_personal_periodo_rpension.uactua,
                            factua = current_date
                        WHERE
                                id_cia = pin_id_cia
                            AND codper = rec_personal_periodo_rpension.codper;

                    END;

            -- ACTUALIZA LA CLASE 11 - REGIMEN PENSIONARIO
                    BEGIN
                        MERGE INTO personal_clase pc
                        USING dual d ON ( pc.id_cia = pin_id_cia
                                          AND pc.codper = rec_personal_periodo_rpension.codper
                                          AND pc.clase = 11 )
                        WHEN MATCHED THEN UPDATE
                        SET pc.codigo = v_codcla,
                            pc.uactua = rec_personal_periodo_rpension.ucreac,
                            pc.factua = current_date
                        WHEN NOT MATCHED THEN
                        INSERT (
                            id_cia,
                            codper,
                            clase,
                            codigo,
                            situac,
                            ucreac,
                            uactua,
                            fcreac,
                            factua )
                        VALUES
                            ( pin_id_cia,
                              rec_personal_periodo_rpension.codper,
                            11,
                              v_codcla,
                            'S',
                              rec_personal_periodo_rpension.ucreac,
                              rec_personal_periodo_rpension.uactua,
                            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') );

                    EXCEPTION
                        WHEN OTHERS THEN
                            IF sqlcode = -2291 THEN
                                pout_mensaje := 'La Clase [ 11 - REGIMEN PENSIONARIO ] con el Codigo [ '
                                                || v_codcla
                                                || ' - '
                                                || v_nombre
                                                || ' ] no existe ...!';
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            ELSE
                                pout_mensaje := 'mensaje : '
                                                || sqlerrm
                                                || ' codigo :'
                                                || sqlcode;
                                RAISE pkg_exceptionuser.ex_error_inesperado;
                            END IF;
                    END;

                END IF;

                UPDATE personal_periodo_rpension
                SET
                    finicio =
                        CASE
                            WHEN rec_personal_periodo_rpension.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_personal_periodo_rpension.finicio
                        END,
                    ffinal = rec_personal_periodo_rpension.ffinal,
--                    ffinal =
--                        CASE
--                            WHEN rec_personal_periodo_rpension.ffinal IS NULL THEN
--                                ffinal
--                            ELSE
--                                rec_personal_periodo_rpension.ffinal
--                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_periodo_rpension.id_cia
                    AND codper = rec_personal_periodo_rpension.codper
                    AND codafp = rec_personal_periodo_rpension.codafp
                    AND id_prpen = rec_personal_periodo_rpension.id_prpen;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_periodo_rpension
                WHERE
                        id_cia = rec_personal_periodo_rpension.id_cia
                    AND codper = rec_personal_periodo_rpension.codper
                    AND codafp = rec_personal_periodo_rpension.codafp
                    AND id_prpen = rec_personal_periodo_rpension.id_prpen;

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
                                    || rec_personal_periodo_rpension.codper
                                    || ' ] , codigo de AFP [ '
                                    || rec_personal_periodo_rpension.codafp
                                    || ' ] y ID [ '
                                    || rec_personal_periodo_rpension.id_prpen
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
                                        || rec_personal_periodo_rpension.codper
                                        || ' ] o el codido de AFP [ '
                                        || rec_personal_periodo_rpension.codafp
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
