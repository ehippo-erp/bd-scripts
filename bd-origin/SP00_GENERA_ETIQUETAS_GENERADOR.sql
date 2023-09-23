--------------------------------------------------------
--  DDL for Procedure SP00_GENERA_ETIQUETAS_GENERADOR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP00_GENERA_ETIQUETAS_GENERADOR" (
    pin_id_cia IN NUMBER,
    pin_numint IN NUMBER
) AS

    v_wnumite INTEGER;
    v_wtipinv INTEGER;
    v_wcodart VARCHAR(40);
    v_wgen    INTEGER;
    v_valfa   VARCHAR(1);
BEGIN
    v_valfa := NULL;
    DECLARE BEGIN
        SELECT
            vstrg
        INTO v_valfa
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 424;

    EXCEPTION
        WHEN no_data_found THEN
            v_valfa := NULL;
    END;

    IF ( ( v_valfa IS NULL ) OR ( v_valfa <> 'S' ) ) THEN
        dbms_output.put_line('---ccc----------------------------------------');
        FOR i IN (
            SELECT
                d.numite,
                d.tipinv,
                d.codart
            FROM
                documentos_det d
                LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND a.consto IN ( 5, 8 )
                AND ( ( d.canped IS NULL )
                      OR ( d.canped >= 0 ) )
                AND ( d.etiqueta IS NULL
                      OR length(d.etiqueta) < 1 )
                AND ( cantid > 0 )
            ORDER BY
                d.tipinv,
                d.codart,
                d.codadd01,
                d.codadd02,
                d.cantid
        ) LOOP
            EXECUTE IMMEDIATE 'select '
                              || 'GEN_ETIQUETAS_KARDEX_'
                              || pin_id_cia
                              || '.NEXTVAL FROM DUAL'
            INTO v_wgen;
            UPDATE documentos_det
            SET
                etiqueta = v_wgen
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND numite = i.numite;

        END LOOP;

    ELSE
        FOR i IN (
            SELECT
                d.numite,
                d.tipinv,
                d.codart
            FROM
                documentos_det d
                LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                               AND a.tipinv = d.tipinv
                                               AND a.codart = d.codart
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
                AND ( ( d.canped IS NULL )
                      OR ( d.canped >= 0 ) )
                AND ( d.etiqueta IS NULL
                      OR length(d.etiqueta) < 2 )
                AND ( cantid > 0 )
            ORDER BY
                d.tipinv,
                d.codart,
                d.codadd01,
                d.codadd02,
                d.cantid
        ) LOOP
            EXECUTE IMMEDIATE 'select '
                              || 'GEN_ETIQUETAS_KARDEX_'
                              || pin_id_cia
                              || '.NEXTVAL FROM DUAL'
            INTO v_wgen;
            UPDATE documentos_det
            SET
                etiqueta = 'v_WGEN'
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND numite = i.numite;

        END LOOP;
    END IF;

END sp00_genera_etiquetas_generador;

/
