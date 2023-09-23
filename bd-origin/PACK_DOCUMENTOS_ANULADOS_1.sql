--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_ANULADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_ANULADOS" AS

    PROCEDURE sp_documento_aceptado_maxdias (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_maxdias    VARCHAR2(1) := 'N';
        v_numdias    NUMBER := 0;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        BEGIN
            SELECT
                'S',
                ( TO_DATE(current_date, 'DD/MM/YYYY') - TO_DATE(c.femisi, 'DD/MM/YYYY') )
            INTO
                v_maxdias,
                v_numdias
            FROM
                documentos_cab             c
                LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                AND s.numint = c.numint
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint
                AND s.estado = 1
                AND c.tipdoc IN ( 1, 7, 8 )
                AND substr(c.series, 1, 1) = 'F'
                AND ( TO_DATE(current_date, 'DD/MM/YYYY') - TO_DATE(c.femisi, 'DD/MM/YYYY') ) > 7;

        EXCEPTION
            WHEN no_data_found THEN
                v_maxdias := 'N';
                v_numdias := 0;
        END;

        IF v_maxdias = 'N' THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Procede ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        ELSE
            pout_mensaje := 'El comprobante ACEPTADO por SUNAT, Execedio los 7 dias Maximos para su Anulación - #DIAS = ' || v_numdias
            ;
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

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

    END sp_documento_aceptado_maxdias;

    FUNCTION sp_documentos_relacionados (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER AS
        v_count_dr INTEGER;
    BEGIN
        BEGIN
            SELECT
                COUNT(dr.numintre)
            INTO v_count_dr
            FROM
                     documentos_relacion dr
                INNER JOIN documentos_cab dc ON dc.id_cia = dr.id_cia
                                                AND dc.numint = dr.numint
                                                AND NOT ( dc.situac IN ( 'J', 'K' ) )
            WHERE
                    dr.id_cia = pin_id_cia
                AND dr.numintre = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_count_dr := 0;
        END;

        RETURN v_count_dr;
    END sp_documentos_relacionados;

    FUNCTION sp_documentos_correlacionadas (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER AS
        v_count_cor INTEGER;
    BEGIN
        BEGIN
            SELECT
                COUNT(numint)
            INTO v_count_cor
            FROM
                dcta101
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_count_cor := 0;
        END;

        RETURN v_count_cor;
    END sp_documentos_correlacionadas;

    FUNCTION sp_documentos_planilla_cxc (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER AS
        v_count_pcxc INTEGER;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count_pcxc
            FROM
                (
                    SELECT
                        libro,
                        periodo,
                        mes,
                        secuencia,
                        numint
                    FROM
                        dcta103
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = pin_numint
                        AND situac <> 'J'
                    UNION
                    SELECT
                        libro,
                        periodo,
                        mes,
                        secuencia,
                        numint
                    FROM
                        dcta113
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = pin_numint
                        AND situac <> 'J'
                );

        EXCEPTION
            WHEN no_data_found THEN
                v_count_pcxc := 0;
        END;

        RETURN v_count_pcxc;
    END;

    FUNCTION sp_documentos_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_tipdoc NUMBER
    ) RETURN INTEGER AS
        v_count_doc INTEGER;
    BEGIN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_count_doc
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND tipdoc = pin_tipdoc
                AND situac NOT IN ( 'J', 'K', 'H', 'G' );

        EXCEPTION
            WHEN no_data_found THEN
                v_count_doc := 0;
        END;

        RETURN v_count_doc;
    END sp_documentos_obtener;

    FUNCTION sp_existe_factor (
        pin_id_cia IN NUMBER,
        pin_factor IN NUMBER
    ) RETURN VARCHAR2 AS
        v_swacti VARCHAR2(150);
    BEGIN
        BEGIN
            SELECT
                vstrg
            INTO v_swacti
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = pin_factor;

        EXCEPTION
            WHEN no_data_found THEN
                v_swacti := NULL;
        END;

        RETURN v_swacti;
    END sp_existe_factor;

    PROCEDURE sp_actualiza_situacion (
        pin_id_cia           IN NUMBER,
        pin_numint           IN NUMBER,
        pin_situac           IN VARCHAR2,
        pin_coduser          IN VARCHAR2,
        pin_mensaje          OUT VARCHAR2,
        v_swacti             VARCHAR2,
        v_proccesslock       VARCHAR2, -- NO SE USA
        v_formconsulta       VARCHAR2,
        v_unlock             VARCHAR2,
        v_actualizasituacmax VARCHAR2
    ) AS
        -- VARIABLES AUXILIARES
        v_count_clase      NUMBER;
        v_strcon           VARCHAR2(1) := '';
        v_valor            VARCHAR2(1);
        v_tipdoc           NUMBER;
        v_count_precios    NUMBER := 0;
        v_numdoc           NUMBER;
        -- VARIABLES POR DEFECTO
        v_actualiza_numdoc VARCHAR2(1) := 'N';
        v_swinteger        VARCHAR2(1) := 'N';
        v_integer          VARCHAR2(1) := 'N';
        v_series           VARCHAR2(5 CHAR);
    BEGIN
    -- PASO 0
        dbms_output.put_line('PASO ACTUALIZA SITUACION 0 - '
                             || pin_situac
                             || ' - '
                             || pin_numint);
        IF ( pin_situac = 'K' ) THEN
            v_actualiza_numdoc := 'S';
        END IF;
        dbms_output.put_line('PASO ACTUALIZA SITUACION 1');
     --PASO 1
        IF pin_situac = 'B' OR pin_situac = 'F' THEN
            BEGIN
                SELECT
                    1 AS count,
                    nvl(m.valor, 'N'),
                    c.tipdoc,
                    c.series,
                    c.numdoc
                INTO
                    v_count_clase,
                    v_valor,
                    v_tipdoc,
                    v_series,
                    v_numdoc
                FROM
                    documentos_cab c
                    LEFT OUTER JOIN motivos_clase  m ON m.id_cia = c.id_cia
                                                       AND m.tipdoc = c.tipdoc
                                                       AND m.id = c.id
                                                       AND m.codmot = c.codmot
                                                       AND m.codigo = 17
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.numint = pin_numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count_clase := 0;
                    v_series := NULL;
                    v_valor := 'N';
                    v_tipdoc := 0;
                    v_numdoc := 0;
            END;

            IF
                v_count_clase > 0
                AND v_valor = 'S'
            THEN
                CASE v_tipdoc
                    WHEN 104 THEN
                        v_strcon := 'S';--AND (CANTID=0)AND((CASE WHEN SWACTI IS NULL THEN 0 ELSE SWACTI END)<>2)
                    ELSE
                        v_strcon := 'N';--AND (CANTID=0 OR PREUNI=0)AND((CASE WHEN SWACTI IS NULL THEN 0 ELSE SWACTI END)<>2)AND(MONOTR IS NULL OR MONOTR=0)
                END CASE;

            -- PASO 3
                dbms_output.put_line('PASO ACTUALIZA SITUACION 2');
                CASE v_strcon
                    WHEN 'S' THEN
                        dbms_output.put_line('PASO ACTUALIZA SITUACION 2 - S');
                        BEGIN
                            SELECT
                                COUNT(numite) AS conteo
                            INTO v_count_precios
                            FROM
                                documentos_det
                            WHERE
                                    id_cia = pin_id_cia
                                AND numint = pin_numint
                                AND ( cantid = 0 )
                                AND ( ( nvl(swacti, 0) ) <> 2 );

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_count_precios := 0;
                        END;

                    WHEN 'N' THEN
                        dbms_output.put_line('PASO ACTUALIZA SITUACION 2 - N');
                        BEGIN
                            SELECT
                                COUNT(numite) AS conteo
                            INTO v_count_precios
                            FROM
                                documentos_det
                            WHERE
                                    id_cia = pin_id_cia
                                AND numint = pin_numint
                                AND ( cantid = 0
                                      OR preuni = 0 )
                                AND ( ( nvl(swacti, 0) ) <> 2 )
                                AND ( monotr IS NULL
                                      OR monotr = 0 );

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_count_precios := 0;
                        END;

                END CASE;

                dbms_output.put_line('PASO ACTUALIZA SITUACION 3 - ' || v_count_precios);
                IF v_count_precios = 0 THEN
                    v_swinteger := 'S';
                ELSE
                    v_swinteger := 'S';
--                    v_swinteger := 'N';-- SALIR
--                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            ELSE
                v_swinteger := 'S';
            END IF;

        ELSE
            v_swinteger := 'S';
        END IF;

        dbms_output.put_line('PASO ACTUALIZA SITUACION 4');
        IF
            v_swinteger = 'S'
            AND v_actualizasituacmax = 'S'
        THEN
            UPDATE documentos_situac_max
            SET
                factua = current_date,
                usuari = pin_coduser
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND situac = pin_situac;

        END IF;

        dbms_output.put_line('PASO ACTUALIZA SITUACION 5');
        IF v_swinteger = 'S' THEN
            IF v_swacti = 'N' THEN
                UPDATE documentos_cab
                SET
                    situac = pin_situac,
                    usuari = pin_coduser
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint;

                DELETE FROM caja_det
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint;

            END IF;
        END IF;

        dbms_output.put_line('PASO ACTUALIZA SITUACION 6');
        IF v_swinteger = 'S' THEN
            -- ACTUALIZA DETALLES
            UPDATE documentos_det
            SET
                situac = pin_situac --'J'
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            DELETE FROM caja_det
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Proceso culminado correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL DOCUMENTO '
                                    || v_series
                                    || ' - '
                                    || v_numdoc
                                    || '  TIENE UN PRECIO UNITARIO Y/O CANTIDAD DE ARTICULO EN CERO, REVISAR EL DETALLE DEL DOCUMENTO'
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
    END;

    PROCEDURE sp_actualiza_documentos_aprobacion (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_situac     IN VARCHAR2,
        pin_situac_dev IN VARCHAR2,
        pin_coduser    IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS
    BEGIN
        MERGE INTO documentos_aprobacion da
        USING dual ddd ON ( da.id_cia = pin_id_cia
                            AND da.numint = pin_numint )
        WHEN MATCHED THEN UPDATE
        SET situac =
            CASE
                WHEN pin_situac IS NULL THEN
                    situac
                WHEN pin_situac = 'Z' THEN
                    NULL
                ELSE
                    pin_situac
            END,
            situac_dev =
            CASE
                WHEN pin_situac_dev IS NULL THEN
                    situac_dev
                WHEN pin_situac_dev = 'Z' THEN
                    NULL
                ELSE
                    pin_situac_dev
            END,
            factua = current_timestamp,
            uactua = pin_coduser
        WHERE -- ESTO NO ES NECESARIO, PERO*
                id_cia = pin_id_cia
            AND numint = pin_numint
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            numint,
            situac,
            situac_dev,
            ucreac,
            uactua,
            fcreac,
            factua )
        VALUES
            ( pin_id_cia,
              pin_numint,
                CASE
                    WHEN pin_situac = 'Z' THEN
                        NULL
                    ELSE
                        pin_situac
                END,
                CASE
                    WHEN pin_situac_dev = 'Z' THEN
                        NULL
                    ELSE
                        pin_situac_dev
                END,
              pin_coduser,
              pin_coduser,
              current_timestamp,
              current_timestamp );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
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
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_actualiza_documentos_aprobacion;

    FUNCTION sp_marca_completo (
        pin_id_cia  NUMBER,
        pin_numint  NUMBER,
        pin_tipdoc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2 AS
        v_situac  VARCHAR2(1);
        v_mensaje VARCHAR2(1000);
    BEGIN
        CASE pin_tipdoc
            WHEN 102 THEN
                v_situac := 'C';
            WHEN 1 THEN
                pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'H', NULL, pin_coduser,
                                                                           v_mensaje);
                v_situac := 'F';
            WHEN 3 THEN
                pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'H', NULL, pin_coduser,
                                                                           v_mensaje);
                v_situac := 'F';
            ELSE
                v_situac := 'H';
        END CASE;

        RETURN v_situac;
    END sp_marca_completo;

    FUNCTION sp_marca_situac_ori (
        pin_id_cia  NUMBER,
        pin_numint  NUMBER,
        pin_tipdoc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2 AS
        v_situac  VARCHAR2(1);
        v_mensaje VARCHAR2(1000);
    BEGIN
        CASE
            WHEN pin_tipdoc = 102 THEN
                v_situac := 'F';
            WHEN pin_tipdoc IN ( 201, 115, 125, 105, 100,
                                 101, 104, 126, 127 ) THEN
                v_situac := 'B';
            WHEN pin_tipdoc IN ( 1, 3 ) THEN
                v_situac := 'F';
                pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'Z', NULL, pin_coduser,
                                                                           v_mensaje);
            ELSE
                v_situac := 'F';
        END CASE;

        RETURN v_situac;
    END sp_marca_situac_ori;

    FUNCTION sp_marca_parcial (
        pin_id_cia    NUMBER,
        pin_numint    NUMBER,
        pin_tipdoc    NUMBER,
        pin_series    VARCHAR2,
        pin_total     NUMBER,
        pin_pendiente NUMBER,
        pin_coduser   VARCHAR2
    ) RETURN VARCHAR2 AS
        v_situac  VARCHAR2(1);
        dc_vstrg  VARCHAR2(30);
        v_mensaje VARCHAR2(1000);
    BEGIN
        CASE
            WHEN pin_tipdoc = 1 THEN
                pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'G', NULL, pin_coduser,
                                                                           v_mensaje);
                v_situac := 'F';
            WHEN pin_tipdoc = 3 THEN
                pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'G', NULL, pin_coduser,
                                                                           v_mensaje);
                v_situac := 'F';
            WHEN pin_tipdoc = 201 THEN
                v_situac := 'G';
            WHEN pin_tipdoc = 105 THEN
                v_situac := 'G';
            WHEN pin_tipdoc = 102 THEN
                v_situac := 'F';
            WHEN pin_tipdoc = 103 THEN
                v_situac := 'F';
            WHEN pin_tipdoc = 104 THEN
                v_situac := 'G';
            WHEN pin_tipdoc IN ( 108, 101 ) THEN
             -- NO ES NESESARIO, PERO IGUAL ESTE BUCLE SOLO SE EJECUTA UNA VEZ
