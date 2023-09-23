--------------------------------------------------------
--  DDL for Package Body PACK_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_COMPR010" AS

    PROCEDURE sp_actualiza_ddetrac (
        pin_id_cia  IN NUMBER,
        pin_datos    IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_compr010 compr010%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_compr010.id_cia := pin_id_cia;
        rec_compr010.tipo := o.get_number('tipo');
        rec_compr010.docume := o.get_number('docume');
        rec_compr010.ddetrac := o.get_string('ddetrac');
        rec_compr010.fdetrac := o.get_date('fdetrac');
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualización se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

        UPDATE compr010
        SET
            ddetrac =
                CASE
                    WHEN rec_compr010.ddetrac IS NULL THEN
                        ddetrac
                    ELSE
                        rec_compr010.ddetrac
                END,
            fdetrac = CASE
                    WHEN rec_compr010.fdetrac IS NULL THEN
                        fdetrac 
                    ELSE
                        rec_compr010.fdetrac
                END
            --fdetrac = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
        WHERE
                id_cia = pin_id_cia
            AND tipo = rec_compr010.tipo
                AND docume = rec_compr010.docume;
        COMMIT;
    EXCEPTION
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
    END sp_actualiza_ddetrac;

END;

/
