--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_KARDEX" AS
    -- SP (PASO 2)
    PROCEDURE sp_hereda_aprobaciones (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_total NUMBER := 0;
    BEGIN
        BEGIN
            SELECT
                COUNT(1) AS count
            INTO v_total
            FROM
                     documentos_relacion r
                INNER JOIN documentos_aprobacion d ON d.id_cia = r.id_cia
                                                      AND d.numint = r.numintre
                                                      AND d.situac = 'B'
            WHERE
                    r.id_cia = pin_id_cia
                AND r.numint = pin_numint
                AND NOT EXISTS (
                    SELECT
                        numint
                    FROM
                        documentos_aprobacion
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = pin_numint
                );

        EXCEPTION
            WHEN no_data_found THEN
                v_total := 0;
        END;

        IF v_total > 0 THEN
            INSERT INTO documentos_aprobacion (
                id_cia,
                numint,
                situac,
                ucreac,
                uactua,
                fcreac,
                factua
            ) VALUES (
                pin_id_cia,
                pin_numint,
                'B',
                pin_coduser,
                pin_coduser,
                current_timestamp,
                current_timestamp
            );

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
    END sp_hereda_aprobaciones;

    PROCEDURE sp_genera_documento_ent (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        IF pin_numint <> 0 THEN
        -- INSERTAR
            INSERT INTO documentos_ent (
                id_cia,
                opnumdoc,
                opnumite,
                orinumint,
                orinumite,
                entreg,
                piezas
            )
                SELECT
                    d.id_cia,
                    CASE
                        WHEN c.opnumdoc = d.opnumdoc THEN
                            c.ordcomni
                        ELSE
                            CASE
                                WHEN d.opnumdoc IS NULL THEN
                                        0
                                ELSE
                                    d.opnumdoc
                            END
                    END,
                    CASE
                        WHEN d.opnumite IS NULL THEN
                            0
                        ELSE
                            d.opnumite
                    END,
                    d.numint,
                    d.numite,
                    CASE
                        WHEN ( d.codund <> a.coduni )
                             AND ( c.tipdoc = 103 )
                             AND ( c.id = 'I' )
                             AND ( c.codmot IN ( 1, 28 ) ) THEN
                            d.cantid / (
                                CASE
                                    WHEN al.vreal IS NULL THEN
                                        1.00
                                    ELSE
                                        al.vreal
                                END
                            )
                        ELSE
                            d.cantid
                    END,
                    CASE
                        WHEN ( d.codund <> a.coduni )
                             AND ( c.tipdoc = 103 )
                             AND ( c.id = 'I' )
                             AND ( c.codmot IN ( 1, 28 ) ) THEN
                            d.piezas / (
                                CASE
                                    WHEN al.vreal IS NULL THEN
                                        1.00
                                    ELSE
                                        al.vreal
                                END
                            )
                        ELSE
                            (
                                CASE
                                    WHEN d.piezas IS NULL THEN
                                        0
                                    ELSE
                                        d.piezas
                                END
                            )
                    END
                FROM
                         documentos_det d
                    INNER JOIN documentos_cab              c ON c.id_cia = d.id_cia
                                                   AND c.numint = d.numint
                    LEFT OUTER JOIN articulos                   a ON a.id_cia = d.id_cia
                                                   AND a.tipinv = d.tipinv
                                                   AND a.codart = d.codart
                    LEFT OUTER JOIN articulos_clase_alternativo al ON al.id_cia = d.id_cia
                                                                      AND al.tipinv = d.tipinv
                                                                      AND al.codart = d.codart
                                                                      AND al.clase = 2
                                                                      AND al.codigo = d.codund
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                    AND d.cantid > 0;
        -- INSERTAR IMP
            INSERT INTO documentos_ent (
                id_cia,
                opnumdoc,
                opnumite,
                orinumint,
                orinumite,
                entreg,
                piezas
            )
                SELECT
                    d.id_cia,
                    dr.opnumint,
                    dr.opnumite,
                    d.numint,
                    d.numite,
                    d.cantid,
                    d.piezas
                FROM
                         documentos_det d
                    INNER JOIN documentos_det_relacion dr ON dr.id_cia = d.id_cia
                                                             AND dr.numint = d.numint
                                                             AND dr.numite = d.numite
                    INNER JOIN documentos_cab          c ON c.id_cia = d.id_cia
                                                   AND c.numint = d.numint
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                    AND d.cantid > 0;

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
    END sp_genera_documento_ent;

    PROCEDURE sp_genera_documento_material_ent (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        IF pin_numint > 0 THEN
        -- INSERTAR
            INSERT INTO documentos_materiales_ent (
                id_cia,
                opnumdoc,
                opnumite,
                orinumint,
                orinumite,
                opnumsec,
                entreg,
                piezas
            )
                SELECT
                    d.id_cia,
                    CASE
                        WHEN c.opnumdoc = d.opnumdoc THEN
                            c.ordcomni
                        ELSE
                            nvl(d.opnumdoc, 0)
                    END,
                    nvl(d.opnumite, 0),
                    d.numint,
                    d.numite,
                    d.opnumsec,
                    d.cantid,
                    d.piezas
                FROM
                         documentos_cab c
                    INNER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                   AND d.numint = c.numint
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.numint = pin_numint
                    AND d.cantid > 0
                    AND nvl(d.opnumsec, 0) > 0;

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
    END sp_genera_documento_material_ent;

    PROCEDURE sp_genera_kardex (
        pin_id_cia         IN NUMBER,
        pin_numint         IN NUMBER,
        pin_numite         IN NUMBER,
        pin_codalm         IN NUMBER,
        pin_tipdoc         IN NUMBER,
        pin_id             IN VARCHAR2,
        pin_mensaje        OUT VARCHAR2,
        v_sw               IN VARCHAR2,
        v_swsoloetiqueta   IN VARCHAR2,
        v_swsoloetiquetano IN VARCHAR2,
        v_swpasneg         IN VARCHAR2
    ) AS

        v_sumcodigo  INTEGER := 0;
        v_locali     INTEGER := 0;
        pout_mensaje VARCHAR2(1000 CHAR);
        v_mensaje    VARCHAR2(1000 CHAR);
        o            json_object_t;
    BEGIN
        dbms_output.put_line('PASO 8.1 GENERA ETIQUETAS GENERADOR');
        IF pin_id = 'I' THEN
            FOR j IN (
                SELECT
                    e.id_cia,
                    e.opnumdoc,
                    e.opnumite,
                    SUM(de.entreg) AS entregado,
                    MAX(d.cantid)  AS cantid_pro
                FROM
                         documentos_ent e
                    INNER JOIN documentos_det d ON d.id_cia = e.id_cia
                                                   AND d.numint = e.opnumdoc
                                                   AND d.numite = e.opnumite
                    INNER JOIN documentos_ent de ON de.id_cia = d.id_cia
                                                    AND de.opnumdoc = d.numint
                                                    AND de.opnumite = d.numite
                    INNER JOIN documentos_cab c ON c.id_cia = e.id_cia
                                                   AND c.numint = e.opnumdoc
                WHERE
                        e.id_cia = pin_id_cia
                    AND e.orinumint = pin_numint
                    AND c.tipdoc = 104
                GROUP BY
                    e.id_cia,
                    e.opnumdoc,
                    e.opnumite
            ) LOOP
                IF j.cantid_pro - j.entregado <= 0 THEN
                    UPDATE documentos_det -- NO DEBE DEJAR JALAR MAS ITEMS
                    SET
                        swacti = 1
                    WHERE
                            id_cia = j.id_cia
                        AND numint = j.opnumdoc
                        AND numite = j.opnumite;

                END IF;
            END LOOP;

            pack_documentos_kardex.sp_asigna_kilos_unitarios(pin_id_cia, pin_numint, 'admin', v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

            dbms_output.put_line('PASO 8.1 GENERACION DE ETIQUETAS, SEGUN TIPO DE STOCK 2,3,4');
            FOR i IN (
                SELECT
                    d.id_cia,
                    d.numint,
                    d.numite,
                    to_char(d.numint, '0000000000')
                    || d.codart
                    || ' '
                    ||
                    CASE
                        WHEN length(d.numite) > 4 THEN
                                ''
                        ELSE
                            to_char(d.numite, '0000')
                    END
                    AS etiqueta
                FROM
                         documentos_det d
                    INNER JOIN articulos a ON a.id_cia = d.id_cia
                                              AND a.tipinv = d.tipinv
                                              AND a.codart = d.codart
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                    AND nvl(d.canped, 0) >= 0
                    AND a.consto IN ( 2, 3, 4 ) -- SOLO PARA ARTICULOS,  CUYO STOCK SE CONTROLE POR CARRETES , ESTROBOS O ALAMABRES
                    AND TRIM(d.etiqueta) IS NULL -- SIN ETIQUETA
                ORDER BY
                    d.numite
            ) LOOP
                UPDATE documentos_det
                SET
                    etiqueta = i.etiqueta
                WHERE
                        id_cia = i.id_cia
                    AND numint = i.numint
                    AND numite = i.numite;

            END LOOP;
            -- GENERANDO ETIQUETAS, PARA LOS DEMAS CASOS
            sp00_genera_etiquetas_generador(pin_id_cia, pin_numint);
        END IF;

        dbms_output.put_line('PASO 8.2');
        IF
            pin_id = 'I'
            AND pin_tipdoc = 103
            AND pack_documentos_anulados.sp_existe_factor(pin_id_cia, 349) = 'S'
        THEN
            dbms_output.put_line('PASO 8.2 - TIENE EL FACTOR CONFIGURADO - VALIDACION');
            BEGIN
                SELECT
                    SUM(
                        CASE
                            WHEN(al.codigo IS NULL) THEN
                                1
                            ELSE
                                0
                        END
                    ) AS sw
                INTO v_sumcodigo
                FROM
                    documentos_det    d
                    LEFT OUTER JOIN almacen_ubicacion al ON al.id_cia = d.id_cia
                                                            AND al.tipinv = d.tipinv
                                                            AND al.codalm = d.codalm
                                                            AND al.codigo = d.ubica
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numint
                    AND d.etiqueta IS NOT NULL;

            EXCEPTION
                WHEN no_data_found THEN
                    v_sumcodigo := 0;
            END;

            IF v_sumcodigo > 0 THEN
                -- SALIR
                dbms_output.put_line('PASO 8.3 SALIR');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        dbms_output.put_line('PASO 8.4 ENVIAR KARDEX '
                             || pin_id_cia
                             || ' - '
                             || pin_numint);
        sp_enviar_kardex(pin_id_cia, pin_numint);
        COMMIT;
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
                    'message' VALUE 'Genera Kardex => Faltan(n) '
                                    || v_sumcodigo
                                    || ' item(s) sin codigo de almacen definido ...!'
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
    END sp_genera_kardex;

    PROCEDURE sp_envia_kardex_guia_interna (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                json_object_t;
        sw_enviar_kardex VARCHAR2(1) := 'S';
        c_tipdoc         NUMBER := 0;
        c_id             VARCHAR2(1);
        c_codmot         NUMBER;
        c_ordcomni       NUMBER := 0;
        m_codmot         NUMBER;
        m_docayuda       NUMBER;
        v_mensaje        VARCHAR2(1000) := 'ND';
        pout_mensaje     VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('PASO 1 EXISTE GUIA INTERNA? DOCUMENTOS_CAB');
        BEGIN
            SELECT
                c.tipdoc,
                c.id,
                c.codmot,
                c.ordcomni,
                nvl(m.docayuda, 0)
            INTO
                c_tipdoc,
                c_id,
                c_codmot,
                c_ordcomni,
                m_docayuda
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint
                AND c.tipdoc = 103; -- GUIA INTERNA

        EXCEPTION
            WHEN no_data_found THEN
                c_tipdoc := 0;
                c_id := '';
                c_codmot := 0;
                c_ordcomni := 0;
                m_docayuda := 0;
                pout_mensaje := 'EL DOCUMENTO CON NUMERO INTERNO [ '
                                || to_char(pin_numint)
                                || ' ] NO EXISTE COMO GUIA INTERNA';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        dbms_output.put_line('PASO 2 HEREDA APROBACIONES');
        pack_documentos_kardex.sp_hereda_aprobaciones(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 3 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'F', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'N');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF c_codmot <= 200 THEN
            dbms_output.put_line('PASO 5.1 ELIMINA DOCUMENTO ENT');
            DELETE FROM documentos_ent
            WHERE
                    id_cia = pin_id_cia
                AND orinumint = pin_numint;

            COMMIT;
        END IF;

        dbms_output.put_line('PASO 5.2 ELIMINA DOCUMENTO MATERIALES ENT');
        DELETE FROM documentos_materiales_ent
        WHERE
                id_cia = pin_id_cia
            AND orinumint = pin_numint;

        dbms_output.put_line('PASO 6 ELIMINA KARDEX');
        DELETE FROM kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        dbms_output.put_line('PASO 7 GENERA DOCUMENTO ENT');
        IF c_codmot < 200 OR m_docayuda = 117 THEN
            dbms_output.put_line('PASO 7.5 - DOCUMENTO AYUDA');
            pack_documentos_kardex.sp_genera_documento_ent(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        dbms_output.put_line('PASO 7 GENERA DOCUMENTO MATERIAL ENT');
        pack_documentos_kardex.sp_genera_documento_material_ent(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF sw_enviar_kardex = 'S' THEN
            dbms_output.put_line('PASO 8 GENERA KARDEX');
            pack_documentos_kardex.sp_genera_kardex(pin_id_cia, pin_numint, 0, 0, c_tipdoc,
                                                   c_id, v_mensaje, 'N', 'N', 'N',
                                                   'N');

            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        dbms_output.put_line('PASO 9 ACTUALIZA SITUACION DE DOCUMENTOS_RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 10 ACTUALIZAR SITUACION SEGUN SALDO');
        pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'GUIA DE INTERNA ENVIADA EL KARDEX'
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
    END sp_envia_kardex_guia_interna;

    PROCEDURE sp_envia_kardex_guia_remision (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                json_object_t;
        sw_enviar_kardex VARCHAR2(1) := 'S';
        c_tipdoc         NUMBER := 0;
        c_id             VARCHAR2(1);
        c_codmot         NUMBER;
        c_ordcomni       NUMBER := 0;
        m_docayuda       NUMBER;
        v_mensaje        VARCHAR2(1000) := 'ND';
        pout_mensaje     VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('PASO 1 EXISTE GUIA DE REMISION? DOCUMENTOS_CAB');
        BEGIN
            SELECT
                c.tipdoc,
                c.id,
                c.codmot,
                c.ordcomni,
                nvl(m.docayuda, 0),
                nvl(mt28.valor, 'N')
            INTO
                c_tipdoc,
                c_id,
                c_codmot,
                c_ordcomni,
                m_docayuda,
                sw_enviar_kardex
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN motivos_clase  mt28 ON mt28.id_cia = c.id_cia
                                                      AND mt28.tipdoc = c.tipdoc
                                                      AND mt28.id = c.id
                                                      AND mt28.codmot = c.codmot
                                                      AND mt28.codigo = 28
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint
                AND c.tipdoc = 102; -- GUIA DE REMISION

        EXCEPTION
            WHEN no_data_found THEN
                c_tipdoc := 0;
                c_id := '';
                c_codmot := 0;
                c_ordcomni := 0;
                m_docayuda := 0;
                sw_enviar_kardex := 'N';
                pout_mensaje := 'EL DOCUMENTO CON NUMERO INTERNO [ '
                                || to_char(pin_numint)
                                || ' ] NO EXISTE COMO GUIA DE REMISION';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        dbms_output.put_line('PASO 2 HEREDA APROBACIONES');
        pack_documentos_kardex.sp_hereda_aprobaciones(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 3 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'F', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'S');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        IF c_codmot <= 200 THEN
            dbms_output.put_line('PASO 5 ELIMINA DOCUMENTO ENT');
            DELETE FROM documentos_ent
            WHERE
                    id_cia = pin_id_cia
                AND orinumint = pin_numint;

        END IF;

        dbms_output.put_line('PASO 6 ELIMINA KARDEX');
        DELETE FROM kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        dbms_output.put_line('PASO 7 GENERA DOCUMENTO ENT');
        IF c_codmot < 200 OR m_docayuda = 117 THEN
            dbms_output.put_line('PASO 7.5 - DOCUMENTO AYUDA');
            pack_documentos_kardex.sp_genera_documento_ent(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        IF sw_enviar_kardex = 'S' THEN
            dbms_output.put_line('PASO 8 GENERA KARDEX');
            pack_documentos_kardex.sp_genera_kardex(pin_id_cia, pin_numint, 0, 0, c_tipdoc,
                                                   c_id, v_mensaje, 'N', 'N', 'N',
                                                   'N');

            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END IF;

        dbms_output.put_line('PASO 9 ACTUALIZA SITUACION DE DOCUMENTOS_RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 10 ACTUALIZAR SITUACION SEGUN SALDO');
        pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'GUIA DE REMISION ENVIADA AL KARDEX'
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
    END sp_envia_kardex_guia_remision;

    PROCEDURE sp_verifica_movimientos_relacionados (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_movimientos VARCHAR2(1 CHAR) := 'N';
        v_asiento     VARCHAR2(4000 CHAR) := '';
        pout_mensaje  VARCHAR2(1000 CHAR) := '';
    BEGIN
        FOR i IN (
            SELECT
                mr.*
            FROM
                movimientos_relacion mr
            WHERE
                    mr.id_cia = pin_id_cia
                AND mr.numint = pin_numint
            ORDER BY
                asiento,
                item
        ) LOOP
            dbms_output.put_line('PASO INTERMEDIO  - LOOP');
            v_asiento := v_asiento
                         || ' | '
                         || i.periodo
                         || '-'
                         || i.mes
                         || ' '
                         || i.libro
                         || ' '
                         || i.asiento
                         || '-'
                         || i.item;

            v_movimientos := 'S';
        END LOOP;

        v_asiento := substr(v_asiento, 3, 195);
        IF v_movimientos = 'S' THEN
            dbms_output.put_line('PASO INTERMEDIO  - MOVIMIENTOS - SALIR');
            pout_mensaje := 'No se puede ANULAR LA GUIA INTERNA [ '
                            || pin_numint
                            || ' ] porque esta relacionada al COSTEO DE IMPORTACIONES [ '
                            || v_asiento
                            || ' ] ...!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
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

    END sp_verifica_movimientos_relacionados;

    PROCEDURE sp_verifica_movimientos (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_etiquetas   VARCHAR2(100) := '';
        v_movimientos VARCHAR2(1) := 'N';
        pout_mensaje  VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('PASO INTERMEDIO  - ES UN INGRESO');
        FOR i IN (
            SELECT DISTINCT
                k.etiqueta
            FROM
                kardex k
                LEFT OUTER JOIN kardex kk ON kk.id_cia = k.id_cia
                                             AND kk.numint <> k.numint
                                             AND kk.femisi >= k.femisi
                                             AND kk.locali >= k.locali
                                             AND kk.tipinv = k.tipinv
                                             AND kk.codart = k.codart
                                             AND kk.etiqueta = k.etiqueta
            WHERE
                    k.id_cia = pin_id_cia
                AND k.numint = pin_numint
                AND k.etiqueta IS NOT NULL
                AND length(TRIM(k.etiqueta)) > 1
                AND kk.numint IS NOT NULL
        ) LOOP
            dbms_output.put_line('PASO INTERMEDIO  - LOOP');
            v_etiquetas := v_etiquetas
                           || ' - '
                           || i.etiqueta;
            v_movimientos := 'S';
        END LOOP;

        v_etiquetas := substr(v_etiquetas, 3, 195);
        IF v_movimientos = 'S' THEN
            dbms_output.put_line('PASO INTERMEDIO  - ETIQUETAS - SALIR');
            pout_mensaje := 'No se puede ANULAR LA GUIA INTERNA [ '
                            || pin_numint
                            || ' ] porque las ETIQUETAS  [ '
                            || v_etiquetas
                            || ' ] tienen movimientos posteriores al ingreso de la guia ...!';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO INTERMEDIO  - SIN ETIQUETAS');
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

    END sp_verifica_movimientos;

    PROCEDURE sp_anular_guia_interna (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        c_tipdoc     NUMBER := 0;
        c_id         VARCHAR2(1);
        c_codmot     NUMBER;
        c_ordcomni   VARCHAR2(20);
        o            json_object_t;
        v_mensaje    VARCHAR2(1000) := '';
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        BEGIN
            SELECT
                tipdoc,
                id,
                codmot,
                ordcomni
            INTO
                c_tipdoc,
                c_id,
                c_codmot,
                c_ordcomni
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND tipdoc = 103;

        EXCEPTION
            WHEN no_data_found THEN
                c_tipdoc := 0;
                c_id := '';
                c_codmot := 0;
                c_ordcomni := 0;
                -- PASO 0 DOCUMENTO NO EXISTE
                RAISE pkg_exceptionuser.ex_documento_no_existe;
        END;

        -- PASO 0 EL USUARIO TIENE EL PERMISO?
        dbms_output.put_line('PASO 0 EL USUARIO TIENE EL PERMISO?');
        IF pack_documentos_cab.sp_conforme_para_anular(pin_id_cia, 103, pin_coduser) = 'N' THEN
            RAISE pkg_exceptionuser.ex_usuario_sin_permiso;
        END IF;

        -- PASO 0 TIENE MOVIMIENTOS RELACIONADOS?
        dbms_output.put_line('PASO 0 TIENE MOVIMIENTOS RELACIONADOS?');
        pack_documentos_kardex.sp_verifica_movimientos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        -- PASO 0 TIENE MOVIMIENTOS? -- SOLO SI ES INGRESO
        IF c_id = 'I' THEN
            dbms_output.put_line('TIENE MOVIMIENTOS -- SOLO SI ES INGRESO');
            pack_documentos_kardex.sp_verifica_movimientos(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

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

        -- PASO 3 ELIMINA KARDEX
        dbms_output.put_line('PASO 3 ELIMINA KARDEX');
        DELETE FROM kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        -- PASO 4 ACTUALIZA SITUACION DE DOCUMENTOS_RELACIONADOS
        dbms_output.put_line('PASO 4 ACTUALIZA SITUACION DE DOCUMENTOS_RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;           

        -- PASO 5 ACTUALIZAR SITUACION SEGUN SALDO
        dbms_output.put_line('PASO 5 ACTUALIZAR SITUACION SEGUN SALDO');
        pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, c_ordcomni, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Guia Interna anulada correctamente ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_usuario_sin_permiso THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El usuario no tiene permiso para realizar esta acción ...!'
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
    END sp_anular_guia_interna;

    PROCEDURE sp_asigna_kilos_unitarios (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_kilos NUMBER;
    BEGIN
        FOR i IN (
            SELECT
                d.id_cia,
                d.tipinv,
                d.codart,
                d.cantid,
                d.etiqueta,
                d.opnumdoc,
                d.opnumite,
                d.opcargo
            FROM
                documentos_det d
                LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND TRIM(d.etiqueta) IS NOT NULL
                AND a.consto = 3 /* SOLO EL CALCULO PARA ESTROBOS/ESLINGAS */
        ) LOOP
            SELECT
                SUM(
                    CASE
                        WHEN a.consto = 2
                             AND d.largo > 0 THEN
                            d.largo
                        ELSE
                            k.cantid
                    END
                    * nvl(a.faccon, 0) *
                    CASE
                        WHEN k.id = 'I' THEN
                            - 1
                        ELSE
                            1
                    END
                ) AS kilos
            INTO v_kilos
            FROM
                     documentos_cab c
                INNER JOIN documentos_det d ON d.id_cia = c.id_cia
                                               AND d.numint = c.numint
                INNER JOIN kardex         k ON k.id_cia = d.id_cia
                                       AND k.numint = d.numint
                                       AND k.numite = d.numite
                LEFT OUTER JOIN articulos      a ON a.id_cia = k.id_cia
                                               AND a.tipinv = k.tipinv
                                               AND a.codart = k.codart
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = k.id_cia
                                                    AND mc.tipdoc = k.tipdoc
                                                    AND mc.id = k.id
                                                    AND mc.codmot = k.codmot
                                                    AND mc.codigo = 22
            WHERE
                    c.id_cia = i.id_cia
                AND c.numint = i.opnumdoc
                AND d.numite = i.opnumite
                AND c.tipdoc = 104
                AND ( k.id = 'S'
                      OR nvl(mc.valor, 'N') = 'S' );

            DELETE FROM kilos_unitario
            WHERE
                    id_cia = i.id_cia
                AND tipinv = i.tipinv
                AND codart = i.codart
                AND etiqueta = i.etiqueta;

            IF
                i.cantid <> 0
                AND v_kilos <> 0
            THEN
                INSERT INTO kilos_unitario (
                    id_cia,
                    tipinv,
                    codart,
                    etiqueta,
                    kilosunit
                ) VALUES (
                    i.id_cia,
                    i.tipinv,
                    i.codart,
                    i.etiqueta,
                    v_kilos / i.cantid
                );

            END IF;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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
    END sp_asigna_kilos_unitarios;

END;

/
