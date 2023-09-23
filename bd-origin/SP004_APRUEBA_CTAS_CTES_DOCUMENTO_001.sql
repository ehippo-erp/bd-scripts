--------------------------------------------------------
--  DDL for Procedure SP004_APRUEBA_CTAS_CTES_DOCUMENTO_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP004_APRUEBA_CTAS_CTES_DOCUMENTO_001" (
    pin_id_cia       IN NUMBER,
    pin_numint       IN NUMBER,
    pin_swverify     IN VARCHAR2,
    pin_swmuestramsj IN VARCHAR2,
    pin_coduser      IN VARCHAR2,
    pin_verifylimcre IN VARCHAR2,
    pout_v_resultado OUT VARCHAR2,
    pout_message     OUT VARCHAR2
) IS

    v_swhaydocto     VARCHAR2(1) := 'N';
    v_mensaje        VARCHAR2(1000) := '';
    v_desdoc         VARCHAR2(30) := '';
    v_tipdoc         NUMBER := 0;
    v_series         VARCHAR2(5) := '';
    v_numdoc         NUMBER := 0;
    v_ordcomni       NUMBER;
    v_cpago_aproauto VARCHAR2(25);
    v_swinsconpag    VARCHAR2(1);
    v_codcli         VARCHAR2(20);
    v_codcpag        NUMBER;
    v_usuari         VARCHAR2(10);
    v_lfac412        VARCHAR2(10);
    v_lsituaccot     VARCHAR2(1);
    v_resultado      VARCHAR2(1) := 'S';
    v_message        VARCHAR2(1000) := '';
    v_count_cli      NUMBER;
BEGIN
    IF ( v_resultado = 'S' ) THEN
        BEGIN
            SELECT
                d.descri AS desdoc,
                dc.tipdoc,
                dc.series,
                dc.numdoc,
                dc.ordcomni
            INTO
                v_desdoc,
                v_tipdoc,
                v_series,
                v_numdoc,
                v_ordcomni
            FROM
                documentos_cab dc
                LEFT OUTER JOIN documentos     d ON d.id_cia = dc.id_cia
                                                AND d.codigo = dc.tipdoc
                                                AND d.series = dc.series
            WHERE
                    dc.id_cia = pin_id_cia
                AND dc.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_desdoc := '';
                v_tipdoc := 0;
                v_numdoc := 0;
                v_series := '';
                v_ordcomni := 0;
        END;
      --------------

        IF ( v_tipdoc = 100 ) THEN
            v_swhaydocto := 'S';
            IF (
                ( v_resultado = 'S' )
                AND ( upper(pin_swverify) = 'S' )
            ) THEN
                sp001_verifica_documento_001(pin_id_cia, pin_numint, pin_swmuestramsj, pin_verifylimcre, v_resultado,
                                            v_message);
                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

            END IF;

       /*-- SI TODO ESTA OK.. ENTONCES PROCEDE --*/

            BEGIN
                SELECT
                    vstrg
                INTO v_lfac412
                FROM
                    factor
                WHERE
                        id_cia = pin_id_cia
                    AND codfac = 412;

            EXCEPTION
                WHEN no_data_found THEN
                    v_lfac412 := 'N';
            END;

            v_lfac412 := nvl(v_lfac412, 'N');
            v_lsituaccot := 'B';
            IF ( v_lfac412 = 'S' ) THEN
                v_lsituaccot := 'O';
            END IF;
            IF ( upper(v_resultado) = 'S' ) THEN                                  
       --- B - APROBACION DE COTIZACIONES ---
                sp002_actualiza_situacion_documento(pin_id_cia, pin_numint, v_lsituaccot, 'N', pin_swmuestramsj,
                                                   pin_coduser, v_resultado, v_message);

                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

            END IF;

        END IF;--100

