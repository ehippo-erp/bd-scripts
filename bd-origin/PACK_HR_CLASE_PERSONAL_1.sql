--------------------------------------------------------
--  DDL for Package Body PACK_HR_CLASE_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CLASE_PERSONAL" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_clase_personal
        PIPELINED
    IS
        v_table t_clase_personal;
    BEGIN
--select *
--from table(pack_clase_personal.sp_sel_clase_personal (5,1,'%'));    
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            clase_personal
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
        rec_clase_personal clase_personal%rowtype;
        v_accion           VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "clase": 1,
--    "descri": "PAIS",
--    "secuen":"N",
--    "longit":5,
--    "situac":"S",
--    "obliga":"N",
--    "ucreac":"ADMIN",
--    "uactua":"ADMIN"
--}';
--    pack_clase_personal.sp_save_clase_personal(5,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;    
        o := json_object_t.parse(pin_datos);
        rec_clase_personal.id_cia := pin_id_cia;
        rec_clase_personal.clase := o.get_number('clase');
        rec_clase_personal.descri := o.get_string('descri');
        rec_clase_personal.secuen := o.get_string('secuen');
        rec_clase_personal.longit := o.get_number('longit');
        rec_clase_personal.situac := o.get_string('situac');
        rec_clase_personal.obliga := o.get_string('obliga');
        rec_clase_personal.ucreac := o.get_string('ucreac');
        rec_clase_personal.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO clase_personal (
                    id_cia,
                    clase,
                    descri,
                    secuen,
                    longit,
                    situac,
                    obliga,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_personal.id_cia,
                    rec_clase_personal.clase,
                    rec_clase_personal.descri,
                    rec_clase_personal.secuen,
                    rec_clase_personal.longit,
                    rec_clase_personal.situac,
                    rec_clase_personal.obliga,
                    rec_clase_personal.ucreac,
                    rec_clase_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_personal
                SET
                    descri = rec_clase_personal.descri,
                    secuen = rec_clase_personal.secuen,
                    longit = rec_clase_personal.longit,
                    situac = rec_clase_personal.situac,
                    obliga = rec_clase_personal.obliga,
                    uactua = rec_clase_personal.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_personal.id_cia
                    AND clase = rec_clase_personal.clase;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_personal
                WHERE
                        id_cia = rec_clase_personal.id_cia
                    AND clase = rec_clase_personal.clase;

                DELETE FROM clase_codigo_personal
                WHERE
                        id_cia = rec_clase_personal.id_cia
                    AND clase = rec_clase_personal.clase;
                    --AND codigo = rec_clase_codigo_personal.codigo;

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
                    'message' VALUE 'El registro con codigo de clase personal [ '
                                    || rec_clase_personal.clase
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

    FUNCTION sp_buscar_codigo (
        pin_id_cia IN NUMBER,
        pin_clase  IN INTEGER,
        pin_codigo IN VARCHAR2,
        pin_descri IN VARCHAR2
    ) RETURN datatable_clase_codigo
        PIPELINED
    IS
        v_table datatable_clase_codigo;
    BEGIN
        SELECT
            id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            swdefault,
            fcreac,
            factua,
            ucreac,
            uactua,
            tiptra
        BULK COLLECT
        INTO v_table
        FROM
            clase_codigo_personal
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

--SET SERVEROUTPUT ON;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--    "clase": 2,
--    "codigo":"01110",
--    "descri": "CLASE DE PRUEBA - CEREALES",
--    "abrevi":"PRUEBA",
--    "situac":"S",
--    "swdefault":"N",
--    "tiptra":"S",
--    "ucreac":"admin",
--    "uactua":"admin"
--}';
--
--pack_hr_clase_personal.sp_save_codigo(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--end;
--
--SELECT * FROM pack_hr_clase_personal.sp_buscar_codigo(66, 2, '01110', NULL);

    PROCEDURE sp_save_codigo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                         json_object_t;
        rec_clase_codigo_personal clase_codigo_personal%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_codigo_personal.id_cia := pin_id_cia;
        rec_clase_codigo_personal.clase := o.get_number('clase');
        rec_clase_codigo_personal.codigo := o.get_string('codigo');
        rec_clase_codigo_personal.descri := o.get_string('descri');
        rec_clase_codigo_personal.abrevi := o.get_string('abrevi');
        rec_clase_codigo_personal.situac := o.get_string('situac');
        rec_clase_codigo_personal.swdefault := o.get_string('swdefault');
        rec_clase_codigo_personal.tiptra := o.get_string('tiptra');
        rec_clase_codigo_personal.ucreac := o.get_string('ucreac');
        rec_clase_codigo_personal.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO clase_codigo_personal (
                    id_cia,
                    clase,
                    codigo,
                    descri,
                    abrevi,
                    situac,
                    swdefault,
                    tiptra,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_clase_codigo_personal.id_cia,
                    rec_clase_codigo_personal.clase,
                    rec_clase_codigo_personal.codigo,
                    rec_clase_codigo_personal.descri,
                    rec_clase_codigo_personal.abrevi,
                    rec_clase_codigo_personal.situac,
                    rec_clase_codigo_personal.swdefault,
                    rec_clase_codigo_personal.tiptra,
                    rec_clase_codigo_personal.ucreac,
                    rec_clase_codigo_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE clase_codigo_personal
                SET
                    descri = rec_clase_codigo_personal.descri,
                    abrevi = rec_clase_codigo_personal.abrevi,
                    situac = rec_clase_codigo_personal.situac,
                    swdefault = rec_clase_codigo_personal.swdefault,
                    tiptra = rec_clase_codigo_personal.tiptra,
                    uactua = rec_clase_codigo_personal.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_clase_codigo_personal.id_cia
                    AND clase = rec_clase_codigo_personal.clase
                    AND codigo = rec_clase_codigo_personal.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM clase_codigo_personal
                WHERE
                        id_cia = rec_clase_codigo_personal.id_cia
                    AND clase = rec_clase_codigo_personal.clase
                    AND codigo = rec_clase_codigo_personal.codigo;

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
                    'message' VALUE 'El registro con codigo de clase personal [ '
                                    || rec_clase_codigo_personal.clase
                                    || ' ] y codigo [ '
                                    || rec_clase_codigo_personal.codigo
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

    END sp_save_codigo;

END;

/
