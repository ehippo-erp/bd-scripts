--------------------------------------------------------
--  DDL for Package Body PACK_SCRIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_SCRIPT" AS

    PROCEDURE sp_despues_migrar (
        pin_id_cia    IN NUMBER,
        pin_id_modelo IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    ) AS

        v_mensaje    VARCHAR2(1000);
        pout_mensaje VARCHAR2(1000);
        v_count      INTEGER := 0;
        o            json_object_t;
    BEGIN
        INSERT INTO empresa_modulos (
            id_cia,
            codmod,
            swacti
        )
            SELECT
                pin_id_cia,
                m.codmod,
                m.swacti
            FROM
                empresa_modulos m
            WHERE
                    m.id_cia = pin_id_modelo
                AND NOT EXISTS (
                    SELECT
                        x.codmod
                    FROM
                        empresa_modulos x
                    WHERE
                            x.id_cia = pin_id_cia
                        AND x.codmod = m.codmod
                );

        sp_disable_enable_all_triggers(0, 'TSI', v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        sp_update_sequence_coprometido_cia(pin_id_cia);
        sp_generate_sequences_the_documents_for_cia(pin_id_cia);
        sp_update_sequence_kardex_cia(pin_id_cia);
        sp_update_sequence_numint_cab_cia(pin_id_cia);
        sp_update_sequence_documentos_cab_log_cia(pin_id_cia);
        sp_update_sequence_dcta102_caja_cab_cia(pin_id_cia);
        sp_genera_secuencia_tdocume(pin_id_cia);
        sp_update_sequence_tdocume(pin_id_cia, NULL);
        UPDATE dcta100
        SET
            fcance = NULL
        WHERE
                id_cia = pin_id_cia
            AND trunc(fcance) = '01/01/1900';

        UPDATE prov100
        SET
            fcance = NULL
        WHERE
                id_cia = pin_id_cia
            AND trunc(fcance) = '01/01/1900';

        UPDATE prov100
        SET
            fvenci2 = NULL
        WHERE
                id_cia = pin_id_cia
            AND trunc(fvenci2) = '01/01/1900';

        INSERT INTO factor (
            id_cia,
            codfac,
            nomfac,
            tfactor,
            vreal,
            vstrg,
            vdate,
            vtime,
            ventero,
            cuenta,
            situac,
            fcreac,
            usuari,
            factua,
            swacti,
            observ
        )
            SELECT
                pin_id_cia,
                f.codfac,
                f.nomfac,
                f.tfactor,
                f.vreal,
                f.vstrg,
                f.vdate,
                f.vtime,
                f.ventero,
                f.cuenta,
                f.situac,
                f.fcreac,
                f.usuari,
                f.factua,
                f.swacti,
                f.observ
            FROM
                factor f
            WHERE
                    f.id_cia = pin_id_modelo
                AND f.codfac IN ( 434 )
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        factor ff
                    WHERE
                            ff.id_cia = pin_id_cia
                        AND ff.codfac = f.codfac
                );

        -- SOLO PARA PRUEBA
        DECLARE
            CURSOR cur_conf_fetest IS
            SELECT
                id_cia,
                item,
                pathzip,
                pathxml,
                pathxmlres,
                pathresok,
                pathtxt,
                sunat_user,
                sunat_clave,
                serv_reten,
                serv_percep,
                serv_comven,
                serv_guirem,
                urlws_tsi,
                version_ubl
            FROM
                compania_facelec
            WHERE
                id_cia = 5;

            v_count INTEGER := 0;
        BEGIN
            FOR rconf IN cur_conf_fetest LOOP
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count
                    FROM
                        compania_facelec
                    WHERE
                            id_cia = pin_id_cia
                        AND item = 1;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                IF v_count = 0 THEN
                    INSERT INTO compania_facelec (
                        id_cia,
                        item,
                        pathzip,
                        pathxml,
                        pathxmlres,
                        pathresok,
                        pathtxt,
                        sunat_user,
                        sunat_clave,
                        serv_reten,
                        serv_percep,
                        serv_comven,
                        serv_guirem,
                        urlws_tsi,
                        version_ubl
                    ) VALUES (
                        pin_id_cia,
                        rconf.item,
                        rconf.pathzip,
                        rconf.pathxml,
                        rconf.pathxmlres,
                        rconf.pathresok,
                        rconf.pathtxt,
                        rconf.sunat_user,
                        rconf.sunat_clave,
                        rconf.serv_reten,
                        rconf.serv_percep,
                        rconf.serv_comven,
                        rconf.serv_guirem,
                        rconf.urlws_tsi,
                        rconf.version_ubl
                    );

                    COMMIT;
                ELSE
                    UPDATE compania_facelec
                    SET
                        pathzip = rconf.pathzip,
                        pathxml = rconf.pathxml,
                        pathxmlres = rconf.pathxmlres,
                        pathresok = rconf.pathresok,
                        pathtxt = rconf.pathtxt,
                        sunat_user = rconf.sunat_user,
                        sunat_clave = rconf.sunat_clave,
                        serv_reten = rconf.serv_reten,
                        serv_percep = rconf.serv_percep,
                        serv_comven = rconf.serv_comven,
                        serv_guirem = rconf.serv_guirem,
                        urlws_tsi = rconf.urlws_tsi,
                        version_ubl = rconf.version_ubl
                    WHERE
                            id_cia = pin_id_cia
                        AND item = rconf.item;

                    COMMIT;
                END IF;

            END LOOP;
        END;

        BEGIN
            SELECT
                0
            INTO v_count
            FROM
                tfactor
            WHERE
                    id_cia = pin_id_cia
                AND tipo = 300
                AND codfac = '09';

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO tfactor (
                    id_cia,
                    tipo,
                    codfac,
                    nomfac,
                    vreal,
                    vstrg,
                    vdate,
                    vtime,
                    ventero,
                    cuenta,
                    dh,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    300,
                    '09',
                    'Ley N° 30737',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    'admin',
                    current_date,
                    NULL
                );

        END;

        BEGIN
            SELECT
                0
            INTO v_count
            FROM
                tfactor
            WHERE
                    id_cia = pin_id_cia
                AND tipo = 301
                AND codfac = '099';

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO tfactor (
                    id_cia,
                    tipo,
                    codfac,
                    nomfac,
                    vreal,
                    vstrg,
                    vdate,
                    vtime,
                    ventero,
                    cuenta,
                    dh,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    301,
                    '099',
                    'Ley N° 30737',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    'admin',
                    current_date,
                    NULL
                );

        END;

        BEGIN
            SELECT
                0
            INTO v_count
            FROM
                tfactor
            WHERE
                    id_cia = pin_id_cia
                AND tipo = 300
                AND codfac = '09';

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO tfactor (
                    id_cia,
                    tipo,
                    codfac,
                    nomfac,
                    vreal,
                    vstrg,
                    vdate,
                    vtime,
                    ventero,
                    cuenta,
                    dh,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    300,
                    '09',
                    'Ley N° 30737',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    'admin',
                    current_date,
                    NULL
                );

        END;

        BEGIN
            SELECT
                0
            INTO v_count
            FROM
                tfactor
            WHERE
                    id_cia = pin_id_cia
                AND tipo = 301
                AND codfac = '099';

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO tfactor (
                    id_cia,
                    tipo,
                    codfac,
                    nomfac,
                    vreal,
                    vstrg,
                    vdate,
                    vtime,
                    ventero,
                    cuenta,
                    dh,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    301,
                    '099',
                    'Ley N° 30737',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    0,
                    NULL,
                    NULL,
                    NULL,
                    'admin',
                    current_date,
                    NULL
                );

        END;

        BEGIN
    -- PROCESO PARA LA ANALITICA DE CUENTAS
            UPDATE pcuentas
            SET
                codtana = NULL
            WHERE
                id_cia = pin_id_cia;

            DELETE FROM tanalitica
            WHERE
                id_cia = pin_id_cia;

            INSERT INTO tanalitica
                (
                    SELECT
                        pin_id_cia,
                        t.codtana,
                        t.descri,
                        t.usuari,
                        t.fcreac,
                        t.factua,
                        t.swacti,
                        t.moneda
                    FROM
                        tanalitica t
                    WHERE
                        t.id_cia = pin_id_modelo
                );

            UPDATE pcuentas
            SET
                codtana = 0
            WHERE
                id_cia = pin_id_cia;

            UPDATE pcuentas
            SET
                codtana = 12
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '12%';

            UPDATE pcuentas
            SET
                codtana = 14
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '14%';

            UPDATE pcuentas
            SET
                codtana = 16
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '16%';

            UPDATE pcuentas
            SET
                codtana = 19
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '19%';

            UPDATE pcuentas
            SET
                codtana = 42
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '42%';

            UPDATE pcuentas
            SET
                codtana = 44
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '44%';

            UPDATE pcuentas
            SET
                codtana = 46
            WHERE
                    id_cia = pin_id_cia
                AND cuenta LIKE '46%';

            COMMIT;
            -- PROCESO PARA EL TSI REPORTES
            INSERT INTO exceldinamico_especifico
                (
                    SELECT
                        pin_id_cia,
                        ex.codexc,
                        ex.desexc,
                        ex.cadsql,
                        ex.observ,
                        ex.nlibro,
                        ex.codmod,
                        ex.tipbd,
                        ex.params,
                        ex.swtabd,
                        ex.swsistema
                    FROM
                        exceldinamico_especifico ex
                    WHERE
                            ex.id_cia = pin_id_modelo
                        AND NOT EXISTS (
                            SELECT
                                exx.*
                            FROM
                                exceldinamico_especifico exx
                            WHERE
                                    exx.id_cia = pin_id_cia
                                AND exx.codexc = ex.codexc
                        )
                );

            BEGIN
                INSERT INTO grupo_usuario VALUES (
                    pin_id_cia,
                    1,
                    'GRUPO GENERAL DE USUARIOS',
                    'S',
                    'admin',
                    'admin',
                    current_timestamp,
                    current_timestamp
                );

            EXCEPTION
                WHEN dup_val_on_index THEN
                    NULL;
            END;

            INSERT INTO usuario_grupo
                (
                    SELECT
                        pin_id_cia,
                        1,
                        u.coduser,
                        'admin',
                        'admin',
                        current_timestamp,
                        current_timestamp
                    FROM
                        usuarios u
                    WHERE
                            u.id_cia = pin_id_cia
                        AND NOT EXISTS (
                            SELECT
                                uu.*
                            FROM
                                usuario_grupo uu
                            WHERE
                                    uu.id_cia = pin_id_cia
                                AND uu.codgrupo = 1
                                AND uu.coduser = u.coduser
                        )
                );

            INSERT INTO exceldinamico_grupo
                (
                    SELECT
                        pin_id_cia,
                        e.codexc,
                        1,
                        'admin',
                        'admin',
                        current_timestamp,
                        current_timestamp
                    FROM
                        (
                            SELECT
                                codexc
                            FROM
                                exceldinamico_especifico
                            WHERE
                                id_cia = pin_id_modelo
                            UNION ALL
                            SELECT
                                codexc
                            FROM
                                exceldinamico_generico
                            WHERE
                                id_cia = 1
                        ) e
                    WHERE
                        NOT EXISTS (
                            SELECT
                                *
                            FROM
                                exceldinamico_grupo ee
                            WHERE
                                    ee.id_cia = pin_id_cia
                                AND ee.codexc = e.codexc
                                AND ee.codgrupo = 1
                        )
                );

        END;

        -- LICENCIA - ERP
        DECLARE
            v_fregis   DATE := TO_DATE ( '01/01/23', 'DD/MM/YY' );
            v_fvenci   DATE := TO_DATE ( '31/12/23', 'DD/MM/YY' );
            v_licencia NUMBER;
        BEGIN
        -- DELETE LICENCIA

            DELETE FROM licencia_producto
            WHERE
                id_cia = pin_id_cia;

            FOR i IN (
                SELECT
                    cia              AS id_cia,
                    nvl(usuarios, 0) AS usuarios
                FROM
                    companias
                WHERE
                    cia = pin_id_cia
            ) LOOP
                FOR j IN 1..i.usuarios LOOP
                    BEGIN
                        SELECT
                            id_licencia + 1
                        INTO v_licencia
                        FROM
                            licencia_producto
                        WHERE
                            id_cia = i.id_cia
                        ORDER BY
                            id_licencia DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_licencia := 1;
                    END;

                    INSERT INTO licencia_producto VALUES (
                        i.id_cia,
                        v_licencia,
                        'LICENCIA DEL ERP N° ' || to_char(j),
                        'ERP',
                        v_fregis,
                        v_fvenci,
                        'LICENCIA DEL ERP N° ' || to_char(j),
                        'S',
                        'admin',
                        'admin',
                        current_timestamp,
                        current_timestamp
                    );

                END LOOP;
            END LOOP;

        END;

        -- LICENCIA APP
        DECLARE
            v_fregis   DATE := TO_DATE ( '01/01/23', 'DD/MM/YY' );
            v_fvenci   DATE := TO_DATE ( '31/12/23', 'DD/MM/YY' );
            v_licencia NUMBER;
        BEGIN
            FOR i IN (
                SELECT
                    cia                                 AS id_cia,
                    ( trunc(nvl(usuarios, 0) / 2) + 1 ) AS usuarios
                FROM
                    companias
                WHERE
                    cia = pin_id_cia
            ) LOOP
                FOR j IN 1..i.usuarios LOOP
                    BEGIN
                        SELECT
                            id_licencia + 1
                        INTO v_licencia
                        FROM
                            licencia_producto
                        WHERE
                            id_cia = i.id_cia
                        ORDER BY
                            id_licencia DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_licencia := 1;
                    END;

                    INSERT INTO licencia_producto VALUES (
                        i.id_cia,
                        v_licencia,
                        'LICENCIA DEL APP N° ' || to_char(j),
                        'APP',
                        v_fregis,
                        v_fvenci,
                        'LICENCIA DEL APP N° ' || to_char(j),
                        'S',
                        'admin',
                        'admin',
                        current_timestamp,
                        current_timestamp
                    );

                END LOOP;
            END LOOP;
        END;

               -- ACTUALIZANDO LICENCIA RESUMEN
        BEGIN
            FOR j IN (
                SELECT
                    *
                FROM
                    producto_licencia
            ) LOOP
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_count
                    FROM
                        licencia_producto
                    WHERE
                            id_cia = pin_id_cia
                        AND codpro = j.codpro
                        AND situac = 'S'
                        AND trunc(current_timestamp) BETWEEN fregis AND fvenci;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_count := 0;
                END;

                MERGE INTO licencia_resumen lr
                USING dual ddd ON ( lr.id_cia = pin_id_cia
                                    AND lr.codpro = j.codpro )
                WHEN MATCHED THEN UPDATE
                SET nrolicencia = v_count,
                    factua = current_timestamp
                WHERE
                        id_cia = pin_id_cia
                    AND lr.codpro = j.codpro
                WHEN NOT MATCHED THEN
                INSERT (
                    id_cia,
                    codpro,
                    nrolicencia,
                    fcreac,
                    factua )
                VALUES
                    ( pin_id_cia,
                      j.codpro,
                      v_count,
                      current_timestamp,
                      current_timestamp );

            END LOOP;
        END;

        -- DW CVENTA
        pack_dw.sp_dw_cventasv2(pin_id_cia, TO_DATE('01/01/2018', 'DD/MM/YYYY'), TO_DATE('01/01/2024', 'DD/MM/YYYY'));

        pack_dw.sp_dw_actualiza_cventas_hijas(pin_id_cia, 1, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        sp_disable_enable_all_triggers(1, 'TSI', v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
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
    END sp_despues_migrar;

END;

/
