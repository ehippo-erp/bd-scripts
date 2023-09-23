--------------------------------------------------------
--  DDL for Package Body PACK_CF_CERTIFICADO_PFX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_CERTIFICADO_PFX" AS

    FUNCTION sp_obtener_vigente (
        pin_id_cia IN NUMBER,
        pin_fhoy   IN DATE
    ) RETURN datatable_certificado_pfx
        PIPELINED
    IS
        v_table datatable_certificado_pfx;
    BEGIN
        SELECT
            pfx.*,
            current_timestamp
        BULK COLLECT
        INTO v_table
        FROM
            certificados_pfx pfx
        WHERE
                pfx.id_cia = pin_id_cia
            AND TRUNC(nvl(pin_fhoy, current_timestamp)) BETWEEN TRUNC(pfx.femisi) AND TRUNC(pfx.fvenci)
            AND pfx.swacti = 'S';
--              AND pfx.item = 1;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_vigente;

    PROCEDURE sp_valida_certificado (
        pin_id_cia  IN NUMBER,
        pin_fhoy    IN DATE,
        pin_mensaje OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000 CHAR);
        v_numpen     NUMBER;
        v_number     NUMBER;
    BEGIN
        BEGIN
            SELECT
                numpen,
                desdoc
            INTO
                v_numpen,
                pout_mensaje
            FROM
                pack_dw_alerta.sp_vencimiento_certificado ( pin_id_cia );

            IF v_numpen >= 0 THEN
                v_number := 0.0;
                RAISE pkg_exceptionuser.ex_error_inesperado;
            ELSE
                v_number := 1.1;
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.0,
                        'message' VALUE 'Success ...!'
                    )
                INTO pin_mensaje
                FROM
                    dual;

                RETURN;
        END;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE v_number,
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

    END sp_valida_certificado;

END;

/
