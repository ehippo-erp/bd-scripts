--------------------------------------------------------
--  DDL for Procedure SP001_VERIFICA_DOCUMENTO_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP001_VERIFICA_DOCUMENTO_001" (
    pin_id_cia        IN      NUMBER,
    pin_numint        IN      NUMBER,
    pin_swmuestramsj  IN      VARCHAR2,
    pin_verifylimcre  IN      VARCHAR2,
    pout_swresult     IN OUT  VARCHAR2,
    pout_messaje      IN OUT  VARCHAR2
) IS

    v_result          VARCHAR2(1);
    v_messaje         VARCHAR2(1000);
    v_id_cia          NUMBER;
    v_id_anopro       NUMBER;
    v_mespro          NUMBER;
    v_conteo          NUMBER;
    v_swhaydocto      VARCHAR2(1);
    v_codcli          VARCHAR2(20);
    v_descri          VARCHAR2(30);
    v_id              VARCHAR2(02);
    v_codmot          NUMBER;
    v_tipdoc          NUMBER;
    v_series          VARCHAR2(5);
    v_numdoc          NUMBER;
    v_swvisachkcred   VARCHAR2(5);
    v_swchecklimcred  VARCHAR2(5);
    v_descrip         VARCHAR2(50);
BEGIN
    v_swhaydocto := 'N';
    v_result := 'S';
    v_messaje := '';
    v_conteo := 0;
    v_id := '';
    v_codmot := 0;
    v_swchecklimcred := 'S';
    BEGIN
        SELECT
            dc.id_cia,
            d.descri,
            dc.tipdoc,
            dc.series,
            dc.numdoc,
            dc.codcli,
            dc.id,
            dc.codmot,
            d.visachkcred,
            EXTRACT(YEAR FROM dc.femisi),
            EXTRACT(MONTH FROM dc.femisi)
        INTO
            v_id_cia,
            v_descri,
            v_tipdoc,
            v_series,
            v_numdoc,
            v_codcli,
            v_id,
            v_codmot,
            v_swvisachkcred,
            v_id_anopro,
            v_mespro
        FROM
            documentos_cab  dc
            LEFT OUTER JOIN documentos      d ON d.id_cia = dc.id_cia
                                            AND d.codigo = dc.tipdoc
                                            AND d.series = dc.series
        WHERE
                dc.id_cia = pin_id_cia
            AND dc.numint = pin_numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_descri := '';
            v_tipdoc := 0;
            v_series := '';
            v_numdoc := 0;
            v_codcli := '';
            v_id := '';
            v_codmot := 0;
            v_id_anopro := 0;
            v_mespro := 0;
            v_swvisachkcred := 'N';
    END;
