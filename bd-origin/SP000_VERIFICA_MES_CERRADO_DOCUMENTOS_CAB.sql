--------------------------------------------------------
--  DDL for Procedure SP000_VERIFICA_MES_CERRADO_DOCUMENTOS_CAB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VERIFICA_MES_CERRADO_DOCUMENTOS_CAB" (
    pin_id_cia     IN NUMBER,
    pin_tipdoc     NUMBER,
    pin_numdoc     NUMBER,
    pin_femisi     DATE,
    pin_codcpag    NUMBER,
    pin_situacold  VARCHAR2,
    pin_situacnew  VARCHAR2
) AS

    v_cierra         NUMBER;
    v_periodo        NUMBER;
    v_mes            NUMBER;
    v_swenviactacte  VARCHAR2(1);
    v_situacold      VARCHAR2(1);
    v_situacnew      VARCHAR2(1);
BEGIN
    IF ( pin_situacold IS NULL ) THEN
        v_situacold := 'A';
    END IF;
    IF ( pin_situacnew IS NULL ) THEN
        v_situacnew := 'A';
    END IF;
    v_situacold := upper(v_situacold);
    v_situacnew := upper(v_situacnew);
    v_periodo := extract(YEAR FROM pin_femisi);
    v_mes := extract(MONTH FROM pin_femisi);
    IF ( pin_tipdoc IN (
        666999
    ) ) THEN
                                     /*  1-CONTABILIDAD  */
        v_cierra := 1;
        BEGIN
            SELECT
                cierre
            INTO v_cierra
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND ( sistema = 1 )
                AND ( periodo = v_periodo )
                AND ( mes = v_mes );

        EXCEPTION
            WHEN no_data_found THEN
                v_cierra := NULL;
        END;

        IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_contabilidad;
        END IF;

    END IF;

    IF ( pin_tipdoc IN (
        4,
        5,
        6,
        9,
        41
    ) ) THEN
                                      /*  2-CUENTAS POR COBRAR - CLIENTES  */
        v_cierra := 1;
        BEGIN
            SELECT
                periodo,
                mes
            INTO
                v_periodo,
                v_mes
            FROM
                dcta105
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND numdoc = pin_numdoc;

        EXCEPTION
            WHEN no_data_found THEN
                v_periodo := 0;
                v_mes := 0;
        END;

        BEGIN
            SELECT
                cierre
            INTO v_cierra
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND ( sistema = 2 )
                AND ( periodo = v_periodo )
                AND ( mes = v_mes );

        EXCEPTION
            WHEN no_data_found THEN
                v_cierra := NULL;
        END;

        IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_ctaxcobrar;
        END IF;

    END IF;

    IF ( pin_tipdoc IN (
        1,
        3,
        7,
        8
    ) ) THEN
                                     /*  3-COMERCIAL  */
        v_cierra := 1;
        BEGIN
            SELECT
                cierre
            INTO v_cierra
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND ( sistema = 3 )
                AND ( periodo = v_periodo )
                AND ( mes = v_mes );

        EXCEPTION
            WHEN no_data_found THEN
                v_cierra := NULL;
        END;

        IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_comercial;
        END IF;


     /* EL ENVIO A CTAS X COBRAR SE VALIDA EN FUNCION A LA CONDICION DE PAGO SOLO POR EL CAMBIO DE SITUACION OJO */

        IF ( ( v_situacnew = 'F' ) OR (
            ( v_situacold = 'F' ) AND ( ( v_situacnew = 'F' ) OR ( v_situacnew = 'A' ) OR ( v_situacnew = 'B' ) OR ( v_situacnew =
            'E' ) OR ( v_situacnew = 'J' ) OR ( v_situacnew = 'K' ) )
        ) ) THEN
            v_swenviactacte := 'N';
            BEGIN
                SELECT
                    valor
                INTO v_swenviactacte
                FROM
                    c_pago_clase c
                WHERE
                        id_cia = pin_id_cia
                    AND c.codpag = pin_codcpag
                    AND codigo = 1;

            EXCEPTION
                WHEN no_data_found THEN
                    v_swenviactacte := NULL;
            END;

            IF ( v_swenviactacte IS NULL ) THEN
                v_swenviactacte := 'N';
            END IF;
            IF ( upper(v_swenviactacte) = 'S' ) THEN

                                                /*  2-CUENTAS POR COBRAR - CLIENTES  */
                v_cierra := 1;
                BEGIN
                    SELECT
                        cierre
                    INTO v_cierra
                    FROM
                        cierre
                    WHERE
                            id_cia = pin_id_cia
                        AND ( sistema = 2 )
                        AND ( periodo = v_periodo )
                        AND ( mes = v_mes );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cierra := NULL;
                END;

                IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
                    RAISE pkg_exceptionuser.ex_mes_cerrado_ctaxcobrar;
                END IF;

            END IF;

        END IF;

    END IF;

    IF ( pin_tipdoc IN (
        102,
        103,
        111,
        115
    ) ) THEN

    /* 2014-09-13 - CONVERZANDO CON CARLOS SE QUEDO EN QUIE G.REMISION TAMBIEN VERIFIQUE COMERCIAL */
        IF ( pin_tipdoc IN (
            102
        ) ) THEN
      /* 2014-11-14 - CUANDO EL COMPROBANTE DE VENTA CAMBIE LA SITUACION DE LA GUIA DE REMISION, NO VERIFICARA EL PERIODO CERRADO*/
            IF ( NOT (
                ( ( v_situacnew = 'G' ) OR ( v_situacnew = 'H' ) OR ( v_situacnew = 'F' ) OR ( v_situacnew = 'C' ) ) AND ( ( pin_situacold =
                'F' ) OR ( pin_situacold = 'C' ) )
            ) ) THEN
                v_cierra := 1;
                BEGIN
                    SELECT
                        cierre
                    INTO v_cierra
                    FROM
                        cierre
                    WHERE
                            id_cia = pin_id_cia
                        AND ( sistema = 3 )
                        AND ( periodo = v_periodo )
                        AND ( mes = v_mes );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cierra := NULL;
                END;

                IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
                    RAISE pkg_exceptionuser.ex_mes_cerrado_comercial;
                END IF;

                v_cierra := 1;
                BEGIN
                    SELECT
                        cierre
                    INTO v_cierra
                    FROM
                        cierre
                    WHERE
                            id_cia = pin_id_cia
                        AND ( sistema = 4 )
                        AND ( periodo = v_periodo )
                        AND ( mes = v_mes );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cierra := NULL;
                END;

                IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
                    RAISE pkg_exceptionuser.ex_mes_cerrado_logistica;
                END IF;

            END IF;

        ELSE

        /*  4-LOGISTICA  */
            v_cierra := 1;
            BEGIN
                SELECT
                    cierre
                INTO v_cierra
                FROM
                    cierre
                WHERE
                        id_cia = pin_id_cia
                    AND ( sistema = 4 )
                    AND ( periodo = v_periodo )
                    AND ( mes = v_mes );

            EXCEPTION
                WHEN no_data_found THEN
                    v_cierra := NULL;
            END;

            IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
                RAISE pkg_exceptionuser.ex_mes_cerrado_logistica;
            END IF;

        END IF;
    END IF;

    IF ( pin_tipdoc IN (
        666999
    ) ) THEN
                                  /*  5-CUENTAS POR PAGAR - PROVEEDORES  */
        v_cierra := 1;
        BEGIN
            SELECT
                cierre
            INTO v_cierra
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND ( sistema = 5 )
                AND ( periodo = v_periodo )
                AND ( mes = v_mes );

        EXCEPTION
            WHEN no_data_found THEN
                v_cierra := NULL;
        END;

        IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_ctaxpagar;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_mes_cerrado_contabilidad THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_contabilidad, 'Mes cerrado en módulo Contabilidad');
    WHEN pkg_exceptionuser.ex_mes_cerrado_ctaxcobrar THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_ctaxcobrar, 'Mes cerrado en módulo Cuentas por cobrar');
    WHEN pkg_exceptionuser.ex_mes_cerrado_comercial THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_comercial, 'Mes cerrado en módulo Comercial '|| pin_femisi );
    WHEN pkg_exceptionuser.ex_mes_cerrado_logistica THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_logistica, 'Mes cerrado en módulo Logística');
    WHEN pkg_exceptionuser.ex_mes_cerrado_ctaxpagar THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_ctaxpagar, 'Mes cerrado en módulo Cuentas por pagar');
END sp000_verifica_mes_cerrado_documentos_cab;

/
