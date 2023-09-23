--------------------------------------------------------
--  DDL for Package Body PACK_RETENDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RETENDET" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_item   NUMBER
    ) RETURN datatable_retendet
        PIPELINED
    IS
        v_table datatable_retendet;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            retendet
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint
            AND item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_tdocum VARCHAR2,
        pin_serie  VARCHAR2,
        pin_numero NUMBER
    ) RETURN datatable_retendet
        PIPELINED
    IS
        v_table datatable_retendet;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            retendet
        WHERE
                id_cia = pin_id_cia
            AND ( nvl(pin_numint, - 1) = - 1
                  OR numint = pin_numint )
            AND ( nvl(pin_tdocum, - 1) = - 1
                  OR tdocum = pin_tdocum )
            AND ( nvl(pin_serie, - 1) = - 1
                  OR serie = pin_serie )
            AND ( nvl(pin_numero, - 1) = - 1
                  OR numero = pin_numero );

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
--  "numint":1000,
--  "item":1,
--  "tdocum":"01",
--  "serie": "F001",
--  "numero":1000,
--  "fdocum":"2022-12-01",
--  "pago":1500,
--  "pago01":1500,
--  "pago02":506.41,
--  "retencion": 94,
--  "retencion01":94,
--  "retencion02":40.32
--                }';
--pack_retendet.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_retendet.sp_obtener(66,1000,1);
--
--SELECT * FROM pack_retendet.sp_buscar(66,NULL,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o            json_object_t;
        rec_retendet retendet%rowtype;
        rec_retenhea retenhea%rowtype;
        v_accion     VARCHAR2(50) := '';
        v_situac     NUMBER;
        v_aux        NUMBER;
        pout_mensaje VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_retendet.id_cia := pin_id_cia;
        rec_retendet.numint := o.get_number('numint');
        rec_retendet.item := o.get_number('item');
        rec_retendet.tdocum := o.get_string('tdocum');
        rec_retendet.serie := o.get_string('serie');
        rec_retendet.numero := o.get_number('numero');
        rec_retendet.fdocum := o.get_date('fdocum');
        rec_retendet.pago := o.get_number('pago');
--        rec_retendet.pago01 := o.get_number('pago01');
--        rec_retendet.pago02 := o.get_number('pago02');
        rec_retendet.retencion := o.get_number('retencion');
--        rec_retendet.retencion01 := o.get_number('retencion01');
--        rec_retendet.retencion02 := o.get_number('retencion02');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_retendet.item, 0) = 0 THEN
                    BEGIN
                        SELECT
                            ( item + 1 )
                        INTO rec_retendet.item
                        FROM
                            retendet
                        WHERE
                                id_cia = rec_retendet.id_cia
                            AND numint = rec_retendet.numint
                        ORDER BY
                            item DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_retendet.item := 1;
                    END;
                END IF;

                BEGIN
                    SELECT
                        tcamb01,
                        tcamb02
                    INTO
                        rec_retenhea.tcamb01,
                        rec_retenhea.tcamb02
                    FROM
                        retenhea
                    WHERE
                            id_cia = rec_retendet.id_cia
                        AND numint = rec_retendet.numint
                        AND nvl(tcamb01, 0) > 0
                        AND nvl(tcamb02, 0) > 0;

                    rec_retendet.pago01 := rec_retendet.pago * rec_retenhea.tcamb01;
                    rec_retendet.pago02 := rec_retendet.pago * rec_retenhea.tcamb02;
                    rec_retendet.retencion01 := rec_retendet.retencion * rec_retenhea.tcamb01;
                    rec_retendet.retencion02 := rec_retendet.retencion * rec_retenhea.tcamb02;
                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                        || rec_retendet.numint
                                        || ' TIENE EL TIPO DE CAMBIO SIN DEFINIR!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                INSERT INTO retendet (
                    id_cia,
                    numint,
                    item,
                    tdocum,
                    serie,
                    numero,
                    fdocum,
                    pago,
                    pago01,
                    pago02,
                    retencion,
                    retencion01,
                    retencion02,
                    fcreac,
                    factua
                ) VALUES (
                    rec_retendet.id_cia,
                    rec_retendet.numint,
                    rec_retendet.item,
                    rec_retendet.tdocum,
                    rec_retendet.serie,
                    rec_retendet.numero,
                    rec_retendet.fdocum,
                    rec_retendet.pago,
                    rec_retendet.pago01,
                    rec_retendet.pago02,
                    rec_retendet.retencion,
                    rec_retendet.retencion01,
                    rec_retendet.retencion02,
                    current_timestamp,
                    current_timestamp
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                IF nvl(rec_retendet.pago, 0) <> 0 THEN
                    rec_retendet.pago01 := rec_retendet.pago * rec_retenhea.tcamb01;
                    rec_retendet.pago02 := rec_retendet.pago * rec_retenhea.tcamb02;
                END IF;

                IF nvl(rec_retendet.retencion, 0) <> 0 THEN
                    rec_retendet.retencion01 := rec_retendet.retencion * rec_retenhea.tcamb01;
                    rec_retendet.retencion02 := rec_retendet.retencion * rec_retenhea.tcamb02;
                END IF;

                UPDATE retendet
                SET
                    tdocum =
                        CASE
                            WHEN rec_retendet.tdocum IS NULL THEN
                                tdocum
                            ELSE
                                rec_retendet.tdocum
                        END,
                    serie =
                        CASE
                            WHEN rec_retendet.serie IS NULL THEN
                                serie
                            ELSE
                                rec_retendet.serie
                        END,
                    numero =
                        CASE
                            WHEN rec_retendet.numero IS NULL THEN
                                numero
                            ELSE
                                rec_retendet.numero
                        END,
                    fdocum =
                        CASE
                            WHEN rec_retendet.fdocum IS NULL THEN
                                fdocum
                            ELSE
                                rec_retendet.fdocum
                        END,
                    pago =
                        CASE
                            WHEN rec_retendet.pago IS NULL THEN
                                pago
                            ELSE
                                rec_retendet.pago
                        END,
                    pago01 =
                        CASE
                            WHEN rec_retendet.pago01 IS NULL THEN
                                pago01
                            ELSE
                                rec_retendet.pago01
                        END,
                    retencion =
                        CASE
                            WHEN rec_retendet.retencion IS NULL THEN
                                retencion
                            ELSE
                                rec_retendet.retencion
                        END,
                    retencion01 = nvl(rec_retendet.retencion01, retencion01),
                    retencion02 = nvl(rec_retendet.retencion02, retencion02),
                    factua = current_timestamp
                WHERE
                        id_cia = rec_retendet.id_cia
                    AND numint = rec_retendet.numint
                    AND item = rec_retendet.item;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                BEGIN
                    SELECT
                        1
                    INTO v_aux
                    FROM
                        retenhea
                    WHERE
                            id_cia = rec_retendet.id_cia
                        AND numint = rec_retendet.numint
                        AND situac = 9;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                        || rec_retendet.numint
                                        || ' TIENE QUE ESTAR ANULADO';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                BEGIN
                    SELECT
                        situac
                    INTO v_situac
                    FROM
                        retencion_envio_sunat
                    WHERE
                            id_cia = rec_retendet.id_cia
                        AND numint = rec_retendet.numint
                        AND situac = 1; -- REGISTRO ENVIADO A SUNAT
                    pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                    || rec_retendet.numint
                                    || ' YA ESTA VINCULADO A SUNAT!';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                EXCEPTION
                    WHEN no_data_found THEN
                        DELETE FROM retendet
                        WHERE
                                id_cia = rec_retendet.id_cia
                            AND numint = rec_retendet.numint
                            AND item = rec_retendet.item;

                END;

            WHEN 5 THEN
                v_accion := 'La eliminación';
                BEGIN
                    SELECT
                        1
                    INTO v_aux
                    FROM
                        retenhea
                    WHERE
                            id_cia = rec_retendet.id_cia
                        AND numint = rec_retendet.numint
                        AND situac = 9;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                        || rec_retendet.numint
                                        || ' TIENE QUE ESTAR ANULADO';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                BEGIN
                    SELECT
                        situac
                    INTO v_situac
                    FROM
                        retencion_envio_sunat
                    WHERE
                            id_cia = rec_retendet.id_cia
                        AND numint = rec_retendet.numint
                        AND situac = 1; -- REGISTRO ENVIADO A SUNAT
                    pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                    || rec_retendet.numint
                                    || ' YA ESTA VINCULADO A SUNAT!';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                EXCEPTION
                    WHEN no_data_found THEN
                        DELETE FROM retendet
                        WHERE
                                id_cia = rec_retendet.id_cia
                            AND numint = rec_retendet.numint;

                END;

        END CASE;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'pagosage' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'pagosage' VALUE 'El registro con NUMERO INTERNO - ITEM [ '
                                     || rec_retendet.numint
                                     || ' - '
                                     || rec_retendet.item
                                     || ' ] ya existe y no puede duplicarse'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'pagosage' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
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

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'pagosage' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/
