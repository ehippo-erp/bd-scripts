--------------------------------------------------------
--  DDL for Package Body PACK_DETRACCION_CAB_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DETRACCION_CAB_ENVIO_SUNAT" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_detraccion_cab_envio_sunat
        PIPELINED
    IS
        v_table datatable_detraccion_cab_envio_sunat;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            detraccion_cab_envio_sunat
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_detraccion_cab_envio_sunat
        PIPELINED
    IS
        v_table datatable_detraccion_cab_envio_sunat;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            detraccion_cab_envio_sunat c
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND ( nvl(pin_mes, - 1) = - 1
                  OR mes = pin_mes );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_generador (
        pin_id_cia  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_sequence_name VARCHAR2(1000);
        count_exist     INTEGER;
        last_number     INTEGER;
    BEGIN
        v_sequence_name := 'GEN_DETRACCION_CAB_ENVIO_SUNAT_' || to_char(pin_id_cia);
        SELECT
            0
        INTO count_exist
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = upper(v_sequence_name)
        FETCH NEXT 1 ROWS ONLY;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN no_data_found THEN
            BEGIN
                SELECT
                    numint + 1
                INTO last_number
                FROM
                    detraccion_cab_envio_sunat
                WHERE
                    id_cia = pin_id_cia
                ORDER BY
                    numint DESC
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    last_number := 1;
            END;

            EXECUTE IMMEDIATE 'CREATE SEQUENCE '
                              || upper(v_sequence_name)
                              || ' START WITH '
                              || last_number
                              || ' INCREMENT BY 1 ORDER'
                              || ' MINVALUE '
                              || 1
                              || ' NOCACHE ';

            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Success!'
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

            ROLLBACK;
    END sp_generador;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--  "numint": 999,
--  "periodo": 2023,
--  "mes": 7,
--  "numdoc": 100,
--  "fenvio": "2023-07-01",
--  "frespuesta": "2023-07-01",
--  "estado": 1,
--  "ctxt": 1,
--  "ucreac": "admin",
--  "uactua": "admin"
--}';
--pack_detraccion_cab_envio_sunat.sp_save(25, NULL, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_detraccion_cab_envio_sunat.sp_obtener(25,10);
--
--SELECT * FROM pack_detraccion_cab_envio_sunat.sp_buscar(25,2023,7);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_txt     IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o                              json_object_t;
        rec_detraccion_cab_envio_sunat detraccion_cab_envio_sunat%rowtype;
        v_accion                       VARCHAR2(50) := '';
        v_sequence_name                VARCHAR2(1000);
        v_mensaje                      VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_detraccion_cab_envio_sunat.id_cia := pin_id_cia;
        rec_detraccion_cab_envio_sunat.numint := o.get_number('numint');
        rec_detraccion_cab_envio_sunat.periodo := o.get_number('periodo');
        rec_detraccion_cab_envio_sunat.mes := o.get_number('mes');
--        rec_detraccion_cab_envio_sunat.numdoc := o.get_number('numdoc');
        rec_detraccion_cab_envio_sunat.fenvio := o.get_date('fenvio');
        rec_detraccion_cab_envio_sunat.frespuesta := o.get_date('frespuesta');
        rec_detraccion_cab_envio_sunat.estado := o.get_number('estado');
--        rec_detraccion_cab_envio_sunat.txt := o.get_date('txt');
        rec_detraccion_cab_envio_sunat.ctxt := o.get_number('ctxt');
        rec_detraccion_cab_envio_sunat.ucreac := o.get_string('ucreac');
        rec_detraccion_cab_envio_sunat.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    pack_detraccion_cab_envio_sunat.sp_generador(pin_id_cia, v_mensaje);
                    v_sequence_name := 'GEN_DETRACCION_CAB_ENVIO_SUNAT_' || to_char(pin_id_cia);
                    EXECUTE IMMEDIATE 'SELECT '
                                      || v_sequence_name
                                      || '.NEXTVAL FROM DUAL'
                    INTO rec_detraccion_cab_envio_sunat.numint;
                    dbms_output.put_line(rec_detraccion_cab_envio_sunat.numint);
                END;

                BEGIN
                    SELECT
                        nvl(numdoc, 0) + 1
                    INTO rec_detraccion_cab_envio_sunat.numdoc
                    FROM
                        detraccion_cab_envio_sunat
                    WHERE
                            id_cia = pin_id_cia
                        AND periodo = rec_detraccion_cab_envio_sunat.periodo
                    ORDER BY
                        numdoc DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_detraccion_cab_envio_sunat.numdoc := 1;
                END;

                INSERT INTO detraccion_cab_envio_sunat (
                    id_cia,
                    numint,
                    periodo,
                    mes,
                    numdoc,
                    fenvio,
                    frespuesta,
                    estado,
                    txt,
                    ctxt,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_detraccion_cab_envio_sunat.id_cia,
                    rec_detraccion_cab_envio_sunat.numint,
                    rec_detraccion_cab_envio_sunat.periodo,
                    rec_detraccion_cab_envio_sunat.mes,
                    rec_detraccion_cab_envio_sunat.numdoc,
--                    rec_detraccion_cab_envio_sunat.fenvio,
                    current_timestamp,
                    rec_detraccion_cab_envio_sunat.frespuesta,
                    1,
                    pin_txt,
                    1,
                    rec_detraccion_cab_envio_sunat.ucreac,
                    rec_detraccion_cab_envio_sunat.uactua,
                    current_timestamp,
                    current_timestamp
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE detraccion_cab_envio_sunat
                SET
                    periodo =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.periodo IS NULL THEN
                                periodo
                            ELSE
                                rec_detraccion_cab_envio_sunat.periodo
                        END,
                    mes =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.mes IS NULL THEN
                                mes
                            ELSE
                                rec_detraccion_cab_envio_sunat.mes
                        END,
                    numdoc =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.numdoc IS NULL THEN
                                numdoc
                            ELSE
                                rec_detraccion_cab_envio_sunat.numdoc
                        END,
                    fenvio =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.fenvio IS NULL THEN
                                fenvio
                            ELSE
                                rec_detraccion_cab_envio_sunat.fenvio
                        END,
                    frespuesta =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.frespuesta IS NULL THEN
                                frespuesta
                            ELSE
                                rec_detraccion_cab_envio_sunat.frespuesta
                        END,
                    estado =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.estado IS NULL THEN
                                estado
                            ELSE
                                rec_detraccion_cab_envio_sunat.estado
                        END,
                    txt =
                        CASE
                            WHEN pin_txt IS NULL THEN
                                txt
                            ELSE
                                pin_txt
                        END,
--                    txt = pin_txt,
                    ctxt =
                        CASE
                            WHEN rec_detraccion_cab_envio_sunat.ctxt IS NULL THEN
                                ctxt
                            ELSE
                                rec_detraccion_cab_envio_sunat.ctxt
                        END,
                    uactua = rec_detraccion_cab_envio_sunat.uactua,
                    factua = current_timestamp
                WHERE
                        id_cia = rec_detraccion_cab_envio_sunat.id_cia
                    AND numint = rec_detraccion_cab_envio_sunat.numint;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM detraccion_cab_envio_sunat
                WHERE
                        id_cia = rec_detraccion_cab_envio_sunat.id_cia
                    AND numint = rec_detraccion_cab_envio_sunat.numint;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!',
                'numint' VALUE rec_detraccion_cab_envio_sunat.numint,
                'numdoc' VALUE rec_detraccion_cab_envio_sunat.numdoc
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje,
                    'numint' VALUE 0,
                    'numdoc' VALUE 0
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_save;

END;

/
