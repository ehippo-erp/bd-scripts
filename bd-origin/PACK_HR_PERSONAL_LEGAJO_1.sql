--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_LEGAJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_LEGAJO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codleg VARCHAR2
    ) RETURN datatable_personal_legajo
        PIPELINED
    AS
        v_table datatable_personal_legajo;
    BEGIN
        SELECT
            pl.id_cia,
            pl.codper,
            pl.codleg,
            pl.descri AS desleg,
            pl.codtip,
            pl.codite,
            ti.nombre AS desitem,
            pl.finicio,
            pl.ffin,
            pl.countadj,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_legajo pl
            LEFT OUTER JOIN tipoitem        ti ON ti.id_cia = pl.id_cia
                                           AND ti.codtip = pl.codtip
                                           AND ti.codite = pl.codite
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.codper = pin_codper
            AND pl.codleg = pin_codleg;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_legajo
        PIPELINED
    AS
        v_table datatable_personal_legajo;
    BEGIN
        SELECT
            pl.id_cia,
            pl.codper,
            pl.codleg,
            pl.descri AS desleg,
            pl.codtip,
            pl.codite,
            ti.nombre AS desitem,
            pl.finicio,
            pl.ffin,
            pl.countadj,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_legajo pl
            LEFT OUTER JOIN tipoitem        ti ON ti.id_cia = pl.id_cia
                                           AND ti.codtip = pl.codtip
                                           AND ti.codite = pl.codite
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.codper = pin_codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--/
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codper":"P002",
--                "codleg":"PPPP",
--                "desleg":"15642",
--                "codtip":"DO",
--                "codite":201,
--                "finicio":"2022-01-01",
--                "ffin":"2023-01-01",
--                "countadj":5,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_legajo.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--/
--SELECT * FROM pack_hr_personal_legajo.sp_obtener(66,'P002','PPPP');
--/
--SELECT * FROM pack_hr_personal_legajo.sp_buscar(66,'P002');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                   json_object_t;
        rec_personal_legajo personal_legajo%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_legajo.id_cia := pin_id_cia;
        rec_personal_legajo.codper := o.get_string('codper');
        rec_personal_legajo.codleg := o.get_string('codleg');
        rec_personal_legajo.descri := o.get_string('desleg');
        rec_personal_legajo.codtip := o.get_string('codtip');
        rec_personal_legajo.codite := o.get_number('codite');
        rec_personal_legajo.finicio := o.get_date('finicio');
        rec_personal_legajo.ffin := o.get_date('ffin');
        rec_personal_legajo.ucreac := o.get_string('ucreac');
        rec_personal_legajo.uactua := o.get_string('uactua');
        rec_personal_legajo.countadj := o.get_number('countadj');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO personal_legajo (
                    id_cia,
                    codper,
                    codleg,
                    descri,
                    codtip,
                    codite,
                    finicio,
                    ffin,
                    countadj,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_legajo.id_cia,
                    rec_personal_legajo.codper,
                    rec_personal_legajo.codleg,
                    rec_personal_legajo.descri,
                    rec_personal_legajo.codtip,
                    rec_personal_legajo.codite,
                    rec_personal_legajo.finicio,
                    rec_personal_legajo.ffin,
                    rec_personal_legajo.countadj,
                    rec_personal_legajo.ucreac,
                    rec_personal_legajo.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE personal_legajo
                SET
                    descri =
                        CASE
                            WHEN rec_personal_legajo.descri IS NULL THEN
                                descri
                            ELSE
                                rec_personal_legajo.descri
                        END,
                    codtip =
                        CASE
                            WHEN rec_personal_legajo.codtip IS NULL THEN
                                codtip
                            ELSE
                                rec_personal_legajo.codtip
                        END,
                    codite =
                        CASE
                            WHEN rec_personal_legajo.codite IS NULL THEN
                                codite
                            ELSE
                                rec_personal_legajo.codite
                        END,
                    countadj =
                        CASE
                            WHEN rec_personal_legajo.countadj IS NULL THEN
                                countadj
                            ELSE
                                rec_personal_legajo.countadj
                        END,
                    finicio =
                        CASE
                            WHEN rec_personal_legajo.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_personal_legajo.finicio
                        END,
                    ffin =
                        CASE
                            WHEN rec_personal_legajo.ffin IS NULL THEN
                                ffin
                            ELSE
                                rec_personal_legajo.ffin
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal_legajo.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_personal_legajo.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_legajo.id_cia
                    AND codper = rec_personal_legajo.codper
                    AND codleg = rec_personal_legajo.codleg;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM personal_legajo
                WHERE
                        id_cia = rec_personal_legajo.id_cia
                    AND codper = rec_personal_legajo.codper
                    AND codleg = rec_personal_legajo.codleg;

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
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_personal_legajo.codper
                                    || ' ] y con el legajo [ '
                                    || rec_personal_legajo.codleg
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
                                        || rec_personal_legajo.codtip
                                        || ' - '
                                        || rec_personal_legajo.codite
                                        || ' ] no existe ...! '
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