---         101 = ORDEN DE DESPACHO / PEDIDO     ---

        IF ( v_tipdoc = 101 ) THEN
            v_swhaydocto := 'S';
            IF (
                ( v_resultado = 'S' )
                AND ( upper(pin_swverify) = 'S' )
            ) THEN
                sp001_verifica_documento_001(pin_id_cia, pin_numint, pin_swmuestramsj, pin_verifylimcre, v_resultado,
                                            v_message);
                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

            END IF;

       -- SI TODO ESTA OK.. ENTONCES PROCEDE --

            IF ( v_resultado = 'S' ) THEN                                --- B - APROBACION DE ORDENES ----
                sp000_elimina_documentos_ent_001(pin_id_cia, pin_numint);
                sp002_actualiza_situacion_documento(pin_id_cia, pin_numint, 'B', 'N', pin_swmuestramsj,
                                                   pin_coduser, v_resultado, v_message);

                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

                sp000_genera_documentos_ent_001(pin_id_cia, pin_numint);
                IF ( v_resultado = 'S' ) THEN
                    sp003a_actualiza_situacion_documento_relacionados(pin_id_cia, pin_numint, pin_swmuestramsj, pin_coduser, v_resultado
                    ,
                                                                     v_message);
                    IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                        v_resultado := 'N';
                    ELSE
                        v_resultado := 'S';
                    END IF;

                END IF;

                IF ( v_resultado = 'S' ) THEN
                    sp003_actualiza_situacion_documento_segun_saldo(pin_id_cia, v_ordcomni, pin_swmuestramsj, pin_coduser, v_resultado
                    ,
                                                                   v_message);
                    IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                        v_resultado := 'N';
                    ELSE
                        v_resultado := 'S';
                    END IF;

                END IF;

          /*2015-09-30 --APROBACION AUTOMATICA SEGUN CLASE CONDICION DE PAGO -- */

                v_cpago_aproauto := 'N';
                BEGIN
                    SELECT
                        upper(p.valor),
                        upper(f.vstrg),
                        d.codcli,
                        d.codcpag,
                        d.usuari
                    INTO
                        v_cpago_aproauto,
                        v_swinsconpag,
                        v_codcli,
                        v_codcpag,
                        v_usuari
                    FROM
                        documentos_cab d
                        LEFT OUTER JOIN c_pago_clase   p ON p.id_cia = d.id_cia
                                                          AND p.codpag = d.codcpag
                                                          AND p.codigo = 5  /* FLAG APROBACION AUTOMATICA */
                        LEFT OUTER JOIN factor         f ON f.id_cia = d.id_cia
                                                    AND f.codfac = 348
                    WHERE
                            d.id_cia = pin_id_cia
                        AND d.numint = pin_numint;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cpago_aproauto := 'N';
                        v_swinsconpag := 'N';
                        v_codcli := '';
                        v_codcpag := 0;
                        v_usuari := '';
                END;

                IF ( ( v_cpago_aproauto IS NULL ) OR ( v_cpago_aproauto <> 'S' ) ) THEN
                    v_cpago_aproauto := 'N';
                END IF;

                IF ( v_cpago_aproauto = 'S' ) THEN
                    sp000_inserta_actualiza_aprobacion_001(pin_id_cia, pin_numint, 'B', pin_coduser);
                END IF;
            ---reemplazando not exists en if

                BEGIN
                    SELECT
                        COUNT(codcli) AS valor
                    INTO v_count_cli
                    FROM
                        cliente_codpag
                    WHERE
                            id_cia = pin_id_cia
                        AND codcli = v_codcli
                        AND codpag = v_codcpag;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count_cli := 0;
                END;
            ----

                IF (
                    ( v_cpago_aproauto = 'S' )
                    AND ( v_swinsconpag = 'S' )
                    AND ( v_count_cli = 0 )
                ) THEN
                    INSERT INTO cliente_codpag (
                        id_cia,
                        codcli,
                        codpag,
                        fcreac,
                        factua,
                        usuari,
                        swdefaul
                    ) VALUES (
                        pin_id_cia,
                        v_codcli,
                        v_codcpag,
                        current_timestamp,
                        current_timestamp,
                        v_usuari,
                        'N'
                    );

                    COMMIT;
                END IF;

            END IF;

        END IF;--101

       /*          201 = ORDEN DE DEVOLUCION   */

        IF ( v_tipdoc = 201 ) THEN
            v_swhaydocto := 'S';
            IF (
                ( v_resultado = 'S' )
                AND ( upper(pin_swverify) = 'S' )
            ) THEN
                sp001_verifica_documento_001(pin_id_cia, pin_numint, pin_swmuestramsj, pin_verifylimcre, v_resultado,
                                            v_message);
                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

            END IF;

          /*-- SI TODO ESTA OK.. ENTONCES PROCEDE --*/

            IF ( v_resultado = 'S' ) THEN                                  /* B - APROBACION DE ORDENES */
                pack_documentos_ent_dev.sp_eliminar(pin_id_cia, pin_numint, NULL, v_mensaje);
                sp002_actualiza_situacion_documento(pin_id_cia, pin_numint, 'B', 'N', pin_swmuestramsj,
                                                   pin_coduser, v_resultado, v_message);

                IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                    v_resultado := 'N';
                ELSE
                    v_resultado := 'S';
                END IF;

                pack_documentos_ent_dev.sp_generar(pin_id_cia, pin_numint, NULL, v_mensaje);
                IF ( v_resultado = 'S' ) THEN
                    sp003a_actualiza_situacion_documento_relacionados(pin_id_cia, pin_numint, pin_swmuestramsj, pin_coduser, v_resultado
                    ,
                                                                     v_message);
                    IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                        v_resultado := 'N';
                    ELSE
                        v_resultado := 'S';
                    END IF;

                END IF;

                IF ( v_resultado = 'S' ) THEN
                    sp003_actualiza_situacion_documento_segun_saldo(pin_id_cia, v_ordcomni, pin_swmuestramsj, pin_coduser, v_resultado
                    ,
                                                                   v_message);
                    IF ( ( v_resultado IS NULL ) OR ( upper(v_resultado) <> 'S' ) ) THEN
                        v_resultado := 'N';
                    ELSE
                        v_resultado := 'S';
                    END IF;

                END IF;

            END IF;

        END IF;--201  

---------------------------------------------

        IF ( v_swhaydocto = 'N' ) THEN
            v_resultado := 'N';
            v_message := v_message
                         || 'El Documento '
  --                       || v_desdoc
                         || ' '
                         || v_series
                         || '-'
                         || to_char(v_numdoc)
                         || ' No esta configurado en SP004_APRUEBA_CTAS_CTES_DOCUMENTO_001';

        END IF;

    END IF;

    pout_v_resultado := v_resultado;
    pout_message := v_message;
END sp004_aprueba_ctas_ctes_documento_001;

/
