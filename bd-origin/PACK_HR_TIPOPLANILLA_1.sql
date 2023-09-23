--------------------------------------------------------
--  DDL for Package Body PACK_HR_TIPOPLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_TIPOPLANILLA" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tippla IN VARCHAR2
    ) RETURN datatable_tipoplanila
        PIPELINED
    IS
        v_table datatable_tipoplanila;
    BEGIN
        SELECT
            e.id_cia,
            e.tippla,
            e.nombre,
            e.diapla,
            e.horpla,
            e.redond,
            e.codcta,
            p1.nombre AS descodctaemp,
            e.facade,
            e.dh,
            e.agrupa,
            e.libro,
            e.swcuenta,
            e.swacti,
            e.codctaobr,
            p2.nombre AS descodctaobr,
            e.ucreac,
            e.uactua,
            e.fcreac,
            e.factua
        BULK COLLECT
        INTO v_table
        FROM
            tipoplanilla e
            LEFT OUTER JOIN pcuentas     p1 ON p1.id_cia = e.id_cia
                                           AND p1.cuenta = e.codcta
            LEFT OUTER JOIN pcuentas     p2 ON p2.id_cia = e.id_cia
                                           AND p2.cuenta = e.codctaobr
        WHERE
                e.id_cia = pin_id_cia
            AND ( ( pin_tippla IS NULL )
                  OR ( e.tippla = pin_tippla ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_tippla IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_tipoplanila
        PIPELINED
    IS
        v_table datatable_tipoplanila;
    BEGIN
        SELECT
            e.id_cia,
            e.tippla,
            e.nombre,
            e.diapla,
            e.horpla,
            e.redond,
            e.codcta,
            p1.nombre AS descodctaemp,
            e.facade,
            e.dh,
            e.agrupa,
            e.libro,
            e.swcuenta,
            e.swacti,
            e.codctaobr,
            p2.nombre AS descodctaobr,
            e.ucreac,
            e.uactua,
            e.fcreac,
            e.factua
        BULK COLLECT
        INTO v_table
        FROM
            tipoplanilla e
            LEFT OUTER JOIN pcuentas     p1 ON p1.id_cia = e.id_cia
                                           AND p1.cuenta = e.codcta
            LEFT OUTER JOIN pcuentas     p2 ON p2.id_cia = e.id_cia
                                           AND p2.cuenta = e.codctaobr
        WHERE
                e.id_cia = pin_id_cia
            AND ( pin_tippla IS NULL
                  OR e.tippla = pin_tippla )
            AND ( ( pin_nombre IS NULL )
                  OR ( instr(upper(e.nombre),
                             upper(pin_nombre)) >= 1 ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_buscar_config (
        pin_id_cia IN NUMBER
    ) RETURN datatable_tipoplanila
        PIPELINED
    IS
        v_table datatable_tipoplanila;
    BEGIN
        SELECT
            e.id_cia,
            e.tippla,
            e.nombre,
            e.diapla,
            e.horpla,
            e.redond,
            e.codcta,
            p1.nombre AS descodctaemp,
            e.facade,
            e.dh,
            e.agrupa,
            e.libro,
            e.swcuenta,
            e.swacti,
            e.codctaobr,
            p2.nombre AS descodctaobr,
            e.ucreac,
            e.uactua,
            e.fcreac,
            e.factua
        BULK COLLECT
        INTO v_table
        FROM
            tipoplanilla    e
            LEFT OUTER JOIN pcuentas        p1 ON p1.id_cia = e.id_cia
                                           AND p1.cuenta = e.codcta
            LEFT OUTER JOIN pcuentas        p2 ON p2.id_cia = e.id_cia
                                           AND p2.cuenta = e.codctaobr
            LEFT OUTER JOIN factor_planilla fp701 ON fp701.id_cia = e.id_cia
                                                     AND fp701.codfac = '701'
            LEFT OUTER JOIN factor_planilla fp702 ON fp702.id_cia = e.id_cia
                                                     AND fp702.codfac = '702'
        WHERE
                e.id_cia = pin_id_cia
            AND ( e.tippla NOT IN ( 'V', 'G' )
                  OR ( e.tippla = 'V'
                       AND fp701.valfa1 = 0 )
                  OR ( e.tippla = 'G'
                       AND fp702.valfa1 = 0 ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_config;

/*
set SERVEROUTPUT on;

DECLARE 
mensaje VARCHAR2(500);
cadjson VARCHAR2(5000);
BEGIN
    cadjson := '{
        "tippla":"A",
        "nombre":"tipoplanilla",
        "diapla":100,
        "horpla":100,
        "redond":100,
        "codcta":"PRUEBA",
        "facade":100,
        "dh":"P",
        "agrupa":"P",
        "libro":"P",
        "swcuenta":"P",
        "swacti":"P",
        "codctaobr":"PRUEBA",
        "ucreac":"admin",
        "uactua":"admin"
        }';
        PACK_HR_tipoplanilla.SP_SAVE(100,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;

SELECT* FROM PACK_HR_TIPOPLANILLA.SP_OBTENER(100,'A');

SELECT* FROM PACK_HR_TIPOPLANILLA.SP_BUSCAR(100,'A','TIPO');
*/

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                json_object_t;
        rec_tipoplanilla tipoplanilla%rowtype;
        v_accion         VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipoplanilla.id_cia := pin_id_cia;
        rec_tipoplanilla.tippla := o.get_string('tippla');
        rec_tipoplanilla.nombre := o.get_string('nombre');
        rec_tipoplanilla.diapla := o.get_number('diapla');
        rec_tipoplanilla.horpla := o.get_number('horpla');
        rec_tipoplanilla.redond := o.get_number('redond');
        rec_tipoplanilla.codcta := o.get_string('codcta');
        rec_tipoplanilla.facade := o.get_number('facade');
        rec_tipoplanilla.dh := o.get_string('dh');
        rec_tipoplanilla.agrupa := o.get_string('agrupa');
        rec_tipoplanilla.libro := o.get_string('libro');
        rec_tipoplanilla.swcuenta := o.get_string('swcuenta');
        rec_tipoplanilla.swacti := o.get_string('swacti');
        rec_tipoplanilla.codctaobr := o.get_string('codctaobr');
        rec_tipoplanilla.ucreac := o.get_string('ucreac');
        rec_tipoplanilla.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tipoplanilla (
                    id_cia,
                    tippla,
                    nombre,
                    diapla,
                    horpla,
                    redond,
                    codcta,
                    facade,
                    dh,
                    agrupa,
                    libro,
                    swcuenta,
                    swacti,
                    codctaobr,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_tipoplanilla.id_cia,
                    rec_tipoplanilla.tippla,
                    rec_tipoplanilla.nombre,
                    rec_tipoplanilla.diapla,
                    rec_tipoplanilla.horpla,
                    rec_tipoplanilla.redond,
                    rec_tipoplanilla.codcta,
                    rec_tipoplanilla.facade,
                    rec_tipoplanilla.dh,
                    rec_tipoplanilla.agrupa,
                    rec_tipoplanilla.libro,
                    rec_tipoplanilla.swcuenta,
                    rec_tipoplanilla.swacti,
                    rec_tipoplanilla.codctaobr,
                    rec_tipoplanilla.ucreac,
                    rec_tipoplanilla.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE tipoplanilla
                SET
                    nombre =
                        CASE
                            WHEN rec_tipoplanilla.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_tipoplanilla.nombre
                        END,
                    diapla =
                        CASE
                            WHEN rec_tipoplanilla.diapla IS NULL THEN
                                diapla
                            ELSE
                                rec_tipoplanilla.diapla
                        END,
                    horpla =
                        CASE
                            WHEN rec_tipoplanilla.horpla IS NULL THEN
                                horpla
                            ELSE
                                rec_tipoplanilla.horpla
                        END,
                    redond =
                        CASE
                            WHEN rec_tipoplanilla.redond IS NULL THEN
                                redond
                            ELSE
                                rec_tipoplanilla.redond
                        END,
                    codcta = rec_tipoplanilla.codcta,
                    facade =
                        CASE
                            WHEN rec_tipoplanilla.facade IS NULL THEN
                                facade
                            ELSE
                                rec_tipoplanilla.facade
                        END,
                    dh =
                        CASE
                            WHEN rec_tipoplanilla.dh IS NULL THEN
                                dh
                            ELSE
                                rec_tipoplanilla.dh
                        END,
                    agrupa =
                        CASE
                            WHEN rec_tipoplanilla.agrupa IS NULL THEN
                                agrupa
                            ELSE
                                rec_tipoplanilla.agrupa
                        END,
                    libro =
                        CASE
                            WHEN rec_tipoplanilla.libro IS NULL THEN
                                libro
                            ELSE
                                rec_tipoplanilla.libro
                        END,
                    swcuenta =
                        CASE
                            WHEN rec_tipoplanilla.swcuenta IS NULL THEN
                                swcuenta
                            ELSE
                                rec_tipoplanilla.swcuenta
                        END,
                    codctaobr = rec_tipoplanilla.codctaobr,
                    swacti =
                        CASE
                            WHEN rec_tipoplanilla.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_tipoplanilla.swacti
                        END,
                    uactua = rec_tipoplanilla.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tipoplanilla.id_cia
                    AND tippla = rec_tipoplanilla.tippla;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tipoplanilla
                WHERE
                        id_cia = rec_tipoplanilla.id_cia
                    AND tippla = rec_tipoplanilla.tippla;

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
                    'message' VALUE 'El registro con codigo de planilla [ '
                                    || rec_tipoplanilla.tippla
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
