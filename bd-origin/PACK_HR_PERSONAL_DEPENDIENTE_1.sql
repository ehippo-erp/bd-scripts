--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_DEPENDIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_DEPENDIENTE" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_item   VARCHAR2
    ) RETURN datatable_personal_dependiente
        PIPELINED
    AS
        v_table datatable_personal_dependiente;
    BEGIN
        SELECT
            dp.id_cia,
            dp.codper,
            dp.item,
            dp.clas03,
            dp.codi03,
            cc03.descri as desclas03,
            dp.numdoc, 
            dp.apepat,
            dp.apemat,
            dp.nombre,
            dp.fecnac,
            dp.sexo,
            dp.clas19,
            dp.codi19,
            cc19.descri as desclas19,
            dp.fecalt,
            dp.clas20,
            dp.codi20,
            cc20.descri as desclas20,
            dp.misdom,
            dp.ucreac,
            dp.uactua,
            dp.fcreac,
            dp.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_dependiente  dp
            LEFT OUTER JOIN clase_codigo_personal cc03 ON cc03.id_cia = dp.id_cia
                                                          AND cc03.clase = dp.clas03
                                                          AND cc03.codigo = dp.codi03
            LEFT OUTER JOIN clase_codigo_personal cc19 ON cc19.id_cia = dp.id_cia
                                                          AND cc19.clase = dp.clas19
                                                          AND cc19.codigo = dp.codi19
            LEFT OUTER JOIN clase_codigo_personal cc20 ON cc20.id_cia = dp.id_cia
                                                          AND cc20.clase = dp.clas20
                                                          AND cc20.codigo = dp.codi20
        WHERE
                dp.id_cia = pin_id_cia
            AND dp.codper = pin_codper
            AND dp.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_dependiente
        PIPELINED
    AS
        v_table datatable_personal_dependiente;
    BEGIN
       SELECT
            dp.id_cia,
            dp.codper,
            dp.item,
            dp.clas03,
            dp.codi03,
            cc03.descri as desclas03,
            dp.numdoc, 
            dp.apepat,
            dp.apemat,
            dp.nombre,
            dp.fecnac,
            dp.sexo,
            dp.clas19,
            dp.codi19,
            cc19.descri as desclas19,
            dp.fecalt,
            dp.clas20,
            dp.codi20,
            cc20.descri as desclas20,
            dp.misdom,
            dp.ucreac,
            dp.uactua,
            dp.fcreac,
            dp.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_dependiente  dp
            LEFT OUTER JOIN clase_codigo_personal cc03 ON cc03.id_cia = dp.id_cia
                                                          AND cc03.clase = dp.clas03
                                                          AND cc03.codigo = dp.codi03
            LEFT OUTER JOIN clase_codigo_personal cc19 ON cc19.id_cia = dp.id_cia
                                                          AND cc19.clase = dp.clas19
                                                          AND cc19.codigo = dp.codi19
            LEFT OUTER JOIN clase_codigo_personal cc20 ON cc20.id_cia = dp.id_cia
                                                          AND cc20.clase = dp.clas20
                                                          AND cc20.codigo = dp.codi20
        WHERE
                dp.id_cia = pin_id_cia
            AND dp.codper = pin_codper;

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
--                "item":100,
--                "numdoc":"54165465165",
--                "clas03":3,
--                "codi03":"01",
--                "numdoc":"72776354",
--                "apepat":"Calvo",
--                "apemat":"Quispe",
--                "nombre":"Luis Antonio",
--                "fecnac":"2022-01-01",
--                "sexo":"M",
--                "clas19":19,
--                "codi19":"1",
--                "fecalt":"",
--                "clas20":"",
--                "codi20":"",
--                "misdom":"4",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_dependiente.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_dependiente.sp_obtener(66,'P001',100);
--
--SELECT * FROM pack_hr_personal_dependiente.sp_buscar(66,'P001');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                        json_object_t;
        rec_personal_dependiente personal_dependiente%rowtype;
        v_accion                 VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_dependiente.id_cia := pin_id_cia;
        rec_personal_dependiente.codper := o.get_string('codper');
        rec_personal_dependiente.item := o.get_string('item');
        rec_personal_dependiente.clas03 := o.get_number('clas03');
        rec_personal_dependiente.codi03 := o.get_string('codi03');
        rec_personal_dependiente.numdoc := o.get_string('numdoc');
        rec_personal_dependiente.apepat := o.get_string('apepat');
        rec_personal_dependiente.apemat := o.get_string('apemat');
        rec_personal_dependiente.nombre := o.get_string('nombre');
        rec_personal_dependiente.fecnac := o.get_date('fecnac');
        rec_personal_dependiente.sexo := o.get_string('sexo');
        rec_personal_dependiente.clas19 := o.get_number('clas19');
        rec_personal_dependiente.codi19 := o.get_string('codi19');
        rec_personal_dependiente.fecalt := o.get_date('fecalt');
        rec_personal_dependiente.clas20 := o.get_number('clas20');
        rec_personal_dependiente.codi20 := o.get_string('codi20');
        rec_personal_dependiente.misdom := o.get_string('misdom');
        rec_personal_dependiente.ucreac := o.get_string('ucreac');
        rec_personal_dependiente.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO personal_dependiente (
                    id_cia,
                    codper,
                    item,
                    clas03,
                    codi03,
                    numdoc,
                    apepat,
                    apemat,
                    nombre,
                    fecnac,
                    sexo,
                    clas19,
                    codi19,
                    fecalt,
                    clas20,
                    codi20,
                    misdom,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_dependiente.id_cia,
                    rec_personal_dependiente.codper,
                    rec_personal_dependiente.item,
                    rec_personal_dependiente.clas03,
                    rec_personal_dependiente.codi03,
                    rec_personal_dependiente.numdoc,
                    rec_personal_dependiente.apepat,
                    rec_personal_dependiente.apemat,
                    rec_personal_dependiente.nombre,
                    rec_personal_dependiente.fecnac,
                    rec_personal_dependiente.sexo,
                    rec_personal_dependiente.clas19,
                    rec_personal_dependiente.codi19,
                    rec_personal_dependiente.fecalt,
                    rec_personal_dependiente.clas20,
                    rec_personal_dependiente.codi20,
                    rec_personal_dependiente.misdom,
                    rec_personal_dependiente.ucreac,
                    rec_personal_dependiente.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE personal_dependiente
                SET
                    clas03 =
                        CASE
                            WHEN rec_personal_dependiente.clas03 IS NULL THEN
                                clas03
                            ELSE
                                rec_personal_dependiente.clas03
                        END,
                    codi03 =
                        CASE
                            WHEN rec_personal_dependiente.codi03 IS NULL THEN
                                codi03
                            ELSE
                                rec_personal_dependiente.codi03
                        END,
                    numdoc =
                        CASE
                            WHEN rec_personal_dependiente.numdoc IS NULL THEN
                                numdoc
                            ELSE
                                rec_personal_dependiente.numdoc
                        END,
                    apepat =
                        CASE
                            WHEN rec_personal_dependiente.apepat IS NULL THEN
                                apepat
                            ELSE
                                rec_personal_dependiente.apepat
                        END,
                    apemat =
                        CASE
                            WHEN rec_personal_dependiente.apemat IS NULL THEN
                                apemat
                            ELSE
                                rec_personal_dependiente.apemat
                        END,
                    nombre =
                        CASE
                            WHEN rec_personal_dependiente.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_personal_dependiente.nombre
                        END,
                    fecnac =
                        CASE
                            WHEN rec_personal_dependiente.fecnac IS NULL THEN
                                fecnac
                            ELSE
                                rec_personal_dependiente.fecnac
                        END,
                    sexo =
                        CASE
                            WHEN rec_personal_dependiente.sexo IS NULL THEN
                                sexo
                            ELSE
                                rec_personal_dependiente.sexo
                        END,
                    clas19 =
                        CASE
                            WHEN rec_personal_dependiente.clas19 IS NULL THEN
                                clas19
                            ELSE
                                rec_personal_dependiente.clas19
                        END,
                    codi19 =
                        CASE
                            WHEN rec_personal_dependiente.codi19 IS NULL THEN
                                codi19
                            ELSE
                                rec_personal_dependiente.codi19
                        END,
                    fecalt =
                        CASE
                            WHEN rec_personal_dependiente.fecalt IS NULL THEN
                                fecalt
                            ELSE
                                rec_personal_dependiente.fecalt
                        END,
                    clas20 =
                        CASE
                            WHEN rec_personal_dependiente.clas20 IS NULL THEN
                                clas20
                            ELSE
                                rec_personal_dependiente.clas20
                        END,
                    codi20 =
                        CASE
                            WHEN rec_personal_dependiente.codi20 IS NULL THEN
                                codi20
                            ELSE
                                rec_personal_dependiente.codi20
                        END,
                    misdom =
                        CASE
                            WHEN rec_personal_dependiente.misdom IS NULL THEN
                                misdom
                            ELSE
                                rec_personal_dependiente.misdom
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal_dependiente.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_personal_dependiente.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_dependiente.id_cia
                    AND codper = rec_personal_dependiente.codper
                    AND item = rec_personal_dependiente.item;

                NULL;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM personal_dependiente
                WHERE
                        id_cia = rec_personal_dependiente.id_cia
                    AND codper = rec_personal_dependiente.codper
                    AND item = rec_personal_dependiente.item;

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
                                    || rec_personal_dependiente.codper
                                    || ' ] y con el IITEM [ '
                                    || rec_personal_dependiente.item
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
                        'message' VALUE 'No se insertar o modificar este registro porque alguna de las clases ( Nacionalidad, Relación y Motivo de Cese ) no existe ...! '
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
