--------------------------------------------------------
--  DDL for Package Body PACK_ESTADO_CIVIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ESTADO_CIVIL" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codeci IN VARCHAR2
    ) RETURN t_estado_civil
        PIPELINED
    IS
        v_table t_estado_civil;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            estado_civil e
        WHERE
                e.id_cia = pin_id_cia
            AND ( ( pin_codeci IS NULL )
                  OR ( e.codeci = pin_codeci ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN t_estado_civil
        PIPELINED
    IS
        v_table t_estado_civil;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            estado_civil e
        WHERE
                e.id_cia = pin_id_cia
            AND ( ( pin_nombre IS NULL )
                  OR ( instr(e.deseci, pin_nombre) >= 1 ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

/*
set SERVEROUTPUT on;
/
DECLARE 
mensaje VARCHAR2(500);
cadjson VARCHAR2(5000);
BEGIN
    cadjson := '{
        "codeci":"01",
        "deseci":"ESTADO_CIVIL",
        "swacti":"S",
        "ucreac":"admin",
        "uactua":"admin"
        }';
        PACK_ESTADO_CIVIL.SP_SAVE(66,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END; 
*/

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                json_object_t;
        rec_estado_civil estado_civil%rowtype;
        v_accion         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_estado_civil.id_cia := pin_id_cia;
        rec_estado_civil.codeci := o.get_string('codeci');
        rec_estado_civil.deseci := o.get_string('deseci');
        rec_estado_civil.swacti := o.get_string('swacti');
        rec_estado_civil.ucreac := o.get_string('ucreac');
        rec_estado_civil.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO estado_civil (
                    id_cia,
                    codeci,
                    deseci,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_estado_civil.id_cia,
                    rec_estado_civil.codeci,
                    rec_estado_civil.deseci,
                    rec_estado_civil.swacti,
                    rec_estado_civil.ucreac,
                    rec_estado_civil.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE estado_civil
                SET
                    deseci =
                        CASE
                            WHEN rec_estado_civil.deseci IS NULL THEN
                                deseci
                            ELSE
                                rec_estado_civil.deseci
                        END,
                    swacti =
                        CASE
                            WHEN rec_estado_civil.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_estado_civil.swacti
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_estado_civil.id_cia
                    AND codeci = rec_estado_civil.codeci;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM estado_civil
                WHERE
                        id_cia = rec_estado_civil.id_cia
                    AND codeci = rec_estado_civil.codeci;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de civil [ '
                                    || rec_estado_civil.codeci
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
