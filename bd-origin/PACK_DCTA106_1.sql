--------------------------------------------------------
--  DDL for Package Body PACK_DCTA106
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DCTA106" AS

    FUNCTION sp_next_numite (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN NUMBER AS
        rec_dcta106 dcta106%rowtype;
    BEGIN
        BEGIN
            SELECT
                nvl(COUNT(0),
                    0)
            INTO rec_dcta106.item
            FROM
                dcta106
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                rec_dcta106.item := 0;
        END;

        RETURN rec_dcta106.item;
    EXCEPTION
        WHEN OTHERS THEN
            rec_dcta106.item := NULL;
            RETURN rec_dcta106.item;
    END sp_next_numite;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o           json_object_t;
        rec_dcta106 dcta106%rowtype;
        v_accion    VARCHAR2(50) := '';
        v_witem     NUMBER;
    BEGIN
    -- TAREA: Se necesita implantación para PROCEDURE PACK_DCTA106.sp_save

        o := json_object_t.parse(pin_datos);
        rec_dcta106.id_cia := pin_id_cia;
        rec_dcta106.numint := o.get_number('numint');
        rec_dcta106.numintap := o.get_number('numintap');
        rec_dcta106.item := o.get_number('item');
        rec_dcta106.id := o.get_string('id');
        rec_dcta106.codcli := o.get_string('codcli');
        rec_dcta106.tipdoc := o.get_number('tipdoc');
        rec_dcta106.docume := o.get_string('docume');
        rec_dcta106.periodo := o.get_number('periodo');
        rec_dcta106.mes := o.get_number('mes');
        rec_dcta106.femisi := o.get_date('femisi');
        rec_dcta106.fvenci := o.get_date('fvenci');
        rec_dcta106.fcance := o.get_date('fcance');
        rec_dcta106.refere01 := o.get_string('Refere01');
        rec_dcta106.refere02 := o.get_string('Refere02');
        rec_dcta106.tipmon := o.get_string('tipmon');
        rec_dcta106.importe := o.get_number('importe');
        rec_dcta106.importemn := o.get_number('importemn');
        rec_dcta106.importeme := o.get_number('importeme');
        rec_dcta106.concpag := o.get_number('concpag');
        rec_dcta106.codven := o.get_number('codven');
        rec_dcta106.codsuc := o.get_number('codsuc');
        rec_dcta106.usuari := o.get_string('usuari');
        rec_dcta106.situac := o.get_string('situac');
        rec_dcta106.tipcam := o.get_number('tipcam');
        rec_dcta106.operac := o.get_number('operac');
        rec_dcta106.codubi := o.get_number('codubi');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                DECLARE BEGIN
                    SELECT
                        MAX(item)
                    INTO v_witem
                    FROM
                        dcta106
                    WHERE
                        numint = rec_dcta106.numint;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_witem := NULL;
                END;

                IF ( v_witem IS NULL ) THEN
                    rec_dcta106.item := 0;
                ELSE
                    rec_dcta106.item := v_witem + 1;
                END IF;

                INSERT INTO dcta106 (
                    id_cia,
                    numint,
                    numintap,
                    item,
                    id,
                    codcli,
                    tipdoc,
                    docume,
                    periodo,
                    mes,
                    femisi,
                    fvenci,
                    fcance,
                    refere01,
                    refere02,
                    tipmon,
                    importe,
                    importemn,
                    importeme,
                    concpag,
                    codven,
                    codsuc,
                    fcreac,
                    factua,
                    usuari,
                    situac,
                    tipcam,
                    operac,
                    codubi
                ) VALUES (
                    rec_dcta106.id_cia,
                    rec_dcta106.numint,
                    rec_dcta106.numintap,
                    rec_dcta106.item,
                    rec_dcta106.id,
                    rec_dcta106.codcli,
                    rec_dcta106.tipdoc,
                    rec_dcta106.docume,
                    rec_dcta106.periodo,
                    rec_dcta106.mes,
                    rec_dcta106.femisi,
                    rec_dcta106.fvenci,
                    rec_dcta106.fcance,
                    rec_dcta106.refere01,
                    rec_dcta106.refere02,
                    rec_dcta106.tipmon,
                    rec_dcta106.importe,
                    rec_dcta106.importemn,
                    rec_dcta106.importeme,
                    rec_dcta106.concpag,
                    rec_dcta106.codven,
                    rec_dcta106.codsuc,
                    current_timestamp,
                    current_timestamp,
                    rec_dcta106.usuari,
                    rec_dcta106.situac,
                    rec_dcta106.tipcam,
                    rec_dcta106.operac,
                    rec_dcta106.codubi
                );

            WHEN 2 THEN
                dbms_output.put_line('Very Good');
            WHEN 3 THEN
                dbms_output.put_line('Good');
            ELSE
                NULL;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    END sp_save;

    PROCEDURE sp_eliminar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        FOR i IN (
            SELECT
                d.numint,
                d.numite,
                d.opnumdoc
            FROM
                documentos_det d
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND d.opcargo = 'APLI-106'
        ) LOOP
            DELETE FROM dcta106
            WHERE
                    id_cia = pin_id_cia
                AND numint = i.opnumdoc
                AND numintap = i.numint
                AND refere01 = i.numite;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
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
    END sp_eliminar_aplicacion;

    PROCEDURE sp_insertar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO dcta106 (
            id_cia,
            numint,
            numintap,
            item,
            id,
            codcli,
            tipdoc,
            docume,
            periodo,
            mes,
            femisi,
            fvenci,
            refere01,
            tipmon,
            importe,
            importemn,
            importeme,
            concpag,
            codven,
            codsuc,
            fcreac,
            factua,
            usuari,
            situac,
            tipcam,
            operac,
            codubi
        )
            SELECT
                d.id_cia,
                d.opnumdoc,
                d.numint,
                0,
--                (
--                    SELECT
--                        pack_dcta106.sp_next_numite(d.id_cia, d.opnumdoc)
--                    FROM
--                        dual
--                ) AS item,
                CASE
                    WHEN ( ( d.opcargo = 'APLI-106' )
                           AND ( d.tipdoc = 7 ) ) THEN
                        'I'
                    ELSE
                        c.id
                END,
                c.codcli,
                c.tipdoc,
                CASE
                    WHEN c.tipdoc = 5 THEN
                        CAST(c.numdoc AS VARCHAR2(12))
                    ELSE
                        c.series
                        || (
                            SELECT
                                sp000_ajusta_string(c.numdoc, 07, '0', 'R')
                            FROM
                                dual
                        )
                END,
                EXTRACT(YEAR FROM c.femisi),
                EXTRACT(MONTH FROM c.femisi),
                c.femisi,
                c.fecter,
                d.numite,
                c.tipmon,
                abs(d.monafe + d.monina + d.monigv),
                CASE
                    WHEN c.tipmon = 'PEN' THEN
                        abs(d.monafe + d.monina + d.monigv)
                    ELSE
                        abs(d.monafe + d.monina + d.monigv) * c.tipcam
                END,
                CASE
                    WHEN c.tipmon <> 'PEN' THEN
                        abs(d.monafe + d.monina + d.monigv)
                    ELSE
                        abs(d.monafe + d.monina + d.monigv) / c.tipcam
                END,
                c.codcpag,
                c.codven,
                c.codsuc,
                current_date,
                current_date,
                d.usuari,
                'A',
                c.tipcam,
                0,
                0
            FROM
                documentos_det d
                LEFT OUTER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                                    AND c.numint = d.numint
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND NOT ( d.situac IN ( 'J', 'K' ) )
                AND ( d.opcargo IN ( 'APLI-106', 'APNC-106' ) )
                AND ( d.importe IS NOT NULL )
                AND ( d.importe <> 0 );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
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
    END sp_insertar_aplicacion;

    PROCEDURE sp_actualizar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_mt25             motivos_clase.valor%TYPE := NULL;
        v_mt26             motivos_clase.valor%TYPE := NULL;
        rec_dcta106        dcta106%rowtype;
        rec_documentos_cab documentos_cab%rowtype;
        pout_mensaje       VARCHAR2(1000);
        v_number           NUMBER := 0;
    BEGIN
        BEGIN
            SELECT
                c.numint,
                c.series,
                c.numdoc,
                c.tipdoc,
                c.codcli,
                c.ordcomni,
                c.femisi,
                c.fecter,
                c.tipmon,
                c.numped,
                c.numdue,
                c.tipmon,
                c.preven,
                c.tipcam,
                c.codcpag,
                c.codven,
                c.codsuc,
                c.usuari,
                mt25.valor,
                mt26.valor
            INTO
                rec_documentos_cab.numint,
                rec_documentos_cab.series,
                rec_documentos_cab.numdoc,
                rec_documentos_cab.tipdoc,
                rec_documentos_cab.codcli,
                rec_documentos_cab.ordcomni,
                rec_documentos_cab.femisi,
                rec_documentos_cab.fecter,
                rec_documentos_cab.tipmon,
                rec_documentos_cab.numped,
                rec_documentos_cab.numdue,
                rec_documentos_cab.tipmon,
                rec_documentos_cab.preven,
                rec_documentos_cab.tipcam,
                rec_documentos_cab.codcpag,
                rec_documentos_cab.codven,
                rec_documentos_cab.codsuc,
                rec_documentos_cab.usuari,
                v_mt25,
                v_mt26
            FROM
                documentos_cab c
                LEFT OUTER JOIN motivos        m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN motivos_clase  mt25 ON mt25.id_cia = m.id_cia
                                                      AND mt25.tipdoc = m.tipdoc
                                                      AND mt25.id = m.id
                                                      AND mt25.codmot = m.codmot
                                                      AND mt25.codigo = 25
                LEFT OUTER JOIN motivos_clase  mt26 ON mt26.id_cia = m.id_cia
                                                      AND mt26.tipdoc = m.tipdoc
                                                      AND mt26.id = m.id
                                                      AND mt26.codmot = m.codmot
                                                      AND mt26.codigo = 26
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'No se encontro el DOCUMENTO [ '
                                || pin_numint
                                || ' ]';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        IF v_mt25 = 'S' THEN
            rec_dcta106.id_cia := pin_id_cia;
            IF v_mt26 = 'S' THEN
                rec_dcta106.numint := nvl(rec_documentos_cab.ordcomni, 0);
                rec_dcta106.numintap := rec_documentos_cab.numint;
                rec_dcta106.id := 'S';
            ELSE
                rec_dcta106.numint := rec_documentos_cab.numint;
                rec_dcta106.numintap := nvl(rec_documentos_cab.ordcomni, 0);
                rec_dcta106.id := 'I';
            END IF;

            rec_dcta106.item := 0;
--            rec_dcta106.item := pack_dcta106.sp_next_numite(rec_dcta106.id_cia, rec_dcta106.numint);
            rec_dcta106.codcli := rec_documentos_cab.codcli;
            rec_dcta106.tipdoc := rec_documentos_cab.tipdoc;
            IF rec_documentos_cab.tipdoc = 5 THEN
                rec_dcta106.docume := to_char(rec_documentos_cab.numdoc);
            ELSIF rec_documentos_cab.tipdoc IN ( 1, 3, 7, 8, 12 ) THEN
                rec_dcta106.docume := rec_documentos_cab.series
                                      || to_char(sp000_ajusta_string(rec_documentos_cab.numdoc, 07, '0', 'R'));
            ELSE
                rec_dcta106.docume := rec_documentos_cab.series
                                      || to_char(sp000_ajusta_string(rec_documentos_cab.numdoc, 07, '0', 'R'));
            END IF;

            rec_dcta106.femisi := rec_documentos_cab.femisi;
            rec_dcta106.periodo := extract(YEAR FROM rec_documentos_cab.femisi);
            rec_dcta106.mes := extract(MONTH FROM rec_documentos_cab.femisi);
            rec_dcta106.fvenci := rec_documentos_cab.fecter;
            rec_dcta106.tipmon := rec_documentos_cab.tipmon;
            rec_dcta106.refere01 := rec_documentos_cab.numped;
            rec_dcta106.refere02 := rec_documentos_cab.numdue;
            rec_dcta106.importe := rec_documentos_cab.preven;
            rec_dcta106.tipcam := rec_documentos_cab.tipcam;
            rec_dcta106.importemn := 0;
            rec_dcta106.importeme := 0;
            IF rec_dcta106.tipmon = 'PEN' THEN
                rec_dcta106.importemn := rec_documentos_cab.preven;
            ELSE
                rec_dcta106.importeme := rec_documentos_cab.preven;
            END IF;

            rec_dcta106.concpag := rec_documentos_cab.codcpag;
            rec_dcta106.codven := rec_documentos_cab.codven;
            rec_dcta106.codsuc := rec_documentos_cab.codsuc;
            rec_dcta106.usuari := rec_documentos_cab.usuari;
--            rec_dcta106.usuari := 'PRUEBA';
            -- INSERTA O ACTUALIZA EL DCTA106
            MERGE INTO dcta106 d106
            USING dual ddd ON ( d106.id_cia = rec_dcta106.id_cia
                                AND d106.numint = rec_dcta106.numint
                                AND d106.numintap = rec_dcta106.numintap )
            WHEN MATCHED THEN UPDATE
            SET id =
                CASE
                    WHEN rec_dcta106.id IS NOT NULL THEN
                        rec_dcta106.id
                    ELSE
                        id
                END,
                codcli =
                CASE
                    WHEN rec_dcta106.codcli IS NOT NULL THEN
                        rec_dcta106.codcli
                    ELSE
                        codcli
                END,
                tipdoc =
                CASE
                    WHEN rec_dcta106.tipdoc IS NOT NULL THEN
                        rec_dcta106.tipdoc
                    ELSE
                        tipdoc
                END,
                docume =
                CASE
                    WHEN rec_dcta106.docume IS NOT NULL THEN
                        rec_dcta106.docume
                    ELSE
                        docume
                END,
                periodo =
                CASE
                    WHEN rec_dcta106.periodo IS NOT NULL THEN
                        rec_dcta106.periodo
                    ELSE
                        periodo
                END,
                mes =
                CASE
                    WHEN rec_dcta106.mes IS NOT NULL THEN
                        rec_dcta106.mes
                    ELSE
                        mes
                END,
                femisi =
                CASE
                    WHEN rec_dcta106.femisi IS NOT NULL THEN
                        rec_dcta106.femisi
                    ELSE
                        femisi
                END,
                fvenci =
                CASE
                    WHEN rec_dcta106.fvenci IS NOT NULL THEN
                        rec_dcta106.fvenci
                    ELSE
                        fvenci
                END,
                fcance =
                CASE
                    WHEN rec_dcta106.fcance IS NOT NULL THEN
                        rec_dcta106.fcance
                    ELSE
                        fcance
                END,
                refere01 =
                CASE
                    WHEN rec_dcta106.refere01 IS NOT NULL THEN
                        rec_dcta106.refere01
                    ELSE
                        refere01
                END,
                refere02 =
                CASE
                    WHEN rec_dcta106.refere02 IS NOT NULL THEN
                        rec_dcta106.refere02
                    ELSE
                        refere02
                END,
                tipmon =
                CASE
                    WHEN rec_dcta106.tipmon IS NOT NULL THEN
                        rec_dcta106.tipmon
                    ELSE
                        tipmon
                END,
                importe =
                CASE
                    WHEN rec_dcta106.importe IS NOT NULL THEN
                        rec_dcta106.importe
                    ELSE
                        importe
                END,
                importemn =
                CASE
                    WHEN rec_dcta106.importemn IS NOT NULL THEN
                        rec_dcta106.importemn
                    ELSE
                        importemn
                END,
                importeme =
                CASE
                    WHEN rec_dcta106.importeme IS NOT NULL THEN
                        rec_dcta106.importeme
                    ELSE
                        importeme
                END,
                concpag =
                CASE
                    WHEN rec_dcta106.concpag IS NOT NULL THEN
                        rec_dcta106.concpag
                    ELSE
                        concpag
                END,
                codven =
                CASE
                    WHEN rec_dcta106.codven IS NOT NULL THEN
                        rec_dcta106.codven
                    ELSE
                        codven
                END,
                codsuc =
                CASE
                    WHEN rec_dcta106.codsuc IS NOT NULL THEN
                        rec_dcta106.codsuc
                    ELSE
                        codsuc
                END,
                factua = current_timestamp,
                usuari = rec_dcta106.usuari,
                situac =
                CASE
                    WHEN rec_dcta106.situac IS NOT NULL THEN
                        rec_dcta106.situac
                    ELSE
                        situac
                END,
                tipcam =
                CASE
                    WHEN rec_dcta106.tipcam IS NOT NULL THEN
                        rec_dcta106.tipcam
                    ELSE
                        tipcam
                END,
                operac =
                CASE
                    WHEN rec_dcta106.operac IS NOT NULL THEN
                        rec_dcta106.operac
                    ELSE
                        operac
                END,
                codubi =
                CASE
                    WHEN rec_dcta106.codubi IS NOT NULL THEN
                        rec_dcta106.codubi
                    ELSE
                        codubi
                END
            WHERE
                    id_cia = rec_dcta106.id_cia
                AND numint = rec_dcta106.numint
                AND numintap = rec_dcta106.numintap
            WHEN NOT MATCHED THEN
            INSERT (
                id_cia,
                numint,
                numintap,
                item,
                id,
                codcli,
                tipdoc,
                docume,
                periodo,
                mes,
                femisi,
                fvenci,
                fcance,
                refere01,
                refere02,
                tipmon,
                importe,
                importemn,
                importeme,
                concpag,
                codven,
                codsuc,
                fcreac,
                factua,
                usuari,
                situac,
                tipcam,
                operac,
                codubi )
            VALUES
                ( rec_dcta106.id_cia,
                  rec_dcta106.numint,
                  rec_dcta106.numintap,
                  rec_dcta106.item,
                  rec_dcta106.id,
                  rec_dcta106.codcli,
                  rec_dcta106.tipdoc,
                  rec_dcta106.docume,
                  rec_dcta106.periodo,
                  rec_dcta106.mes,
                  rec_dcta106.femisi,
                  rec_dcta106.fvenci,
                  rec_dcta106.fcance,
                  rec_dcta106.refere01,
                  rec_dcta106.refere02,
                  rec_dcta106.tipmon,
                  rec_dcta106.importe,
                  rec_dcta106.importemn,
                  rec_dcta106.importeme,
                  rec_dcta106.concpag,
                  rec_dcta106.codven,
                  rec_dcta106.codsuc,
                  current_timestamp,
                  current_timestamp,
                  rec_dcta106.usuari,
                  rec_dcta106.situac,
                  rec_dcta106.tipcam,
                  rec_dcta106.operac,
                  rec_dcta106.codubi );

        ELSE
            dbms_output.put_line('NO CONFIGURADO, REVISAR LA CLASE 25 DEL MOTIVO');
        END IF;

        -- ACTUALIZA EL ITEM SI ES UN ANTICIPO O APLICACION DE ANTICIPO
        FOR i IN (
            SELECT
                d.*
            FROM
                dcta106 d
            WHERE
                    d.id_cia = pin_id_cia
                AND ( d.numint = pin_numint
                      OR EXISTS (
                    SELECT
                        d106.*
                    FROM
                        dcta106 d106
                    WHERE
                            d106.id_cia = pin_id_cia
                        AND d106.numint = d.numint
                        AND d106.numintap = pin_numint
                ) )
            ORDER BY
                d.femisi ASC,
                d.id ASC
        ) LOOP
            UPDATE dcta106
            SET
                item = v_number
            WHERE
                    id_cia = i.id_cia
                AND numint = i.numint
                AND numintap = i.numintap;

            v_number := v_number + 1;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
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
    END sp_actualizar_aplicacion;

    PROCEDURE sp_procesar_aplicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        m            json_object_t;
        pout_mensaje VARCHAR2(1000) := '';
        v_mensaje    VARCHAR2(1000) := '';
    BEGIN
        pack_dcta106.sp_eliminar_aplicacion(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        pack_dcta106.sp_insertar_aplicacion(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        pack_dcta106.sp_actualizar_aplicacion(pin_id_cia, pin_numint, pin_coduser, v_mensaje);
        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
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

        COMMIT;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
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
    END sp_procesar_aplicacion;

END pack_dcta106;

/