------  100 = COTIZACIÓN  ----------------

    IF ( v_tipdoc = 100 ) THEN
        v_swhaydocto := 'S';
        IF ( upper(v_result) = 'S' ) THEN
            sp000_tiene_clases_obligatorias_pendientes(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
       -- INVIERTE RESULTADO 
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

            IF ( upper(v_result) = 'S' ) THEN
                sp000_valida_detalles(pin_id_cia, pin_numint, pin_swmuestramsj, 'S', 'S',
                                      v_result, v_messaje);
                IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                    v_result := 'N';
                ELSE
                    v_result := 'S';
                END IF;

            END IF;

        END IF;

    END IF;
------  101 = ORDEN DE DESPACHO / PEDIDO -------

    IF ( v_tipdoc = 101 ) THEN
        v_swhaydocto := 'S';
        IF ( upper(v_result) = 'S' ) THEN
            sp000_tiene_clases_obligatorias_pendientes(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
       ---          -INVIERTE RESULTADO  ---
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF (
            ( upper(v_result) = 'S' ) AND ( upper(pin_verifylimcre) = 'S' )
        ) THEN
            sp000_tiene_credito_cerrado(pin_id_cia, 'A', v_codcli, pin_swmuestramsj, v_result,
                                        v_messaje);
       ------ -INVIERTE RESULTADO ------
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF ( upper(v_result) = 'S' ) THEN  /* SI NO TIENE EL CREDITO CERRADO */
            sp000_tiene_aprobacion(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
            IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                v_result := 'N';
            ELSE
                v_result := 'S';
            END IF;

            sp000_obtener_valores_motivos_clase_001(pin_id_cia, v_tipdoc, 'S', v_codmot, 8,
                                                    v_descrip, v_swchecklimcred); 
   ----8= VERIFICA LIMITE DE CREDITO ----
            IF ( ( v_swchecklimcred IS NULL ) OR ( v_swchecklimcred = '' ) ) THEN
                v_swchecklimcred := 'S';
            END IF;

            IF ( ( upper(v_result) = 'S' ) OR ( ( upper(v_swchecklimcred) <> 'S' ) OR ( upper(v_swvisachkcred) <> 'S' ) ) ) THEN
                v_result := 'S';
            ELSE
                IF ( upper(pin_verifylimcre) = 'S' ) THEN
                    BEGIN
                        SELECT
                            COUNT(0)
                        INTO v_conteo
                        FROM
                            cliente_codpag
                        WHERE
                                id_cia = pin_id_cia
                            AND codcli = v_codcli
                            AND swdefaul = 'S';

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_conteo := 0;
                    END;

                    IF v_conteo > 1 THEN
                        RAISE pkg_exceptionuser.ex_cliente_con_mas_de_una_cpago_defaul;

                    ELSE
                        SELECT
                            swresultado,
                            mensaje
                        INTO
                            v_result,
                            v_messaje
                        FROM
                            TABLE ( sp000_tiene_credito_simple(pin_id_cia, v_codcli, pin_numint, pin_swmuestramsj) );

                        IF ( upper(v_result) = 'N' ) THEN
                            v_result := 'L';
                        ELSE
                            v_result := 'S';
                        END IF;

                        IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                            v_result := 'N';
                        ELSE
                            v_result := 'S';
                        END IF;

                    END IF;

                END IF;
            END IF;
------BLOQUE

            IF ( upper(v_result) = 'S' ) THEN
                sp000_valida_detalles(pin_id_cia, pin_numint, pin_swmuestramsj, 'S', 'S',
                                      v_result, v_messaje);
                IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                    v_result := 'N';
                ELSE
                    v_result := 'S';
                END IF;

            END IF;

        END IF;

    END IF;
--------         103 = GUÍA DE REMISIÓN   ------

    IF ( v_tipdoc = 103 ) THEN
        v_swhaydocto := 'S';
        IF ( upper(v_result) = 'S' ) THEN

	 --- 4=MODULO LOGISTICA ---
            sp000_verifica_mes_cerrado(pin_id_cia, 4, v_id_anopro, v_mespro, v_result,
                                       v_messaje);
                      -- VERIFICA MES CERRADO --
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF ( v_result = 'S' ) THEN
            sp000_tiene_clases_obligatorias_pendientes(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
                   -- INVIERTE RESULTADO --
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF (
            ( upper(v_result) = 'S' ) AND ( upper(pin_verifylimcre) = 'S' )
        ) THEN
            sp000_tiene_credito_cerrado(pin_id_cia, 'A', v_codcli, pin_swmuestramsj, v_result,
                                        v_messaje);
              ---- INVIERTE RESULTADO ----
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF ( v_result = 'S' ) THEN
            sp000_tiene_aprobacion(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
            IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                v_result := 'N';
            ELSE
                v_result := 'S';
            END IF;

            sp000_obtener_valores_motivos_clase_001(pin_id_cia, v_tipdoc, 'S', v_codmot, 8,
                                                    v_descrip, v_swchecklimcred); 
		   --- 8= VERIFICA LIMITE DE CREDITO----
            v_swchecklimcred := nvl(v_swchecklimcred, 'S');
            IF ( ( upper(v_result) = 'S' ) OR ( ( upper(v_swchecklimcred) <> 'S' ) OR ( upper(v_swvisachkcred) <> 'S' ) ) ) THEN
                v_result := 'S';
            ELSE
                IF ( upper(pin_verifylimcre) = 'S' ) THEN
                    SELECT
                        swresultado,
                        mensaje
                    INTO
                        v_result,
                        v_messaje
                    FROM
                        TABLE ( sp000_tiene_credito_simple(pin_id_cia, v_codcli, pin_numint, pin_swmuestramsj) );

                ELSE
                    v_result := 'S';
                END IF;

                IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                    v_result := 'N';
                ELSE
                    v_result := 'S';
                END IF;

            END IF;

        END IF;

        IF ( upper(v_result) = 'S' ) THEN
            sp000_valida_detalles(pin_id_cia, pin_numint, pin_swmuestramsj, 'S', 'S',
                                  v_result, v_messaje);
            IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                v_result := 'N';
            ELSE
                v_result := 'S';
            END IF;

        END IF;

    END IF;
------------------------------------
  /* 201 = ORDEN DE DEVOLUCION */

    IF ( v_tipdoc = 201 ) THEN
        v_swhaydocto := 'S';
        IF ( upper(v_result) = 'S' ) THEN
            sp000_tiene_clases_obligatorias_pendientes(pin_id_cia, pin_numint, pin_swmuestramsj, v_result, v_messaje);
           ---INVIERTE RESULTADO ---
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF ( upper(v_result) = 'S' ) THEN
            sp000_tiene_credito_cerrado(pin_id_cia, 'A', v_codcli, pin_swmuestramsj, v_result,
                                        v_messaje);
       -- INVIERTE RESULTADO ---
            IF ( ( v_result IS NULL ) OR ( upper(v_result) = 'N' ) ) THEN
                v_result := 'S';
            ELSE
                v_result := 'N';
            END IF;

        END IF;

        IF ( upper(v_result) = 'S' ) THEN
            sp000_valida_detalles(pin_id_cia, pin_numint, pin_swmuestramsj, 'S', 'S',
                                  v_result, v_messaje);
            IF ( ( v_result IS NULL ) OR ( upper(v_result) <> 'S' ) ) THEN
                v_result := 'N';
            ELSE
                v_result := 'S';
            END IF;

        END IF;

    END IF;

    IF ( v_swhaydocto = 'N' ) THEN
        v_result := 'N';
        v_messaje := v_messaje
                     || chr(13)
                     || 'EL DOCUMENTO '
                     || v_descri
                     || ' '
                     || v_series
                     || '-'
                     || to_char(v_numdoc)
                     || ' No esta configurado en SP001_VERIFICA_DOCUMENTO_001';

    END IF;

    pout_swresult := v_result;
    pout_messaje := v_messaje;
EXCEPTION
    WHEN pkg_exceptionuser.ex_cliente_con_mas_de_una_cpago_defaul THEN
        raise_application_error(pkg_exceptionuser.cliente_con_mas_de_una_cpago_defaul, 'CLIENTE : '
                                                                                       || v_codcli
                                                                                       || 'tiene mas de una condición de pago default');
END sp001_verifica_documento_001;

/
