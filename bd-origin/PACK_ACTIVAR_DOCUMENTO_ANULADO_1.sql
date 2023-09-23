--------------------------------------------------------
--  DDL for Package Body PACK_ACTIVAR_DOCUMENTO_ANULADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ACTIVAR_DOCUMENTO_ANULADO" AS

    PROCEDURE comprobante_electronico (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_situac VARCHAR2(1);
        v_valor  VARCHAR2(25);
        v_valor2 VARCHAR2(25);
    BEGIN
        BEGIN
            SELECT
                c.situac,
                CASE
                    WHEN mc.valor IS NULL THEN
                        'N'
                    ELSE
                        mc.valor
                END AS valor,
                CASE
                    WHEN cp.valor IS NULL THEN
                        'N'
                    ELSE
                        cp.valor
                END AS valor2
            INTO
                v_situac,
                v_valor,
                v_valor2
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = c.id_cia
                                                    AND mc.tipdoc = c.tipdoc
                                                    AND mc.id = c.id
                                                    AND mc.codmot = c.codmot
                                                    AND mc.codigo = 28
                LEFT OUTER JOIN c_pago_clase   cp ON cp.id_cia = c.id_cia
                                                   AND cp.codpag = c.codcpag
                                                   AND cp.codigo = 2 /*Verifica limite de credito*/
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint
                AND c.tipdoc IN ( 1, 3, 7, 8 );--NO PUEDE ESTAR DADO DE BAJA

        EXCEPTION
            WHEN no_data_found THEN
                v_situac := NULL;
                v_valor := 'N';
        END;

        IF v_situac = 'J' THEN
            UPDATE documentos_cab
            SET
                situac = 'F'
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            pin_mensaje := 'Comprobante Electronico activado ...!';
            sp_actualiza_ctasctes(pin_id_cia, pin_numint);
            IF v_valor2 = 'S' THEN
                sp_actualiza_ctasctes(pin_id_cia, pin_numint);
            END IF;
            IF v_valor = 'S' THEN
                sp_enviar_kardex(pin_id_cia, pin_numint);
            END IF;
            COMMIT;
        ELSE
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Comprobante Electronico activado ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El Comprobante Electronico debe estar en situación de anulado ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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
    END comprobante_electronico;

    PROCEDURE guia_remision ( --TIPDOC = 102
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_situac VARCHAR2(1);
        v_valor  VARCHAR2(25);
    BEGIN
        BEGIN
            SELECT
                c.situac,
                CASE
                    WHEN mc.valor IS NULL THEN
                        'N'
                    ELSE
                        mc.valor
                END
            INTO
                v_situac,
                v_valor
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = c.id_cia
                                                    AND mc.tipdoc = c.tipdoc
                                                    AND mc.id = c.id
                                                    AND mc.codmot = c.codmot
                                                    AND mc.codigo = 28
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint
                AND c.tipdoc = 102; -- GUIAS DE REMISION

        EXCEPTION
            WHEN no_data_found THEN
                v_situac := NULL;
                v_valor := 'N';
        END;

        IF v_situac = 'J' THEN
            pin_mensaje := 'Guia de Remisión activada ...!';
            UPDATE documentos_cab
            SET
                situac = 'F'
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            IF v_valor = 'S' THEN
                sp_enviar_kardex(pin_id_cia, pin_numint);
            END IF;
            COMMIT;
        ELSE
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Guia de Remisión activada ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'La Guia de Remisión debe estar en situación de anulado ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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
    END guia_remision;

END;

/
