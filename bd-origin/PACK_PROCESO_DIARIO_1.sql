--------------------------------------------------------
--  DDL for Package Body PACK_PROCESO_DIARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROCESO_DIARIO" AS

    PROCEDURE sp_update_dcta100 (
        pin_id_cia  IN NUMBER,
        pin_currval IN NUMBER
    ) AS

        v_mensaje VARCHAR2(4000);
        CURSOR emp IS
        SELECT
            cia
        FROM
            companias
        WHERE
            pin_id_cia IS NULL
            OR cia = pin_id_cia;

    BEGIN
        FOR h IN emp LOOP

        -- RECORRIDO POR EMPRESA
            v_mensaje := 'Success ...!';
            BEGIN
                FOR i IN (
                    SELECT
                        d.numint AS numint
                    FROM
                        dcta100 d
                    WHERE
                        d.id_cia = h.cia
                ) LOOP
                -- RECORRIDO POR DOCUMENTO
                    UPDATE dcta100 d100
                    SET
                        d100.fcance = (
                            SELECT
                                MAX(c.femisi)
                            FROM
                                dcta101 c
                            WHERE
                                    c.id_cia = h.cia
                                AND ( c.tipcan < 50 )
                                AND ( c.numint = d100.numint )
                        )
                    WHERE
                            d100.id_cia = h.cia
                        AND d100.numint = i.numint;

                END LOOP;
            -- FINALMENTE REGISTRA EL LOG

                INSERT INTO log_proceso_diario VALUES (
                    h.cia,
                    pin_currval,
                    'S',
                    'sp_update_dcta100',
                    v_mensaje,
                    sysdate,
                    sysdate
                );

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_mensaje := 'mensaje : '
                                 || sqlerrm
                                 || ' codigo :'
                                 || sqlcode;
                    INSERT INTO log_proceso_diario VALUES (
                        h.cia,
                        pin_currval,
                        'N',
                        'sp_update_dcta100',
                        v_mensaje,
                        sysdate,
                        sysdate
                    );

                    ROLLBACK;
            END;

        END LOOP;
    END sp_update_dcta100;

    PROCEDURE sp_update_prov100 (
        pin_id_cia  IN NUMBER,
        pin_currval IN NUMBER
    ) AS

        v_mensaje VARCHAR2(4000);
        CURSOR emp IS
        SELECT
            cia
        FROM
            companias
        WHERE
            pin_id_cia IS NULL
            OR cia = pin_id_cia;

    BEGIN
        FOR h IN emp LOOP

        -- RECORRIDO POR EMPRESA
            v_mensaje := 'Success ...!';
            BEGIN
                FOR i IN (
                    SELECT
                        p.id_cia,
                        p.tipo,
                        p.docu
                    FROM
                        prov100 p
                    WHERE
                        p.id_cia = h.cia
                ) LOOP
                -- RECORRIDO POR DOCUMENTO
                    UPDATE prov100 p100
                    SET
                        p100.fcance = (
                            SELECT
                                MAX(c.femisi)
                            FROM
                                prov101 c
                            WHERE
                                    c.id_cia = i.id_cia
                                AND c.tipo = i.tipo
                                AND c.docu = i.docu
                        )
                    WHERE
                            p100.id_cia = i.id_cia
                        AND p100.tipo = i.tipo
                        AND p100.docu = i.docu;

                END LOOP;
            -- FINALMENTE REGISTRA EL LOG

                INSERT INTO log_proceso_diario VALUES (
                    h.cia,
                    pin_currval,
                    'S',
                    'sp_update_prov100',
                    v_mensaje,
                    sysdate,
                    sysdate
                );

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_mensaje := 'mensaje : '
                                 || sqlerrm
                                 || ' codigo :'
                                 || sqlcode;
                    INSERT INTO log_proceso_diario VALUES (
                        h.cia,
                        pin_currval,
                        'N',
                        'sp_update_prov100',
                        v_mensaje,
                        sysdate,
                        sysdate
                    );

                    ROLLBACK;
            END;

        END LOOP;
    END sp_update_prov100;

    PROCEDURE sp_merge_licencia_resumen (
        pin_id_cia  IN NUMBER,
        pin_date    IN DATE,
        pin_currval IN NUMBER
    ) AS

        v_mensaje VARCHAR2(4000);
        CURSOR emp IS
        SELECT
            cia AS id_cia
        FROM
            companias
        WHERE
            pin_id_cia IS NULL
            OR cia = pin_id_cia;

        v_count   INTEGER;
        v_date    DATE := trunc(current_timestamp);
    BEGIN
        IF pin_date IS NOT NULL THEN
            v_date := pin_date;
        END IF;
        FOR h IN emp LOOP

        -- RECORRIDO POR EMPRESA
            v_mensaje := 'Success ...!';
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
                                id_cia = h.id_cia
                            AND codpro = j.codpro
                            AND situac = 'S'
                            AND trunc(v_date) BETWEEN fregis AND fvenci;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_count := 0;
                    END;

                    MERGE INTO licencia_resumen lr
                    USING dual ddd ON ( lr.id_cia = h.id_cia
                                        AND lr.codpro = j.codpro )
                    WHEN MATCHED THEN UPDATE
                    SET nrolicencia = v_count,
                        factua = current_timestamp
                    WHERE
                            id_cia = h.id_cia
                        AND lr.codpro = j.codpro
                    WHEN NOT MATCHED THEN
                    INSERT (
                        id_cia,
                        codpro,
                        nrolicencia,
                        fcreac,
                        factua )
                    VALUES
                        ( h.id_cia,
                          j.codpro,
                          v_count,
                          current_timestamp,
                          current_timestamp );

                END LOOP;

            -- FINALMENTE REGISTRA EL LOG

                INSERT INTO log_proceso_diario VALUES (
                    h.id_cia,
                    pin_currval,
                    'S',
                    'sp_merge_licencia_resumen',
                    v_mensaje,
                    sysdate,
                    sysdate
                );

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    v_mensaje := 'mensaje : '
                                 || sqlerrm
                                 || ' codigo :'
                                 || sqlcode;
                    INSERT INTO log_proceso_diario VALUES (
                        h.id_cia,
                        pin_currval,
                        'N',
                        'sp_merge_licencia_resumen',
                        v_mensaje,
                        sysdate,
                        sysdate
                    );

                    ROLLBACK;
            END;

        END LOOP;

    END sp_merge_licencia_resumen;

    PROCEDURE sp_update (
        pin_id_cia IN NUMBER
    ) AS
        v_aux NUMBER;
    BEGIN
        -- PROCESOS 
         -- INCREMENTAMOS EL GENERADOR
        SELECT
            gen_proceso_diario.NEXTVAL
        INTO v_aux
        FROM
            dual;

        --UPDATE DCTA100
--        pack_proceso_diario.sp_update_dcta100(pin_id_cia, v_aux);

        --UPDATE DCTA101
--        pack_proceso_diario.sp_update_prov100(pin_id_cia, v_aux);

        -- UPDATE LICENCIAS ACTIVAS
        pack_proceso_diario.sp_merge_licencia_resumen(pin_id_cia, NULL, v_aux);
    END sp_update;

END;

/
