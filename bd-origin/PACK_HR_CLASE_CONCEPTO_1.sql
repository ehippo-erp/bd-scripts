--------------------------------------------------------
--  DDL for Package Body PACK_HR_CLASE_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CLASE_CONCEPTO" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_concepto
        PIPELINED
    IS
        v_table t_clase_concepto;
    BEGIN
--SELECT
--    id_cia,
--    clase,
--    descri,
--    ucreac,
--    uactua,
--    fcreac,
--    factua
--FROM
--    TABLE ( pack_clase_concepto.sp_sel_clase_concepto(5, null, '%') );
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_concepto
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_clase IS NULL )
                  OR ( pin_clase = - 1 )
                  OR ( clase = pin_clase ) )
            AND ( ( pin_descri IS NULL )
                  OR ( upper(descri) LIKE upper(pin_descri || '%') ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                  json_object_t;
        rec_clase_concepto clase_concepto%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "clase": 0,
--    "descri": "CONCEPTO INTERRUPTOR",
--    "ucreac":"admin",
--    "uactua":"admin"
--}';
--    pack_clase_concepto.sp_save_clase_concepto(5,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;    
        o := json_object_t.parse(pin_datos);
        rec_clase_concepto.id_cia := pin_id_cia;
        rec_clase_concepto.clase := o.get_number('clase');
        rec_clase_concepto.descri := o.get_string('descri');
        rec_clase_concepto.indsubcod := o.get_string('indsubcod');
        rec_clase_concepto.indrotulo := o.get_string('indrotulo');
        rec_clase_concepto.ucreac := o.get_string('ucreac');
        rec_clase_concepto.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO clase_concepto (
                    id_cia,
                    clase,
                    descri,
                    indsubcod,
                    indrotulo,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_concepto.id_cia,
                    rec_clase_concepto.clase,
                    rec_clase_concepto.descri,
                    rec_clase_concepto.indsubcod,
                    rec_clase_concepto.indrotulo,
                    rec_clase_concepto.ucreac,
                    rec_clase_concepto.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE clase_concepto
                SET
                    descri = rec_clase_concepto.descri,
                    indsubcod = rec_clase_concepto.indsubcod,
                    indrotulo = rec_clase_concepto.indrotulo,
                    uactua = rec_clase_concepto.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_concepto.id_cia
                    AND clase = rec_clase_concepto.clase;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_concepto
                WHERE
                        id_cia = rec_clase_concepto.id_cia
                    AND clase = rec_clase_concepto.clase;

                DELETE FROM clase_concepto_codigo
                WHERE
                        id_cia = rec_clase_concepto.id_cia
                    AND clase = rec_clase_concepto.clase;

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
                    'message' VALUE 'El registro con codigo de concepto [ '
                                    || rec_clase_concepto.clase
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

    END;

    FUNCTION sp_buscar_codigo (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_codigo IN VARCHAR2,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_concepto_codigo
        PIPELINED
    IS
        v_table t_clase_concepto_codigo;
    BEGIN
 --SELECT
--    id_cia,
--    clase,
--    codigo,
--    descri,
--    abrevi,
--    vstrg,
--    codusercrea,
--    coduseractu,
--    fcreac,
--    factua
--FROM
--    TABLE ( pack_clase_concepto.sp_sel_clase_concepto_codigo(5, NULL, NULL, NULL) );  
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_concepto_codigo
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_clase IS NULL )
                  OR ( pin_clase = - 1 )
                  OR ( clase = pin_clase ) )
            AND ( ( pin_codigo IS NULL )
                  OR ( pin_codigo = '-1' )
                  OR ( codigo = pin_codigo ) )
            AND ( ( pin_descri IS NULL )
                  OR ( pin_descri = '-1' )
                  OR ( upper(descri) LIKE upper(pin_descri || '%') ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_codigo;

    PROCEDURE sp_save_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                         json_object_t;
        rec_clase_concepto_codigo clase_concepto_codigo%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
 --SET SERVEROUTPUT ON;
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "clase": 0,
--    "codigo":"N",
--    "descri": "INACTIVO",
--    "abrevi":"INACT",
--    "vstrg":"N",
--    "ucreac":"admin",
--    "uactua":"admin"
--}';
--    pack_clase_concepto.sp_save_clase_concepto_codigo(5,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;   
        o := json_object_t.parse(pin_datos);
        rec_clase_concepto_codigo.id_cia := pin_id_cia;
        rec_clase_concepto_codigo.clase := o.get_number('clase');
        rec_clase_concepto_codigo.codigo := o.get_string('codigo');
        rec_clase_concepto_codigo.descri := o.get_string('descri');
        rec_clase_concepto_codigo.abrevi := o.get_string('abrevi');
        rec_clase_concepto_codigo.vstrg := o.get_string('vstrg');
        rec_clase_concepto_codigo.ucreac := o.get_string('ucreac');
        rec_clase_concepto_codigo.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO clase_concepto_codigo (
                    id_cia,
                    clase,
                    codigo,
                    descri,
                    abrevi,
                    vstrg,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_concepto_codigo.id_cia,
                    rec_clase_concepto_codigo.clase,
                    rec_clase_concepto_codigo.codigo,
                    rec_clase_concepto_codigo.descri,
                    rec_clase_concepto_codigo.abrevi,
                    rec_clase_concepto_codigo.vstrg,
                    rec_clase_concepto_codigo.ucreac,
                    rec_clase_concepto_codigo.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE clase_concepto_codigo
                SET
                    descri = rec_clase_concepto_codigo.descri,
                    abrevi = rec_clase_concepto_codigo.abrevi,
                    vstrg = rec_clase_concepto_codigo.vstrg,
                    uactua = rec_clase_concepto_codigo.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_concepto_codigo.id_cia
                    AND clase = rec_clase_concepto_codigo.clase
                    AND codigo = rec_clase_concepto_codigo.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_concepto_codigo
                WHERE
                        id_cia = rec_clase_concepto_codigo.id_cia
                    AND clase = rec_clase_concepto_codigo.clase
                    AND codigo = rec_clase_concepto_codigo.codigo;

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
                    'message' VALUE 'El registro con codigo de concepto [ '
                                    || rec_clase_concepto_codigo.clase
                                    || ' ] y codigo [ '
                                    || rec_clase_concepto_codigo.codigo
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

    END;

END;

/
