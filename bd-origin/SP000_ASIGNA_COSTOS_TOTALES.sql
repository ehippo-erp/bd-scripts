--------------------------------------------------------
--  DDL for Procedure SP000_ASIGNA_COSTOS_TOTALES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_ASIGNA_COSTOS_TOTALES" (
    pin_id_cia   IN NUMBER,
    pin_tipinv   IN NUMBER,
    pin_periodo  IN NUMBER,
    pout_mensaje OUT VARCHAR2
) AS

    wtipinv   INTEGER;
    wcodart   VARCHAR(40);
    wcanmov01 NUMBER(11, 4);
    wcanini01 NUMBER(11, 4);
    wtotmov01 NUMBER(11, 4);
    wtotmov02 NUMBER(11, 4);
    wtotini01 NUMBER(11, 4);
    wtotini02 NUMBER(11, 4);
    wcodadd01 VARCHAR(10);
    wcodadd02 VARCHAR(10);
BEGIN
    UPDATE articulos_costo
    SET
        cantid = 0,
        costo01 = 0,
        costo02 = 0
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND tipinv = pin_tipinv;

    UPDATE articulos_costo_codadd
    SET
        cantid = 0,
        costo01 = 0,
        costo02 = 0
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND tipinv = pin_tipinv;

    -- ARTICULOS_COSTO
    FOR i IN (
        SELECT
            codart,
            cantid,
            costo01,
            costo02
        FROM
            articulos_costo
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo - 1
            AND tipinv = pin_tipinv
    ) LOOP
        UPDATE articulos_costo
        SET
            cantid = i.cantid,
            costo01 = i.costo01,
            costo02 = i.costo02
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND tipinv = pin_tipinv
            AND codart = i.codart;

    END LOOP;

      -- ARTICULOS_COSTO_CODADD
    FOR i IN (
        SELECT
            codart,
            cantid,
            costo01,
            costo02,
            codadd01,
            codadd02
        FROM
            articulos_costo_codadd
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo - 1
            AND tipinv = pin_tipinv
    ) LOOP
        UPDATE articulos_costo_codadd
        SET
            cantid = i.cantid,
            costo01 = i.costo01,
            costo02 = i.costo02
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND tipinv = pin_tipinv
            AND codart = i.codart
            AND codadd01 = i.codadd01
            AND codadd02 = i.codadd02;

    END LOOP;

    wcanini01 := 0;
    wtotini01 := 0;
    wtotini02 := 0;
    wcanmov01 := 0;
    wtotmov01 := 0;
    wtotmov02 := 0;
    FOR i IN (
        SELECT
            k.tipinv,
            k.codart,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) AS cantid,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) AS costo01,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) AS costo02
        FROM
            kardex k
        WHERE
                k.id_cia = pin_id_cia
            AND k.periodo = pin_periodo
            AND k.tipinv = pin_tipinv
            AND ( length(TRIM(k.codadd01)) IS NULL
                  OR ( length(TRIM(k.codadd01)) = 0 ) )
            AND ( length(TRIM(k.codadd02)) IS NULL
                  OR ( length(TRIM(k.codadd02)) = 0 ) )
        GROUP BY
            k.tipinv,
            k.codart
        ORDER BY
            k.tipinv,
            k.codart
    ) LOOP
        UPDATE articulos_costo
        SET
            cantid = cantid + nvl(i.cantid, 0),
            costo01 = costo01 + nvl(i.costo01, 0),
            costo02 = costo02 + nvl(i.costo02, 0)
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND tipinv = i.tipinv
            AND codart = i.codart;

    END LOOP;

    INSERT INTO articulos_costo_codadd (
        id_cia,
        tipinv,
        codart,
        codadd01,
        codadd02,
        periodo,
        cantid,
        costo01,
        costo02
    )
        SELECT DISTINCT
            k.id_cia,
            k.tipinv,
            k.codart,
            k.codadd01,
            k.codadd02,
            pin_periodo,
            0,
            0,
            0
        FROM
            kardex                 k
            LEFT OUTER JOIN articulos_costo_codadd a ON a.id_cia = k.id_cia
                                                        AND a.tipinv = k.tipinv
                                                        AND a.codart = k.codart
                                                        AND a.codadd01 = k.codadd01
                                                        AND a.codadd02 = k.codadd02
                                                        AND a.periodo = k.periodo
        WHERE
                k.id_cia = pin_id_cia
            AND k.tipinv = pin_tipinv
            AND k.periodo = pin_periodo
            AND ( length(TRIM(k.codadd01)) IS NOT NULL
                  AND ( length(TRIM(k.codadd01)) > 1 ) )
            AND ( length(TRIM(k.codadd02)) IS NOT NULL
                  AND ( length(TRIM(k.codadd02)) > 1 ) )
            AND a.periodo IS NULL;

    FOR i IN (
        SELECT
            k.tipinv,
            k.codart,
            k.codadd01,
            k.codadd02,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.cantid
                    ELSE
                        0
                END
            ) AS cantid,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot01
                    ELSE
                        0
                END
            ) AS costo01,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) - SUM(
                CASE
                    WHEN k.id = 'S' THEN
                        k.costot02
                    ELSE
                        0
                END
            ) AS costo02
        FROM
            kardex k
        WHERE
                k.id_cia = pin_id_cia
            AND k.periodo = pin_periodo
            AND k.tipinv = pin_tipinv
            AND ( length(TRIM(k.codadd01)) IS NOT NULL
                  AND ( length(TRIM(k.codadd01)) > 1 ) )
            AND ( length(TRIM(k.codadd02)) IS NOT NULL
                  AND ( length(TRIM(k.codadd02)) > 1 ) )
        GROUP BY
            k.tipinv,
            k.codart,
            k.codadd01,
            k.codadd02
        ORDER BY
            k.tipinv,
            k.codart,
            k.codadd01,
            k.codadd02
    ) LOOP
        UPDATE articulos_costo_codadd
        SET
            cantid = cantid + nvl(i.cantid, 0),
            costo01 = costo01 + nvl(i.costo01, 0),
            costo02 = costo02 + nvl(i.costo02, 0)
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND tipinv = i.tipinv
            AND codart = i.codart
            AND codadd01 = i.codadd01
            AND codadd02 = i.codadd01;

    END LOOP;

END sp000_asigna_costos_totales;

/
