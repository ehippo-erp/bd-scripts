--------------------------------------------------------
--  DDL for Package Body PACK_CF_EXCELDINAMICO_GRUPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_EXCELDINAMICO_GRUPO" AS

    FUNCTION sp_obtener (
        pin_id_cia   NUMBER,
        pin_codexc   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_exceldinamico_grupo
        PIPELINED
    AS
        v_table datatable_exceldinamico_grupo;
    BEGIN
        SELECT
            ex.id_cia,
            ex.codexc,
            ex.codgrupo,
            gu.desgrupo,
            ex.ucreac,
            ex.uactua,
            ex.fcreac,
            ex.factua
        BULK COLLECT
        INTO v_table
        FROM
            exceldinamico_grupo ex
            LEFT OUTER JOIN grupo_usuario       gu ON gu.id_cia = ex.id_cia
                                                AND gu.codgrupo = ex.codgrupo
        WHERE
                ex.id_cia = pin_id_cia
            AND ex.codexc = pin_codexc
            AND ex.codgrupo = pin_codgrupo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_codexc   NUMBER,
        pin_codgrupo NUMBER
    ) RETURN datatable_exceldinamico_grupo
        PIPELINED
    AS
        v_table datatable_exceldinamico_grupo;
    BEGIN
        SELECT
            ex.id_cia,
            ex.codexc,
            ex.codgrupo,
            gu.desgrupo,
            ex.ucreac,
            ex.uactua,
            ex.fcreac,
            ex.factua
        BULK COLLECT
        INTO v_table
        FROM
            exceldinamico_grupo ex
            LEFT OUTER JOIN grupo_usuario       gu ON gu.id_cia = ex.id_cia
                                                AND gu.codgrupo = ex.codgrupo
        WHERE
                ex.id_cia = pin_id_cia
            AND ( nvl(pin_codexc, - 1) = - 1
                  OR ex.codexc = pin_codexc )
            AND ( nvl(pin_codgrupo, - 1) = - 1
                  OR ex.codgrupo = pin_codgrupo );

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
--                "codexc":500,
--                "codgrupo":1,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cf_exceldinamico_grupo.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_exceldinamico_grupo.sp_obtener(25,500,1);
--
--SELECT * FROM pack_cf_exceldinamico_grupo.sp_buscar(25,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                       json_object_t;
        rec_exceldinamico_grupo exceldinamico_grupo%rowtype;
        v_accion                VARCHAR2(50) := '';
        pout_mensaje            VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_exceldinamico_grupo.id_cia := pin_id_cia;
        rec_exceldinamico_grupo.codexc := o.get_number('codexc');
        rec_exceldinamico_grupo.codgrupo := o.get_number('codgrupo');
        rec_exceldinamico_grupo.ucreac := o.get_string('ucreac');
        rec_exceldinamico_grupo.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO exceldinamico_grupo (
                    id_cia,
                    codexc,
                    codgrupo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_exceldinamico_grupo.id_cia,
                    rec_exceldinamico_grupo.codexc,
                    rec_exceldinamico_grupo.codgrupo,
                    rec_exceldinamico_grupo.ucreac,
                    rec_exceldinamico_grupo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
--                UPDATE exceldinamico_grupo
--                SET
--                    desgrupo =
--                        CASE
--                            WHEN rec_exceldinamico_grupo.desgrupo IS NULL THEN
--                                desgrupo
--                            ELSE
--                                rec_exceldinamico_grupo.desgrupo
--                        END,
--                    swacti =
--                        CASE
--                            WHEN rec_exceldinamico_grupo.swacti IS NULL THEN
--                                swacti
--                            ELSE
--                                rec_exceldinamico_grupo.swacti
--                        END,
--                    uactua = rec_exceldinamico_grupo.uactua,
--                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
--             'YYYY-MM-DD HH24:MI:SS')
--                WHERE
--                        id_cia = rec_exceldinamico_grupo.id_cia
--                    AND codgrupo = rec_exceldinamico_grupo.codgrupo;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM exceldinamico_grupo
                WHERE
                        id_cia = rec_exceldinamico_grupo.id_cia
                    AND codexc = rec_exceldinamico_grupo.codexc
                    AND codgrupo = rec_exceldinamico_grupo.codgrupo;

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
                    'message' VALUE 'El registro con CODIGO DE REPORTE [ '
                                    || rec_exceldinamico_grupo.codexc
                                    || ' ], para el GRUPO [ '
                                    || rec_exceldinamico_grupo.codgrupo
                                    || ' ] ya existe y no puede duplicarse ...!'
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

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede INSERTAR O MODIFICAR este registro, porque el CODIGO DE GRUPO [ '
                                        || rec_exceldinamico_grupo.codgrupo
                                        || ' ] NO EXISTE'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede INSERTAR O MODIFICAR este registro, porque el no esta asociado a NINGUN REPORTE'
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
