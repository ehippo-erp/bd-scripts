--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL_DOCUMENTO" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2,
        pin_codtip VARCHAR2,
        pin_codite NUMBER
    ) RETURN datatable_personal_documento
        PIPELINED
    AS
        v_table datatable_personal_documento;
    BEGIN
        SELECT
            pd.id_cia,
            pd.codper,
            pd.codtip,
            pd.codite,
            ti.nombre  AS nomtdo,
            pd.nrodoc,
            pd.clase,
            pd.codigo,
            ccp.descri AS destipo,
            pd.situac,
            pd.ucreac,
            pd.uactua,
            pd.fcreac,
            pd.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_documento    pd
            LEFT OUTER JOIN tipoitem              ti ON ti.id_cia = pd.id_cia
                                           AND ti.codtip = 'DO'
                                           AND ti.codite = pd.codite
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = pd.id_cia
                                                         AND ccp.clase = 3
                                                         AND ccp.codigo = pd.codigo
        WHERE
                pd.id_cia = pin_id_cia
            AND pd.codper = pin_codper
            AND pd.codtip = pin_codtip
            AND pd.codite = pin_codite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_personal_documento
        PIPELINED
    AS
        v_table datatable_personal_documento;
    BEGIN
        SELECT
            pd.id_cia,
            pd.codper,
            pd.codtip,
            pd.codite,
            ti.nombre  AS nomtdo,
            pd.nrodoc,
            pd.clase,
            pd.codigo,
            ccp.descri AS destipo,
            pd.situac,
            pd.ucreac,
            pd.uactua,
            pd.fcreac,
            pd.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal_documento    pd
            LEFT OUTER JOIN tipoitem              ti ON ti.id_cia = pd.id_cia
                                           AND ti.codtip = 'DO'
                                           AND ti.codite = pd.codite
            LEFT OUTER JOIN clase_codigo_personal ccp ON ccp.id_cia = pd.id_cia
                                                         AND ccp.clase = 3
                                                         AND ccp.codigo = pd.codigo
        WHERE
                pd.id_cia = pin_id_cia
            AND pd.codper = pin_codper;

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
--                "codtip":"DO",
--                "codite":201,
--                "nrodoc":"15642",
--                "clase":"",
--                "codigo":"",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal_documento.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal_documento.sp_obtener(66,'P001','DO',201);
--
--SELECT * FROM pack_hr_personal_documento.sp_buscar(66,'P001');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                      json_object_t;
        rec_personal_documento personal_documento%rowtype;
        v_accion               VARCHAR2(50) := '';
        v_nrodoc               VARCHAR2(20);
        v_clase                NUMBER;
        v_codigo               VARCHAR2(20);
        pout_mensaje           VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal_documento.id_cia := pin_id_cia;
        rec_personal_documento.codper := o.get_string('codper');
        rec_personal_documento.codtip := o.get_string('codtip');
        rec_personal_documento.codite := o.get_number('codite');
        rec_personal_documento.nrodoc := o.get_string('nrodoc');
        rec_personal_documento.clase := o.get_number('clase');
        rec_personal_documento.codigo := o.get_string('codigo');
        rec_personal_documento.ucreac := o.get_string('ucreac');
        rec_personal_documento.uactua := o.get_string('uactua');
        v_accion := '';
        --   VALIDACION CLASE OBLIGATORIA
        BEGIN
            SELECT
                nrodoc,
                clase,
                codigo
            INTO
                v_nrodoc,
                v_clase,
                v_codigo
            FROM
                pack_hr_personal_documento.sp_obtener(pin_id_cia, rec_personal_documento.codper, 'DO', 201)
            WHERE
                situac = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                IF NOT (
                    rec_personal_documento.codtip = 'DO'
                    AND rec_personal_documento.codite = 201
                ) THEN
                    pout_mensaje := 'No se puede insertar o modificar este registro, porque aun no ha terminado de definir o confirmar la clase obligatoria [ DOCUMENTO IDENTIDAD ]';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;
        END;

        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO personal_documento (
                    id_cia,
                    codper,
                    codtip,
                    codite,
                    nrodoc,
                    clase,
                    codigo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal_documento.id_cia,
                    rec_personal_documento.codper,
                    rec_personal_documento.codtip,
                    rec_personal_documento.codite,
                    rec_personal_documento.nrodoc,
                    rec_personal_documento.clase,
                    rec_personal_documento.codigo,
                    rec_personal_documento.ucreac,
                    rec_personal_documento.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE personal_documento
                SET
                    clase =
                        CASE
                            WHEN rec_personal_documento.clase IS NULL THEN
                                clase
                            ELSE
                                rec_personal_documento.clase
                        END,
                    nrodoc =
                        CASE
                            WHEN rec_personal_documento.nrodoc IS NULL THEN
                                nrodoc
                            ELSE
                                rec_personal_documento.nrodoc
                        END,
                    codigo =
                        CASE
                            WHEN rec_personal_documento.codigo IS NULL THEN
                                codigo
                            ELSE
                                rec_personal_documento.codigo
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal_documento.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_personal_documento.uactua
                        END,
                    situac = 'S',
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal_documento.id_cia
                    AND codper = rec_personal_documento.codper
                    AND codtip = rec_personal_documento.codtip
                    AND codite = rec_personal_documento.codite;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM personal_documento
                WHERE
                        id_cia = rec_personal_documento.id_cia
                    AND codper = rec_personal_documento.codper
                    AND codtip = rec_personal_documento.codtip
                    AND codite = rec_personal_documento.codite;

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
                                    || rec_personal_documento.codper
                                    || ' ] y con el TipoItem [ '
                                    || rec_personal_documento.codtip
                                    || ' - '
                                    || rec_personal_documento.codite
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
                        'message' VALUE 'No se insertar o modificar este registro porque el TipoItem [ '
                                        || rec_personal_documento.codtip
                                        || ' - '
                                        || rec_personal_documento.codite
                                        || ' ] o la Clase/Codigo [ '
                                        || rec_personal_documento.clase
                                        || ' - '
                                        || rec_personal_documento.codigo
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
