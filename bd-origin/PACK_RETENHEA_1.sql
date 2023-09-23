--------------------------------------------------------
--  DDL for Package Body PACK_RETENHEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RETENHEA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_retenhea
        PIPELINED
    IS
        v_table datatable_retenhea;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            retenhea
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--  "numint":1000,
--  "serie": "F001",
--  "numero":1000,
--  "periodo":2022,
--  "mes":12,
--  "libro":"16",
--  "asiento":2,
--  "femisi": "2022-12-01",
--  "moneda":"PEN",
--  "tcamb01":3.97,
--  "tcamb02":0.28,
--  "codigo": "456465465456",
--  "razonc": "PRUEBA2",
--  "cuentaret": "1212021",
--  "dhret": "H",
--  "cuentaigv": "1212023",
--  "situac": 1
--                }';
--pack_retenhea.sp_save(66, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_retenhea.sp_obtener(66,1000);
--
--SELECT * FROM pack_retenhea.sp_buscar(66,'16',NULL,NULL,NULL);

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_libro   VARCHAR2,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_asiento NUMBER
    ) RETURN datatable_retenhea
        PIPELINED
    IS
        v_table datatable_retenhea;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            retenhea
        WHERE
                id_cia = pin_id_cia
            AND libro = pin_libro
            AND ( nvl(pin_periodo, - 1) = - 1
                  OR periodo = pin_periodo )
            AND ( nvl(pin_mes, - 1) = - 1
                  OR mes = pin_mes )
            AND ( nvl(pin_asiento, - 1) = - 1
                  OR asiento = pin_asiento );

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

        o            json_object_t;
        rec_retenhea retenhea%rowtype;
        v_accion     VARCHAR2(50) := '';
        v_moneda     VARCHAR2(5);
        pout_mensaje VARCHAR2(1000);
        v_venta      NUMBER;
        v_aux        NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_retenhea.id_cia := pin_id_cia;
        rec_retenhea.numint := o.get_number('numint');
        rec_retenhea.serie := o.get_string('serie');
        rec_retenhea.numero := o.get_number('numero');
        rec_retenhea.periodo := o.get_number('periodo');
        rec_retenhea.mes := o.get_number('mes');
        rec_retenhea.libro := o.get_string('libro');
        rec_retenhea.asiento := o.get_number('asiento');
        rec_retenhea.femisi := o.get_date('femisi');
        rec_retenhea.moneda := o.get_string('moneda');
        rec_retenhea.tcamb01 := o.get_number('tcamb01');
        rec_retenhea.tcamb02 := o.get_number('tcamb02');
        rec_retenhea.codigo := o.get_string('codigo');
        rec_retenhea.razonc := o.get_string('razonc');
        rec_retenhea.cuentaret := o.get_string('cuentaret');
        rec_retenhea.dhret := o.get_string('dhret');
        rec_retenhea.cuentaigv := o.get_string('cuentaigv');
        rec_retenhea.situac := o.get_number('situac');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF rec_retenhea.numero > 0 THEN
                    BEGIN
                        SELECT
                            numero
                        INTO rec_retenhea.numero
                        FROM
                            retenhea
                        WHERE
                                id_cia = rec_retenhea.id_cia
                            AND serie = rec_retenhea.serie
                            AND numero = rec_retenhea.numero
                        FETCH NEXT 1 ROWS ONLY;

                        pout_mensaje := 'EL DOCUMENTO '
                                        || rec_retenhea.serie
                                        || ' - '
                                        || rec_retenhea.numero
                                        || ' YA ESTA REGISTRADO Y NO PUEDE DUPLICARSE';

                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    EXCEPTION
                        WHEN no_data_found THEN
                            NULL;
                    END;
                END IF;
