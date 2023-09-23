--------------------------------------------------------
--  DDL for Package Body PACK_TBANCOS_CHEQUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TBANCOS_CHEQUES" AS

--    FUNCTION sp_obtener (
--        pin_id_cia NUMBER,
--        pin_codban NUMBER,
--        pin_serie  VARCHAR2,
--        pin_periodo NUMBER
--    ) RETURN datatable_tbancos_cheques
--        PIPELINED
--    AS
--        v_table datatable_tbancos_cheques;
--    BEGIN
--        SELECT
--            tb.id_cia,
--            tb.codban,
--            ti.desban AS desban,
--            tb.serie,
--            a.periodo  AS correl,
--            tb.periodo,
--            tb.periodo,
--            tb.mes,
--            tb.libro,
--            tb.asiento,
--            tb.ucreac,
--            tb.uactua,
--            tb.fcreac,
--            tb.factua
--        BULK COLLECT
--        INTO v_table
--        FROM
--            tbancos_cheques aa
--            LEFT OUTER JOIN t_inventario    ti ON ti.id_cia = tb.id_cia
--                                               AND ti.codban = tb.codban
--            LEFT OUTER JOIN articulos       a ON a.id_cia = tb.id_cia
--                                           AND a.codban = tb.codban
--                                           AND a.serie = tb.serie
--        WHERE
--                tb.id_cia = pin_id_cia
--            AND tb.codban = pin_codban
--            AND tb.serie = pin_serie
--            AND tb.periodo = pin_periodo;
--
--        FOR registro IN 1..v_table.count LOOP
--            PIPE ROW ( v_table(registro) );
--        END LOOP;
--
--        RETURN;
--    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2,
        pin_serie  VARCHAR2
    ) RETURN datatable_tbancos_cheques
        PIPELINED
    AS
        v_table datatable_tbancos_cheques;
    BEGIN
        SELECT DISTINCT
            tb.id_cia,
            tb.codban,
            ti.descri AS desban,
            tb.serie,
            0,
            tb.descri AS desche,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
--            tb.periodo,
--            tb.mes,
--            tb.libro,
--            tb.asiento,
--            tb.situac,
--            tb.ucreac,
--            tb.uactua,
--            tb.fcreac,
--            tb.factua
        BULK COLLECT
        INTO v_table
        FROM
            tbancos_cheques tb
            LEFT OUTER JOIN tbancos         ti ON ti.id_cia = tb.id_cia
                                          AND ti.codban = tb.codban
        WHERE
                tb.id_cia = pin_id_cia
            AND ( pin_codban IS NULL
                  OR pin_codban = - 1
                  OR tb.codban = pin_codban )
            AND ( pin_serie IS NULL
                  OR tb.serie = pin_serie );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_buscar_detalle (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2,
        pin_serie  VARCHAR2,
        pin_correl NUMBER
    ) RETURN datatable_tbancos_cheques
        PIPELINED
    AS
        v_table datatable_tbancos_cheques;
    BEGIN
        SELECT
            tb.id_cia,
            tb.codban,
            ti.descri AS desban,
            tb.serie,
            tb.correl,
            tb.descri AS desche,
            tb.periodo,
            tb.mes,
            tb.libro,
            tb.asiento,
            tb.situac,
            CASE
                WHEN tb.situac = 'A' THEN
                    'Emitida'
                WHEN tb.situac = 'B' THEN
                    'Contabilizada'
                WHEN tb.situac = 'J' THEN
                    'Anulada'
            END       AS dessituac,
            tb.ucreac,
            tb.uactua,
            tb.fcreac,
            tb.factua
        BULK COLLECT
        INTO v_table
        FROM
            tbancos_cheques tb
            LEFT OUTER JOIN tbancos         ti ON ti.id_cia = tb.id_cia
                                          AND ti.codban = tb.codban
        WHERE
                tb.id_cia = pin_id_cia
            AND ( pin_codban IS NULL
                  OR pin_codban = - 1
                  OR tb.codban = pin_codban )
            AND ( pin_serie IS NULL
                  OR tb.serie = pin_serie )
            AND ( pin_correl IS NULL
                  OR pin_correl = - 1
                  OR tb.correl = pin_correl );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_detalle;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codban":11,
