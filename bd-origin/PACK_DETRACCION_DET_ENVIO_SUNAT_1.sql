--------------------------------------------------------
--  DDL for Package Body PACK_DETRACCION_DET_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DETRACCION_DET_ENVIO_SUNAT" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_tipo   NUMBER,
        pin_docume NUMBER
    ) RETURN datatable_detraccion_det_envio_sunat
        PIPELINED
    IS
        v_table datatable_detraccion_det_envio_sunat;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            detraccion_det_envio_sunat
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint
            AND tipo = pin_tipo
            AND docume = pin_docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_detraccion_det_envio_sunat
        PIPELINED
    IS
        v_table datatable_detraccion_det_envio_sunat;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            detraccion_det_envio_sunat c
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--/
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--  "numint": 11,
--  "tipo": 600,
--  "docume": 9
--}';
--pack_detraccion_det_envio_sunat.sp_save(25, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--/
--SELECT * FROM pack_detraccion_det_envio_sunat.sp_obtener(25,11,600,7);
--/
--SELECT * FROM pack_detraccion_det_envio_sunat.sp_buscar(25,11);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o                              json_object_t;
        rec_detraccion_det_envio_sunat detraccion_det_envio_sunat%rowtype;
        v_accion                       VARCHAR2(50) := '';
        v_sequence_name                VARCHAR2(1000);
        v_mensaje                      VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_detraccion_det_envio_sunat.id_cia := pin_id_cia;
        rec_detraccion_det_envio_sunat.numint := o.get_number('numint');
        rec_detraccion_det_envio_sunat.tipo := o.get_number('tipo');
        rec_detraccion_det_envio_sunat.docume := o.get_number('docume');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO detraccion_det_envio_sunat (
                    id_cia,
                    numint,
                    tipo,
                    docume
                ) VALUES (
                    rec_detraccion_det_envio_sunat.id_cia,
                    rec_detraccion_det_envio_sunat.numint,
                    rec_detraccion_det_envio_sunat.tipo,
                    rec_detraccion_det_envio_sunat.docume
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM detraccion_det_envio_sunat
                WHERE
                        id_cia = rec_detraccion_det_envio_sunat.id_cia
                    AND numint = rec_detraccion_det_envio_sunat.numint
                    AND tipo = rec_detraccion_det_envio_sunat.tipo
                    AND docume = rec_detraccion_det_envio_sunat.docume;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'tiposage' VALUE 'Success!'
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
                    'tiposage' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_save;

END;

/