/* 2011-11-21- Carlos - El Tipo de cambio usado en el  Comprobante de Retencion debe ser el de la fecha de Emision..
                        Del Asiento...
*/
                IF rec_retenhea.moneda <> 'PEN' THEN
                    v_moneda := rec_retenhea.moneda;
                ELSE
                    v_moneda := 'USD';
                END IF;

                BEGIN
                    SELECT
                        round(venta, 2)
                    INTO v_venta
                    FROM
                        tcambio
                    WHERE
                            id_cia = pin_id_cia
                        AND fecha = rec_retenhea.femisi
                        AND hmoneda = 'PEN'
                        AND moneda = v_moneda;

                    IF v_venta > 0 THEN
                        IF rec_retenhea.moneda = 'PEN' THEN
                            rec_retenhea.tcamb01 := 1;
                            rec_retenhea.tcamb02 := 1 / v_venta;
                        ELSE
                            rec_retenhea.tcamb01 := v_venta;
                            rec_retenhea.tcamb02 := 1;
                        END IF;

                    END IF;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE TIPO DE CAMBIO REGISTRADO LA FECHA '
                                        || to_char(rec_retenhea.femisi, 'DD/MM/YY')
                                        || '';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                INSERT INTO retenhea (
                    id_cia,
                    numint,
                    serie,
                    numero,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    femisi,
                    moneda,
                    tcamb01,
                    tcamb02,
                    codigo,
                    razonc,
                    cuentaret,
                    dhret,
                    cuentaigv,
                    situac,
                    fcreac,
                    factua
                ) VALUES (
                    rec_retenhea.id_cia,
                    rec_retenhea.numint,
                    rec_retenhea.serie,
                    rec_retenhea.numero,
                    rec_retenhea.periodo,
                    rec_retenhea.mes,
                    rec_retenhea.libro,
                    rec_retenhea.asiento,
                    rec_retenhea.femisi,
                    rec_retenhea.moneda,
                    rec_retenhea.tcamb01,
                    rec_retenhea.tcamb02,
                    rec_retenhea.codigo,
                    rec_retenhea.razonc,
                    rec_retenhea.cuentaret,
                    rec_retenhea.dhret,
                    rec_retenhea.cuentaigv,
                    0, -- LIBRE
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE retenhea
                SET
                    serie =
                        CASE
                            WHEN rec_retenhea.serie IS NULL THEN
                                serie
                            ELSE
                                rec_retenhea.serie
                        END,
                    numero =
                        CASE
                            WHEN rec_retenhea.numero IS NULL THEN
                                numero
                            ELSE
                                rec_retenhea.numero
                        END,
                    periodo =
                        CASE
                            WHEN rec_retenhea.periodo IS NULL THEN
                                periodo
                            ELSE
                                rec_retenhea.periodo
                        END,
                    mes =
                        CASE
                            WHEN rec_retenhea.mes IS NULL THEN
                                mes
                            ELSE
                                rec_retenhea.mes
                        END,
                    libro =
                        CASE
                            WHEN rec_retenhea.libro IS NULL THEN
                                libro
                            ELSE
                                rec_retenhea.libro
                        END,
                    femisi =
                        CASE
                            WHEN rec_retenhea.femisi IS NULL THEN
                                femisi
                            ELSE
                                rec_retenhea.femisi
                        END,
                    moneda = nvl(rec_retenhea.moneda, moneda),
                    tcamb01 = nvl(rec_retenhea.tcamb01, tcamb01),
                    tcamb02 = nvl(rec_retenhea.tcamb02, tcamb02),
                    codigo = nvl(rec_retenhea.codigo, codigo),
                    razonc = nvl(rec_retenhea.razonc, razonc),
                    cuentaret = nvl(rec_retenhea.cuentaret, cuentaret),
                    dhret = nvl(rec_retenhea.dhret, dhret),
                    cuentaigv = nvl(rec_retenhea.cuentaigv, cuentaigv),
                    situac = nvl(rec_retenhea.situac, situac),
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_retenhea.id_cia
                    AND numint = rec_retenhea.numint;

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
                            id_cia = rec_retenhea.id_cia
                        AND numint = rec_retenhea.numint
                        AND situac = 9;

                    DELETE FROM retenhea
                    WHERE
                            id_cia = rec_retenhea.id_cia
                        AND numint = rec_retenhea.numint;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'EL REGISTRO DE RETENCION N° '
                                        || rec_retenhea.numint
                                        || ' TIENE QUE ESTAR ANULADO';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

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
                    'message' VALUE 'El registro con NUMERO INTERNO [ '
                                    || rec_retenhea.numint
                                    || ' ] ya existe y no puede duplicarse'
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
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/
