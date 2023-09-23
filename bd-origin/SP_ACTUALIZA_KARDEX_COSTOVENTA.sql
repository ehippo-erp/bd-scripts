--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_KARDEX_COSTOVENTA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_KARDEX_COSTOVENTA" (
    pin_id_cia      IN NUMBER,
    pin_fecha_desde IN DATE,
    pin_fecha_hasta IN DATE,
    pout_mensaje    OUT VARCHAR2
) AS

    v_tipdoc    INTEGER;
    v_deskardex VARCHAR(2);
    v_femisi    DATE;
    v_numintfac INTEGER;
    v_numitefac INTEGER;
    v_numintgui INTEGER;
    v_numitegui INTEGER;
    v_cantid    NUMERIC(16, 4);
    v_costot01  NUMERIC(16, 2);
    v_costot02  NUMERIC(16, 2);
    v_fproceso  INTEGER;
    v_swacti    VARCHAR2(20 CHAR);
    v_item      INTEGER;
    pin_mensaje VARCHAR2(1000) := '';
BEGIN
    DELETE FROM kardex_costoventa
    WHERE
            id_cia = pin_id_cia
        AND ( TRUNC(femisi) BETWEEN pin_fecha_desde AND pin_fecha_hasta );

    BEGIN
        SELECT
            ventero,
            nvl(vstrg, 'N')
        INTO
            v_fproceso,
            v_swacti
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 216;

    EXCEPTION
        WHEN no_data_found THEN
            v_fproceso := NULL;
    END;

    IF v_fproceso = 1 THEN
        FOR i IN (
            SELECT
                c.tipdoc,
                c.femisi,
                d.numint AS numintfac,
                d.numite AS numitefac,
                CASE
                    WHEN c.tipdoc = 7 THEN
                        d.opnumdoc
                    ELSE
                        d1.numint
                END      AS numintgui,
                CASE
                    WHEN c.tipdoc = 7 THEN
                        d.opnumite
                    ELSE
                        d1.numite
                END      AS numitegui
            FROM
                documentos_cab c
                LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det d1 ON d1.id_cia = d.id_cia
                                                     AND d1.numint = d.opnumdoc
                                                     AND d1.numite = d.opnumite
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc IN ( 1, 3, 7, 8 )
                AND c.situac IN ( 'C', 'B', 'H', 'G', 'F' )
                AND ( TRUNC(c.femisi) BETWEEN pin_fecha_desde AND pin_fecha_hasta )
        ) LOOP
            IF i.tipdoc = 7 THEN
                BEGIN
                    SELECT
                        d2.numint,
                        d2.numite
                    INTO
                        v_numintgui,
                        v_numitegui
                    FROM
                        documentos_det d2
                    WHERE
                            d2.id_cia = pin_id_cia
                        AND d2.numint = i.numintgui
                        AND d2.numite = i.numitegui
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_numintgui := NULL;
                        v_numitegui := NULL;
                END;
            END IF;

            -- VALIDADCION POR PK, TABLA KARDEX_COSTO_VENTA
            IF
                i.numintfac IS NOT NULL
                AND i.numitefac IS NOT NULL
            THEN

            -- INICIALMENTE SUPONEMOS QUE EL INGRESO LO HIZO UNA FACTURA
                v_deskardex := 'F';
                v_costot01 := 0;
                v_costot02 := 0;
                v_cantid := 0;
                BEGIN
                    SELECT
                        nvl(costot01, 0),
                        nvl(costot02, 0),
                        nvl(cantid, 0)
                    INTO
                        v_costot01,
                        v_costot02,
                        v_cantid
                    FROM
                        kardex
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = i.numintfac
                        AND numite = i.numitefac
                    FETCH NEXT 1 ROWS ONLY;

                    INSERT INTO kardex_costoventa (
                        id_cia,
                        numint,
                        numite,
                        numint_k,
                        numite_k,
                        femisi,
                        costot01,
                        costot02,
                        cantid
                    ) VALUES (
                        pin_id_cia,
                        i.numintfac,
                        i.numitefac,
                        i.numintfac,
                        i.numitefac,
                        trunc(i.femisi),
                        v_costot01,
                        v_costot02,
                        v_cantid
                    );

                EXCEPTION
                    WHEN no_data_found THEN
                -- SI NO ENCONTRAMOS INFORMACION, SUPONEMOS QUE EL INGRESO LO HIZO UNA GUIA DE REMISION
                        v_deskardex := 'G';
                        v_costot01 := 0;
                        v_costot02 := 0;
                        v_cantid := 0;
                        BEGIN
                            SELECT
                                nvl(costot01, 0),
                                nvl(costot02, 0),
                                nvl(cantid, 0)
                            INTO
                                v_costot01,
                                v_costot02,
                                v_cantid
                            FROM
                                kardex
                            WHERE
                                    id_cia = pin_id_cia
                                AND numint = i.numintgui
                                AND numite = i.numitegui
                            FETCH NEXT 1 ROWS ONLY;

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_costot01 := 0;
                                v_costot02 := 0;
                                v_cantid := 0;
                        END;

                        INSERT INTO kardex_costoventa (
                            id_cia,
                            numint,
                            numite,
                            numint_k,
                            numite_k,
                            femisi,
                            costot01,
                            costot02,
                            cantid
                        ) VALUES (
                            pin_id_cia,
                            i.numintfac,
                            i.numitefac,
                            i.numintgui,
                            i.numitegui,
                            trunc(i.femisi),
                            v_costot01,
                            v_costot02,
                            v_cantid
                        );

                END;

            END IF;

        END LOOP;
    ELSIF v_fproceso = 2 THEN
        FOR i IN (
            SELECT
                c.tipdoc,
                c.femisi,
                d.numint AS numintfac,
                d.numite AS numitefac,
                CASE
                    WHEN c.tipdoc = 7 THEN
                        d.opnumdoc
                    ELSE
                        d1.numint
                END      AS numintgui,
                CASE
                    WHEN c.tipdoc = 7 THEN
                        d.opnumite
                    ELSE
                        d1.numite
                END      AS numitegui
            FROM
                documentos_cab                                                              c
                LEFT OUTER JOIN documentos_det                                                              d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN TABLE ( pack_trazabilidad.sp_trazabilidad_tipdoc(d.id_cia, d.numint, 102) ) t ON 0 = 0
                LEFT OUTER JOIN documentos_det                                                              d1 ON d1.id_cia = t.id_cia
                                                     AND d1.numint = t.numint
                                                     AND ( ( d1.opnumdoc = d.numint
                                                             AND d1.opnumite = d.numite ) )
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc IN ( 1, 3, 7, 8 )
                AND c.situac IN ( 'C', 'B', 'H', 'G', 'F' )
                AND ( TRUNC(c.femisi) BETWEEN pin_fecha_desde AND pin_fecha_hasta )
        ) LOOP
            IF i.tipdoc = 7 THEN
                BEGIN
                    SELECT
                        d2.numint,
                        d2.numite
                    INTO
                        v_numintgui,
                        v_numitegui
                    FROM
                        documentos_det d2
                    WHERE
                            d2.id_cia = pin_id_cia
                        AND d2.numint = i.numintgui
                        AND d2.numite = i.numitegui
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_numintgui := NULL;
                        v_numitegui := NULL;
                END;
            END IF;

            -- VALIDACION POR CONFIGURACION DEL FACTOR 216 VSTRG = 'S' - SOLO CONSIDERAR GUIAS DE REMISION
            IF v_swacti = 'S' THEN
            --  INGRESO LO HIZO UNA GUIA DE REMISION
                v_deskardex := 'G';
                v_costot01 := 0;
                v_costot02 := 0;
                v_cantid := 0;
                BEGIN
                    SELECT
                        nvl(costot01, 0),
                        nvl(costot02, 0),
                        nvl(cantid, 0)
                    INTO
                        v_costot01,
                        v_costot02,
                        v_cantid
                    FROM
                        kardex
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = i.numintgui
                        AND numite = i.numitegui
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_costot01 := 0;
                        v_costot02 := 0;
                        v_cantid := 0;
                END;

                INSERT INTO kardex_costoventa (
                    id_cia,
                    numint,
                    numite,
                    numint_k,
                    numite_k,
                    femisi,
                    costot01,
                    costot02,
                    cantid
                ) VALUES (
                    pin_id_cia,
                    i.numintfac,
                    i.numitefac,
                    i.numintgui,
                    i.numitegui,
                    trunc(i.femisi),
                    v_costot01,
                    v_costot02,
                    v_cantid
                );

            ELSE

            -- VALIDADCION POR PK, TABLA KARDEX_COSTO_VENTA
                IF
                    i.numintfac IS NOT NULL
                    AND i.numitefac IS NOT NULL
                THEN

                -- INICIALMENTE SUPONEMOS QUE EL INGRESO LO HIZO UNA FACTURA
                    v_deskardex := 'F'; /* FACTURA */
                    v_costot01 := 0;
                    v_costot02 := 0;
                    v_cantid := 0;
                    BEGIN
                        SELECT
                            nvl(costot01, 0),
                            nvl(costot02, 0),
                            nvl(cantid, 0)
                        INTO
                            v_costot01,
                            v_costot02,
                            v_cantid
                        FROM
                            kardex
                        WHERE
                                id_cia = pin_id_cia
                            AND numint = i.numintfac
                            AND numite = i.numitefac
                        FETCH NEXT 1 ROWS ONLY;

                        INSERT INTO kardex_costoventa (
                            id_cia,
                            numint,
                            numite,
                            numint_k,
                            numite_k,
                            femisi,
                            costot01,
                            costot02,
                            cantid
                        ) VALUES (
                            pin_id_cia,
                            i.numintfac,
                            i.numitefac,
                            i.numintfac,
                            i.numitefac,
                            trunc(i.femisi),
                            v_costot01,
                            v_costot02,
                            v_cantid
                        );

                    EXCEPTION
                        WHEN no_data_found THEN
                        -- SI NO ENCONTRAMOS INFORMACION, SUPONEMOS QUE EL INGRESO LO HIZO UNA GUIA DE REMISION
                            v_deskardex := 'G';
                            v_costot01 := 0;
                            v_costot02 := 0;
                            v_cantid := 0;
                            BEGIN
                                SELECT
                                    nvl(costot01, 0),
                                    nvl(costot02, 0),
                                    nvl(cantid, 0)
                                INTO
                                    v_costot01,
                                    v_costot02,
                                    v_cantid
                                FROM
                                    kardex
                                WHERE
                                        id_cia = pin_id_cia
                                    AND numint = i.numintgui
                                    AND numite = i.numitegui
                                FETCH NEXT 1 ROWS ONLY;

                            EXCEPTION
                                WHEN no_data_found THEN
                                    v_costot01 := 0;
                                    v_costot02 := 0;
                                    v_cantid := 0;
                            END;

                            INSERT INTO kardex_costoventa (
                                id_cia,
                                numint,
                                numite,
                                numint_k,
                                numite_k,
                                femisi,
                                costot01,
                                costot02,
                                cantid
                            ) VALUES (
                                pin_id_cia,
                                i.numintfac,
                                i.numitefac,
                                i.numintgui,
                                i.numitegui,
                                trunc(i.femisi),
                                v_costot01,
                                v_costot02,
                                v_cantid
                            );

                    END;

                END IF;
            END IF;

        END LOOP;
    ELSE -- IF = 3
        FOR i IN (
            SELECT
                c.tipdoc,
                c.femisi,
                d.numint AS numintfac,
                d.numite AS numitefac,
                CASE
                    WHEN c.tipdoc = 7
                         OR m.docayuda = 102 THEN
                        d.opnumdoc
                    ELSE
                        d1.numint
                END      AS numintgui,
                CASE
                    WHEN c.tipdoc = 7
                         OR m.docayuda = 102 THEN
                        d.opnumite
                    ELSE
                        d1.numite
                END      AS numitegui
            FROM
                documentos_cab                                                              c
                LEFT OUTER JOIN documentos_det                                                              d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN motivos                                                                     m ON m.id_cia = c.id_cia
                                             AND m.tipdoc = c.tipdoc
                                             AND m.id = c.id
                                             AND m.codmot = c.codmot
                LEFT OUTER JOIN TABLE ( pack_trazabilidad.sp_trazabilidad_tipdoc(d.id_cia, d.numint, 102) ) t ON 0 = 0
                LEFT OUTER JOIN documentos_det                                                              d1 ON d1.id_cia = t.id_cia
                                                     AND d1.numint = t.numint
                                                     AND ( ( d1.opnumdoc = d.numint
                                                             AND d1.opnumite = d.numite ) )
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipdoc IN ( 1, 3, 7, 8 )
                AND c.situac IN ( 'C', 'B', 'H', 'G', 'F' )
                AND TRUNC(c.femisi) BETWEEN pin_fecha_desde AND pin_fecha_hasta
        ) LOOP
            IF i.tipdoc = 7 THEN
                BEGIN
                    SELECT
                        d2.numint,
                        d2.numite
                    INTO
                        v_numintgui,
                        v_numitegui
                    FROM
                        documentos_det d2
                    WHERE
                            d2.id_cia = pin_id_cia
                        AND d2.numint = i.numintgui
                        AND d2.numite = i.numitegui
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_numintgui := NULL;
                        v_numitegui := NULL;
                END;
            END IF;

            -- VALIDADCION POR PK, TABLA KARDEX_COSTO_VENTA
            IF
                i.numintfac IS NOT NULL
                AND i.numitefac IS NOT NULL
            THEN

                -- INICIALMENTE SUPONEMOS QUE EL INGRESO LO HIZO UNA FACTURA
                v_deskardex := 'F'; /* FACTURA */
                v_costot01 := 0;
                v_costot02 := 0;
                v_cantid := 0;
                BEGIN
                    SELECT
                        nvl(costot01, 0),
                        nvl(costot02, 0),
                        nvl(cantid, 0)
                    INTO
                        v_costot01,
                        v_costot02,
                        v_cantid
                    FROM
                        kardex
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = i.numintfac
                        AND numite = i.numitefac
                    FETCH NEXT 1 ROWS ONLY;

                    INSERT INTO kardex_costoventa (
                        id_cia,
                        numint,
                        numite,
                        numint_k,
                        numite_k,
                        femisi,
                        costot01,
                        costot02,
                        cantid
                    ) VALUES (
                        pin_id_cia,
                        i.numintfac,
                        i.numitefac,
                        i.numintfac,
                        i.numitefac,
                        trunc(i.femisi),
                        v_costot01,
                        v_costot02,
                        v_cantid
                    );

                EXCEPTION
                    WHEN no_data_found THEN
                        -- SI NO ENCONTRAMOS INFORMACION, SUPONEMOS QUE EL INGRESO LO HIZO UNA GUIA DE REMISION
                        v_deskardex := 'G'; /* GUIA REMISION*/
                        v_costot01 := 0;
                        v_costot02 := 0;
                        v_cantid := 0;
                        BEGIN
                            SELECT
                                nvl(costot01, 0),
                                nvl(costot02, 0),
                                nvl(cantid, 0)
                            INTO
                                v_costot01,
                                v_costot02,
                                v_cantid
                            FROM
                                kardex
                            WHERE
                                    id_cia = pin_id_cia
                                AND numint = i.numintgui
                                AND numite = i.numitegui
                            FETCH NEXT 1 ROWS ONLY;

                        EXCEPTION
                            WHEN no_data_found THEN
                                v_costot01 := 0;
                                v_costot02 := 0;
                                v_cantid := 0;
                        END;

                        INSERT INTO kardex_costoventa (
                            id_cia,
                            numint,
                            numite,
                            numint_k,
                            numite_k,
                            femisi,
                            costot01,
                            costot02,
                            cantid
                        ) VALUES (
                            pin_id_cia,
                            i.numintfac,
                            i.numitefac,
                            i.numintgui,
                            i.numitegui,
                            trunc(i.femisi),
                            v_costot01,
                            v_costot02,
                            v_cantid
                        );

                END;

            END IF;

        END LOOP;
    END IF;

    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'Success...!'
        )
    INTO pout_mensaje
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
        INTO pout_mensaje
        FROM
            dual;

END sp_actualiza_kardex_costoventa;

/
