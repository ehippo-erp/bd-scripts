--------------------------------------------------------
--  DDL for Procedure SP_ASIGNACION_MASIVA_COLUMNAS_DE_BALANCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ASIGNACION_MASIVA_COLUMNAS_DE_BALANCE" (
    pin_id_cia INTEGER,
    pin_nivel  INTEGER
) AS
BEGIN
-- ACTUALIZACION MASIVA DEL PLAN DE CUENTAS DE BALANCE
    CASE
        WHEN ( pin_nivel = -1 ) THEN
        /*Cuenta 10 .. 59*/
            UPDATE pcuentas
            SET
                balancecol = 'I'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 10 AND 59;


            /*Cuenta 60 .. 68*/

            UPDATE pcuentas
            SET
                balancecol = 'N'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 60 AND 68;


           /* Cuenta 71 .. 71 */

            UPDATE pcuentas
            SET
                balancecol = 'N'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 71 AND 71;




             /* Cuenta 69 .. 77 ( No incluye 71 )*/

            UPDATE pcuentas
            SET
                balancecol = 'R'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 69 AND 77
                AND NOT pcuentas.cuenta IN (
                    SELECT
                        p.cuenta
                    FROM
                        pcuentas p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.cuenta = pcuentas.cuenta
                        AND CAST(substr(p.cuenta, 1, 2) AS INTEGER) BETWEEN 71 AND 71
                );


            /* Cuenta 92 .. 97 */

            UPDATE pcuentas
            SET
                balancecol = 'F'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 92 AND 97;


            /* Cuenta 79 .. 99( No incluye 92 .. 97)*/

            UPDATE pcuentas
            SET
                balancecol = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 79 AND 99
                AND NOT pcuentas.cuenta IN (
                    SELECT
                        p.cuenta
                    FROM
                        pcuentas p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.cuenta = pcuentas.cuenta
                        AND CAST(substr(p.cuenta, 1, 2) AS INTEGER) BETWEEN 92 AND 97
                );

            COMMIT;
        WHEN ( pin_nivel = 0 ) THEN /*Cuenta 10 .. 59*/
            UPDATE pcuentas
            SET
                balancecol = 'I'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 10 AND 59;

            COMMIT;
        WHEN ( pin_nivel = 1 ) THEN /*Cuenta 60 .. 68*/
            UPDATE pcuentas
            SET
                balancecol = 'N'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 60 AND 68;

            COMMIT;
        WHEN ( pin_nivel = 2 ) THEN /* Cuenta 71 .. 71 */
            UPDATE pcuentas
            SET
                balancecol = 'N'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 71 AND 71;

            COMMIT;
        WHEN ( pin_nivel = 3 ) THEN/* Cuenta 69 .. 77 ( No incluye 71 )*/
            UPDATE pcuentas
            SET
                balancecol = 'R'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 69 AND 77
                AND NOT pcuentas.cuenta IN (
                    SELECT
                        p.cuenta
                    FROM
                        pcuentas p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.cuenta = pcuentas.cuenta
                        AND CAST(substr(p.cuenta, 1, 2) AS INTEGER) BETWEEN 71 AND 71
                );

            COMMIT;
        WHEN ( pin_nivel = 4 ) THEN  /* Cuenta 92 .. 97 */
            UPDATE pcuentas
            SET
                balancecol = 'F'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 92 AND 97;

            COMMIT;
        WHEN ( pin_nivel = 5 ) THEN  /* Cuenta 79 .. 99( No incluye 92 .. 97)*/
            UPDATE pcuentas
            SET
                balancecol = 'S'
            WHERE
                    id_cia = pin_id_cia
                AND CAST(substr(cuenta, 1, 2) AS INTEGER) BETWEEN 79 AND 99
                AND NOT pcuentas.cuenta IN (
                    SELECT
                        p.cuenta
                    FROM
                        pcuentas p
                    WHERE
                            p.id_cia = pin_id_cia
                        AND p.cuenta = pcuentas.cuenta
                        AND CAST(substr(p.cuenta, 1, 2) AS INTEGER) BETWEEN 92 AND 97
                );

            COMMIT;
    END CASE;

-- INICIO ACTUALIZACION
-- ACTUALIZACION MASIVA DEL PLAN DE CUENTAS
-- CLASE 8 (CLASIFICACION DE CUENTAS) 
-- 1 ACTIVO
-- 2 PASIVO
-- 3 PATRIMONIO
-- 4 GASTOS
-- 5 INGRESOS
-- 6 SALDOS INTERMEDIARIOS DE GESTION
-- 7 CUENTAS EN FUNCION DEL GASTO
-- 8 CUENTAS DE ORDEN

    DELETE FROM pcuentas_clase
    WHERE
            id_cia = pin_id_cia
        AND clase = 8;

    COMMIT;
    INSERT INTO pcuentas_clase (
        id_cia,
        cuenta,
        clase,
        codigo,
        swflag,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        fcreac,
        factua
    )
        SELECT
            id_cia,
            cuenta,
            8            AS clase,
            CASE
                WHEN CAST(substr(cuenta, 1, 1) AS INTEGER) = 0 THEN
                    8 -- CUENTAS DE ORDEN DEUDORAS
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 10
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 39 THEN
                    1 -- ACTIVO
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 40
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 49 THEN
                    2 -- PASIVO
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 50
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 59 THEN
                    3 -- PATRIMONIO
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 60
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 69 THEN
                    4 -- GASTOS
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 70
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 79 THEN
                    5 -- INGRESOS
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 80
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 89 THEN
                    6 -- SALDOS INTERMEDIARIOS DE GESTION
                WHEN CAST(substr(cuenta, 1, 2) AS INTEGER) >= 90
                     AND CAST(substr(cuenta, 1, 2) AS INTEGER) <= 95 THEN
                    7 -- CUENTAS DE FUNCION DEL GASTO
            END          AS codigo,
            'S'          AS swflag,
            NULL         AS vreal,
            10           AS vstrg,
            NULL         AS vchar,
            NULL         AS vdate,
            NULL         AS vtime,
            NULL         AS ventero,
            current_date AS fcreac,
            current_date AS factua
        FROM
            pcuentas p
        WHERE
                p.id_cia = pin_id_cia
            AND p.imputa = 'S';

    COMMIT;
    NULL;
END sp_asignacion_masiva_columnas_de_balance;

/
