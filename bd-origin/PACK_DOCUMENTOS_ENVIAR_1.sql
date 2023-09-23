--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_ENVIAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENVIAR" AS

    PROCEDURE sp_actualiza_ctasctes (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        rec_documentos_cab            documentos_cab%rowtype;
        rec_documentos_cab_referencia documentos_cab_referencia%rowtype;
        rec_dcta100                   dcta100%rowtype;
        v_condicion_pago              c_pago_clase.valor%TYPE;
        pout_mensaje                  VARCHAR2(1000 CHAR);
    BEGIN
        SELECT
            *
        INTO rec_documentos_cab
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        BEGIN
            SELECT
                nvl(valor, 'N')
            INTO v_condicion_pago
            FROM
                c_pago_clase
            WHERE
                    id_cia = rec_documentos_cab.id_cia
                AND codpag = rec_documentos_cab.codcpag
                AND codigo = 1
            FETCH NEXT 1 ROWS ONLY;
        -- SI EXISTE Y ES N = FALSO (NO PASA)
        EXCEPTION
            WHEN no_data_found THEN
                v_condicion_pago := 'N';
        END;

        dbms_output.put_line('CONDICION DE PAGO');
        IF nvl(v_condicion_pago, 'N') = 'S' THEN
            dbms_output.put_line('CONDICION INSERT 1 ');
            rec_dcta100.id_cia := rec_documentos_cab.id_cia;
            rec_dcta100.numint := rec_documentos_cab.numint;
            rec_dcta100.codcli := rec_documentos_cab.codcli;
            rec_dcta100.tipdoc := rec_documentos_cab.tipdoc;
            IF rec_dcta100.tipdoc = 5 THEN
                rec_dcta100.docume := to_char(rec_documentos_cab.numdoc);
            ELSE
                rec_dcta100.docume := rec_documentos_cab.series
                                      || to_char(sp000_ajusta_string(rec_documentos_cab.numdoc, 07, '0', 'R'));
            END IF;

            dbms_output.put_line('CONDICION INSERT 2 ');
            rec_dcta100.serie := rec_documentos_cab.series;
            rec_dcta100.numero := to_char(rec_documentos_cab.numdoc);
            rec_dcta100.periodo := extract(YEAR FROM rec_documentos_cab.femisi);
            rec_dcta100.mes := extract(MONTH FROM rec_documentos_cab.femisi);
            rec_dcta100.femisi := rec_documentos_cab.femisi;
            rec_dcta100.fvenci := rec_documentos_cab.fecter;
            rec_dcta100.tipmon := rec_documentos_cab.tipmon;
            dbms_output.put_line('CONDICION INSERT 3 ');
            BEGIN
                SELECT
                    series,
                    numdoc
                INTO
                    rec_documentos_cab_referencia.series,
                    rec_documentos_cab_referencia.numdoc
                FROM
                    documentos_cab_referencia
                WHERE
                        id_cia = pin_id_cia
                    AND numintref = pin_numint;

            EXCEPTION
                WHEN no_data_found THEN
                    rec_documentos_cab_referencia.series := NULL;
                    rec_documentos_cab_referencia.numdoc := NULL;
            END;

            dbms_output.put_line('CONDICION INSERT 4 ');
            IF
                rec_dcta100.tipdoc IN ( 7, 8 )
                AND rec_documentos_cab_referencia.series IS NOT NULL
                AND rec_documentos_cab_referencia.numdoc IS NOT NULL
            THEN
                rec_dcta100.refere01 := rec_documentos_cab_referencia.series
                                        || to_char(sp000_ajusta_string(rec_documentos_cab_referencia.numdoc, 07, '0', 'R'));
            ELSE
                rec_dcta100.refere01 := substr(rec_documentos_cab.numped, 1, 23);
            END IF;

            dbms_output.put_line('CONDICION INSERT 5 ');
            rec_dcta100.refere02 := rec_documentos_cab.ordcom;
            rec_dcta100.tipcam := rec_documentos_cab.tipcam;
            rec_dcta100.importemn := 0;
            rec_dcta100.importeme := 0;
            rec_dcta100.saldomn := 0;
            rec_dcta100.saldome := 0;
            rec_dcta100.importe := rec_documentos_cab.preven;
            dbms_output.put_line('CONDICION INSERT 6 ');
            IF rec_documentos_cab.tipmon = 'PEN' THEN
                rec_dcta100.importemn := rec_documentos_cab.preven;
                rec_dcta100.saldomn := 0;
            ELSE
                rec_dcta100.importeme := rec_documentos_cab.preven;
                rec_dcta100.saldome := 0;
            END IF;

            dbms_output.put_line('CONDICION INSERT 7 ');
            rec_dcta100.concpag := rec_documentos_cab.codcpag;
            rec_dcta100.codven := rec_documentos_cab.codven;
            rec_dcta100.codcob := rec_documentos_cab.codcob;
            rec_dcta100.comisi := rec_documentos_cab.comisi;
            rec_dcta100.codsuc := rec_documentos_cab.codsuc;
            rec_dcta100.usuari := rec_documentos_cab.usuari;
            rec_dcta100.swmigra := 'N';
            -- INSERTA / ACTUALIZA
            MERGE INTO dcta100 d100
            USING dual ddd ON ( d100.id_cia = pin_id_cia
                                AND d100.numint = pin_numint )
            WHEN MATCHED THEN UPDATE
            SET codcli = nvl(rec_dcta100.codcli, codcli),
                tipdoc = nvl(rec_dcta100.tipdoc, tipdoc),
                docume = nvl(rec_dcta100.docume, docume),
                serie = nvl(rec_dcta100.serie, serie),
                numero = nvl(rec_dcta100.numero, numero),
                periodo = nvl(rec_dcta100.periodo, periodo),
                mes = nvl(rec_dcta100.mes, mes),
                femisi = nvl(rec_dcta100.femisi, femisi),
                fvenci = nvl(rec_dcta100.fvenci, fvenci),
                fcance = nvl(rec_dcta100.fcance, fcance),
                codban = nvl(rec_dcta100.codban, codban),
                numbco = nvl(rec_dcta100.numbco, numbco),
                refere01 = nvl(rec_dcta100.refere01, refere01),
                refere02 = nvl(rec_dcta100.refere02, refere02),
                tipmon = nvl(rec_dcta100.tipmon, tipmon),
                importe = nvl(rec_dcta100.importe, importe),
                importemn = nvl(rec_dcta100.importemn, importemn),
                importeme = nvl(rec_dcta100.importeme, importeme),
                saldo = nvl(rec_dcta100.saldo, saldo),
                saldomn = nvl(rec_dcta100.saldomn, saldomn),
                saldome = nvl(rec_dcta100.saldome, saldome),
                concpag = nvl(rec_dcta100.concpag, concpag),
                codcob = nvl(rec_dcta100.codcob, codcob),
                codven = nvl(rec_dcta100.codven, codven),
                comisi = nvl(rec_dcta100.comisi, comisi),
                codsuc = nvl(rec_dcta100.codsuc, codsuc),
                cancelado = nvl(rec_dcta100.cancelado, cancelado),
                factua = current_timestamp,
                usuari = pin_coduser,
                situac = nvl(rec_dcta100.situac, situac),
                cuenta = nvl(rec_dcta100.cuenta, cuenta),
                dh = nvl(rec_dcta100.dh, dh),
                tipcam = nvl(rec_dcta100.tipcam, tipcam),
                operac = 0,
                protes = nvl(rec_dcta100.protes, protes),
                xlibro = nvl(rec_dcta100.xlibro, xlibro),
                xperiodo = nvl(rec_dcta100.xperiodo, xperiodo),
                xmes = nvl(rec_dcta100.xmes, xmes),
                xsecuencia = nvl(rec_dcta100.xsecuencia, xsecuencia),
                codubi = nvl(rec_dcta100.codubi, codubi),
                xprotesto = nvl(rec_dcta100.xprotesto, xprotesto),
                tercero = nvl(rec_dcta100.tercero, tercero),
                codterc = nvl(rec_dcta100.codterc, codterc),
                codacep = nvl(rec_dcta100.codacep, codacep)
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
            WHEN NOT MATCHED THEN
            INSERT (
                id_cia,
                numint,
                codcli,
                tipdoc,
                docume,
                serie,
                numero,
                periodo,
                mes,
                femisi,
                fvenci,
                fcance,
                codban,
                numbco,
                refere01,
                refere02,
                tipmon,
                importe,
                importemn,
                importeme,
                saldo,
                saldomn,
                saldome,
                concpag,
                codcob,
                codven,
                comisi,
                codsuc,
                cancelado,
                fcreac,
                factua,
                usuari,
                situac,
                cuenta,
                dh,
                tipcam,
                operac,
                protes,
                xlibro,
                xperiodo,
                xmes,
                xsecuencia,
                codubi,
                xprotesto,
                tercero,
                codterc,
                codacep,
                swmigra )
            VALUES
                ( rec_dcta100.id_cia,
                  rec_dcta100.numint,
                  rec_dcta100.codcli,
                  rec_dcta100.tipdoc,
                  rec_dcta100.docume,
                  rec_dcta100.serie,
                  rec_dcta100.numero,
                  rec_dcta100.periodo,
                  rec_dcta100.mes,
                  rec_dcta100.femisi,
                  rec_dcta100.fvenci,
                  rec_dcta100.fcance,
--                  rec_dcta100.codban,
                0,
                  rec_dcta100.numbco,
                  rec_dcta100.refere01,
                  rec_dcta100.refere02,
                  rec_dcta100.tipmon,
                  rec_dcta100.importe,
                  rec_dcta100.importemn,
                  rec_dcta100.importeme,
                  rec_dcta100.saldo,
                  rec_dcta100.saldomn,
                  rec_dcta100.saldome,
                  rec_dcta100.concpag,
                  rec_dcta100.codcob,
                  rec_dcta100.codven,
                  rec_dcta100.comisi,
                  rec_dcta100.codsuc,
                  rec_dcta100.cancelado,
                  current_timestamp,
                  current_timestamp,
                  pin_coduser,
                  rec_dcta100.situac,
                  rec_dcta100.cuenta,
                  rec_dcta100.dh,
                  rec_dcta100.tipcam,
                  rec_dcta100.operac,
                  rec_dcta100.protes,
                  rec_dcta100.xlibro,
                  rec_dcta100.xperiodo,
                  rec_dcta100.xmes,
                  rec_dcta100.xsecuencia,
--                  rec_dcta100.codubi,
                1,
                  rec_dcta100.xprotesto,
                  rec_dcta100.tercero,
                  rec_dcta100.codterc,
                  rec_dcta100.codacep,
                  rec_dcta100.swmigra );

            sp_actualiza_saldo_dcta100(pin_id_cia, pin_numint);
        ELSE
            dbms_output.put_line('CONDICION DE PAGO '
                                 || rec_documentos_cab.codcpag
                                 || ' - NO CONFIGURADA, NO SE ENVIA A CTASCTES, REVISAR LA CLASE 1');
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
    END sp_actualiza_ctasctes;

    PROCEDURE sp_ctasctes (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_mensaje          VARCHAR2(2000) := '';
        o                  json_object_t;
        pout_mensaje       VARCHAR2(2000) := '';
        v_mt28             motivos_clase.valor%TYPE := NULL;
        v_mt56             motivos_clase.valor%TYPE := NULL;
        rec_documentos_cab documentos_cab%rowtype;
        v_swenviakardex    VARCHAR2(1 CHAR) := '';
    BEGIN
        -- PASO 1 EXISTE DOCUMENTO - MOTIVOS 28,56?
        dbms_output.put_line('PASO 1 EXISTE DOCUMENTO - MOTIVOS 28,56?');
        BEGIN
            SELECT
                c.lugemi,
                c.ordcomni,
                mt28.valor,
                mt56.valor
            INTO
                rec_documentos_cab.lugemi,
                rec_documentos_cab.ordcomni,
                v_mt28,
                v_mt56
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN motivos_clase  mt28 ON mt28.id_cia = m.id_cia
                                                      AND mt28.tipdoc = m.tipdoc
                                                      AND mt28.id = m.id
                                                      AND mt28.codmot = m.codmot
                                                      AND mt28.codigo = 28
                LEFT OUTER JOIN motivos_clase  mt56 ON mt56.id_cia = m.id_cia
                                                      AND mt56.tipdoc = m.tipdoc
                                                      AND mt56.id = m.id
                                                      AND mt56.codmot = m.codmot
                                                      AND mt56.codigo = 56
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'EL DOCUMENTO N°'
                                || to_char(pin_numint)
                                || ' NO EXISTE';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF v_mt28 IS NOT NULL THEN
            v_swenviakardex := v_mt28;
        END IF;
        dbms_output.put_line('PASO 3 SI ES PUNTO DE VENTA, EN TODOS LOS CASOS SE ENVIARA AL KARDEX');
        IF rec_documentos_cab.lugemi IN ( 3, 5, 6 ) THEN
            IF v_mt56 IS NULL THEN
                dbms_output.put_line('PASO 3.1 - POR DEFECTO SE ENVIARA AL KARDEX ( SIN MT56 )');
                v_swenviakardex := 'S';
            ELSE
                dbms_output.put_line('PASO 3.1 - SE ENVIARA SEGUN EL VALOR DEL MT56');
                v_swenviakardex := v_mt56;
            END IF;
        END IF;

        dbms_output.put_line('PASO 4 ACTUALIZA SITUACION');
        pack_documentos_anulados.sp_actualiza_situacion(pin_id_cia, pin_numint, 'F', pin_coduser, v_mensaje,
                                                       'N', 'S', 'N', 'N', 'N');

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 5 HEREDA APROBACIONES');
        pack_documentos_kardex.sp_hereda_aprobaciones(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 6 ELIMINA DOCUMENTO ENT');
        DELETE FROM documentos_ent
        WHERE
                id_cia = pin_id_cia
            AND orinumint = pin_numint;

        dbms_output.put_line('PASO 7 GENERA DOCUMENTO ENT');
        pack_documentos_kardex.sp_genera_documento_ent(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 8 ACTUALIZA SERIES-NUMERO');
--        IF ( rec_documentos_cab.numdoc <> 0 AND  rec_documentos_cab.series IS NOT NULL ) OR ( rec_documentos_cab.numdoc = 0 AND rec_documentos_cab.situac= 'J') THEN
--            
--            IF rec_documentos_cab.numdoc = 0 AND 
--            
--            END IF;
--            
--            IF rec_documentos_cab.tipdoc IN (1,3,7,8,102,12,210,41) THEN
--            
--            END IF;
--        
--        END IF;
        dbms_output.put_line('PASO 9 ACTUALIZA MOTIVO DOCUMENTO');
        UPDATE documentos_cab
        SET
            motdoc = 1,
            usuari = pin_coduser,
            factua = current_timestamp
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        dbms_output.put_line('PASO 10 ACTUALIZA CTASCTES');
        pack_documentos_enviar.sp_actualiza_ctasctes(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 11 PROCESAR DCTA106');
        pack_dcta106.sp_procesar_aplicacion(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 9 ACTUALIZA SITUACION DE DOCUMENTOS_RELACIONADOS');
        pack_documentos_anulados.sp_actualiza_situacion_documentos_relacionados(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 10 ACTUALIZAR SITUACION SEGUN SALDO');
        pack_documentos_anulados.sp_actualiza_situacion_segun_saldo(pin_id_cia, rec_documentos_cab.ordcomni, pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        dbms_output.put_line('PASO 11 ELIMINA KARDEX');
        DELETE FROM kardex
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        dbms_output.put_line('PASO 12 GENERA KARDEX - SEGUN FACTOR' || v_swenviakardex);
        IF v_swenviakardex = 'S' THEN
            sp_enviar_kardex(pin_id_cia, pin_numint);
        END IF;
        COMMIT;
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
    END sp_ctasctes;

END;

/