--                BEGIN
--                    SELECT
--                        dc.vstrg
--                    INTO dc_vstrg
--                    FROM
--                        documentos_clase       dc
--                        LEFT OUTER JOIN documentos_clase_ayuda dca ON dca.id_cia = dc.id_cia
--                                                                      AND dca.clase = dc.clase
--                    WHERE
--                            dc.id_cia = pin_id_cia
--                        AND dc.codigo = pin_tipdoc
--                        AND dc.series = pin_series
--                        AND dc.clase = 50;
--
--                EXCEPTION
--                    WHEN no_data_found THEN
--                        dc_vstrg := 'N';
--                END;
--                dbms_output.put_line('MARCA PARCIAL - 108/101');
--                IF dc_vstrg = 'S' THEN
--                    dbms_output.put_line('MARCA PARCIAL - 108/101 - ACTUALIZA DOCUMENTOS APROBACION');
--                    pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, 'A', pin_coduser);
--                        IF sp_documentos_aprobacion(pin_id_cia, pin_numint) > 0 THEN
--                            UPDATE documentos_aprobacion
--                            SET
--                                situac = 'A',
--                                factua = current_timestamp,
--                                uactua = pin_coduser
--                            WHERE
--                                    id_cia = pin_id_cia
--                                AND numint = pin_numint;
--
--                        ELSE
--                            INSERT INTO documentos_aprobacion (
--                                id_cia,
--                                numint,
--                                situac,
--                                ucreac,
--                                uactua,
--                                fcreac,
--                                factua
--                            ) VALUES (
--                                pin_id_cia,
--                                pin_numint,
--                                'A',
--                                pin_coduser,
--                                pin_coduser,
--                                current_timestamp,
--                                current_timestamp
--                            );
--
--                        END IF;
--                END IF;

                v_situac := 'G';
            ELSE
                v_situac := 'G';
        END CASE;

        RETURN v_situac;
    END sp_marca_parcial;

    PROCEDURE sp_actualiza_situacion_segun_saldo (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_pendiente  NUMBER := 0;
        v_devtotal   NUMBER := 0;
        v_situac     VARCHAR2(1) := 'B';
        v_tipdoc     NUMBER := 0;
        v_series     VARCHAR2(10) := '';
        v_total      NUMBER := 0;
        pout_mensaje VARCHAR2(1000);
        v_mensaje    VARCHAR2(1000);
        o            json_object_t;
    BEGIN
        IF nvl(pin_numint, 0) = 0 THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Success ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            RETURN;
        ELSE
            BEGIN
                SELECT
                    c.tipdoc,
                    c.series
                INTO
                    v_tipdoc,
                    v_series
                FROM
                    documentos_cab c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.numint = pin_numint;

            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'EL DOCUMENTO RELACIONADO CON NUMERO INTERNO [ '
                                    || pin_numint
                                    || ' ] NO EXISTE';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;

            IF v_tipdoc IN ( 1 ) THEN
                dbms_output.put_line('PASO INTERMEDIO - SALDO DE ORDEN DE DEVOLUCION - ' || pin_numint);
                v_total := 0;
                FOR i IN (
                    SELECT
                        d.saldo,
                        d.cantidad AS cantid
                    FROM
                        pack_documentos_ent_dev.sp_saldo_documentos_det(pin_id_cia, pin_numint, - 1) d
                    WHERE
                            d.id_cia = pin_id_cia
                        AND d.numint = pin_numint
                ) LOOP
                    v_total := v_total + 1;
                    dbms_output.put_line(i.saldo
                                         || ' - '
                                         || i.cantid);
                    IF i.saldo > 0 THEN
                        v_pendiente := v_pendiente + 1;
                    END IF;
                    IF i.saldo = i.cantid THEN
                        v_devtotal := v_devtotal + 1;
                    END IF;

                END LOOP;

                IF
                    v_total > 0
                    AND v_pendiente = 0
                THEN
                    dbms_output.put_line('PASO INTERMEDIO - MARCA COMPLETO - H');
                    pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, NULL, 'H', pin_coduser,
                                                                               v_mensaje);
                ELSE
                    IF v_total = v_devtotal THEN
                        dbms_output.put_line('PASO INTERMEDIO - MARCA ORIGINAL - NULL');
                        pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, NULL, 'Z', pin_coduser,
                                                                                   v_mensaje);
                    ELSE
                        dbms_output.put_line('PASO INTERMEDIO - MARCA PARCIAL - G');
                        pack_documentos_anulados.sp_actualiza_documentos_aprobacion(pin_id_cia, pin_numint, NULL, 'G', pin_coduser,
                                                                                   v_mensaje);
                    END IF;
                END IF;

            END IF;

            dbms_output.put_line('PASO INTERMEDIO - SALDO DE DOCUMENTO DET - ' || pin_numint);
            v_total := 0;
            IF v_tipdoc IN ( 1000 ) THEN -- TEMPORALMENTE
                FOR j IN (
                    SELECT
                        d.saldo,
                        d.cantidad AS cantid
                    FROM
                        pack_documentos_ent.sp_saldo_documentos_det(pin_id_cia, pin_numint, - 1) d
                    WHERE
                            d.id_cia = pin_id_cia
                        AND d.numint = pin_numint
                    UNION ALL
                    SELECT
                        dd.saldo,
                        dd.cantidad AS cantid
                    FROM
                        pack_documentos_ent_dev.sp_saldo_documentos_det(pin_id_cia, pin_numint, - 1) dd
                    WHERE
                            dd.id_cia = pin_id_cia
                        AND dd.numint = pin_numint
                ) LOOP
                    v_total := v_total + 1;
                    dbms_output.put_line(j.saldo
                                         || ' - '
                                         || j.cantid);
                    IF j.saldo > 0 THEN
                        v_pendiente := v_pendiente + 1;
                    END IF;
                    IF j.saldo = j.cantid THEN
                        v_devtotal := v_devtotal + 1;
                    END IF;

                END LOOP;

                dbms_output.put_line(v_total);
                IF
                    v_total > 0
                    AND v_pendiente = 0
                THEN
                    dbms_output.put_line('PASO INTERMEDIO - MARCA COMPLETO');
                    v_situac := pack_documentos_anulados.sp_marca_completo(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                ELSE
                    IF v_total = v_devtotal THEN
                        dbms_output.put_line('PASO INTERMEDIO - MARCA ORIGINAL');
                        v_situac := pack_documentos_anulados.sp_marca_situac_ori(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                    ELSE
                        IF v_pendiente <= v_total THEN --
                            dbms_output.put_line('PASO INTERMEDIO - MARCA PARCIAL');
                            v_situac := pack_documentos_anulados.sp_marca_parcial(pin_id_cia, pin_numint, v_tipdoc, v_series, v_total
                            ,
                                                                                 v_pendiente, pin_coduser);

                        ELSE -- R
                            v_situac := pack_documentos_anulados.sp_marca_situac_ori(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                        END IF;
                    END IF;
                END IF;

                dbms_output.put_line('PASO INTERMEDIO - ACTUALIZAR SITUACION - '
                                     || pin_id_cia
                                     || '-'
                                     || pin_numint
                                     || '-'
                                     || v_situac);

                pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, v_situac, pin_coduser, v_mensaje,
                                                               'N', 'S', 'N', 'N', 'N');

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            ELSE
                FOR j IN (
                    SELECT
                        d.saldo,
                        d.cantidad AS cantid
                    FROM
                        pack_documentos_ent.sp_saldo_documentos_det(pin_id_cia, pin_numint, - 1) d
                    WHERE
                            d.id_cia = pin_id_cia
                        AND d.numint = pin_numint
                ) LOOP
                    v_total := v_total + 1;
                    dbms_output.put_line(j.saldo
                                         || ' - '
                                         || j.cantid);
                    IF j.saldo > 0 THEN
                        v_pendiente := v_pendiente + 1;
                    END IF;
                    IF j.saldo = j.cantid THEN
                        v_devtotal := v_devtotal + 1;
                    END IF;

                END LOOP;

                dbms_output.put_line(v_total);
                IF
                    v_total > 0
                    AND v_pendiente = 0
                THEN
                    dbms_output.put_line('PASO INTERMEDIO - MARCA COMPLETO');
                    v_situac := pack_documentos_anulados.sp_marca_completo(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                ELSE
                    IF v_total = v_devtotal THEN
                        dbms_output.put_line('PASO INTERMEDIO - MARCA ORIGINAL');
                        v_situac := pack_documentos_anulados.sp_marca_situac_ori(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                    ELSE
                        IF v_pendiente <= v_total THEN --
                            dbms_output.put_line('PASO INTERMEDIO - MARCA PARCIAL');
                            v_situac := pack_documentos_anulados.sp_marca_parcial(pin_id_cia, pin_numint, v_tipdoc, v_series, v_total
                            ,
                                                                                 v_pendiente, pin_coduser);

                        ELSE -- R
                            v_situac := pack_documentos_anulados.sp_marca_situac_ori(pin_id_cia, pin_numint, v_tipdoc, pin_coduser);
                        END IF;
                    END IF;
                END IF;

                dbms_output.put_line('PASO INTERMEDIO - ACTUALIZAR SITUACION - '
                                     || pin_id_cia
                                     || '-'
                                     || pin_numint
                                     || '-'
                                     || v_situac);

                pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, v_situac, pin_coduser, v_mensaje,
                                                               'N', 'S', 'N', 'N', 'N');

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            END IF;

        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

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

            ROLLBACK;
    END sp_actualiza_situacion_segun_saldo;

    PROCEDURE sp_actualiza_situacion_documentos_relacionados (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_count VARCHAR2(1) := 'N';
    BEGIN
        FOR i IN (
            SELECT
                r.numintre
            FROM
                documentos_relacion r
                LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                    AND c.numint = r.numintre
            WHERE
                    r.id_cia = pin_id_cia
                AND r.numint = pin_numint
        ) LOOP
            IF i.numintre IS NOT NULL THEN
                dbms_output.put_line('PASO INTERMEDIO - SE ENCONTRARON DOCUMENTOS RELACIONADOS');
                pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, i.numintre, pin_coduser, pin_mensaje);
                v_count := 'S';
            END IF;
        END LOOP;

        IF v_count = 'N' THEN
            dbms_output.put_line('PASO INTERMEDIO - NO SE ENCONTRARON DOCUMENTOS RELACIONADOS');
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Proceso culminado correctamente ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        END IF;

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
    END sp_actualiza_situacion_documentos_relacionados;

    PROCEDURE sp_anular (
        pin_id_cia     IN NUMBER,
        pin_tipdoc     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS

        c_ordcomni   NUMBER;
        v_validacion VARCHAR2(1) := 'S';
        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        -- PASO 0 EL USUARIO TIENE EL PERMISO?
        dbms_output.put_line('PASO 0 EL USUARIO TIENE EL PERMISO');
        IF pack_documentos_cab.sp_conforme_para_anular(pin_id_cia, pin_tipdoc, pin_coduser) = 'N' THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_usuario_sin_permiso;
        END IF;
        -- PASO 1 EXISTE EL DOCUMENTO? -- Modificado
        dbms_output.put_line('PASO 4 EXISTE EL DOCUMENTO? -- Modificado');
        IF pack_documentos_anulados.sp_documentos_obtener(pin_id_cia, pin_numint, pin_tipdoc) = 0 THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_documento_no_existe;
        END IF;
        -- PASO 1.5 DOCUMENTO APROBADO POR SUNAT, PLAZO 7 DIAS ?
        dbms_output.put_line('PASO 1.5 DOCUMENTO APROBADO POR SUNAT, PLAZO 7 DIAS ?');
        pack_documentos_anulados.sp_documento_aceptado_maxdias(pin_id_cia, pin_numint, pin_tipdoc, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
        -- PASO 2 ESTA RELACIONADO?  -- DOCUMENTOS RELACIONADOS CON SITUACION DIFERENTE DE 'J' O 'K'
        dbms_output.put_line('PASO 2 ESTA RELACIONADO? -- Modificado');
        IF pack_documentos_anulados.sp_documentos_relacionados(pin_id_cia, pin_numint) > 0 THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_documento_con_relaciones;
        END IF;
        -- PASO 3 TIENE CORRELACIONES? -- DCTA101
        dbms_output.put_line('PASO 3 TIENE CORRELACIONES?');
        IF pack_documentos_anulados.sp_documentos_correlacionadas(pin_id_cia, pin_numint) > 0 THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_documento_con_correlaciones;
        END IF;
        -- PASO 4 TIENE PLANILLA DE CXC? -- DCTA103 DCTA113 
        dbms_output.put_line('PASO 4 TIENE PLANILLA DE CXC? -- DCTA103 DCTA113');
        IF pack_documentos_anulados.sp_documentos_planilla_cxc(pin_id_cia, pin_numint) > 0 THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_documento_con_planillas;
        END IF;

        IF ( v_validacion = 'S' ) THEN
            -- PASO 5 ACTUALIZA SITUACION
            dbms_output.put_line('PASO 5 ACTUALIZA SITUACION');
            pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'J', pin_coduser, v_mensaje,
                                                           'N', 'S', 'N', 'N', 'S');

            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
            -- PASO 6 ELIMINA DOCUMENTO ENT
            dbms_output.put_line('PASO 6 ELIMINA DOCUMENTO ENT');
            DELETE FROM documentos_ent
            WHERE
                    id_cia = pin_id_cia
                AND orinumint = pin_numint;

            -- PASO 7 ELIMINA KARDEX
            dbms_output.put_line('PASO 7 ELIMINA KARDEX');
            DELETE FROM kardex
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            -- PASO 8 ELIMINA COMPROMETIDO - FRANK
            dbms_output.put_line('PASO 8 ELIMINA COMPROMETIDO');
--            IF pack_documentos_anulados.sp_existe_factor(pin_id_cia, 411) = 'S' THEN
--                DELETE FROM comprometido
--                WHERE
--                        id_cia = pin_id_cia
--                    AND numint = pin_numint; 
--            END IF;

            -- PASO 9 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS
            dbms_output.put_line('PASO 9 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS');
            pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;              
            -- PASO10 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO
            dbms_output.put_line('PASO10 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO');
            BEGIN
                SELECT
                    ordcomni
                INTO c_ordcomni
                FROM
                    documentos_cab
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint
                    AND ordcomni IS NOT NULL;

                pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            EXCEPTION
                WHEN no_data_found THEN
                    c_ordcomni := NULL;
            END;
            -- PASO 11 ACTUALIZA SITUACION
            dbms_output.put_line('PASO 11 ACTUALIZA SITUACION');
            FOR h IN (
                SELECT
                    r.numintre,
                    c.tipdoc AS tipdocre
                FROM
                    documentos_relacion r
                    LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                        AND c.numint = r.numintre
                WHERE
                        r.id_cia = pin_id_cia
                    AND r.numint = pin_numint
            ) LOOP
                CASE h.tipdocre
                    WHEN 108 THEN
                        UPDATE documentos_cab
                        SET
                            situac = 'E', --Impreso/Atendido
                            usuari = pin_coduser,
                            factua = current_timestamp
                        WHERE
                                id_cia = pin_id_cia
                            AND numint = h.numintre;

                    ELSE
                        NULL;
                END CASE;
            END LOOP;

            -- PASO 12 ELIMINA DOCUMENTO RELACION - J, K
            dbms_output.put_line('PASO 12 ELIMINA DOCUMENTO RELACION - J, K');
            DELETE FROM documentos_relacion
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            -- PASO 13 ELIMINA CTASCTES
            dbms_output.put_line('PASO 13 ELIMINA CTASCTES');
            DELETE FROM dcta100
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            DELETE FROM dcta106
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND numintap = 0;

            -- PASO 14 ELIMINA APLICACION DE DCTA106
            dbms_output.put_line('PASO 14 ELIMINA APLICACION DE DCTA106');
            FOR i IN (
                SELECT
                    numint,
                    numite,
                    opnumdoc
                FROM
                    documentos_det
                WHERE
                        id_cia = pin_id_cia
                    AND numint = pin_numint
                    AND opcargo = 'APLI-106'
            ) LOOP
                DELETE FROM dcta106
                WHERE
                        id_cia = pin_id_cia
                    AND numint = i.opnumdoc
                    AND numintap = i.numint
                    AND refere01 = i.numite;

            END LOOP;

        -- PASO 15 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO
            dbms_output.put_line('PASO 15 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO');
            UPDATE documentos_cab
            SET
                presen =
                    CASE
                        WHEN pin_comentario IS NULL THEN
                            presen
                        ELSE
                            pin_comentario
                    END
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Comprobante anulado correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_usuario_sin_permiso THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El USUARIO [ '
                                    || pin_coduser
                                    || ' ] no permiso para realizar esta acción ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_con_relaciones THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL DOCUMENTO ESTA CORRELACIONADO A OTROS DOCUMENTOS'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_con_correlaciones THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL DOCUMENTO TIENEN REGISTROS DE CANCELACION'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_con_planillas THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL DOCUMENTO TIENE PLANILLAS DE CUENTAS POR COBRAR'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_no_existe THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'No se pudo obtener el documento o tienen una situación no valida para la anulación ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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
    END sp_anular;

    PROCEDURE sp_anular_guia_remision (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS

        c_ordcomni   NUMBER;
        v_validacion VARCHAR2(1) := 'S';
        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        -- PASO 0 EL USUARIO TIENE EL PERMISO?
        dbms_output.put_line('PASO 0 EL USUARIO TIENE EL PERMISO');
        IF pack_documentos_cab.sp_conforme_para_anular(pin_id_cia, 102, pin_coduser) = 'N' THEN
            v_validacion := 'N';
            RAISE pkg_exceptionuser.ex_usuario_sin_permiso;
        END IF;

        BEGIN
            SELECT
                ordcomni
            INTO c_ordcomni
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND tipdoc = 102;

        EXCEPTION
            WHEN no_data_found THEN
                c_ordcomni := NULL;
                v_validacion := 'N';
                RAISE pkg_exceptionuser.ex_documento_no_existe;
        END;

        IF ( v_validacion = 'S' ) THEN
            -- PASO 1 ACTUALIZA SITUACION
            dbms_output.put_line('PASO 5 ACTUALIZA SITUACION');
            pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'J', pin_coduser, v_mensaje,
                                                           'N', 'S', 'N', 'N', 'S');

            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
            -- PASO 2 ELIMINA DOCUMENTO ENT
            dbms_output.put_line('PASO 6 ELIMINA DOCUMENTO ENT');
            DELETE FROM documentos_ent
            WHERE
                    id_cia = pin_id_cia
                AND orinumint = pin_numint;

            -- PASO 3 ELIMINA KARDEX
            dbms_output.put_line('PASO 7 ELIMINA KARDEX');
            DELETE FROM kardex
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            -- PASO 4 ELIMINA COMPROMETIDO - FRANK
            dbms_output.put_line('PASO 8 ELIMINA COMPROMETIDO');
--            IF pack_documentos_anulados.sp_existe_factor(pin_id_cia, 411) = 'S' THEN
--                DELETE FROM comprometido
--                WHERE
--                        id_cia = pin_id_cia
--                    AND numint = pin_numint; 
--            END IF;

            -- PASO 5 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS
            dbms_output.put_line('PASO 9 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS');
            pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;              
            -- PASO 6 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO
            dbms_output.put_line('PASO10 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO');
            pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        -- PASO 15 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO
            dbms_output.put_line('PASO 15 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO');
            UPDATE documentos_cab
            SET
                presen =
                    CASE
                        WHEN pin_comentario IS NULL THEN
                            presen
                        ELSE
                            pin_comentario
                    END
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Guia de Remisión anulada correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_usuario_sin_permiso THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El USUARIO [ '
                                    || pin_coduser
                                    || ' ] no permiso para realizar esta acción ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_no_existe THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'No se pudo obtener el documento o tienen una situación no valida para la anulación ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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
    END sp_anular_guia_remision;

    PROCEDURE sp_anular_orden_pedido (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS

        c_ordcomni   NUMBER;
        c_situac     VARCHAR(1) := '';
        v_validacion VARCHAR2(1) := 'S';
        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        -- PASO 0 EL USUARIO TIENE EL PERMISO?
        dbms_output.put_line('PASO 0 EL USUARIO TIENE EL PERMISO');
        IF pack_documentos_cab.sp_conforme_para_anular(pin_id_cia, 101, pin_coduser) = 'N' THEN
            RAISE pkg_exceptionuser.ex_usuario_sin_permiso;
        END IF;

        -- PASO 1 EXISTE EL DOCUMENTO?
        dbms_output.put_line('PASO 1 EXISTE EL DOCUMENTO?');
        IF pack_documentos_anulados.sp_documentos_obtener(pin_id_cia, pin_numint, 101) = 0 THEN
            RAISE pkg_exceptionuser.ex_documento_no_existe;
        END IF;

        BEGIN
            SELECT
                situac,
                ordcomni
            INTO
                c_situac,
                c_ordcomni
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND tipdoc = 101;

        EXCEPTION
            WHEN no_data_found THEN
                c_situac := '';
                c_ordcomni := NULL;
                v_validacion := 'N';
                RAISE pkg_exceptionuser.ex_documento_no_existe;
        END;

        IF NOT ( c_situac = 'A' OR c_situac = 'B' OR c_situac = 'I' ) THEN
            pout_mensaje := 'La Orden de Pedido debe estar en una situación Emitida, Visada o Cerrada para ser Anulada';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

            -- PASO 1 ACTUALIZA SITUACION
        dbms_output.put_line('PASO 1 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'J', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'S');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
            -- PASO 2 ELIMINA DOCUMENTO ENT
        dbms_output.put_line('PASO 2 ELIMINA DOCUMENTO ENT');
        DELETE FROM documentos_ent
        WHERE
                id_cia = pin_id_cia
            AND orinumint = pin_numint;

            -- PASO 5 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS
        dbms_output.put_line('PASO 5 ACTUALIZA SITUACION DOCUMENTOS RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;              
            -- PASO 6 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO
        dbms_output.put_line('PASO 6 ACTUALIZA SITUACION DOCUMENTO SEGUN SALDO - '
                             || pin_id_cia
                             || '-'
                             || c_ordcomni);
        pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

            -- PASO 7 ELIMINA DOCUMENTO RELACION - J, K
        dbms_output.put_line('PASO 7 ELIMINA DOCUMENTO RELACION - J, K');
        DELETE FROM documentos_relacion
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

            -- PASO 8 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO
        dbms_output.put_line('PASO 8 ACTUALIZA EL CAMPO PRESEN - SI HAY COMENTARIO');
        UPDATE documentos_cab
        SET
            presen = pin_comentario
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Orden de Pedido anulado correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_usuario_sin_permiso THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El USUARIO [ '
                                    || pin_coduser
                                    || ' ] no permiso para realizar esta acción ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_no_existe THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'No se pudo obtener el documento o tienen una situación no valida para la anulación ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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
    END sp_anular_orden_pedido;

    PROCEDURE sp_anular_cotizacion (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    ) AS

        c_ordcomni   NUMBER;
        c_situac     VARCHAR(1) := '';
        v_validacion VARCHAR2(1) := 'S';
        v_mensaje    VARCHAR2(1000) := '';
        o            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        -- PASO 0 EL USUARIO TIENE EL PERMISO?
        dbms_output.put_line('PASO 0 EL USUARIO TIENE EL PERMISO?');
        IF pack_documentos_cab.sp_conforme_para_anular(pin_id_cia, 100, pin_coduser) = 'N' THEN
            RAISE pkg_exceptionuser.ex_usuario_sin_permiso;
        END IF;

        -- PASO 1 EXISTE EL DOCUMENTO?
        dbms_output.put_line('PASO 1 EXISTE EL DOCUMENTO?');
        IF pack_documentos_anulados.sp_documentos_obtener(pin_id_cia, pin_numint, 100) = 0 THEN
            RAISE pkg_exceptionuser.ex_documento_no_existe;
        END IF;

            -- PASO 2 ACTUALIZA SITUACION Y COMENTARIO DEL DOCUMENTO (COTIZACION)
        dbms_output.put_line('PASO 2 ACTUALIZA SITUACION Y COMENTARIO DEL DOCUMENTO (COTIZACION)');
        UPDATE documentos_cab
        SET
            situac = 'J',
            usuari = pin_coduser,
            factua = current_timestamp,
            presen = pin_comentario
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Cotización anulada correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_usuario_sin_permiso THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El USUARIO [ '
                                    || pin_coduser
                                    || ' ] no permiso para realizar esta acción ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_documento_no_existe THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'No se pudo obtener el documento o tiene una situación no valida para la anulación ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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
    END sp_anular_cotizacion;

END;

/
