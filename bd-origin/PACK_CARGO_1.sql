--------------------------------------------------------
--  DDL for Package Body PACK_CARGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CARGO" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codcar IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_cargo
        PIPELINED
    IS
        v_table t_cargo;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cargo
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codcar IS NULL )
                  OR ( codcar = pin_codcar ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;
/*
set SERVEROUTPUT on;

DECLARE
    mensaje VARCHAR2(500);
    cadjson VARCHAR2(5000);
BEGIN
        cadjson := '{
            "codcar":"S",
            "nombre":"Prueba",
            "ucreac":"admin",
            "uactua":"admin"
        }';
        PACK_CARGO.SP_SAVE(100,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;

SELECT *  FROM PACK_CARGO.SP_BUSCAR(100,NULL,NULL);

*/
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o         json_object_t;
        rec_cargo cargo%rowtype;
        v_accion  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cargo.id_cia := pin_id_cia;
        rec_cargo.codcar := o.get_string('codcar');
        rec_cargo.nombre := o.get_string('nombre');
        rec_cargo.ucreac := o.get_string('ucreac');
        rec_cargo.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cargo (
                    id_cia,
                    codcar,
                    nombre,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_cargo.id_cia,
                    rec_cargo.codcar,
                    rec_cargo.nombre,
                    rec_cargo.ucreac,
                    rec_cargo.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE cargo
                SET
                    nombre = rec_cargo.nombre,
                    uactua = rec_cargo.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_cargo.id_cia
                    AND codcar = rec_cargo.codcar;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cargo
                WHERE
                        id_cia = rec_cargo.id_cia
                    AND codcar = rec_cargo.codcar;

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
         WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de cargo [ '
                                    || rec_cargo.codcar
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

    END sp_save;

END;

/
