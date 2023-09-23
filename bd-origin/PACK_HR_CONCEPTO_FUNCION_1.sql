--------------------------------------------------------
--  DDL for Package Body PACK_HR_CONCEPTO_FUNCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CONCEPTO_FUNCION" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_condes VARCHAR2,
        pin_conori VARCHAR2,
        pin_codfun NUMBER
    ) RETURN datatable_concepto_funcion
        PIPELINED
    AS
        v_table datatable_concepto_funcion;
    BEGIN
        SELECT
            cf.id_cia,
            cf.condes,
            des.nombre AS desdes,
            cf.conori,
            ori.nombre AS desori,
            cf.codfun,
            fp.nombre  AS desfun,
            fp.nomfun,
            fp.observ,
            cf.ucreac,
            cf.uactua,
            cf.fcreac,
            cf.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_funcion cf
            LEFT OUTER JOIN concepto         ori ON ori.id_cia = cf.id_cia
                                            AND ori.codcon = cf.conori
            LEFT OUTER JOIN concepto         des ON des.id_cia = cf.id_cia
                                            AND des.codcon = cf.condes
            LEFT OUTER JOIN funcion_planilla fp ON fp.id_cia = cf.id_cia
                                                   AND fp.codfun = cf.codfun
        WHERE
                cf.id_cia = pin_id_cia
            AND cf.condes = pin_condes
            AND cf.conori = pin_conori
            AND cf.codfun = pin_codfun;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_condes VARCHAR2,
        pin_conori VARCHAR2,
        pin_codfun NUMBER
    ) RETURN datatable_concepto_funcion
        PIPELINED
    AS
        v_table datatable_concepto_funcion;
    BEGIN
        SELECT
            cf.id_cia,
            cf.condes,
            des.nombre AS desdes,
            cf.conori,
            ori.nombre AS desori,
            cf.codfun,
            fp.nombre  AS desfun,
            fp.nomfun,
            fp.observ,
            cf.ucreac,
            cf.uactua,
            cf.fcreac,
            cf.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto_funcion cf
            LEFT OUTER JOIN concepto         ori ON ori.id_cia = cf.id_cia
                                            AND ori.codcon = cf.conori
            LEFT OUTER JOIN concepto         des ON des.id_cia = cf.id_cia
                                            AND des.codcon = cf.condes
            LEFT OUTER JOIN funcion_planilla fp ON fp.id_cia = cf.id_cia
                                                   AND fp.codfun = cf.codfun
        WHERE
                cf.id_cia = pin_id_cia
            AND ( pin_condes IS NULL
                  OR cf.condes = pin_condes )
            AND ( pin_conori IS NULL
                  OR cf.conori = pin_conori )
            AND ( pin_codfun IS NULL
                  OR cf.codfun = pin_codfun );

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
--                "condes":"POP",
--                "conori":"POP",
--                "codfun":2,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_concepto_funcion.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_concepto_funcion.sp_obtener(66,'POP','POP',2);
--
--SELECT * FROM pack_hr_concepto_funcion.sp_buscar(66,'POP',NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                    json_object_t;
        rec_concepto_funcion concepto_funcion%rowtype;
        v_accion             VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_concepto_funcion.id_cia := pin_id_cia;
        rec_concepto_funcion.condes := o.get_string('condes');
        rec_concepto_funcion.conori := o.get_string('conori');
        rec_concepto_funcion.codfun := o.get_number('codfun');
        rec_concepto_funcion.ucreac := o.get_string('ucreac');
        rec_concepto_funcion.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO concepto_funcion (
                    id_cia,
                    condes,
                    conori,
                    codfun,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_concepto_funcion.id_cia,
                    rec_concepto_funcion.condes,
                    rec_concepto_funcion.conori,
                    rec_concepto_funcion.codfun,
                    rec_concepto_funcion.ucreac,
                    rec_concepto_funcion.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE concepto_funcion
--                SET
--                    uactua =
--                        CASE
--                            WHEN rec_concepto_funcion.uactua IS NULL THEN
--                                ''
--                            ELSE
--                                rec_concepto_funcion.uactua
--                        END,
--                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_concepto_funcion.id_cia
--                    AND condes = rec_concepto_funcion.condes
--                    AND conori = rec_concepto_funcion.conori
--                    AND codfun = rec_concepto_funcion.codfun;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM concepto_funcion
                WHERE
                        id_cia = rec_concepto_funcion.id_cia
                    AND condes = rec_concepto_funcion.condes
                    AND conori = rec_concepto_funcion.conori
                    AND codfun = rec_concepto_funcion.codfun;

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
                    'message' VALUE 'El registro para el codigo de Concepto de Destino [ '
                                    || rec_concepto_funcion.condes
                                    || ' ], con el Concepto de Origen [ '
                                    || rec_concepto_funcion.conori
                                    || ' ] y con la Codigo de Funcion [ '
                                    || rec_concepto_funcion.codfun
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
                        'message' VALUE 'No es posible insertar o modificar este registro porque el Codigo de Funcion [ '
                                        || rec_concepto_funcion.codfun
                                        || ' ] o el Concepto de Origen [ '
                                        || rec_concepto_funcion.conori
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede insertar o modificar este registro porque no se cagaron los conceptos Obligatorios  ...!'
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
