--------------------------------------------------------
--  DDL for Package Body PACK_CF_EMPRESA_MODULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_EMPRESA_MODULOS" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codmod NUMBER
    ) RETURN datatable_empresa_modulos
        PIPELINED
    AS
        v_table datatable_empresa_modulos;
    BEGIN
        SELECT
            em.id_cia,
            em.codmod,
            m.descri AS desmot,
            em.swacti,
            em.maxuser,
            em.ucreac,
            em.uactua,
            em.fcreac,
            em.factua
        BULK COLLECT
        INTO v_table
        FROM
            empresa_modulos em
            LEFT OUTER JOIN modulos         m ON m.id_cia = 1
                                         AND m.codmod = em.codmod
        WHERE
                em.id_cia = pin_id_cia
            AND em.codmod = pin_codmod;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_swacti VARCHAR2
    ) RETURN datatable_empresa_modulos
        PIPELINED
    AS
        v_table datatable_empresa_modulos;
    BEGIN
        SELECT
            em.id_cia,
            em.codmod,
            m.descri AS desmot,
            em.swacti,
            em.maxuser,
            em.ucreac,
            em.uactua,
            em.fcreac,
            em.factua
        BULK COLLECT
        INTO v_table
        FROM
            empresa_modulos em
            LEFT OUTER JOIN modulos         m ON m.id_cia = 1
                                         AND m.codmod = em.codmod
        WHERE
                em.id_cia = pin_id_cia
            AND ( pin_swacti IS NULL
                  OR em.swacti = pin_swacti );

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
--                "codmod":33,
--                "swacti":"S",
--                "maxuser":5,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_cf_empresa_modulos.sp_save(100, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_cf_empresa_modulos.sp_obtener(100,33);
--
--SELECT * FROM pack_cf_empresa_modulos.sp_buscar(100,'S');
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                   json_object_t;
        rec_empresa_modulos empresa_modulos%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_empresa_modulos.id_cia := pin_id_cia;
        rec_empresa_modulos.codmod := o.get_number('codmod');
        rec_empresa_modulos.swacti := o.get_string('swacti');
        rec_empresa_modulos.maxuser := o.get_number('maxuser');
        rec_empresa_modulos.ucreac := o.get_string('ucreac');
        rec_empresa_modulos.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO empresa_modulos (
                    id_cia,
                    codmod,
                    swacti,
                    maxuser,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_empresa_modulos.id_cia,
                    rec_empresa_modulos.codmod,
                    rec_empresa_modulos.swacti,
                    rec_empresa_modulos.maxuser,
                    rec_empresa_modulos.ucreac,
                    rec_empresa_modulos.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE empresa_modulos
                SET
                    swacti =
                        CASE
                            WHEN rec_empresa_modulos.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_empresa_modulos.swacti
                        END,
                    maxuser =
                        CASE
                            WHEN rec_empresa_modulos.maxuser IS NULL THEN
                                maxuser
                            ELSE
                                rec_empresa_modulos.maxuser
                        END,
                    uactua = rec_empresa_modulos.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_empresa_modulos.id_cia
                    AND codmod = rec_empresa_modulos.codmod;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM empresa_modulos
                WHERE
                        id_cia = rec_empresa_modulos.id_cia
                    AND codmod = rec_empresa_modulos.codmod;

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
                    'message' VALUE 'El registro con el MODULO [ '
                                    || rec_empresa_modulos.codmod
                                    || ' ] ya existe y no puede duplicarse ...!'
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
                        'message' VALUE 'No se insertar o modificar este registro porque el MODULO [ '
                                        || rec_empresa_modulos.codmod
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se eliminar este MODULO [ '
                                        || rec_empresa_modulos.codmod
                                        || ' ] porque tiene USUARIOS registrados ...! '
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
