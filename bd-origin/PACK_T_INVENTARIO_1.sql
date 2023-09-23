--------------------------------------------------------
--  DDL for Package Body PACK_T_INVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_T_INVENTARIO" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tipinv IN VARCHAR2
    ) RETURN datatable_t_inventario
        PIPELINED
    IS
        v_table datatable_t_inventario;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            t_inventario
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_descri IN VARCHAR2
    ) RETURN datatable_t_inventario
        PIPELINED
    IS
        v_table datatable_t_inventario;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            t_inventario c
        WHERE
                id_cia = pin_id_cia
            AND ( pin_descri IS NULL
                  OR instr(upper(c.dtipinv), upper(pin_descri)) > 0 )
        ORDER BY
            tipinv ASC;

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
        "tipinv":10000,
        "dtipinv":"Descripción de Prueba",
        "abrevi":"Pru",
        "codsunat":"Prueba",
        "usuari":"Admin",
        "swacti":"S",
        "cuenta":"Cuenta Prueba",
        "patron":"Patron no Definido",
        "swdefaul":"S"
        }';
        PACK_t_inventario.SP_SAVE(100,cadjson,2,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;
*/

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_patron IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                json_object_t;
        rec_t_inventario t_inventario%rowtype;
        v_accion         VARCHAR2(50) := '';
        v_patron  VARCHAR2(1500);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_t_inventario.id_cia := pin_id_cia;
        rec_t_inventario.tipinv := o.get_number('tipinv');
        rec_t_inventario.dtipinv := o.get_string('dtipinv');
        rec_t_inventario.abrevi := o.get_string('abrevi');
        rec_t_inventario.codsunat := o.get_string('codsunat');
        rec_t_inventario.usuari := o.get_string('usuari');
        rec_t_inventario.swacti := o.get_string('swacti');
        rec_t_inventario.cuenta := o.get_string('cuenta');
        v_patron := pin_patron;
        rec_t_inventario.patron := '';
        rec_t_inventario.swdefaul := o.get_string('swdefaul');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO t_inventario (
                    id_cia,
                    tipinv,
                    dtipinv,
                    abrevi,
                    codsunat,
                    fcreac,
                    factua,
                    usuari,
                    swacti,
                    cuenta,
                    patron,
                    swdefaul
                ) VALUES (
                    rec_t_inventario.id_cia,
                    rec_t_inventario.tipinv,
                    rec_t_inventario.dtipinv,
                    rec_t_inventario.abrevi,
                    rec_t_inventario.codsunat,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    rec_t_inventario.usuari,
                    rec_t_inventario.swacti,
                    rec_t_inventario.cuenta,
                    v_patron,
                    rec_t_inventario.swdefaul
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE t_inventario
                SET
                    dtipinv =
                        CASE
                            WHEN rec_t_inventario.dtipinv IS NULL THEN
                                dtipinv
                            ELSE
                                rec_t_inventario.dtipinv
                        END,
                    abrevi =
                        CASE
                            WHEN rec_t_inventario.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_t_inventario.abrevi
                        END,
                    codsunat =
                        CASE
                            WHEN rec_t_inventario.codsunat IS NULL THEN
                                codsunat
                            ELSE
                                rec_t_inventario.codsunat
                        END,
                    usuari =
                        CASE
                            WHEN rec_t_inventario.usuari IS NULL THEN
                                ''
                            ELSE
                                rec_t_inventario.usuari
                        END,
                    swacti =
                        CASE
                            WHEN rec_t_inventario.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_t_inventario.swacti
                        END,
                    cuenta =
                        CASE
                            WHEN rec_t_inventario.cuenta IS NULL THEN
                                cuenta
                            ELSE
                                rec_t_inventario.cuenta
                        END,
                    patron =
                        CASE
                            WHEN v_patron IS NULL THEN
                                patron
                            ELSE
                                v_patron
                        END,
                    swdefaul =
                        CASE
                            WHEN rec_t_inventario.swdefaul IS NULL THEN
                                swdefaul
                            ELSE
                                rec_t_inventario.swdefaul
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_t_inventario.id_cia
                    AND tipinv = rec_t_inventario.tipinv;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM t_inventario
                WHERE
                        id_cia = rec_t_inventario.id_cia
                    AND tipinv = rec_t_inventario.tipinv;

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
            --pin_mensaje := 'El registro ya existe ...!';
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro ya existe ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN no_data_found THEN        
            --pin_mensaje := 'El registro no existe ...!';
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro no existe ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            --pin_mensaje := ' Formato Incorrecto, No se puede resgistrar ...!';
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'Formato Incorrecto, No se puede resgistrar ...!'
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

    FUNCTION sp_genera_correlativo (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_patron IN VARCHAR2
    ) RETURN VARCHAR2 AS

        v_estructura_patron   VARCHAR(1500);
        l_array               json_array_t;
        o                     json_object_t;
        v_kind                VARCHAR2(20);
        v_codeclass           NUMBER := 0;
        v_width               NUMBER := 0;
        v_width_aux           NUMBER := 0;
        v_codartantes         VARCHAR2(50) := '';
        v_codartdespues       VARCHAR2(50) := '';
        v_codartautogenerado_ VARCHAR2(20) := '';
        v_codartautogenerado0 VARCHAR2(20) := '';
        v_codartbuscar        VARCHAR2(100) := '';
        v_patron              VARCHAR2(100) := '';
        v_count_codart        NUMBER := 0;
    BEGIN
        BEGIN
            SELECT
                patron
            INTO v_estructura_patron
            FROM
                t_inventario
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = pin_tipinv;

        EXCEPTION
            WHEN no_data_found THEN
                v_estructura_patron := '';
        END;

        l_array := json_array_t.parse(v_estructura_patron);
        v_width_aux := 0;
        FOR indx IN 0 .. l_array.get_size - 1 LOOP
            o := json_object_t(l_array.get(indx));
            v_kind := o.get_string('kind');
            v_codeclass := o.get_number('codeClass');
            v_width := o.get_number('width');
            DBMS_OUTPUT.PUT_LINE ('Index: ' || indx || 'kind: ' || v_kind || 'codeclass: ' || v_codeclass || 'width: ' || v_width); 
            IF ( upper(v_kind) = 'AUTOGENERADO' ) THEN
                v_codartantes := substr(pin_patron, 1, v_width_aux);
                IF length(pin_patron) - (v_width_aux + v_width) = 0 THEN
                    v_codartdespues := '';
                ELSE
                    v_codartdespues := substr(pin_patron, -(length(pin_patron) -(v_width_aux + v_width)));
                END IF;                

                FOR i IN 1..v_width LOOP
                    v_codartautogenerado_ := v_codartautogenerado_ || '_';
                    v_codartautogenerado0 := v_codartautogenerado0 || '0';
                END LOOP;

                v_codartbuscar := v_codartantes
                                  || v_codartautogenerado_
                                  || v_codartdespues;
                BEGIN
                    SELECT
                        COUNT(codart)
                    INTO v_count_codart
                    FROM
                        articulos
                    WHERE
                            id_cia = pin_id_cia
                        AND tipinv = pin_tipinv
                        AND codart LIKE v_codartbuscar;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count_codart := 0;
                END;

               v_count_codart := v_count_codart + 1;
                v_patron := v_codartantes
                            ||  LTRIM(to_char(v_count_codart,v_codartautogenerado0))
                            || v_codartdespues;
                RETURN v_patron;
            ELSE
                v_width_aux := v_width_aux + v_width;
            END IF;

        END LOOP;

        RETURN pin_patron;
    END sp_genera_correlativo;

END;

/
