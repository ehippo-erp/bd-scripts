--------------------------------------------------------
--  DDL for Package Body PACK_INTEGRIDAD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_INTEGRIDAD" AS

    PROCEDURE valid_cpago (
        pin_id_cia    IN   INTEGER,
        pin_codpag    IN   INTEGER,
        pout_mensaje  OUT  VARCHAR2
    ) IS
        v_count INTEGER;
    BEGIN
        pout_mensaje := '';
        BEGIN
            SELECT
                COUNT(codcpag) AS conteo
            INTO v_count
            FROM
                documentos_cab dc
            WHERE
                    dc.id_cia = pin_id_cia
                AND dc.codcpag = pin_codpag;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := 0;
        END;

        IF v_count != 0 THEN
            pout_mensaje := 'La condicion de pago tiene '
                            || to_char(v_count)
                            || ' documentos relacionados';
        END IF;

    END;

    PROCEDURE valid_documento (
        pin_id_cia    IN   INTEGER,
        pin_tipdoc    IN   INTEGER,
        pin_series    IN   VARCHAR2,
        pout_mensaje  OUT  VARCHAR2
    ) AS
        v_count INTEGER;
    BEGIN 
--set SERVEROUTPUT ON
--    DECLARE
--        msj VARCHAR2(150);
--    BEGIN
--        pack_integridad.valid_documento(23, 601, '', msj);
--        IF ( msj != ' ' ) THEN
--            dbms_output.put_line(msj);
--        ELSE
--            dbms_output.put_line('Es posible borrar');
--        END IF;
--
--    END;
        pout_mensaje := '';
        CASE
        /*CORRELATIVO DOCUMENTOS_CAB*/
            WHEN ( ( pin_tipdoc = 1 ) OR /*FACTURA*/ ( pin_tipdoc = 3 ) OR /*BOLETA*/ ( pin_tipdoc = 7 ) OR /*NOTA DE CREDITO*/ ( pin_tipdoc = 8 ) OR /*NOTA DE DEBITO*/ ( pin_tipdoc = 104 ) OR /*ORDEN DE PRODUCCION*/ ( pin_tipdoc = 101 ) OR /*ORDEN DE DESPACHO*/ ( pin_tipdoc = 108 ) OR /*GUIA DE RECEPCION*/ ( pin_tipdoc = 102 ) OR /*GUIA DE REMISION*/ ( pin_tipdoc = 103 ) OR /*GUIAS INTERNAS*/ ( pin_tipdoc = 41 ) /*CONSTANCIA DE PERCEPCION*/ ) THEN
                BEGIN
                    SELECT
                        COUNT(0) AS conteo
                    INTO v_count
                    FROM
                        documentos_cab dc
                    WHERE
                            dc.id_cia = pin_id_cia
                        AND dc.tipdoc = pin_tipdoc
                        AND dc.series = pin_series;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                IF v_count != 0 THEN
                    pout_mensaje := 'El tipo de documento '
                                    || to_char(pin_tipdoc)
                                    || '-'
                                    || pin_series
                                    || ' tiene documentos relacionados';

                END IF;

            WHEN ( ( pin_tipdoc = 4 ) OR /*CHEQUE DEVUELTO*/ ( pin_tipdoc = 5 ) OR /*LETRAS DE CAMBIO*/ ( pin_tipdoc = 9 ) OR /*ANTICIPOS*/ ( pin_tipdoc = 6 ) OR /*CHEQUE DE COBRANZA FUTURA*/ ( pin_tipdoc = 43 ) OR /*DEPOSITO NO IDENTIFICADO*/ ( pin_tipdoc = 44 ) ) THEN
                IF pin_series = '999' THEN
                    BEGIN
                        SELECT
                            COUNT(0)
                        INTO v_count
                        FROM
                            dcta105
                        WHERE
                                id_cia = pin_id_cia
                            AND tipdoc = pin_tipdoc;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_count := 0;
                    END;

                    IF v_count != 0 THEN
                        pout_mensaje := 'El tipo de documento '
                                        || to_char(pin_tipdoc)
                                        || '-'
                                        || pin_series
                                        || ' tiene documentos relacionados';

                    END IF;

                END IF;
            WHEN ( ( pin_tipdoc = 601 ) OR /*DOCUMENTO DE COMPRAS PROVEEDOR*/ ( pin_tipdoc = 602 ) OR /*RECIBOS POR HONORARIOS*/ ( pin_tipdoc = 610 ) OR /*CTAS. X PAGAR PROVEEDORES*/ ( pin_tipdoc = 611 )  /*REGISTRO DE RECIBOS*/ ) THEN
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count
                    FROM
                        compr010
                    WHERE
                            id_cia = pin_id_cia
                        AND tipo = pin_tipdoc;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                IF v_count != 0 THEN
                    pout_mensaje := 'El tipo de documento '
                                    || to_char(pin_tipdoc)
                                    || '-'
                                    || pin_series
                                    || ' tiene documentos relacionados'
                                    || ' en compr010';

                END IF;

              /* CAJA CHICA COMPR040 */

            WHEN ( ( pin_tipdoc = 603 )     /*CAJA EGRESOS*/ ) THEN
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count
                    FROM
                        compr040
                    WHERE
                            id_cia = pin_id_cia
                        AND tipo = pin_tipdoc;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                IF v_count != 0 THEN
                    pout_mensaje := 'El tipo de documento '
                                    || to_char(pin_tipdoc)
                                    || ' caja chica'
                                    || ' tiene documentos relacionados en '
                                    || ' COMPR040';

                END IF;  

               /*CORRELATIVO CONSTACIA DE RETENCION */
--

            WHEN ( ( pin_tipdoc = 20 )     /*CONSTACIA DE RETENCION*/ ) THEN
                IF pin_series = '999' THEN
                    BEGIN
                        SELECT
                            COUNT(0)
                        INTO v_count
                        FROM
                            retenhea
                        WHERE
                                id_cia = pin_id_cia
                            AND serie = pin_series;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_count := 0;
                    END;

                    IF v_count != 0 THEN
                        pout_mensaje := 'El tipo de documento '
                                        || to_char(pin_tipdoc)
                                        || ' compras'
                                        || ' tiene documentos relacionados en '
                                        || 'RETENHEA';

                    END IF;

                END IF;
--
            ELSE
                NULL;
        END CASE;

    END;

END;

/