--                "serie":"F001",
--                "desche":"",
--                "cdesde":1,
--                "chasta":100,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_tbancos_cheques.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codban":11,
--                "serie":"F001",
--                "correl":1,
--                "periodo":2022,
--                "mes":10,
--                "libro":"07",
--                "asiento":1,
--                "situac":"A",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_tbancos_cheques.sp_save_detalle(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_tbancos_cheques.sp_buscar(66,NULL,NULL);
--
--SELECT * FROM pack_tbancos_cheques.sp_buscar_detalle(66,NULL,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                   json_object_t;
        rec_tbancos_cheques tbancos_cheques%rowtype;
        v_cdesde            NUMBER;
        v_chasta            NUMBER;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tbancos_cheques.id_cia := pin_id_cia;
        rec_tbancos_cheques.codban := o.get_string('codban');
        rec_tbancos_cheques.serie := o.get_string('serie');
        rec_tbancos_cheques.descri := o.get_string('desche');
        v_cdesde := o.get_number('cdesde');
        v_chasta := o.get_number('chasta');
        IF rec_tbancos_cheques.descri IS NULL THEN
            rec_tbancos_cheques.descri := rec_tbancos_cheques.serie
                                          || ' - CORRELATIVO DEL '
                                          || v_cdesde
                                          || ' - '
                                          || v_chasta;
        END IF;

        rec_tbancos_cheques.ucreac := o.get_string('ucreac');
        rec_tbancos_cheques.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                FOR i IN v_cdesde..v_chasta LOOP
                    rec_tbancos_cheques.correl := i;
                    INSERT INTO tbancos_cheques (
                        id_cia,
                        codban,
                        serie,
                        correl,
                        descri,
                        periodo,
                        mes,
                        libro,
                        asiento,
                        situac,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        rec_tbancos_cheques.id_cia,
                        rec_tbancos_cheques.codban,
                        rec_tbancos_cheques.serie,
                        rec_tbancos_cheques.correl,
                        rec_tbancos_cheques.descri,
                        rec_tbancos_cheques.periodo,
                        rec_tbancos_cheques.mes,
                        rec_tbancos_cheques.libro,
                        rec_tbancos_cheques.asiento,
                        rec_tbancos_cheques.situac,
                        rec_tbancos_cheques.ucreac,
                        rec_tbancos_cheques.uactua,
                        to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                        to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                    );

                END LOOP;

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                rec_tbancos_cheques.descri := o.get_string('desche');
                UPDATE tbancos_cheques
                SET
                    descri =
                        CASE
                            WHEN rec_tbancos_cheques.descri IS NULL THEN
                                descri
                            ELSE
                                rec_tbancos_cheques.descri
                        END,
                    uactua =
                        CASE
                            WHEN rec_tbancos_cheques.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_tbancos_cheques.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tbancos_cheques.id_cia
                    AND codban = rec_tbancos_cheques.codban
                    AND serie = rec_tbancos_cheques.serie;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM tbancos_cheques
                WHERE
                        id_cia = rec_tbancos_cheques.id_cia
                    AND codban = rec_tbancos_cheques.codban
                    AND serie = rec_tbancos_cheques.serie;

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
                    'message' VALUE 'El registro con el con el BANCO [ '
                                    || rec_tbancos_cheques.codban
                                    || ' ], con la SERIE [ '
                                    || rec_tbancos_cheques.serie
                                    || ' ] y con el CORRELATIVO [ '
                                    || rec_tbancos_cheques.correl
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un mes incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el BANCO [ '
                                        || rec_tbancos_cheques.codban
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' mes :'
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

    PROCEDURE sp_save_detalle (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                   json_object_t;
        rec_tbancos_cheques tbancos_cheques%rowtype;
        v_cdesde            NUMBER;
        v_chasta            NUMBER;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tbancos_cheques.id_cia := pin_id_cia;
        rec_tbancos_cheques.codban := o.get_string('codban');
        rec_tbancos_cheques.serie := o.get_string('serie');
        rec_tbancos_cheques.descri := o.get_string('desche');
        rec_tbancos_cheques.correl := o.get_number('correl');
        rec_tbancos_cheques.periodo := o.get_number('periodo');
        rec_tbancos_cheques.mes := o.get_number('mes');
        rec_tbancos_cheques.libro := o.get_string('libro');
        rec_tbancos_cheques.asiento := o.get_number('asiento');
        rec_tbancos_cheques.situac := o.get_string('situac');
        rec_tbancos_cheques.ucreac := o.get_string('ucreac');
        rec_tbancos_cheques.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO tbancos_cheques (
                    id_cia,
                    codban,
                    serie,
                    correl,
                    descri,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_tbancos_cheques.id_cia,
                    rec_tbancos_cheques.codban,
                    rec_tbancos_cheques.serie,
                    rec_tbancos_cheques.correl,
                    rec_tbancos_cheques.descri,
                    rec_tbancos_cheques.periodo,
                    rec_tbancos_cheques.mes,
                    rec_tbancos_cheques.libro,
                    rec_tbancos_cheques.asiento,
                    rec_tbancos_cheques.situac,
                    rec_tbancos_cheques.ucreac,
                    rec_tbancos_cheques.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';

                UPDATE tbancos_cheques
                SET
                    periodo =
                        CASE
                            WHEN rec_tbancos_cheques.periodo IS NULL THEN
                                periodo
                            ELSE
                                rec_tbancos_cheques.periodo
                        END,
                    mes =
                        CASE
                            WHEN rec_tbancos_cheques.mes IS NULL THEN
                                mes
                            ELSE
                                rec_tbancos_cheques.mes
                        END,
                    libro =
                        CASE
                            WHEN rec_tbancos_cheques.libro IS NULL THEN
                                libro
                            ELSE
                                rec_tbancos_cheques.libro
                        END,
                    asiento =
                        CASE
                            WHEN rec_tbancos_cheques.asiento IS NULL THEN
                                asiento
                            ELSE
                                rec_tbancos_cheques.asiento
                        END,
                    situac =
                        CASE
                            WHEN rec_tbancos_cheques.situac IS NULL THEN
                                situac
                            ELSE
                                rec_tbancos_cheques.situac
                        END,
                    uactua =
                        CASE
                            WHEN rec_tbancos_cheques.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_tbancos_cheques.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tbancos_cheques.id_cia
                    AND codban = rec_tbancos_cheques.codban
                    AND serie = rec_tbancos_cheques.serie
                    AND correl = rec_tbancos_cheques.correl;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM tbancos_cheques
                WHERE
                        id_cia = rec_tbancos_cheques.id_cia
                    AND codban = rec_tbancos_cheques.codban
                    AND serie = rec_tbancos_cheques.serie
                    AND correl = rec_tbancos_cheques.correl;

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
                    'message' VALUE 'El registro con el con el BANCO [ '
                                    || rec_tbancos_cheques.codban
                                    || ' ], con la SERIE [ '
                                    || rec_tbancos_cheques.serie
                                    || ' ] y con el CORRELATIVO [ '
                                    || rec_tbancos_cheques.correl
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un mes incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el BANCO [ '
                                        || rec_tbancos_cheques.codban
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' mes :'
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
    END sp_save_detalle;

END;

/
