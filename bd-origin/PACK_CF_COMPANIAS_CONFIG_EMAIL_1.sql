--------------------------------------------------------
--  DDL for Package Body PACK_CF_COMPANIAS_CONFIG_EMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_COMPANIAS_CONFIG_EMAIL" AS

    PROCEDURE sp_valida_emision (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000 CHAR);
        v_email      VARCHAR2(1000 CHAR);
        v_codper     VARCHAR2(20 CHAR);
        v_numpen     NUMBER;
        v_codigo     VARCHAR2(20 CHAR);
    BEGIN
        BEGIN
            SELECT
                email
            INTO v_email
            FROM
                companias_config_email
            WHERE
                    id_cia = pin_id_cia
                AND tipo = 4
                AND email IS NOT NULL
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'LA EMPRESA NO TIENE UN EMAIL EMISOR CONFIGURADO ( TIPO 4 - PLANILLA ), PARA EL ENVIO DE BOLETAS';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                p.codper,
                p.email,
                pc.codigo
            INTO
                v_codper,
                v_email,
                v_codigo
            FROM
                     planilla_auxiliar pa
                INNER JOIN personal       p ON p.id_cia = pa.id_cia
                                         AND p.codper = pa.codper
                LEFT OUTER JOIN personal_clase pc ON pc.id_cia = p.id_cia
                                                     AND pc.codper = p.codper
                                                     AND pc.clase = 1100
                                                     AND pc.codigo = 'S'
            WHERE
                    pa.id_cia = pin_id_cia
                AND pa.numpla = pin_numpla
                AND pa.codper = pin_codper
                AND pa.situac = 'S';

            IF nvl(v_codigo, 'N') = 'N' THEN
                pout_mensaje := 'EL PERSONAL [ '
                                || v_codper
                                || ' ] NO ESTA CONFIGURADO PARA EL ENVIO ELECTRONICO DE SU BOLETA, REVISAR LA ASGINACION DE CLASE 1100'
                                ;
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            IF TRIM(v_email) IS NULL THEN
                pout_mensaje := 'EL PERSONAL [ '
                                || v_codper
                                || ' ] NO TIENE UN EMAIL CONFIGURADO ENVIO ELECTRONICO DE SU BOLETA';
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL PERSONAL [ '
                                || pin_codper
                                || ' ] NO EXISTE EN LA PLANILLA ACTUAL';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        BEGIN
            SELECT
                numpen,
                desdoc
            INTO
                v_numpen,
                pout_mensaje
            FROM
                pack_dw_alerta.sp_vencimiento_certificado ( pin_id_cia );

            IF v_numpen > 0 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.0,
                        'message' VALUE pout_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

                RETURN;
            ELSE
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        EXCEPTION
            WHEN no_data_found THEN
                NULL; -- OK
        END;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
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

    END sp_valida_emision;

END;

/
